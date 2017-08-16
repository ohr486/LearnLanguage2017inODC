defmodule Parser do
  alias Parser.State

  @type parser          :: (State.t() -> State.t)
  @type previous_parser :: parser | nil

  @spec parse(any, parser, Keyword.t) :: [term] | Keyword.t | {:error, term}
  def parse(input, parser, options \\ []) do
    case parser.(%State{input: input}) do
      %State{status: :ok} = ps ->
        transform_state(ps, options)
      %State{error: res} ->
        {:error, res}
      x ->
        {:error, {:fatal, x}}
    end
  end

  def ignore_filter(:__ignore), do: false
  def ignore_filter(_), do: true

  defp filter_ignores(element) when is_list(element) do
    element |> Enum.filter(&ignore_filter/1) |> Enum.map(&filter_ignores/1)
  end
  defp filter_ignores(element), do: element

  defp transform_state(state, options) do
    defaults = [keyword: false]
    options = Keyword.merge(defaults, options) |> Enum.into(%{})
    results = state.results |> Enum.reverse |> Enum.filter(&ignore_filter/1) |> Enum.map(&filter_ignores/1)
    if options.keyword do
      labels = state.labels |> Enum.map(&String.to_atom/1) |> Enum.reverse
      can_zip? = length(labels) == length(results)
      case {results, can_zip?} do
        {[h|tail], _} when is_list(h) -> Enum.map([h|tail], &Enum.zip(labels, &1))
        {_, true} -> labels |> Enum.zip(results)
        _ -> raise("Can not label all parsed results")
      end
    else
      results
    end
  end
end
