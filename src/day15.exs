import Enum
defmodule Navigate do
  defstruct grid: "", width: 0, height: 0, goal: {0,0}
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
    %Navigate{ grid: grid, width: width, height: height, goal: {width-1, height-1} }
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
    %Navigate{ grid: grid, width: width, height: height, goal: {width-1, height-1} }
  end

  defp risk_at(nav, {x,y}) do
    index = y * nav.width + x
    :binary.at(nav.grid, index)
  end

  def valid_move(nav, {x,y}, {dx,dy}) do
    x = x + dx
    y = y + dy
    if x in 0..(nav.width-1) and y in 0..(nav.height-1) do
      {:ok, {x,y}}
    else
      {:err, :out_of_bounds}
    end
  end

  def new_best(bests, coords, risk) do
    case Map.get_and_update(bests, coords, fn v -> {v, min([risk, v])} end) do
      {prev, bests} when risk < prev -> {:ok, bests}
      _ -> {:err, :worse}
    end
  end

  def plausible_path(nav, bests, {x,y}, risk) do
    case Map.get(bests, nav.goal) do
      nil -> :ok
      best -> with {gx,gy} <- nav.goal do
        if((risk + gx - x + gy - y) < best, do: :ok, else: :err)
      end
    end
  end

  defp path(nav, bests \\ %{{0,0}=>0}, to_visit \\ [{0,0}], to_visit_set \\ MapSet.new)
  defp path(nav, bests, [], _), do: Map.get(bests, nav.goal)
  defp path(nav, bests, [coords|to_visit], to_visit_set) do
    to_visit_set = MapSet.delete(to_visit_set, coords)
    {more_steps, {bests, to_visit_set}} = @moves |> flat_map_reduce({bests, to_visit_set}, fn move, {bests, to_visit_set} ->
      with {:ok, ncoords} <- valid_move(nav, coords, move),
           risk <- (Map.get(nav.grid, ncoords) + Map.get(bests, coords)),
           :ok <- plausible_path(nav, bests, ncoords, risk), # This saves maybe 1.5s out of ~45s
           {:ok, bests} <- new_best(bests, ncoords, risk) do
        {
          if(ncoords == nav.goal, do: [], else: [ncoords]),
          {bests, MapSet.put(to_visit_set, ncoords)}
        }
      else
        _ -> {[],{bests,to_visit_set}}
      end
    end)
    path(nav, bests, to_visit ++ more_steps, to_visit_set)
  end

  def min_risk(nav) do
    start = Time.utc_now
    risk = path(nav)
    {risk, Time.diff(Time.utc_now, start, :millisecond)}
  end
end

Navigate.load_file("input/day15")
|> IO.inspect
|> Navigate.expand(4,4)
|> IO.inspect
|> Navigate.min_risk
|> IO.inspect