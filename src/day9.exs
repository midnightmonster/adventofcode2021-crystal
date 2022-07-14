import Enum
nines = String.duplicate("9",102)
lines = [nines | File.stream!("input/day9") |> map(&("9#{String.trim(&1)}9"))] ++ [nines]
lines = lines |> map(fn line -> for <<d::binary-1 <- line>>, do: String.to_integer(d) end)
defmodule SmokeBasin do
  defp go_x(total, [_,ab,ac|atail], [ba,bb,bc|btail], [_,cb,cc|ctail]) do
    next = total + if([ab,ba,bc,cb] |> all?(&(bb < &1)), do: 1 + bb, else: 0)
    go_x(next, [ab,ac|atail], [bb,bc|btail], [cb,cc|ctail])
  end
  defp go_x(total, _, _, _), do: total
  def low_points(lines, total \\ 0)
  def low_points([a,b,c|tail], total), do: low_points([b,c|tail], go_x(total,a,b,c))
  def low_points(_, total), do: total
  def basins(lines) do
    lines |> reduce({%{}, %{}, for(_ <- (1..102), do: nil), 1}, fn line, {counts, key_map, prev_line, next_key} ->
      {mapped_line, {_left, counts, key_map, next_key}} =
        map_reduce(zip(line,prev_line),{nil, counts, key_map, next_key}, fn
          # Current location is a ridge
          ({9, _}, {_, counts, key_map, next_key}) -> {nil, {nil, counts, key_map, next_key}}
          # Above and left were both ridges: make a new basin
          ({_, nil}, {nil, counts, key_map, next_key}) -> {next_key, {next_key, counts |> upcount(next_key), key_map, next_key + 1}}
          # Above was ridge, left was basin: add one to left basin
          ({_, nil}, {left, counts, key_map, next_key}) -> {left, {left, counts |> upcount(left), key_map, next_key}}
          # Left was ridge, above was basin: add one to above basin
          ({_, above}, {nil, counts, key_map, next_key}) ->
            with basin <- resolve_key(above, key_map)
            do
              {basin, {basin, counts |> upcount(basin), key_map, next_key}}
            end
          # Left and above are both basins, possibly the same
          ({_, above}, {left, counts, key_map, next_key}) ->
            {counts, key_map} = merge_basins(counts, key_map, left, above)
            {left, {left, counts, key_map, next_key}}
        end)
      # Debug display of entire map
      # mapped_line |> map(&(String.pad_leading("#{&1 || "___"}", 3, "0"))) |> join(" ") |> IO.puts 
      {counts, key_map, mapped_line, next_key}
    end)
    |> elem(0)
    |> Map.values
    |> sort(:desc)
    |> then(fn [a,b,c|_tail] -> a * b * c end)
  end
  defp resolve_key(key, key_map) do
    resolved = Map.get(key_map, key, key)
    if resolved == key, do: key, else: resolve_key(resolved, key_map)
  end
  defp upcount(counts, key) do
    Map.update(counts, key, 1, &(&1 + 1))
  end
  defp merge_basins(counts, key_map, a, b) do
    b = resolve_key(b, key_map)
    if a == b do
      {upcount(counts, a), key_map}
    else
      {to_add, counts} = Map.get_and_update counts, b, &({&1, 0})
      {Map.update!(counts, a, &(&1 + 1 + to_add)), Map.put(key_map, b, a)}
    end
  end
end
SmokeBasin.low_points(lines) |> IO.puts
SmokeBasin.basins(lines) |> IO.puts