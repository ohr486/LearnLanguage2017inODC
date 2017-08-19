defmodule Base do
  @moduledoc """
  基本的な構成要素となる単純なパーサー
  """

  # --- 基本パーサー ---

  @doc """
  引数のトークンが先頭にマッチすれば成功するパーサーを返す

  # Example
      iex> import #{__MODULE__}
      ...> one_of("").("abc")
      {:error, "abc"}
      ...> one_of("a").("abc")
      {:ok, "a", "bc"}
  """
  def one_of(token) do
    fn input ->
      {head, tail} = String.split_at(input, 1)
      if token == head do
        {:ok, head, tail}
      else
        {:error, input}
      end
    end
  end

  @doc """
  引数の正規表現が先頭にマッチすれば成功するパーサーを返す

  # Example
      iex> import #{__MODULE__}
      ...> reg_of(~r/[0-9]+/).("12ab")
      {:ok, "12", "ab"}
  """
  def reg_of(pattern) do
    fn input ->
      case Regex.run(pattern, input, return: :index) do
        nil            -> {:error, input}
        [{pos, count}] ->
          if pos != 0 do
            {:error, input}
          else
            {sub, rest} = String.split_at(input, count)
            {:ok, sub, rest}
          end
      end
    end
  end

  # --- パーサーの演算 ---

  @doc """
  引数のパーサーのどちらかがマッチすれば成功するパーサーを返す

  # Example
      iex> import #{__MODULE__}
      ...> p1 = one_of("1")
      ...> p2 = one_of("a")
      ...> either(p1, p2).("abc123")
      {:ok, "a", "bc123"}
      ...> either(p1, p2).("23abc")
      {:error, "23abc"}
  """
  def either(p1, p2) do
    fn input ->
      case p1.(input) do
        {:error, _} -> p2.(input)
        any -> any
      end
    end
  end

  @doc """
  引数のパーサーを順番に適用

  # Example
      iex> import #{__MODULE__}
      ...> p1 = one_of("1")
      ...> p2 = one_of("a")
      ...> seq(p1, p2).("1abc23")
      {:ok, {"1", "a"}, "bc23"}
  """
  def seq(p1, p2) do
    fn input ->
      with {:ok, sub1, rest1} <- p1.(input),
           {:ok, sub2, rest2} <- p2.(rest1),
      do: {:ok, {sub1, sub2}, rest2}
    end
  end

  @doc """
  引数のパーサーを失敗するまで繰り返し適用

  # Example
      iex> import #{__MODULE__}
      ...> p = one_of("a")
      ...> rep(p, "aabbcc", ["1", "2"])
      {:ok, ["2", "1", "a", "a"], "bbcc"}
  """
  def rep(p, rest, results) do
    case p.(rest) do
      {:ok, val, next} -> rep(p, next, [val | results])
      {:error, next}   -> {:ok, Enum.reverse(results), next}
    end
  end

  @doc """
  引数のパーサーを失敗するまで繰り返し適用する関数

  # Example
      iex> import #{__MODULE__}
      ...> p1 = one_of("a")
      ...> loop(p1).("aabbcc")
      {:ok, ["a", "a"], "bbcc"}
      ...> p2 = one_of("b")
      ...> p3 = either(p1, p2)
      ...> loop(p3).("abbaaacba")
      {:ok, ["a", "b", "b", "a", "a", "a"], "cba"}
  """
  def loop(p) do
    fn input ->
      rep(p, input, [])
    end
  end

  @doc """
  引数のパーサーが成功すれば、結果に対して関数を適用

  # Example
      iex> import #{__MODULE__}
      ...> p = one_of("a")
      ...> map(p, &String.upcase/1).("aabbcc")
      {:ok, "A", "abbcc"}
  """
  def map(p, fun) do
    fn input ->
      case p.(input) do
        {:ok, val, next} -> {:ok, fun.(val), next}
        any -> any
      end
    end
  end
end
