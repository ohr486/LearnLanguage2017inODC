defmodule Calc do
  @moduledoc """
  四則演算を行うモジュール
  """

  @doc """
  引数文字列をパースして四則演算結果を返す

  # Example
      iex> import #{__MODULE__}
      ...> eval("1+2+3")
      6
  """
  def eval(exp_str) do
    case expression().(exp_str) do
      {:ok, result, _rest} -> result
      _ -> {:error, exp_str}
    end
  end

  @doc """
  引数文字列が四則演算かどうか判定する関数

  BNF: expression ::= additive

  # Example
      iex> import #{__MODULE__}
      ...> expression().("(1+2)*(3+4)")
      {:ok, 21, ""}
  """
  def expression do
    fn input ->
      additive().(input)
    end
  end

  @doc """
  引数文字列が加算減算か判定する関数

  BNF: additive ::= multitive ('+' multitive | '-' multitive)*

  # Example
      iex> import #{__MODULE__}
      ...> additive().("1+2")
      {:ok, 3, ""}
      ...> additive().("1+2*3")
      {:ok, 7, ""}
  """
  def additive do
    Base.seq(
      multitive(),
      Base.loop(
        Base.either(
          Base.seq(
            Base.one_of("+") |> Base.map(fn _ -> &(&1 + &2) end),
            multitive()
          ),
          Base.seq(
            Base.one_of("-") |> Base.map(fn _ -> &(&1 - &2) end),
            multitive()
          )
        )
      )
    )
    |> fold_result
  end

  @doc """
  引数文字列が掛算除算か判定する関数

  BNF: multitive ::= primary ('*' primary | '/' multitive)*

  # Example
      iex> import #{__MODULE__}
      ...> multitive().("1*2")
      {:ok, 2, ""}
      ...> multitive().("1*2+3")
      {:ok, 2, "+3"}
  """
  def multitive do
    Base.seq(
      primary(),
      Base.loop(
        Base.either(
          Base.seq(
            Base.one_of("*") |> Base.map(fn _ -> &(&1 * &2) end),
            primary()
          ),
          Base.seq(
            Base.one_of("/") |> Base.map(fn _ -> &(div(&1, &2)) end),
            primary()
          )
        )
      )
    )
    |> fold_result
  end

  @doc """
  パースした結果を畳み込む
  """
  defp fold_result(p) do
    Base.map(
      p,
      fn values ->
        {h, t} = values
        List.foldl(
          t, h,
          fn r, a ->
            {f, e} = r
            f.(a, e)
          end
        )
      end
    )
  end

  @doc """
  引数文字列が四則演算の基本要素(整数かカッコで式をくくったもの)か判定する関数

  BNF: primary ::= '(' expression ')' | number

  # Example
      iex> import #{__MODULE__}
      ...> primary().("123")
      {:ok, 123, ""}
      ...> primary().("(123)")
      {:ok, 123, ""}
      ...> primary().("(2*3)")
      {:ok, 6, ""}
      ...> primary().("1+2")
      {:ok, 1, "+2"}
  """
  def primary do
    Base.either(
      Base.map(
        Base.one_of("(") |> Base.seq(expression()) |> Base.seq(Base.one_of(")")),
        &strip_pars/1
      ),
      number()
    )
  end
  defp strip_pars(result) do
    {{"(", exp}, ")"} = result
    exp
  end

  @doc """
  引数文字列が整数かどうか判定する関数

  BNF: number::= '0' | [1-9][0-9]*

  # Example
      iex> import #{__MODULE__}
      ...> number().("123")
      {:ok, 123, ""}
      ...> number().("abc")
      {:error, "abc"}
      ...> number().("123abc")
      {:ok, 123, "abc"}
  """
  def number do
    Base.reg_of(~r/[0-9]+/)
    |> Base.map(&to_number/1)
  end
  defp to_number(result) do
    result |> Integer.parse |> elem(0)
  end
end
