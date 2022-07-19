import Enum
defmodule Caves do
  @lowcase ~r/^[a-z]+$/
  def parse(lines) do
    lines |> reduce(%{}, fn line, connections ->
      Regex.run(~r/(\w+)-(\w+)/, line)
      |> tl
      |> map(&(if String.match?(&1, @lowcase), do: String.to_atom(&1), else: &1))
      |> then(fn [left, right] ->
        connections
        |> Map.update(left, [right], &([right | &1]))
        |> Map.update(right, [left], &([left | &1]))
      end)
    end)
  end
  def traverse({[:end|connections],caves}), do: 1 + traverse({connections,caves})
  def traverse({dead_end,_caves}) when dead_end in [[], nil], do: 0
  def traverse({[next|connections],caves}) when is_atom(next) do
    traverse(Map.pop(caves,next,nil)) + traverse({connections,caves})
  end
  def traverse({[next|connections],caves}) do
    traverse({Map.fetch!(caves,next), caves}) + traverse({connections,caves})
  end
  def traverse(caves), do: traverse(Map.pop!(caves,:start))
end

File.stream!("input/day12")
|> Caves.parse
|> Caves.traverse |> IO.puts