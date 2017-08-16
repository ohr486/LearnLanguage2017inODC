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



  def str(prefix) do
    &(
      case String.starts_with?(&1, prefix) do
        true ->
          {ele1, ele2} = String.split_at(&1, String.length(prefix))
          {:ok, ele1, ele2}
        _ -> {:error, &1}
      end
    )
  end

  def _or(p1, p2) do
    &(
      case p1.(&1) do
        {:error, _} -> p2.(&1)
        any -> any
      end
    )
  end

  def seq(p1, p2) do
    &(
      with {:ok, h1, t1} <- p1.(&1),
           {:ok, h2, t2} <- p2.(t1),
           do: {:ok, {h1, h2}, t2}
    )
  end

  def loop(p, rest, results) do
    case p.(rest) do
      {:ok, v, next} -> loop(p, next, [v | results])
      {:error, next} -> {:ok, Enum.reverse(results), next}
    end
  end

  def rep(p), do: &loop(p, &1, [])

  def map(p, f) do
    &(
      case p.(&1) do
        {:ok, v, next} -> {:ok, f.(v), next}
        any -> any
      end
    )
  end

  def reg(pat) do
    &(
      case Regex.run(pat, &1, return: :index) do
        nil -> {:error, &1}
        [{f, l}] ->
          if f != 0 do
            {:error, &1}
          else
            {ele1, ele2} = String.split_at(&1, l)
            {:ok, ele1, ele2}
          end
      end
    )
  end

  def comb(p1, p2) do
    map(
      seq(p1, rep(seq(p2, p1))),
      fn values ->
        {h, t} = values
        List.foldl(
          t,
          h,
          fn(r, a) ->
            {f, e} = r
            f.(a, e)
          end
        )
      end
    )
  end

  def block(b), do: &(b.()).(&1)
end
