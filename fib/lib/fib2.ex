defmodule Fib2 do
  @moduledoc """
    フィボナッチ数を計算
    メモ化して高速化
  """

  def start_link do
    # フィボナッチ数を保存するAgentプロセスを起動
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  def calc(n) do
    case Agent.get(__MODULE__, &Map.get(&1, n)) do
      nil ->
        # Agentに対象のフィボナッチ数が無ければ計算して追加
        value = calc(n - 1) + calc(n - 2)
        Agent.update(__MODULE__, &Map.put(&1, n, value))
        value
      value -> value
    end
  end
end
