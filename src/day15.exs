import Enum
defmodule Navigate do
  defstruct grid: "", width: 0, height: 0
  @moves [{1,0},{0,1},{-1,0},{0,-1}]
  def load_file(path) do
    {grid,{width,height}} = File.stream!(path)
    |> reduce({%{},{0,0}}, fn line, {grid,{w,h}} ->
      line = String.trim(line)
      grid = line
      |> :binary.bin_to_list
      |> map(&(&1 - 48))
      |> with_index
      |> reduce(grid, fn {v, x}, grid ->
        Map.put(grid,{x,h},v)
      end)
      {grid,{max([w,byte_size(line)]), h + 1}}
    end)
    %Navigate{ grid: grid, width: width, height: height }
  end

  def expand(nav, ex, ey) do
    grid = 0..ex
    |> flat_map(fn sx -> 0..ey |> map(&({sx, &1})) end)
    |> map(fn {sx,sy} ->
      Map.new(nav.grid, fn {{x,y}, v} ->
        v = case rem(v + sx + sy, 9) do
          0 -> 9
          v -> v
        end
        {{x + nav.width * sx, y + nav.height * sy}, v}
      end)
    end)
    |> reduce(&Map.merge/2)
    width = nav.width * (ex + 1)
    height = nav.height * (ey + 1)
    %Navigate{ grid: grid, width: width, height: height }
  end

  def cost(nav, start, goal), do: costr({[{0, start}], %{start => 0}}, nav, goal)
  
  defp costr({[{final_cost, node} | _], _}, _nav, goal) when node == goal, do: final_cost

  defp costr({[{cost_so_far, node} | frontier], costs}, nav, goal) do
    neighbors(nav, node) |> reduce({frontier, costs}, fn next, {frontier, costs} ->
      with cost <- (node_cost(nav, next) + cost_so_far),
           {:ok, costs} <- new_best(costs, next, cost) do
        {enqueue(frontier,{cost,next}), costs}
      else
        _ -> {frontier, costs}
      end
    end) |> costr(nav, goal)
  end

  defp enqueue(list, item) do
    {left, right} = split_while(list, &(&1 < item))
    left ++ [item | right]
  end

  def node_cost(nav, node) do
    Map.get(nav.grid, node)
  end

  # def node_cost(nav, {x,y}) do
  #   index = y * nav.width + x
  #   :binary.at(nav.grid, index)
  # end

  def neighbors(nav, {x,y}) do
    @moves |> flat_map(fn {dx,dy} ->
      x = x + dx
      y = y + dy
      if x in 0..(nav.width-1) and y in 0..(nav.height-1) do
        [{x,y}]
      else
        []
      end
    end)
  end

  defp new_best(known_costs, node, cost) do
    Map.get_and_update(known_costs, node, fn
      v when cost < v -> {:ok, cost}
      v -> {:err, v}
    end)
  end
end

Navigate.load_file("input/day15")
# |> IO.inspect
|> Navigate.expand(4,4)
# |> IO.inspect
|> Navigate.cost({0,0},{499,499})
|> IO.inspect