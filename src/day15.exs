import Enum
defmodule Navigate do
  defstruct grid: "", width: 0, height: 0, goal: {0,0}
  @moves [{1,0},{0,1},{-1,0},{0,-1}]
  def load_file(path) do
    nav = StringIO.open("", fn pid ->
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
    %{nav | goal: {nav.width-1, nav.height-1}}
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

  defp path(nav, coords \\ {0,0}, risk \\ 0, bests \\ %{}) do
    @moves |> reduce(bests, fn move, bests ->
      with {:ok, coords} <- valid_move(nav, coords, move),
           risk <- (risk_at(nav, coords) + risk),
           :ok <- plausible_path(nav, bests, coords, risk),
           {:ok, bests} <- new_best(bests, coords, risk) do
        case coords == nav.goal do
          true -> bests
          false -> path(nav, coords, risk, bests)
        end
      else
        _ -> bests
      end
    end)
  end

  def min_risk(nav) do
    start = Time.utc_now
    risk = path(nav) |> Map.get(nav.goal)
    {risk, Time.diff(Time.utc_now, start, :millisecond)}
  end
end

Navigate.load_file("input/day15")
|> IO.inspect
|> Navigate.min_risk
|> IO.inspect