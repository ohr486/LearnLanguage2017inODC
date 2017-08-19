defmodule ParserTest do
  use ExUnit.Case
  doctest Base
  doctest Calc

  test "1+2 = 3" do
    assert Calc.eval("1+2") == 3
  end
  test "1-2 = -1" do
    assert Calc.eval("1-2") == -1
  end
  test "1*2 = 2" do
    assert Calc.eval("1*2") == 2
  end
  test "1/2 = 0" do
    assert Calc.eval("1/2") == 0
  end
  test "1+2*3/4 = 2" do
    assert Calc.eval("1+2*3/4") == 2
  end
  test "(1+2)*3/4 = 2" do
    assert Calc.eval("(1+2)*3/4") == 2
  end
  test "(1+2)*(3/4) = 0" do
    assert Calc.eval("(1+2)*(3/4)") == 0
  end
end
