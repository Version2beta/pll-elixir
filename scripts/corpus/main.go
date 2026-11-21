// Reproducible fixture producer: public github.com/version2beta/pll API only.
package main

import (
	"errors"
	"fmt"
	pll "github.com/version2beta/pll"
	"math"
	"time"
)

func code(e error) string {
	switch {
	case e == nil:
		return "ok"
	case errors.Is(e, pll.ErrOrder):
		return "order"
	case errors.Is(e, pll.ErrOverflow):
		return "overflow"
	case errors.Is(e, pll.ErrNotAnchored):
		return "not_anchored"
	}
	panic(e)
}
func main() {
	fmt.Println("PLL-CORPUS 1 971282632129110794c9d6edd22026e9de2359be")
	for _, scenario := range []string{"clean", "window", "jump", "fraction", "signed", "overflow"} {
		rn := uint64(1000)
		window := int64(0)
		b := 0.1
		d := math.Sqrt2 / 2
		th := int64(5000000)
		if scenario == "window" {
			rn = 1000000000
			window = 4
		}
		if scenario == "fraction" {
			rn = 800000000
			th = 1
		}
		if scenario == "signed" {
			rn = 1000000000
			window = math.MaxInt64
		}
		if scenario == "overflow" {
			b = 1e-300
			d = 1e-300
			th = math.MaxInt64
		}
		r, _ := pll.UnitsPerSecond(rn, 1)
		c := pll.DefaultFollowerConfig(r)
		c.Window = time.Duration(window)
		c.Bandwidth = b
		c.Damping = d
		c.OutlierThreshold = time.Duration(th)
		f, err := pll.NewFollower(c)
		if err != nil {
			panic(err)
		}
		fmt.Printf("C %s %d %d %016x %016x %d\n", scenario, rn, window, math.Float64bits(b), math.Float64bits(d), th)
		// Every record includes both query directions, offset, trim, jitter and lifecycle.
		emit := func(op string, l, remote int64) {
			status := "none"
			e := int64(0)
			var err error
			if op == "O" {
				var o pll.Observation
				o, err = f.Observe(time.Duration(l), remote)
				if err == nil {
					status = o.Status.String()
					e = int64(o.Error)
				}
			}
			if op == "R" {
				f.Reset()
			}
			a, ae := f.Local(remote)
			z, ze := f.Remote(time.Duration(l))
			fmt.Printf("%s %d %d %s %s %d %s %d %s %d %016x %d %d %s\n", op, l, remote, code(err), status, e, code(ae), a, code(ze), z, math.Float64bits(f.Offset()), f.Trim(), f.Jitter(), f.State(time.Duration(l)).String())
		}
		emit("Q", 0, 0)
		switch scenario {
		case "clean":
			for k := int64(0); k <= 120; k++ {
				emit("O", k*10000000+(k*7919)%10001, k*10)
			}
			emit("Q", 7000000000, 1300)
		case "jump":
			emit("O", 0, 0)
			for k := int64(1); k <= 3; k++ {
				emit("O", k*10000000, 2000+k*10)
			}
			emit("O", 30000000, 2030)
			emit("R", 0, 0)
			emit("O", -10, -10)
		case "window":
			for _, v := range [][2]int64{{0, 0}, {1, 1}, {4, 4}, {5, 5}, {6, 9}, {8, 12}, {9, 13}, {10, 14}, {13, 17}, {12, 18}} {
				emit("O", v[0], v[1])
			}
		case "fraction":
			for _, v := range [][2]int64{{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 4}} {
				emit("O", v[0], v[1])
			}
		case "signed":
			for _, v := range [][2]int64{{math.MinInt64, math.MinInt64}, {math.MinInt64 + 1, math.MinInt64 + 1}, {-1, -1}, {0, 0}, {1, 1}} {
				emit("O", v[0], v[1])
			}
		case "overflow":
			emit("O", 0, 0)
			emit("O", math.MaxInt64, 9223372036855)
			emit("O", 1000000, 1)
		}
		fmt.Println("END")
	}
}
