require "option_parser"

class BingoBoard
  def initialize
    @cells = Array(Int32).new(25)
  end

  def reset!
    @cells.truncate(0,0)
  end

  def add_row(line)
    @cells.concat(line.strip.split(/\s+/).map(&.to_i))
  end

  def ready?
    @cells.size == 25
  end

  def call(call)
    if found = @cells.index(call)
      @cells[found] = -1
      return score(call) if winner?
    end
    false
  end

  def score(call)
    call * @cells.sum {|v| v==-1 ? 0 : v }
  end

  def winner?
    [
      {0,4,1},
      {5,9,1},
      {10,14,1},
      {15,19,1},
      {20,24,1},
      {0,20,5},
      {1,21,5},
      {2,22,5},
      {3,23,5},
      {4,24,5}
    ].any? do |min,max,step|
      (min..max).step(step).all? {|i| @cells[i] == -1 }
    end
  end
end

def part1(filename)
  calls = nil
  fastest = Int32::MAX
  score = 0
  board = BingoBoard.new
  File.each_line(filename) do |line|
    if calls.nil?
      calls = line.split(',').map(&.to_i)
      fastest = calls.size
      next
    end
    case line
    when ""
      if board.ready?
        (0..fastest-1).each_with_index do |call_index,index|
          if win = board.call(calls[call_index])
            fastest = index
            score = win
            break
          end
        end
      end
      board.reset!
    else
      board.add_row(line)
    end
  end
  puts "Winning score is #{score} after #{fastest} calls"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 4, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Winning bingo board score" do |filename|
    part1(filename)
    exit
  end
  # parser.on "-2 FILENAME", "--part2=FILENAME", "Life support rating from diagnostic report" do |filename|
  #   part2(filename)
  #   exit
  # end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
