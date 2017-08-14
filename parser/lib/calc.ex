defmodule Calc do
  import Parser
  alias Parser, as: P

  def eval(str), do: e.(str)

  def e do
    P._block(
      fn -> a end
    )
  end

  def a do
    P._block(fn ->
      P._comb(
        m,
        P._or(
          P._map(P._str("+"), fn _ -> &(&1 + &2) end),
          P._map(P._str("-"), fn _ ->  &(&1 - &2) end)
        )
      )
    end)
  end

  def m do
    P._block(fn ->
      P._comb(
        p,
        P._or(
          P._map(P._str("*"), fn _ -> &(&1 * &2) end),
          P._map(P._str("/"), fn _ -> &(div(&1, &2)) end)
        )
      )
    end)
  end

  def p do
    P._block(
      fn ->
        P._or(
          P._map(
            P._str("(")
            |> P._seq(e)
            |> P._seq(P._str(")")),
            fn result ->
              {{"(", v}, ")"} = result
              v
            end
          ),
          n
        )
      end
    )
  end

  def n do
    P._map(P._reg(~r/[0-9]+/), fn v1 ->
      {v2, _} = Integer.parse(v1)
      v2
    end)
  end
end
