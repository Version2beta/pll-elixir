# Independent frozen-rate integer state model, period 1 ns; no production helpers.
defmodule PLL.HistoryOracle do
  def new(window),
    do: %{window: window, candidate: nil, run: [], shift: 0, prev: nil, accepted: 0}

  def read(s, l, r) do
    cond do
      s.prev == nil ->
        {%{s | prev: {l, r}, shift: l - r, accepted: l}, :anchored, 0}

      l < elem(s.prev, 0) or r <= elem(s.prev, 1) ->
        {s, :order, 0}

      s.window == 0 ->
        feed(%{s | prev: {l, r}}, l, r)

      s.candidate == nil ->
        {%{s | prev: {l, r}, candidate: {l, l, r, l - r - s.shift}}, :pending, 0}

      true ->
        {start, cl, cr, ce} = s.candidate

        if l - start < s.window do
          c = if l - r - s.shift < ce, do: {start, l, r, l - r - s.shift}, else: s.candidate
          {%{s | prev: {l, r}, candidate: c}, :pending, 0}
        else
          {n, status, e} = feed(s, cl, cr)
          {%{n | prev: {l, r}, candidate: {l, l, r, l - r - n.shift}}, status, e}
        end
    end
  end

  defp feed(s, l, r) do
    e = l - r - s.shift

    if abs(e) > 10 do
      run = if s.run != [] and abs(e - hd(s.run)) <= 10, do: s.run ++ [e], else: [e]

      if length(run) == 3,
        do: {%{s | run: [], shift: l - r, accepted: l}, :stepped, e},
        else: {%{s | run: run}, :rejected, e}
    else
      {%{s | run: [], accepted: l}, :accepted, e}
    end
  end
end
