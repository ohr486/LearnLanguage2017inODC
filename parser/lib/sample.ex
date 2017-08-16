defmodule Sample do
  use Parser

  def parse_day(str) do
    parser = label(integer(), "year")
             |> ignore(either(char("-"), char("/")))
             |> label(integer(), "month")
             |> ignore(either(char("-"), char("/")))
             |> label(integer(), "day")
    Parser.parse(str, parser)
  end
end
