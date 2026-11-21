defmodule PLL.FollowerCore do
  @moduledoc false
  # Writable Stage 2 stubs. Implement the fixed public seam in follower.ex using
  # README/SPEC equations; all supplied data/public modules are complete.
  # S2-config: new/1; S2-mapping: anchoring and queries; S2-loop: accepted
  # updates, lifecycle and the explicit temporary unsupported boundary.
  def new(_config), do: {:error, %PLL.Error{code: :not_anchored}}
  def observe(_follower, _local_ns, _remote), do: {:error, %PLL.Error{code: :not_anchored}}
  def local(_follower, _remote), do: {:error, %PLL.Error{code: :not_anchored}}
  def remote(_follower, _local_ns), do: {:error, %PLL.Error{code: :not_anchored}}
  def offset(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
  def trim(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
  def jitter(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
  def state(_follower, _now_ns), do: {:error, %PLL.Error{code: :not_anchored}}
  def reset(_follower), do: {:error, %PLL.Error{code: :not_anchored}}
end
