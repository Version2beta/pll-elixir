defmodule PLL.FollowerHistory do
  @moduledoc false
  @doc "Apply README window/outlier/step rules transactionally after validated input order."
  @spec observe(PLL.Follower.t(), integer(), integer()) ::
          {:ok, PLL.Follower.t(), PLL.Observation.t()} | {:error, PLL.Error.t()}
  def observe(follower, local_ns, remote) do
    # Preserve the stable no-window inlier path on supplied stubs.
    e = PLL.FollowerCore.history_error(follower, local_ns, remote)

    if follower.config.window_ns == 0 and
         abs(e) <= :erlang.float(follower.config.outlier_threshold_ns),
       do: PLL.FollowerCore.history_inlier(follower, local_ns, remote, e),
       else: {:error, %PLL.Error{code: :unsupported}}
  end
end
