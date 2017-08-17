defmodule Calc do
  alias Parser, as: P

  def expression, do: P.eval(fn -> additive() end)

  def additive do
    P.comb(
      multitive(),
      P._or(
        P.map(P.str("+"), fn _ -> &(&1 + &2) end),
        P.map(P.str("-"), fn _ -> &(&1 - &2) end)
      )
    )
  end

  def multitive do
    P.comb(
      primary(),
      P._or(
        P.map(P.str("*"), fn _ -> &(&1 * &2) end),
        P.map(P.str("/"), fn _ -> &(div(&1, &2)) end)
      )
    )
  end

  def primary do
    P._or(
      P.map(
        P.str("(") |> P.seq(expression()) |> P.seq(P.str(")")),
        &strip_parentheses/1
      ),
      number()
    )
  end
  defp strip_parentheses(result) do
    {{"(", exp}, ")"} = result
    exp
  end

  def number do
    P._or(
      P.str("0"),
      P.reg(~r/[1-9][0-9]*/)
    )
    |> P.map(&to_number/1)
  end
  defp to_number(result) do
    result |> Integer.parse |> elem(0)
  end
end
