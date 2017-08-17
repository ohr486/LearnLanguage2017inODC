defmodule SlowFib do
  @moduledoc """
    フィボナッチ数を計算
    非効率な実装
  """
  def calc(0), do: 0
  def calc(1), do: 1
  def calc(n), do: calc(n - 1) + calc(n - 2)
end
