defmodule DotPrinter do
  def print(dots) do
    dots
    |> Enum.sort_by(fn {x,y} -> {y,x} end)
    |> Enum.chunk_by(&(elem(&1,1)))
    |> Enum.each(fn dots -> dots |> Enum.map(&(elem(&1,0))) |> println end)
  end
  def println(xs, str \\ "")
  def println([], str), do: IO.puts str
  def println([x|xs], str) do
    println(xs, String.pad_trailing(str,x," ") <> "#")
  end
end

File.stream!("input/day13")
|> Enum.reduce({MapSet.new, []}, fn line, {dots, folds} ->
  case Regex.run(~r/(\d+),(\d+)|([xy])=(\d+)/, line) do
    [_, _, _, axis, v] -> {dots, folds ++ [{axis, String.to_integer(v)}]}
    [_, x, y] -> {MapSet.put(dots, {String.to_integer(x),String.to_integer(y)}), folds}
    _ -> {dots, folds}
  end
end)
|> then(fn {dots, folds} ->
  folds |> Enum.reduce(dots, fn {axis,v}, dots ->
    MapSet.new(dots, fn
      {x,y} when x > v and axis=="x" -> {v - (x - v), y}
      {x,y} when y > v and axis=="y" -> {x, v - (y - v)}
      dot -> dot
    end)
    |> tap(fn dots -> IO.puts "#{MapSet.size(dots)} dots" end)
  end)
end)
|> DotPrinter.print