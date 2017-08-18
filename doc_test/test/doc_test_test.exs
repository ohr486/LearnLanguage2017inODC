defmodule DocTestTest do
  use ExUnit.Case
  doctest DocTest

  test "greets the world" do
    assert DocTest.hello() == :world
  end
end

