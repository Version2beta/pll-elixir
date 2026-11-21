# Independent literal moderate-input model. No production helpers or structs.
defmodule PLL.FollowerEquationOracle do
  def anchor(l, r), do: %{a: l, frac: 0.0, r: r, y: 0.0, t: l, m: nil, n: 0}

  def update(s, l, r, p, b, d, limit) do
    predicted_displacement = s.frac + (r - s.r) * p / (1 + s.y)
    e = l - s.a - predicted_displacement
    dt = (l - s.t) / 1.0e9
    x = min(0.5, 2 * :math.pi() * b * dt)
    kp = min(1.0, 2 * d * x)
    y = max(-limit, min(limit, s.y - x * x / dt * e / 1.0e9))
    v = predicted_displacement + kp * e
    w = round(v)
    m = if s.m == nil, do: e * e, else: s.m + (e * e - s.m) / 16
    {%{a: s.a + w, frac: v - w, r: r, y: y, t: l, m: m, n: s.n + 1}, e}
  end

  def local(s, r, p), do: s.a + round(s.frac + (r - s.r) * p / (1 + s.y))
end
