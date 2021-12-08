require "option_parser"

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 1, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Count readings deeper than previous reading" do |filename|
    deeper, _ = File.open(filename) do |file|
      file.each_line.reduce({0,nil}) do |(deeper,last),line|
        current = line.to_i
        {last && current > last ? deeper + 1 : deeper, current}
      end
    end
    puts "#{deeper} readings were deeper than previous"
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Count sliding window of 3 readings deeper than previous window" do |filename|
    deeper, _ = File.open(filename) do |file|
      file.each_line.reduce({0,Deque(Int32).new(4)}) do |(deeper,window),line|
        prev = window.sum
        window.push(line.to_i)
        if window.size > 3
          window.shift
          {window.sum > prev ? deeper + 1 : deeper, window}
        else
          {deeper,window}
        end
      end
    end
    puts "#{deeper} sliding windows of 3 were deeper than previous"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end