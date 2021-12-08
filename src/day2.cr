require "option_parser"

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 2, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Follow the course" do |filename|
    horiz, depth = File.open(filename) do |file|
      file.each_line.reduce({0,0}) do |(horiz,depth),line|
        /(\w+)\s+(\d+)/.match(line).try do |match|
          command, n = match.captures
          distance = n.nil? ? 0 : n.to_i
          case command
          when "forward" then horiz += distance
          when "up" then depth -= distance
          when "down" then depth += distance
          end
        end
        {horiz,depth}
      end
    end
    puts "Position: #{horiz}, #{depth}. Product: #{horiz*depth}"
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Follow the course with aim" do |filename|
    horiz, depth, _ = File.open(filename) do |file|
      file.each_line.reduce({0,0,0}) do |(horiz,depth,aim),line|
        /(\w+)\s+(\d+)/.match(line).try do |match|
          command, n = match.captures
          num = n.nil? ? 0 : n.to_i
          case command
          when "forward"
            horiz += num
            depth += num * aim
          when "up" then aim -= num
          when "down" then aim += num
          end
        end
        {horiz,depth,aim}
      end
    end
    puts "Position: #{horiz}, #{depth}. Product: #{horiz*depth}"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end