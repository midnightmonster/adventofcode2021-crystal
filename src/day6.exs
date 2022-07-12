# Part 2 only; ~20 min
days = 256 # change to 80 for Part 1
File.read!("input/day6") |> String.trim |> String.split(",") |> Enum.map(&String.to_integer/1)
|> Enum.reduce(%{}, fn age, pop -> Map.update(pop, age, 1, fn v -> v + 1 end) end)
|> then(fn pop ->
  Enum.reduce(1..days, pop, fn _, pop ->
    Enum.flat_map(pop, fn
      {age, count} when age == 0 -> [{6, count},{8, count}]
      {age, count} -> [{age - 1, count}]
    end)
    |> Enum.reduce(%{}, fn {age, count}, pop -> Map.update(pop, age, count, fn v -> v + count end) end)
  end)
end)
|> Map.values |> Enum.sum |> IO.puts