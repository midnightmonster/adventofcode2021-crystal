defmodule Parser do
  @expect %{
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
  }
  @error_points %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }
  @autocomplete_points %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
  }
  def error_score(binary, expect_stack \\ [nil])
  def error_score("\n", _), do: 0
  def error_score(<<char::binary-1, rest::binary>>, [expected|stack]) do
    case {Map.get(@expect, char), char == expected}  do
      {nil, false} -> Map.get(@error_points, char)
      {nil, true} -> error_score(rest, stack)
      {push, _} -> error_score(rest, [push,expected|stack])
    end
  end
  def autocomplete_line_score(binary, expect_stack \\ [nil])
  def autocomplete_line_score("\n", stack) do
    stack |> Enum.join(", ") |> IO.puts
    Enum.reduce(stack, 0, fn
      nil, memo -> memo
      char, memo -> memo * 5 + Map.get(@autocomplete_points,char)
    end)
  end
  def autocomplete_line_score(<<char::binary-1, rest::binary>>, [expected|stack]) do
    case {Map.get(@expect, char), char == expected}  do
      {nil, false} -> nil
      {nil, true} -> autocomplete_line_score(rest, stack)
      {push, _} -> autocomplete_line_score(rest, [push,expected|stack])
    end
  end
  def autocomplete_score(enum) do
    {scores, count} = enum |> Enum.flat_map_reduce(0, fn line, memo ->
      case Parser.autocomplete_line_score(line) do
        nil -> {[], memo}
        score -> {[score], memo + 1}
      end
    end)
    scores |> Enum.sort |> Enum.at(div(count, 2))
  end
end
File.stream!("input/day10") |> Enum.reduce(0, fn line, score ->
  score + Parser.error_score(line)
end) |> IO.puts
File.stream!("input/day10") |> Parser.autocomplete_score |> IO.puts