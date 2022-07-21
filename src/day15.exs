import Enum
defmodule Navigate do
  defstruct grid: "", width: 0, height: 0
  @moves [{1,0},{0,1},{-1,0},{0,-1}]
  def load_file(path) do
    StringIO.open("", fn pid ->
      {width,height} = File.stream!(path)
      |> reduce({0,0}, fn line, {w,h} ->
        line = String.trim(line)
        bytes = line
          |> :binary.bin_to_list
          |> Enum.map(&(&1 - 48))
          |> :binary.list_to_bin
        IO.write pid, bytes
        {max([w,byte_size(line)]), h + 1}
      end)
      {_, grid} = StringIO.contents pid
      %Navigate{ grid: grid, width: width, height: height }
    end) |> elem(1)
  end

  def risk_at(nav, {x,y}) do
    index = y * nav.width + x
    if index in 0..(byte_size(nav.grid)-1), do: :binary.at(nav.grid, index), else: 999
  end

  def path(nav, coords \\ {0,0}, visited \\ MapSet.new([{0,0}]), risk \\ 0, best \\ nil)
  def path(_, _, _, risk, best) when risk >= best, do: nil
  def path(nav, {x,y}, _, _, _) when x in [-1,nav.width] or y in [-1,nav.height], do: nil
  def path(nav, {x,y}, _, risk, _) when (nav.width - 1) == x and (nav.height - 1) == y, do: risk
  def path(nav, {x,y}, visited, risk, best) do
    @moves |> reduce(best, fn {dx, dy}, best ->
      coords = {x + dx, y + dy}
      if MapSet.member?(visited, coords) do
        best
      else
        min([best, path(nav, coords, MapSet.put(visited, coords), risk + risk_at(nav, coords), best)])
      end
    end)
  end
end

Navigate.load_file("input/day15")
|> IO.inspect
|> Navigate.path
|> IO.inspect