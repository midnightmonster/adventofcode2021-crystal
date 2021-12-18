require "option_parser"

def part1(filename)
  sum = 0
  File.each_line(filename) do |line|
    _,readout = line.split(" | ",2)
    sum += readout.split(' ').count {|s| {2,3,4,7}.includes?(s.size) }
  end
  puts "Number of digits 1, 4, 7, 8: #{sum}"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 8, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Count 1, 4, 7, 8" do |filename|
    part1(filename)
    exit
  end
  # parser.on "-2 FILENAME", "--part2=FILENAME", "Count dangerous thermal vent overlaps, including diagonals" do |filename|
  #   part2(filename)
  #   exit
  # end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
