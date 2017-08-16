defmodule Parser.Base do
  alias Parser.State
  use Helper

  @type predicate :: (term -> boolean)
  @type transform :: (term -> term)
  @type transform2 :: ((term, term) -> term)

  @spec zero(previous_parser) :: parser
  defparser zero(%State{status: :ok} = state), do: %{state | :status => :error, :error => nil}

  @spec eof(previous_parser) :: parser
  defparser eof(%State{status: :ok, input: <<>>} = state), do: state
  defp eof_impl(%State{status: :ok, line: line, column: col} = state) do
    %{state | :status => :error, :error => "Expected end of input at line #{line}, column #{col}"}
  end

  @spec ignore(previous_parser) :: parser
  defparser ignore(%State{status: :ok} = state, parser) when is_function(parser, 1) do
    case parser.(state) do
      %State{status: :ok, results: [_|t]} = s -> %{s | :results => [:__ignore|t]}
      %State{} = s -> s
    end
  end
end
