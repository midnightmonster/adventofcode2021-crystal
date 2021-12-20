INPUT = File.read("input/day15")

grid = INPUT.split("\n").map {|line| line.chars.map &.to_i8 }
start = {0.to_i16,0.to_i16}
goal = {(grid.size - 1).to_i16,(grid[0].size - 1).to_i16}

def step(grid,goal,pos,risk=0,path=Set({Int16,Int16}).new,best=Int32::MAX)
  a,b = pos
  risk += grid[a][b]
  path << pos
  return {false,risk} if risk >= best
  return {true,risk} if pos == goal
  options = Array({Int16,Int16}).new(4)
  options << {a-1,b} unless a == 0 || path.includes?({a-1,b})
  options << {a,b+1} unless b+1 == grid[a].size || path.includes?({a,b+1})
  options << {a+1,b} unless a+1 == grid.size || path.includes?({a+1,b})
  options << {a,b-1} unless b == 0 || path.includes?({a,b-1})
  return {false,risk} if options.empty?
  new_best = best
  options.each do |opt|
    success,score = step(grid,goal,opt,risk,path.dup,new_best)
    new_best = score if success
    # puts path.inspect if success
  end
  new_best < best ? {true,new_best} : {false,best}
end

success,risk_score = step(grid,goal,start,-1*grid[start[0]][start[1]].to_i32)

puts "Lowest possible risk score: #{risk_score}"

# This approach works for a 10x10 board, but it takes too long for the 100x100 
# board. I thought I was being clever by stopping each explorer if its total 
# risk exceeded the best-so-far risk, but I can do better by keeping track of 
# the best-so-far risk to reach each square and prune most branches much faster.
# I think that approach will also benefit from a breadth-first approach.
