class Nav
  def self.parse(filename)
    qgrid = File.read(filename).split("\n").map {|line| line.chars.map &:to_i }
    # return new(qgrid)
    la = qgrid.size
    lb = qgrid.first.size
    grid = (0...la*5).map { [] }
    (0..4).each do |ma|
      (0..4).each do |mb|
        qgrid.each_with_index do |line,a|
          line.each_with_index do |v,b|
            nv = (v + ma + mb) % 9
            grid[ma*la+a][mb*lb+b] = (nv == 0 ? 9 : nv)
          end
        end
      end
    end
    new(grid)
  end

  def initialize(grid)
    @grid = grid
    @width = grid.first.size
    @height = grid.size
  end

  def cost(start, goal)
    costs = Hash.new {|h,k| h[k] = {} }
    costs[start.first][start.last] = 0
    frontier = [[self.class.heuristic_cost(start,goal),start]]
    count = 0
    while(item = frontier.shift) do
      _,node = item
      x,y = node
      cost_so_far = costs[x][y]
      # puts "Considering #{node} (cost: #{cost_so_far})"
      count += 1
      if node == goal
        puts "Considered #{count}"
        return cost_so_far
      end
      neighbors(node).each do |next_node|
        cost = node_cost(next_node) + cost_so_far
        next unless self.class.new_best(costs,next_node,cost)
        self.class.enqueue(frontier,[cost + self.class.heuristic_cost(next_node, goal), next_node])
      end
      # puts "Frontier #{frontier}" if(count > 10423)
    end
    puts "Found nothing, considered #{count}"
  end

  def node_cost(node)
    x,y = node
    @grid[y][x]
  end

  def neighbors(node)
    x,y = node
    [[0,1],[1,0],[0,-1],[-1,0]].map do |(dx,dy)|
      [x + dx, y + dy]
    end.select do |(x,y)|
      (0...@width).include?(x) && (0...@height).include?(y)
    end
  end

  def self.new_best(costs,node,cost)
    x,y = node
    prev = costs[x][y]
    return false unless prev.nil? || cost < prev
    costs[x][y] = cost
  end

  def self.enqueue(list,item)
    icost,_ = item
    i = list.index {|(xcost,_)| xcost > icost } || list.size
    list.insert(i, item)
  end

  def self.heuristic_cost(a,b)
    (a.first - b.first).abs + (a.last - b.last).abs
  end

end

puts Nav.parse("input/day15").cost([0,0],[499,499])
