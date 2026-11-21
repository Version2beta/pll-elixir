defmodule PLLPacing.Runner do
  @moduledoc "Public-API-only bounded real-time pacing worker."
  @doc "Run validated config through injected now/wait/cancelled/write/progress functions. See SPEC."
  @spec run(map(), map()) :: map() | {:error, term()}
  def run(_cfg, _io), do: {:error, :unfinished}
end
