defmodule Calc do
  alias Parser, as: P

  def number do
    new_parser = P._or(
      P.str("0"),
      P.reg(~r/[1-9][0-9]*/)
    )
    P.map(new_parser, &(Integer.parse(&1) |> elem(0)))
  end

  def primary do
    new_parser = P._or(
      P.map(
        P.str("(") |> P.seq(expression()) |> P.seq(P.str(")")),
        fn result ->
          {{"(", v}, ")"} = result
          v
        end
      ),
      number()
    )
    P.eval(fn -> new_parser end)
  end

  def multitive do
    new_parser = P.comb(
      primary(),
      P._or(
        P.map(P.str("*"), fn _ -> &(&1 * &2) end),
        P.map(P.str("/"), fn _ -> &(div(&1, &2)) end)
      )
    )
    P.eval(fn -> new_parser end)
  end

  def additive do
    new_parser = P.comb(
      multitive(),
      P._or(
        P.map(P.str("+"), fn _ -> &(&1 + &2) end),
        P.map(P.str("-"), fn _ -> &(&1 - &2) end)
      )
    )
    P.eval(fn -> new_parser end)
  end

  def expression, do: P.eval(fn -> additive() end)
end
