defmodule Calc do
  alias Parser, as: P

  def eval(str), do: ev().(str)

  def ev, do: P.block(&add/0)

  def add do
    P.block(fn ->
      P.comb(
        mult(),
        P._or(
          P.map(P.str("+"), fn _ -> &(&1 + &2) end),
          P.map(P.str("-"), fn _ -> &(&1 - &2) end)
        )
      )
    end)
  end

  def mult do
    P.block(fn ->
      P.comb(
        par(),
        P._or(
          P.map(P.str("*"), fn _ -> &(&1 * &2) end),
          P.map(P.str("/"), fn _ -> &(div(&1, &2)) end)
        )
      )
    end)
  end

  def par do
    P.block(fn ->
      P._or(
        P.map(
          P.str("(") |> P.seq(ev()) |> P.seq(P.str(")")),
          fn result ->
            {{"(", v}, ")"} = result
            v
          end
        ),
        num()
      )
    end)
  end

  def num, do: ~r/[0-9]+/ |> P.reg |> P.map(&(&1 |> Integer.parse |> elem(0)))
end
