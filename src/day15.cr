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

qgrid = INPUT.split("\n").map {|line| line.chars.map &.to_i8 }
la = qgrid.size
lb = qgrid.first.size
grid = Array(Array(Int8)).new(la * 5) { Array(Int8).new(lb * 5,0) }
max = {(grid.size - 1),(grid[0].size - 1)}
start = {0,0}
goal = max
(0..4).each do |ma|
  (0..4).each do |mb|
    qgrid.each_with_index do |line,a|
      line.each_with_index do |v,b|
        nv = (v + ma + mb) % 9
        grid[ma*la+a][mb*lb+b] = (nv == 0 ? 9 : nv).to_i8
      end
    end
  end
end

risk_map = Array.new(grid.size) { Array(Int32).new(grid[0].size,Int32::MAX) }
risk_map[start.first][start.last] = 0
# touches = Array.new(grid.size) { Array(Int32).new(grid[0].size,0) }

steps = Array({Int32,Int32}).new(8000)
ssteps = Set({Int32,Int32}).new(8000)
steps << start
ssteps << start
best = Int32::MAX
count = 0
while(step = steps.shift?)
  ssteps.delete step
  count += 1
  a,b = step
  risk = risk_map[a][b]
  next if (best < Int32::MAX) && (risk + (goal.first - a).abs + (goal.last - b).abs > best)
  # touches[a][b] += 1
  next best = {risk,best}.min if {a,b} == goal
  ((a==0 ? 0 : -1)..(a==max.first ? 0 : 1)).each do |da|
    ((b==0 ? 0 : -1)..(b==max.last ? 0 : 1)).each do |db|
      next if da.abs == db.abs
      na = a+da
      nb = b+db
      nrisk = risk + grid[na][nb]
      next if nrisk >= risk_map[na][nb]
      risk_map[na][nb] = nrisk
      # The extra bookkeeping of this set improves the runtime from come back in
      # a few minutes to 0.36s.
      unless ssteps.includes?({na,nb})
        steps << {na,nb}
        ssteps << {na,nb}
      end
    end
  end
  # puts steps.size
end

puts "Considered #{count}"
# # print_grid touches
# # puts "\n"
# # print_grid risk_map

puts "Lowest possible risk score: #{best}"
