File.stream!("input/day2")
|> Enum.map(fn line -> Regex.run ~r/(\w+)\s+(\d+)/m, line end)
|> Enum.map(fn ([_, dir, n]) -> {dir, String.to_integer(n)} end)
|> Enum.reduce({0,0}, fn
  ({"forward", n}, {x, y}) -> {x + n, y}
  ({"down", n}, {x, y}) -> {x, y + n}
  ({"up", n}, {x, y}) -> {x, y - n}
end)
|> Tuple.to_list
|> Enum.product

File.stream!("input/day2")
|> Enum.map(fn line -> Regex.run ~r/(\w+)\s+(\d+)/m, line end)
|> Enum.map(fn ([_, dir, n]) -> {dir, String.to_integer(n)} end)
|> Enum.reduce({0,0,0}, fn
  ({"forward", n}, {x, y, aim}) -> {x + n, y + (n * aim), aim}
  ({"down", n}, {x, y, aim}) -> {x, y, aim + n}
  ({"up", n}, {x, y, aim}) -> {x, y, aim - n}
end)
|> then(fn ({x, y, _}) -> x * y end)