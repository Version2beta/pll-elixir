defmodule PLL.FollowerHistory do
  @moduledoc false

  # Stage 3 histories: window candidates, first-error outlier runs and steps.
  # Mapping arithmetic stays in PLL.FollowerCore (history_error/3, history_inlier/4).
  # Window state is %{start, local, remote, error} in Follower.window; the outlier run
  # is %{first, count} in Follower.outlier. Both are private to this module family.

  @imin -9_223_372_036_854_775_808
  @imax 9_223_372_036_854_775_807

  @doc "Apply README window/outlier/step rules transactionally after validated input order."
  @spec observe(PLL.Follower.t(), integer(), integer()) ::
          {:ok, PLL.Follower.t(), PLL.Observation.t()} | {:error, PLL.Error.t()}
  # window_ns == 0: every later reading is fed at once.
  def observe(%PLL.Follower{config: %{window_ns: 0}} = follower, local_ns, remote) do
    e = PLL.FollowerCore.history_error(follower, local_ns, remote)
    sample(follower, local_ns, remote, e)
  end

  # The first later reading opens a window and becomes its candidate.
  def observe(%PLL.Follower{window: nil} = follower, local_ns, remote) do
    {:ok, open_window(follower, local_ns, remote), pending()}
  end

  def observe(%PLL.Follower{window: window} = follower, local_ns, remote) do
    if local_ns - window.start < follower.config.window_ns do
      # Half-open window: the mapping is fixed, so only a strictly smaller signed error wins.
      e = PLL.FollowerCore.history_error(follower, local_ns, remote)

      candidate =
        if e < window.error,
          do: %{window | local: local_ns, remote: remote, error: e},
          else: window

      next = %{follower | window: candidate, last_local: local_ns, last_remote: remote}
      {:ok, next, pending()}
    else
      # Flush the old candidate; the trigger opens the next window against the flushed mapping.
      with {:ok, flushed, observation} <-
             sample(follower, window.local, window.remote, window.error) do
        {:ok, open_window(flushed, local_ns, remote), observation}
      end
    end
  end

  defp pending, do: %PLL.Observation{status: :pending, error_ns: 0}

  # Opens a window whose candidate is this reading, with its error under the current mapping.
  defp open_window(follower, local_ns, remote) do
    e = PLL.FollowerCore.history_error(follower, local_ns, remote)

    %{
      follower
      | window: %{start: local_ns, local: local_ns, remote: remote, error: e},
        last_local: local_ns,
        last_remote: remote
    }
  end

  # Classifies one unrounded phase error e. Inliers update the mapping; outliers form runs.
  defp sample(follower, local_ns, remote, e) do
    if abs(e) > threshold(follower) do
      outlier(follower, local_ns, remote, e)
    else
      with {:ok, next, observation} <-
             PLL.FollowerCore.history_inlier(follower, local_ns, remote, e) do
        # An inlier ends the outlier run only after the feed succeeds.
        {:ok, %{next | outlier: nil}, observation}
      end
    end
  end

  defp outlier(follower, local_ns, remote, e) do
    run = next_run(follower.outlier, e, threshold(follower))

    if run.count == follower.config.step_after do
      {:ok, step(follower, local_ns, remote),
       %PLL.Observation{status: :stepped, error_ns: error_ns(e)}}
    else
      next = %{follower | outlier: run, last_local: local_ns, last_remote: remote}
      {:ok, next, %PLL.Observation{status: :rejected, error_ns: error_ns(e)}}
    end
  end

  # Runs compare with the FIRST error of the run, not the previous one.
  defp next_run(nil, e, _threshold), do: %{first: e, count: 1}

  defp next_run(%{first: first, count: count}, e, threshold) do
    if abs(e - first) <= threshold,
      do: %{first: first, count: count + 1},
      else: %{first: e, count: 1}
  end

  # Re-anchor exactly to the fed sample, keep the learned rate y, and clear loop history.
  defp step(follower, local_ns, remote) do
    %{
      follower
      | i0: local_ns,
        frac: 0.0,
        r0: remote,
        reference: local_ns,
        last_local: local_ns,
        last_remote: remote,
        last_accepted: local_ns,
        lock_run: 0,
        jitter_count: 0,
        jitter_m: 0.0,
        outlier: nil
    }
  end

  defp threshold(%PLL.Follower{config: config}),
    do: :erlang.float(config.outlier_threshold_ns)

  defp error_ns(e), do: e |> round() |> max(@imin) |> min(@imax)
end
