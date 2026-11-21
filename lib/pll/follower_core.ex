defmodule PLL.FollowerCore do
  @moduledoc false
  # Writable Stage 2 stubs. Implement the fixed public seam in follower.ex using
  # README/SPEC equations; all supplied data/public modules are complete.
  # S2-config: new/1 (implemented here); S2-mapping: anchoring and queries;
  # S2-loop: accepted updates, lifecycle and the explicit temporary unsupported
  # boundary. Functions other than new/1 remain stubs until their tasks.

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

  def observe(_follower, _local_ns, _remote), do: {:error, %PLL.Error{code: :not_anchored}}
  def local(_follower, _remote), do: {:error, %PLL.Error{code: :not_anchored}}
  def remote(_follower, _local_ns), do: {:error, %PLL.Error{code: :not_anchored}}
  def offset(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
  def trim(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
  def jitter(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
  def state(_follower, _now_ns), do: {:error, %PLL.Error{code: :not_anchored}}
  def reset(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
end
