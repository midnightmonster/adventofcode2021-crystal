import Enum
defmodule Navigate do
  defstruct grid: "", width: 0, height: 0
  
  @moves [{1,0},{0,1},{-1,0},{0,-1}]

  def load_file(path, ex \\ 0, ey \\ 0) do
    StringIO.open("", fn pid ->
      {width, height} = 0..ey |> reduce({0,0}, fn sy, {_width, _height} ->
        File.stream!(path) |> reduce({0,0}, fn line, {_w,h} ->
          line = String.trim(line)
          width = byte_size(line)
          costs = line |> :binary.bin_to_list |> map(&(&1 - 48))
          0..ex |> each(fn sx ->
            bytes = costs |> map(fn cost ->
              case rem(cost + sx + sy, 9) do
                0 -> 9
                c -> c
              end
            end) |> :binary.list_to_bin
            IO.write pid, bytes
          end)
          {width, h + 1}
        end)
      end)
      {_, grid} = StringIO.contents pid
      %Navigate{ grid: grid, width: width * (ex + 1), height: height * (ey + 1) }
    end) |> elem(1)
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
    {cost, {x,y}} = item
    estimated = cost - x - y
    {left, right} = split_while(list, fn {cost, {x,y}} -> (cost - x - y) < estimated end)
    left ++ [item | right]
  end

  def node_cost(nav, {x,y}) do
    index = y * nav.width + x
    :binary.at(nav.grid, index)
  end

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

Navigate.load_file("input/day15",4,4)
# |> IO.inspect
|> Navigate.cost({0,0},{499,499})
|> IO.puts