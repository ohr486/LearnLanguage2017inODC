defmodule CalcTest do
  use ExUnit.Case

  test "1+2 -> 3" do
    assert Calc.expression.("1+2") == {:ok, 3, ""}
  end

  test "1-2 -> -1" do
    assert Calc.expression.("1-2") == {:ok, -1, ""}
  end

  test "1*2 -> 2" do
    assert Calc.expression.("1*2") == {:ok, 2, ""}
  end

  test "1/2 -> 0" do
    assert Calc.expression.("1/2") == {:ok, 0, ""}
  end

  test "1+2*3/4 -> 2" do
    assert Calc.expression.("1+2*3/4") == {:ok, 2, ""}
  end

  test "(1+2)*3/4 -> 2" do
    assert Calc.expression.("(1+2)*3/4") == {:ok, 2, ""}
  end

  test "(1+2)*(3/4) -> 0" do
    assert Calc.expression.("(1+2)*(3/4)") == {:ok, 0, ""}
  end
end
