require "option_parser"

class Grid
  @grid : Array(Array(Char))

  def initialize(filename)
    @grid = File.read_lines(filename).map &.chars
  end

  def width
    @grid[0].size
  end

  def height
    @grid.size
  end

  def [](x : Int32, y : Int32) : Char
    return '9' if x < 0 || y < 0
    @grid[y]?.try {|row| row[x]? } || '9'
  end

  def points
    xmax = width - 1
    ymax = height - 1
    x = -1
    y = 0
    Iterator.of do
      x += 1
      if x > xmax
        x = 0
        y += 1
      end
      next Iterator.stop if y > ymax
      {self[x,y], x, y}
    end
  end

  def low_points
    points.select do |char,x,y|
      char < {self[x,y-1],self[x+1,y],self[x,y+1],self[x-1,y]}.min
    end
  end

end

def part1(filename)
  grid = Grid.new(filename)
  sum = grid.low_points.reduce(0){|memo,(char,_,_)| memo + char.to_i + 1 }
  puts "The sum of all low-point risk levels is #{sum}"
end

def fill_grid_area(grid : Grid, x : Int32, y : Int32, points : Set({Int32,Int32}) = Set({Int32,Int32}).new)
  return points if points.includes?({x,y})
  return points if grid[x,y] == '9'
  points << {x,y}
  fill_grid_area(grid,x,y-1,points)
  fill_grid_area(grid,x+1,y,points)
  fill_grid_area(grid,x,y+1,points)
  fill_grid_area(grid,x-1,y,points)
end

def part2(filename)
  grid = Grid.new(filename)
  basins = grid.low_points.map {|(_,x,y)| fill_grid_area(grid,x,y).size }.to_a
  largest = basins.sort[-3,3]
  puts "The largest basins sizes are #{largest.join(", ")} with a product of #{largest.product}"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 8, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Sum risk level of low points" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Product of three largest basins' size" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
