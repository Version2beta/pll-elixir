# complete; do not change
defmodule PLL.FollowerConfig do
  @moduledoc "Explicit immutable configuration; see README for field validation order."
  defstruct nominal: %PLL.Rate{},
            bandwidth_hz: 0.0,
            damping: 0.0,
            max_offset_ppm: 0.0,
            window_ns: 0,
            outlier_threshold_ns: 0,
            step_after: 0,
            lock_threshold_ns: 0,
            lock_count: 0,
            holdover_after_ns: 0

  @type t :: %__MODULE__{}
  @doc "Defaults without nominal validation; validation occurs in Follower.new/1."
  @spec default(term()) :: t()
  def default(nominal),
    do: %__MODULE__{
      nominal: nominal,
      bandwidth_hz: 0.1,
      damping: :math.sqrt(2) / 2,
      max_offset_ppm: 500.0,
      window_ns: 0,
      outlier_threshold_ns: 5_000_000,
      step_after: 3,
      lock_threshold_ns: 100_000,
      lock_count: 8,
      holdover_after_ns: 5_000_000_000
    }
end
