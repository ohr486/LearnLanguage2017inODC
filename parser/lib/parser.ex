defmodule Parser do
  def _str(prefix) do
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

  def _seq(p1, p2) do
    &(
      with {:ok, h1, t1} <- p1.(&1),
           {:ok, h2, t2} <- p2.(t1),
           do: {:ok, {h1, h2}, t2}
    )
  end

  def _loop(p, rest, results) do
    case p.(rest) do
      {:ok, v, next} -> _loop(p, next, [v | results])
      {:error, next} -> {:ok, Enum.reverse(results), next}
    end
  end

  def _rep(p), do: &_loop(p, &1, [])

  def _map(p, f) do
    &(
      case p.(&1) do
        {:ok, v, next} -> {:ok, f.(v), next}
        any -> any
      end
    )
  end

  def _reg(pat) do
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

  def _comb(p1, p2) do
    _map(
      _seq(p1, _rep(_seq(p2, p1))),
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

  def _block(b), do: &(b.()).(&1)
end
