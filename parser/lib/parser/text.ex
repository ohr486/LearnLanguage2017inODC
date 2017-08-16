defmodule Parser.Text do
  alias Parser.State
  alias Parser.Base
  use Helper

  @digits ?0..?9 |> Enum.to_list



  @spec space(previous_parser) :: parser
  defparser space(%State{status: :ok, column: col, input: <<?\s::utf8,rest::binary>>, results: results} = state) do
    %{state | :column => col + 1, :input => rest, :results => [" "|results]}
  end
  defp space_impl(%State{status: :ok, line: line, column: col, input: <<c::utf8,_::binary>>} = state) do
    %{state | :status => :error, :error => "Expected space but found `#{<<c::utf8>>}` at line #{line}, column #{col + 1}."}
  end
  defp space_impl(%State{status: :ok, input: <<>>} = state) do
    %{state | :status => :error, :error => "Expected space, but hit end of input."}
  end



  @spec digit(previous_parser) :: parser
  defparser digit(%State{status: :ok, column: col, input: <<c::utf8,rest::binary>>, results: results} = state)
    when c in @digits do
      digit = case c do
        ?0 -> 0
        ?1 -> 1
        ?2 -> 2
        ?3 -> 3
        ?4 -> 4
        ?5 -> 5
        ?6 -> 6
        ?7 -> 7
        ?8 -> 8
        ?9 -> 9
      end
      %{state | :column => col + 1, :input => rest, :results => [digit|results]}
  end
  defp digit_impl(%State{status: :ok, line: line, column: col, input: <<c::utf8,_::binary>>} = state) do
    %{state | :status => :error, :error => "Expected digit found `#{<<c::utf8>>}` at line #{line}, column #{col + 1}."}
  end
  defp digit_impl(%State{status: :ok, input: <<>>} = state) do
    %{state | :status => :error, :error => "Expected digit, but hit end of input."}
  end



  @spec char() :: parser
  def char() do
    fn state -> any_char_impl(state) end
  end
  defp any_char_impl(%State{status: :ok, column: col, input: <<cp::utf8, rest::binary>>, results: results} = state) do
    %{state | :column => col + 1, :input => rest, :results => [<<cp::utf8>>|results]}
  end
  defp any_char_impl(%State{status: :ok} = state) do
    %{state | :status => :error, :error => "Excepted any character, but hit end of input."}
  end



  @spec char(parser | String.t | pos_integer) :: parser
  @spec char(previous_parser, String.t | pos_integer) :: parser
  def char(c) when is_integer(c) do
    fn state -> char_impl(state, c) end
  end
  def char(parser) when is_function(parser, 1) do
    fn
      %State{status: :ok} = state -> any_char_impl(state)
      %State{} = state -> state
    end
  end
  defparser char(%State{status: :ok, column: col, input: <<c::utf8,rest::binary>>, results: results} = state, <<c::utf8>>) do
    %{state | :column => col + 1, :input => rest, :results => [<<c::utf8>>|results]}
  end
  defp char_impl(%State{status: :ok, column: col, input: <<c::utf8,rest::binary>>, results: results} = state, c) when is_integer(c) do
    %{state | :column => col + 1, :input => rest, :results => [<<c::utf8>>|results]}
  end
  defp char_impl(%State{status: :ok, input: <<>>} = state, c) do
    case c do
      c when is_binary(c) ->
        %{state | :status => :error, :error => "Expected `#{c}`, but hit end of input."}
      c when is_integer(c) ->
        %{state | :status => :error, :error => "Expected `#{<<c::utf8>>}`, but hit end of input."}
    end
  end
  defp char_impl(%State{status: :ok, line: line, column: col, input: <<next::utf8,_::binary>>} = state, c) do
    case c do
      c when is_binary(c) ->
        %{state | :status => :error, :error => "Expected bin:`#{c}`, but found `#{<<next::utf8>>}` at line #{line}, column #{col + 1}."}
      c when is_integer(c) ->
        %{state | :status => :error, :error => "Expected int:`#{<<c::utf8>>}`, but found `#{<<next::utf8>>}` at line #{line}, column #{col + 1}."}
    end
  end



  @spec take_while(previous_parser, (char -> boolean)) :: parser
  defparser take_while(%State{status: :ok} = state, predicate) when is_function(predicate, 1) do
    take_while_loop(state, predicate, [])
  end
  defp take_while_loop(%State{input: <<>>} = state, _predicate, acc), do: %{state | :results => [Enum.reverse(acc)|state.results]}
  defp take_while_loop(%State{input: <<c::utf8,rest::binary>>, column: col} = state, predicate, acc) do
    case predicate.(c) do
      true -> take_while_loop(%{state | :input => rest, :column => col + 1}, predicate, [c|acc])
      _    -> %{state | :results => [Enum.reverse(acc)|state.results]}
    end
  end

end
