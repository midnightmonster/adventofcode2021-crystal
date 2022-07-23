class Nav
  @grid : Array(Array(Int8))
  @width : Int32
  @height : Int32

  def self.parse(filename)
    qgrid = File.read(filename).split("\n").map {|line| line.chars.map &.to_i8 }
    # return new(qgrid)
    la = qgrid.size
    lb = qgrid.first.size
    grid = Array(Array(Int8)).new(la * 5) { Array(Int8).new(lb * 5,0) }
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
    new(grid)
  end

  def initialize(grid)
    @grid = grid
    @width = grid.first.size
    @height = grid.size
  end

  def cost(start, goal)
    costs = Array.new(@grid.size) { Array(Int32).new(@grid[0].size, Int32::MAX) }
    costs[start.last][start.first] = 0
    frontier = Array({Int32,{Int32,Int32}}).new(2000)
    frontier << {self.class.heuristic_cost(start,goal),start}
    count = 0
    while(item = frontier.shift?)
      _,node = item
      cost_so_far = costs[node.last][node.first]
      # puts "Considering #{node} (cost: #{cost_so_far})"
      count += 1
      if node == goal
        puts "Considered #{count}"
        return cost_so_far
      end
      neighbors(node).each do |next_node|
        cost = node_cost(next_node).to_i32 + cost_so_far
        next unless self.class.new_best(costs,next_node,cost)
        self.class.enqueue(frontier,{cost + self.class.heuristic_cost(next_node, goal),next_node})
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
    [{0,1},{1,0},{0,-1},{-1,0}].map do |(dx,dy)|
      {x + dx, y + dy}
    end.select do |(x,y)|
      (0...@width).includes?(x) && (0...@height).includes?(y)
    end
  end

  def self.new_best(costs,node,cost)
    x,y = node
    return false unless cost < costs[y][x]
    costs[y][x] = cost
  end

  def self.enqueue(list,item)
    i = list.index {|existing| existing > item } || list.size
    list.insert(i, item)
  end

  def self.heuristic_cost(a,b)
    (a.first - b.first).abs + (a.last - b.last).abs
  end

end

puts Nav.parse("input/day15").cost({0,0},{499,499})
