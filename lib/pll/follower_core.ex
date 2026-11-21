# complete; do not change
defmodule PLL.FollowerCore do
  @moduledoc false
  # Stable Stage 2 config/mapping/inlier arithmetic; Stage 3 history integration
  # delegates only validated, ordered subsequent samples to FollowerHistory.
  # Protect this complete core in the final Stage 3 task inventory.

  # README signed 64-bit envelope for integer config fields.
  @imin -9_223_372_036_854_775_808
  @imax 9_223_372_036_854_775_807
  # README uint64 envelope for rate terms.
  @u 18_446_744_073_709_551_615

  # Fields are checked in README table order: type, then envelope, then semantic rule.
  def new(%PLL.FollowerConfig{} = config) do
    with :ok <- validate_nominal(config.nominal),
         :ok <-
           validate_float(
             :bandwidth_hz,
             config.bandwidth_hz,
             &(&1 > 0.0),
             "must be finite and > 0"
           ),
         :ok <- validate_float(:damping, config.damping, &(&1 > 0.0), "must be finite and > 0"),
         :ok <-
           validate_float(
             :max_offset_ppm,
             config.max_offset_ppm,
             &(&1 > 0.0 and &1 < 1_000_000.0),
             "must be finite, > 0 and < 1000000"
           ),
         :ok <- validate_integer(:window_ns, config.window_ns, &(&1 >= 0), "must be >= 0"),
         :ok <-
           validate_integer(
             :outlier_threshold_ns,
             config.outlier_threshold_ns,
             &(&1 > 0),
             "must be > 0"
           ),
         :ok <- validate_integer(:step_after, config.step_after, &(&1 >= 1), "must be >= 1"),
         :ok <-
           validate_integer(
             :lock_threshold_ns,
             config.lock_threshold_ns,
             &(&1 >= 0),
             "must be >= 0"
           ),
         :ok <- validate_integer(:lock_count, config.lock_count, &(&1 >= 1), "must be >= 1"),
         :ok <-
           validate_integer(
             :holdover_after_ns,
             config.holdover_after_ns,
             &(&1 > 0),
             "must be > 0"
           ) do
      {:ok, %PLL.Follower{config: config}}
    end
  end

  def new(_config), do: raise(ArgumentError, "expected PLL.FollowerConfig")

  defp validate_nominal(%PLL.Rate{num: num, den: den})
       when is_integer(num) and num >= 1 and num <= @u and
              is_integer(den) and den >= 1 and den <= @u,
       do: :ok

  defp validate_nominal(_nominal), do: config_error(:nominal, "must be a valid Rate")

  defp validate_float(field, value, valid?, reason) do
    cond do
      not is_float(value) -> config_error(field, reason)
      valid?.(value) -> :ok
      true -> config_error(field, reason)
    end
  end

  defp validate_integer(field, value, valid?, reason) do
    cond do
      not is_integer(value) -> config_error(field, reason)
      value < @imin or value > @imax -> {:error, %PLL.Error{code: :overflow}}
      valid?.(value) -> :ok
      true -> config_error(field, reason)
    end
  end

  defp config_error(field, reason),
    do: {:error, %PLL.Error{code: :config, field: field, reason: reason}}

  # Wrong struct kinds raise first; then scalars are validated left-to-right.
  def observe(%PLL.Follower{} = follower, local_ns, remote) do
    with :ok <- validate_int64(local_ns),
         :ok <- validate_int64(remote) do
      observe_valid(follower, local_ns, remote)
    end
  end

  def observe(_follower, _local_ns, _remote), do: raise(ArgumentError, "expected PLL.Follower")

  def local(%PLL.Follower{} = follower, remote) do
    with :ok <- validate_int64(remote), do: map_local(follower, remote)
  end

  def local(_follower, _remote), do: raise(ArgumentError, "expected PLL.Follower")

  def remote(%PLL.Follower{} = follower, local_ns) do
    with :ok <- validate_int64(local_ns), do: map_remote(follower, local_ns)
  end

  def remote(_follower, _local_ns), do: raise(ArgumentError, "expected PLL.Follower")

  def offset(%PLL.Follower{y: y}), do: y
  def offset(_follower), do: raise(ArgumentError, "expected PLL.Follower")

  def trim(%PLL.Follower{y: y}) do
    saturate(round_away(y * 1.0e12), -999_999_999_999, 999_999_999_999)
  end

  def trim(_follower), do: raise(ArgumentError, "expected PLL.Follower")

  def jitter(%PLL.Follower{jitter_count: count}) when count < 2, do: 0

  def jitter(%PLL.Follower{jitter_m: m}),
    do: saturate(round_away(:math.sqrt(m)), @imin, @imax)

  def jitter(_follower), do: raise(ArgumentError, "expected PLL.Follower")

  def state(%PLL.Follower{} = follower, now_ns) do
    with :ok <- validate_int64(now_ns), do: {:ok, lifecycle_state(follower, now_ns)}
  end

  def state(_follower, _now_ns), do: raise(ArgumentError, "expected PLL.Follower")

  # Reset keeps the config and forgets all learned mapping and loop history.
  def reset(%PLL.Follower{config: config}), do: %PLL.Follower{config: config}
  def reset(_follower), do: raise(ArgumentError, "expected PLL.Follower")

  # Stage 3 owns only observe integration/history. Stable arithmetic stays here.
  defp observe_valid(%PLL.Follower{anchored: false} = follower, local_ns, remote),
    do: {:ok, anchor(follower, local_ns, remote), %PLL.Observation{status: :anchored}}

  defp observe_valid(%PLL.Follower{} = follower, local_ns, remote) do
    if local_ns < follower.last_local or remote <= follower.last_remote do
      {:error, %PLL.Error{code: :order}}
    else
      PLL.FollowerHistory.observe(follower, local_ns, remote)
    end
  end

  # Complete adapter to stable Stage 2 arithmetic, not a new public library API.
  def history_error(follower, local_ns, remote), do: phase_error(follower, local_ns, remote)

  def history_inlier(follower, local_ns, remote, e),
    do: feed_inlier(follower, local_ns, remote, e)

  # Accepted inlier: update the mapping (only when dt > 0), then lock and jitter data.
  defp feed_inlier(%PLL.Follower{} = follower, local_ns, remote, e) do
    with {:ok, mapped} <- update_mapping(follower, local_ns, remote, e) do
      lock_threshold = :erlang.float(follower.config.lock_threshold_ns)

      lock_run =
        if abs(e) <= lock_threshold,
          do: min(follower.lock_run + 1, follower.config.lock_count),
          else: 0

      next = %{
        mapped
        | last_local: local_ns,
          last_remote: remote,
          last_accepted: local_ns,
          lock_run: lock_run
      }

      observation = %PLL.Observation{
        status: :accepted,
        error_ns: saturate(round(e), @imin, @imax)
      }

      {:ok, update_jitter(next, e), observation}
    end
  end

  # dt = 0 leaves mapping, rate and reference unchanged.
  defp update_mapping(%PLL.Follower{reference: reference} = follower, local_ns, _remote, _e)
       when local_ns == reference,
       do: {:ok, follower}

  # Gains and the offset update use the old mapping; the anchor moves by rounded displacement.
  defp update_mapping(%PLL.Follower{} = follower, local_ns, remote, e) do
    dt = (local_ns - follower.reference) / 1.0e9
    x = capped_x(follower.config.bandwidth_hz, dt)
    kp = capped_gain(follower.config.damping, x)
    limit = follower.config.max_offset_ppm * 1.0e-6
    y = min(max(follower.y - x * x / dt * (e / 1.0e9), -limit), limit)
    v = predicted_displacement(follower, remote) + kp * e
    whole = round(v)

    with {:ok, i0} <- fit_int64(follower.i0 + whole) do
      {:ok, %{follower | i0: i0, frac: v - whole, r0: remote, y: y, reference: local_ns}}
    end
  end

  # Jitter: first accepted inlier sets m = e*e; later ones use m += (e*e - m)/16.
  defp update_jitter(%PLL.Follower{jitter_count: 0} = follower, e),
    do: %{follower | jitter_count: 1, jitter_m: e * e}

  defp update_jitter(%PLL.Follower{} = follower, e),
    do: %{
      follower
      | jitter_count: 2,
        jitter_m: follower.jitter_m + (e * e - follower.jitter_m) / 16
    }

  # Phase error e = local - predicted(remote), unrounded, in binary64 ns.
  defp phase_error(%PLL.Follower{} = follower, local_ns, remote),
    do: wide_diff(local_ns, follower.i0) - predicted_displacement(follower, remote)

  # frac + (remote - R0) * Pn / (1 + y), the displacement from I0 under the current mapping.
  defp predicted_displacement(%PLL.Follower{} = follower, remote),
    do: follower.frac + wide_diff(remote, follower.r0) * period(follower) / (1 + follower.y)

  # min(0.5, 2*pi*bandwidth*dt), testing the cap before the product can overflow.
  defp capped_x(bandwidth, dt) do
    if bandwidth >= 0.5 / (2 * :math.pi() * dt),
      do: 0.5,
      else: 2 * :math.pi() * bandwidth * dt
  end

  # min(1, 2 * (damping * x)) without forming an overflowing product.
  defp capped_gain(damping, x) do
    p = damping * x
    if p >= 0.5, do: 1.0, else: 2 * p
  end

  defp anchor(%PLL.Follower{} = follower, local_ns, remote) do
    %{
      follower
      | anchored: true,
        i0: local_ns,
        frac: 0.0,
        r0: remote,
        y: 0.0,
        last_local: local_ns,
        last_remote: remote,
        reference: local_ns,
        last_accepted: local_ns,
        lock_run: 0,
        jitter_count: 0,
        jitter_m: 0.0
    }
  end

  defp map_local(%PLL.Follower{anchored: false}, _remote),
    do: {:error, %PLL.Error{code: :not_anchored}}

  # local(r) = I0 + round_away(frac + (r - R0) * Pn / (1 + y)), rounding displacement only.
  defp map_local(%PLL.Follower{} = follower, remote) do
    displacement = wide_diff(remote, follower.r0) * period(follower) / (1 + follower.y)
    fit_int64(follower.i0 + round_away(follower.frac + displacement))
  end

  defp map_remote(%PLL.Follower{anchored: false}, _local_ns),
    do: {:error, %PLL.Error{code: :not_anchored}}

  # remote(l) = R0 + round_away(((l - I0) - frac) * (1 + y) / Pn).
  defp map_remote(%PLL.Follower{} = follower, local_ns) do
    displacement = (wide_diff(local_ns, follower.i0) - follower.frac) * (1 + follower.y)
    fit_int64(follower.r0 + round_away(displacement / period(follower)))
  end

  defp lifecycle_state(%PLL.Follower{anchored: true} = follower, now_ns) do
    cond do
      now_ns - follower.last_accepted > follower.config.holdover_after_ns -> :holdover
      follower.lock_run >= follower.config.lock_count -> :locked
      true -> :acquiring
    end
  end

  defp lifecycle_state(%PLL.Follower{}, _now_ns), do: :acquiring

  # Nominal period Pn = float(den) * 1e9 / float(num) in ns, as binary64.
  defp period(%PLL.Follower{config: %{nominal: %PLL.Rate{num: num, den: den}}}),
    do: den * 1.0e9 / num

  # Integer difference when it fits signed 64-bit; otherwise float(a) - float(b).
  defp wide_diff(a, b) do
    d = a - b

    if d >= @imin and d <= @imax,
      do: :erlang.float(d),
      else: :erlang.float(a) - :erlang.float(b)
  end

  # Half ties away from zero (Elixir round/1), exact for any finite binary64 value.
  defp round_away(v) when is_float(v), do: round(v)

  defp saturate(v, lo, hi), do: v |> max(lo) |> min(hi)

  defp validate_int64(v) when is_integer(v) and v >= @imin and v <= @imax, do: :ok
  defp validate_int64(v) when is_integer(v), do: {:error, %PLL.Error{code: :overflow}}
  defp validate_int64(_v), do: {:error, %PLL.Error{code: :invalid_argument}}

  defp fit_int64(v) when v >= @imin and v <= @imax, do: {:ok, v}
  defp fit_int64(_v), do: {:error, %PLL.Error{code: :overflow}}
end
