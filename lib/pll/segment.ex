# complete; do not change
defmodule PLL.Segment do
  @moduledoc false
  # A snapshot, shared immutably by the cursor and issued spans.
  defstruct start: 0, anchor: 0, trim: 0, pn: 0, pd: 1

  @type t :: %__MODULE__{
          start: non_neg_integer(),
          anchor: non_neg_integer(),
          trim: integer(),
          pn: non_neg_integer(),
          pd: pos_integer()
        }
end
