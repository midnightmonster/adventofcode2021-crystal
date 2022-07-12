import Enum
positions = File.read!("input/day7") |> String.split(",") |> map(&(elem(Integer.parse(&1),0)))
0..max(positions) |> map(fn goal -> map(positions, fn p -> abs(p - goal) end) |> sum end)
|> then(fn list -> IO.puts "Part 1: #{min(list)}" end)
0..max(positions) |> map(fn goal -> map(positions, fn p -> sum(0..abs(p - goal)) end) |> sum end)
|> then(fn list -> IO.puts "Part 2: #{min(list)}" end)