defmodule FastFib do
  @moduledoc """
    フィボナッチ数を計算
    メモ化して高速化

    Example
      iex> FastFib.start_link
      {:ok, #PID<x.x.x>}
      ...> FastFib.calc(10)
      55
  """

  @doc "フィボナッチ数を保存するAgentプロセスを起動"
  def start_link do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  @doc nil
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
