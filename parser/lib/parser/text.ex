defmodule Parser.Text do
  alias Parser.State
  alias Parser.Base
  use Helper

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
end
