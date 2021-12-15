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

def iterate_boards(filename)
  calls = nil
  board = BingoBoard.new
  File.each_line(filename) do |line|
    next calls = line.split(',').map(&.to_i) if calls.nil?
    case line
    when ""
      yield board, calls if board.ready?
      board.reset!
    else
      board.add_row(line)
    end
  end
  nil
end

def part1(filename)
  fastest = Int32::MAX
  score = 0
  iterate_boards(filename) do |board,calls|
    fastest = calls.size if fastest > calls.size
    (0..fastest-1).each_with_index do |call_index,index|
      if win = board.call(calls[call_index])
        fastest = index
        score = win
        break
      end
    end
  end
  puts "Fastest winning score is #{score} after #{fastest} calls"
end

def part2(filename)
  slowest = 0
  score = 0
  iterate_boards(filename) do |board,calls|
    calls.each_with_index do |call,index|
      if win = board.call(call)
        if index > slowest
          slowest = index
          score = win
        end
        break
      end
    end
  end
  puts "Slowest winning score is #{score} after #{slowest} calls"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 4, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Fastest winning bingo board score" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Slowest winning bingo board score" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
