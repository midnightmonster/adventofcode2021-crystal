require "option_parser"
require "colorize"

def part1(filename)
  grid = File.read_lines(filename).map &.chars
  sum = grid.each_with_index.reduce(0) do |memo,(row,y)|
    result = 0
    puts(String.build(1200) do |str|
      result = memo + row.each_with_index.reduce(0) do |memo,(char,x)|
        if char < {
          y > 0 ? grid[y-1][x] : 'a',
          x+1 < row.size ? row[x+1] : 'a',
          y+1 < grid.size ? grid[y+1][x] : 'a',
          x > 0 ? row[x-1] : 'a'
        }.min
          str << char.colorize.red.bold
          memo + char.to_i + 1
        else
          str << char.colorize.dark_gray
          memo
        end
      end
    end)
    result
  end
  puts "The sum of all low-point risk levels is #{sum}"
end

def part2(filename)
  
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 8, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Sum risk level of low points" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
