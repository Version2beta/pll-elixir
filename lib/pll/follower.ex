# complete; do not change
defmodule PLL.Follower do
  @moduledoc "Immutable clock mapping; Stage 2 limitations are explicit in README."
  defstruct config: nil,
            anchored: false,
            i0: 0,
            frac: 0.0,
            r0: 0,
            y: 0.0,
            last_local: 0,
            last_remote: 0,
            reference: 0,
            last_accepted: 0,
            lock_run: 0,
            jitter_count: 0,
            jitter_m: 0.0

  @opaque t :: %__MODULE__{}
  @doc "README new contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec new(term()) :: {:ok, t()} | {:error, PLL.Error.t()}
  defdelegate new(config), to: PLL.FollowerCore

  @doc "README observe contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec observe(term(), term(), term()) ::
          {:ok, t(), PLL.Observation.t()} | {:error, PLL.Error.t()}
  defdelegate observe(follower, local_ns, remote), to: PLL.FollowerCore

  @doc "README local contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec local(term(), term()) :: {:ok, integer()} | {:error, PLL.Error.t()}
  defdelegate local(follower, remote), to: PLL.FollowerCore

  @doc "README remote contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec remote(term(), term()) :: {:ok, integer()} | {:error, PLL.Error.t()}
  defdelegate remote(follower, local_ns), to: PLL.FollowerCore

  @doc "README offset contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec offset(term()) :: float()
  defdelegate offset(follower), to: PLL.FollowerCore

  @doc "README trim contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec trim(term()) :: integer()
  defdelegate trim(follower), to: PLL.FollowerCore

  @doc "README jitter contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec jitter(term()) :: integer()
  defdelegate jitter(follower), to: PLL.FollowerCore

  @doc "README state contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec state(term(), term()) :: {:ok, atom()} | {:error, PLL.Error.t()}
  defdelegate state(follower, now_ns), to: PLL.FollowerCore

  @doc "README reset contract, with documented Stage 2 boundary. Wrong struct kinds raise ArgumentError."
  @spec reset(term()) :: t()
  defdelegate reset(follower), to: PLL.FollowerCore
end
