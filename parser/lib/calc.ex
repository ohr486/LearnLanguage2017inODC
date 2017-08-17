defmodule Calc do
  alias Parser, as: P

  def number do
    P._or(
      P.str("0"),
      P.reg(~r/[0-9][0-9]*/)
    )
    |> P.map(&(Integer.parse(&1) |> elem(0)))
  end

  def primary do
    P.block(fn ->
      P._or(
        P.map(
          P.str("(") |> P.seq(expression()) |> P.seq(P.str(")")),
          fn result ->
            {{"(", v}, ")"} = result
            v
          end
        ),
        number()
      )
    end)
  end

  def multitive do
    P.block(fn ->
      new_parser = P.comb(
        primary(),
        P._or(
          P.map(P.str("*"), fn _ -> &(&1 * &2) end),
          P.map(P.str("/"), fn _ -> &(div(&1, &2)) end)
        )
      )
    end)
  end

  def additive do
    P.block(fn ->
      new_parser = P.comb(
        multitive(),
        P._or(
          P.map(P.str("+"), fn _ -> &(&1 + &2) end),
          P.map(P.str("-"), fn _ -> &(&1 - &2) end)
        )
      )
    end)
  end

  def expression, do: P.block(&additive/0)
end
