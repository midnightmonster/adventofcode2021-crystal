require "option_parser"

def coordinate_pairs(filename)
  File.each_line(filename) do |line|
    x1,y1,x2,y2 = line.split(/\D+/).map(&.to_i16)
    # puts "#{x1},#{y1} -> #{x2},#{y2}"
    yield({x1,y1}, {x2,y2})
  end
  nil
end

def abs_range(a,b)
  a > b ? (b..a) : (a..b)
end

def part1(filename)
  grid = Hash(Tuple(Int16, Int16),Int16).new(0)
  coordinate_pairs(filename) do |(x1,y1),(x2,y2)|
    case
    when x1==x2 then abs_range(y1,y2).each {|y| grid[{x1,y}] += 1 }
    when y1==y2 then abs_range(x1,x2).each {|x| grid[{x,y1}] += 1 }
    end
  end
  danger = grid.each_value.reduce(0) {|memo,v| v > 1 ? memo + 1 : memo }
  puts "Dangerous grid spaces: #{danger}"
end

def iterate_line(x1,y1,x2,y2)
  dx = x2 <=> x1
  dy = y2 <=> y1
  loop do
    yield({x1,y1})
    break if x1==x2 && y1==y2
    x1 += dx
    y1 += dy
  end
end

def part2(filename)
  grid = Hash(Tuple(Int16, Int16),Int16).new(0)
  coordinate_pairs(filename) do |(x1,y1),(x2,y2)|
    iterate_line(x1,y1,x2,y2) {|coords| grid[coords] += 1 }
  end
  danger = grid.each_value.reduce(0) {|memo,v| v > 1 ? memo + 1 : memo }
  puts "Dangerous grid spaces: #{danger}"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 5, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Count dangerous thermal vent overlaps" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Count dangerous thermal vent overlaps, including diagonals" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
