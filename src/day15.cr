INPUT = File.read("input/day15")
# INPUT = "1163751742
# 1381373672
# 2136511328
# 3694931569
# 7463417111
# 1319128137
# 1359912421
# 3125421639
# 1293138521
# 2311944581"

def print_grid(grid)
  grid.each {|line| puts line.join(',') }
end

grid = INPUT.split("\n").map {|line| line.chars.map &.to_i8 }
max = {(grid.size - 1),(grid[0].size - 1)}
start = {0,0}
goal = max
risk_map = Array.new(grid.size) { Array(Int32).new(grid[0].size,Int32::MAX) }
risk_map[start.first][start.last] = 0
touches = Array.new(grid.size) { Array(Int32).new(grid[0].size,0) }

steps = Array({Int32,Int32}).new(400)
steps << start
best = Int32::MAX
count = 0
while(step = steps.shift?)
  count += 1
  a,b = step
  risk = risk_map[a][b]
  next if (best < Int32::MAX) && (risk + (goal.first - a).abs + (goal.last - b).abs > best)
  touches[a][b] += 1
  next best = {risk,best}.min if {a,b} == goal
  ((a==0 ? 0 : -1)..(a==max.first ? 0 : 1)).each do |da|
    ((b==0 ? 0 : -1)..(b==max.last ? 0 : 1)).each do |db|
      next if da.abs == db.abs
      na = a+da
      nb = b+db
      nrisk = risk + grid[na][nb]
      next if nrisk >= risk_map[na][nb]
      risk_map[na][nb] = nrisk
      steps << {na,nb} unless steps.includes?({na,nb})
    end
  end
  puts steps.size
end

puts "Considered #{count}"
print_grid touches
puts "\n"
print_grid risk_map

puts "Lowest possible risk score: #{best}"
