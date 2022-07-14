# Part 2 only; ~20 min
days = 256 # change to 80 for Part 1
File.read!("input/day6") |> String.split(",")
|> Enum.frequencies_by(fn s -> Integer.parse(s) |> elem(0) end)
|> then(fn pop ->
  Enum.reduce(1..days, pop, fn _, pop ->
    Enum.map(pop, fn
      {age, count} when age == 0 -> %{6 => count, 8 => count}
      {age, count} -> %{(age - 1) => count}
    end)
    |> Enum.reduce(fn a, b -> Map.merge(a, b, fn _, v, w -> v + w end) end)
  end)
end)
|> Map.values |> Enum.sum |> IO.puts