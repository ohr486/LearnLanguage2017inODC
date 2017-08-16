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


  @spec sequence(previous_parser, [parser]) :: parser
  defparser sequence(%State{status: :ok} = state, parsers) when is_list(parsers) do
    pipe(parsers, &(&1)).(state)
  end



  @spec pipe(previous_parser, [parser], transform) :: parser
  defparser pipe(%State{status: :ok} = state, parsers, transform) when is_list(parsers) and is_function(transform, 1) do
    orig_results = state.results
    case do_pipe(parsers, %{state | :results => []}) do
      {:ok, acc, %State{status: :ok} = new_state} ->
        transformed = transform.(Enum.reverse(acc))
        %{new_state | :results => [transformed | orig_results]}
      {:error, _acc, state} ->
        state
    end
  end
  defp do_pipe(parsers, state), do: do_pipe(parsers, state, [])
  defp do_pipe([], state, acc), do: {:ok, acc, state}
  defp do_pipe([parser|parsers], %State{status: :ok} = current, acc) do
    case parser.(%{current | :results => []}) do
      %State{status: :ok, results: [:__ignore]} = next -> do_pipe(parsers, %{next | :results => []}, acc)
      %State{status: :ok, results: []} = next -> do_pipe(parsers, next, acc)
      %State{status: :ok, results: rs} = next -> do_pipe(parsers, %{next | :results => []}, rs ++ acc)
      %State{} = next -> {:error, acc, next}
    end
  end
  defp do_pipe(_parsers, %State{} = state, acc), do: {:error, acc, state}

end
