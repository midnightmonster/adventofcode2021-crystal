require "option_parser"

def error_score(line)
  stack = Array(Char).new
  line.chars.each do |char|
    case char
    when '[' then stack.push ']'
    when '(' then stack.push ')'
    when '{' then stack.push '}'
    when '<' then stack.push '>'
    else
      return {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137
      }[char] if char != stack.pop
    end
  end
  return 0
end

def part1(filename)
  sum = 0
  File.each_line(filename) {|line| sum += error_score(line) }
  puts "Syntax error score: #{sum}"
end

def autocomplete_score(line)
  stack = Array(Char).new
  score = 0.to_i64
  line.chars.each do |char|
    case char
    when '[' then stack.push ']'
    when '(' then stack.push ')'
    when '{' then stack.push '}'
    when '<' then stack.push '>'
    else
      return score if char != stack.pop
    end
  end
  while(char = stack.pop?)
    score *= 5
    score += {
      ')' => 1,
      ']' => 2,
      '}' => 3,
      '>' => 4
    }[char]
  end
  score
end

def part2(filename)
  line_scores = Array(Int64).new
  File.each_line(filename) do |line|
    score = autocomplete_score(line)
    line_scores << score if score > 0
  end
  mid_score = line_scores.sort[line_scores.size // 2]
  puts "The middle autocomplete line score is #{mid_score}"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 8, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Syntax error score" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Autocomplete score" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
