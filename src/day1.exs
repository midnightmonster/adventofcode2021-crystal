# First attempt at part one
for l <- File.stream!("input/day1", [], :line) do
  String.trim(l) |> String.to_integer
end |> Enum.reduce({0, 999999}, fn
  (depth, {descents, prev}) when depth > prev -> {descents + 1, depth}
  (depth, {descents, _}) -> {descents, depth}
end)

# Added howmany to Descent module after window
defmodule Descent do
  def howmany(list, count \\ 0)
  def howmany([a,b|tail], count) when b > a, do: howmany([b|tail], count + 1)
  def howmany([_,b|tail], count), do: howmany([b|tail], count)
  def howmany(_list, count), do: count
  def window(list, count \\ 0)
  def window([a,b,c,d|tail], count) when d > a, do: window([b,c,d|tail], count + 1)
  def window([_,b,c,d|tail], count), do: window([b,c,d|tail], count)
  def window(_list, count), do: count
end

# And ultimately I think I like this version better
defmodule Descent do
  def howmany(list, count \\ 0)
  def howmany([a,b|tail], count) do
    howmany([b|tail], count + if(b > a, do: 1, else: 0))
  end
  def howmany(_list, count), do: count
  def window(list, count \\ 0)
  def window([a,b,c,d|tail], count) do
    window([b,c,d|tail], count + if(d > a, do: 1, else: 0))
  end
  def window(_list, count), do: count
end

for l <- File.stream!("input/day1", [], :line) do
  String.trim(l) |> String.to_integer
end |> Descent.howmany

for l <- File.stream!("input/day1", [], :line) do
  String.trim(l) |> String.to_integer
end |> Descent.window
