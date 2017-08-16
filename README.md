# LL2017 in ODC Elixir Sample

## ParserCombinator

```
$ cd parser
$ mix deps.get
$ mix.compile
$ iex -S mix
-----------
iex > Sample.parse_day("2017/8/19")
[2017, 8, 19]
iex > Sample.parse_day("2017-8-19")
[2017, 8, 19]
iex > Sample.parse_day("2017-a-19")
{:error, "Expected `month` at line 1, column 6."}
iex >
-----------
```
