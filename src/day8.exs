import Enum
io = File.stream!("input/day8") |> map(&String.trim/1) |> map(fn line ->
  parts = String.split(line, " | ") |> map(fn part -> String.split(part," ") end)
  [input, output] = map(parts, fn part -> map(part, fn code -> sort(to_charlist(code)) end) end)
  {input, output} # Lists of internally-alphabetized charlists
end)
# Part 1
io |> map(fn {_, o} -> count(o, fn chars -> length(chars) in [2,3,4,7] end) end) |> sum |> IO.puts
# Part 2
# First pass at this was correct except that I wrote [2,3,4,5] instead of ...7.
# Wisely, I included no fallback matcher in cond below, so the code failed there,
# and I had fewer lines to search for my mistake. Just checking the result of the
# first line of the function on one sample input exposed the problem.
io |> map(fn {input, output} ->
  [one, seven, four, eight | rest] = sort_by(input, &({if(length(&1) in [2,3,4,7], do: 0, else: 1), length(&1)}))
  key = %{one => 1, seven => 7, four => 4, eight => 8}
  key = rest |> reduce(key, fn code, key ->
    Map.put(key, code, cond do
      length(code) == 5 and length(one -- code) == 0 -> 3
      length(code) == 5 and length(four -- code) == 1 -> 5
      length(code) == 5 -> 2
      length(code) == 6 and length(one -- code) == 1 -> 6
      length(code) == 6 and length(four -- code) == 0 -> 9
      length(code) == 6 -> 0
    end)
  end)
  output |> map(fn code -> key[code] end) |> Integer.undigits
end) |> sum |> IO.puts