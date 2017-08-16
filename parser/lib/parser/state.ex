defmodule Parser.State do
  @type t :: %__MODULE__{
    input: any,
    column: non_neg_integer,
    line: pos_integer,
    results: [any],
    labels: [any],
    status: :ok | :error,
    error: any
  }

  defstruct input: <<>>,
            column: 0,
            line: 1,
            results: [],
            labels: [],
            status: :ok,
            error: nil
end
