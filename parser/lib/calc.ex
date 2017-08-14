defmodule Calc do
  import Parser
  alias Parser, as: P

  def eval(str), do: ev.(str)

  def ev, do: P._block(&add/0)

  def add do
    P._block(fn ->
      P._comb(
        mult,
        P._or(
          P._map(P._str("+"), fn _ -> &(&1 + &2) end),
          P._map(P._str("-"), fn _ ->  &(&1 - &2) end)
        )
      )
    end)
  end

  def mult do
    P._block(fn ->
      P._comb(
        par,
        P._or(
          P._map(P._str("*"), fn _ -> &(&1 * &2) end),
          P._map(P._str("/"), fn _ -> &(div(&1, &2)) end)
        )
      )
    end)
  end

  def par do
    P._block(fn ->
      P._or(
        P._map(
          P._str("(") |> P._seq(ev) |> P._seq(P._str(")")),
          fn result ->
            {{"(", v}, ")"} = result
            v
          end
        ),
        num
      )
    end)
  end

  def num, do: ~r/[0-9]+/ |> P._reg |> P._map(&(&1 |> Integer.parse |> elem(0)))
end
