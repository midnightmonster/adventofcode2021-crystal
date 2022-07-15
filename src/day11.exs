import Enum
defmodule OctopusGrid do
  defstruct grid: %{}, width: 0, height: 0, steps_complete: 0, flash_count: nil
  def parse(enum) do
    enum
    |> map(&String.trim/1)
    |> map(fn line -> for <<d::binary-1 <- line>>, do: String.to_integer(d) end)
    |> with_index
    |> reduce(%OctopusGrid{}, fn {line, y}, og ->
      line |> with_index |> reduce(%{og | height: y + 1}, fn {v, x}, og ->
        %{og | grid: Map.put(og.grid, {x, y}, v), width: Enum.max([x + 1, og.width])}
      end)
    end)
  end

  def synchronize(og) when og.flash_count == og.width * og.height, do: og.steps_complete
  def synchronize(og), do: synchronize(og |> step)

  def step(og) do
    {og, flashes} = incr_substep(og)
    og = flash_substep(og, flashes)
    %{og | steps_complete: og.steps_complete + 1}
  end

  defp incr_substep(og) do
    {grid_pairs, {flashes, count}} = og.grid |> map_reduce({[], 0}, fn
      ({k, 9}, {flashes, count}) -> {{k, 0}, {[k | flashes], count + 1}}
      ({k, v}, fc) -> {{k, v + 1}, fc}
    end)
    {%{og | flash_count: count, grid: grid_pairs |> into(og.grid)}, flashes}
  end

  defp flash_substep(og, []), do: og
  defp flash_substep(og, [flash|rest]) do
    {flashes, og} = adjacent(flash, og.width, og.height) |> flat_map_reduce(og, fn coords, og ->
      case Map.get(og.grid, coords) do
        0 -> {[], og}
        9 -> {[coords], %{og | flash_count: og.flash_count + 1, grid: %{og.grid | coords => 0}}}
        v -> {[], %{og | grid: %{og.grid | coords => v + 1}}}
      end
    end)
    flash_substep(og, flashes ++ rest)
  end

  defp adjacent({x, y}, w, h) do
    [{1,1},{1,0},{1,-1},{0,1},{0,-1},{-1,1},{-1,0},{-1,-1}] |> map(fn {dx, dy} ->
      {x + dx, y + dy}
    end)
    |> filter(fn {x,y} -> x in 0..(w-1) and y in 0..(h-1) end)
  end
end

defimpl String.Chars, for: OctopusGrid do
  def to_string(og) do
    0..(og.height-1) |> map(fn y ->
      0..(og.width-1) |> map(fn x -> og.grid[{x, y}] end)
      |> join
    end)
    |> join("\n")
  end
end

grid = File.stream!("input/day11") |> OctopusGrid.parse
{flashes, grid} = map_reduce(1..100, grid, fn _, og ->
  og = OctopusGrid.step(og)
  {og.flash_count, og}
end)
IO.puts(flashes |> sum)
IO.puts(OctopusGrid.synchronize(grid))