import Enum
defmodule Caves do
  def parse(lines) do
    lines |> reduce(%{}, fn line, caves ->
      Regex.run(~r/(\w+)-(\w+)/, line)
      |> tl
      |> map(&atomize_lcase/1)
      |> then(fn [left, right] ->
        caves |> add(left, right) |> add(right, left)
      end)
    end)
  end
  defp atomize_lcase(str), do: if(String.match?(str, ~r/^[a-z]+$/), do: String.to_atom(str), else: str)
  defp add(caves, _a, :start), do: caves # Don't make connections back to :start
  defp add(caves, a, b), do: Map.update(caves, a, [b], &([b | &1]))
  
  def traverse(_, [], _, _), do: 0
  def traverse(caves, [:end | connections], visited, ar), do: 1 + traverse(caves, connections, visited, ar)
  def traverse(caves, [room | connections], visited, allow_revisit) do
    {returning, deeper} = Map.get_and_update(visited, room, &({(&1||false),true}))
    revisit = is_atom(room) and returning
    case {revisit, allow_revisit} do
      {true, false} -> 0
      _ -> traverse(caves, Map.fetch!(caves, room), deeper, allow_revisit and not revisit)
    end + traverse(caves, connections, visited, allow_revisit)
  end
  def traverse(caves, allow_revisit), do: traverse(caves, Map.fetch!(caves,:start), %{}, allow_revisit)
  def traverse(caves), do: traverse(caves, false)
end

File.stream!("input/day12")
|> Caves.parse
|> then(fn caves ->
  Caves.traverse(caves) |> IO.puts
  Caves.traverse(caves, true) |> IO.puts
end)