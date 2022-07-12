# Part 2 only, 'cause it's a trivial extension of part 1. Whole thing ~30 minutes.
Regex.scan(~r/(\d+),(\d+) -> (\d+),(\d+)/, File.read!("input/day5"))
|> Enum.map(fn [_ | coords] -> Enum.map(coords, &String.to_integer/1) end)
|> Enum.flat_map(fn coords ->
  case coords do
    [ax,ay,bx,by] when ax == bx -> Enum.map(ay..by, fn y -> {ax, y} end)
    [ax,ay,bx,by] when ay == by -> Enum.map(ax..bx, fn x -> {x, ay} end)
    [ax,ay,bx,by] -> Enum.zip(ax..bx, ay..by) # Comment out this line to get part 1 answer
    _ -> []
  end
end)
|> Enum.reduce(%{}, fn pair, map -> Map.update(map, pair, 1, fn v -> v + 1 end) end)
|> Enum.count(fn {_, v} -> v > 1 end)