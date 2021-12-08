require "option_parser"

def part1(filename)
  count, cols = File.open(filename) do |file|
    file.each_line.reduce({0,StaticArray(Int32, 12).new(0)}) do |(count,cols),line|
      (0...cols.size).each {|i| cols[i]+=1 if line[i]=='1'}
      {count+1,cols}
    end
  end
  half = count / 2
  epsilon = cols.map {|c| c > half ? '1' : '0'}.join
  gamma = cols.map {|c| c > half ? '0' : '1'}.join
  puts "Epsilon: #{epsilon}"
  puts "Gamma: #{gamma}"
  puts "Product: #{epsilon.to_i(2) * gamma.to_i(2)}"
end

class BinTree
  ONE = "1".bytes.first

  def initialize
    @count = 0
  end

  def build(chars : (Array(UInt8) | String))
    chars = case chars
    when Array(UInt8) then chars
    when String then chars.bytes
    else raise "wtf?"
    end
    @count += 1
    if chars.size > 0
      byte = chars.shift
      case byte
      when ONE then on(chars)
      else off(chars)
      end
    end
    self
  end

  def on(chars=nil)
    @on = BinTree.new if @on.nil?
    @on.try &.build(chars)
  end

  def off(chars)
    @off = BinTree.new if @off.nil?
    @off.try &.build(chars)
  end

  def count
    @count
  end

  def o2_generator(output="")
    return output unless @on || @off
    onc = @on.try &.count || 0
    offc = @off.try &.count || 0
    return @off.try &.o2_generator("#{output}0") if offc > onc
    return @on.try &.o2_generator("#{output}1")
  end

  def co2_scrubber(output="")
    return output unless @on || @off
    onc = @on.try &.count || Int32::MAX
    offc = @off.try &.count || Int32::MAX
    return @on.try &.co2_scrubber("#{output}1") if onc < offc 
    return @off.try &.co2_scrubber("#{output}0")
  end

end


def part2(filename)
  tree = BinTree.new
  File.each_line(filename) {|line| tree.build(line) }
  o2_generator = tree.o2_generator
  co2_scrubber = tree.co2_scrubber
  puts "Oxygen Generator: #{o2_generator}"
  puts "CO2 Scrubber: #{co2_scrubber}"
  puts "Product: #{(o2_generator.try &.to_i(2) || 1) * (co2_scrubber.try &.to_i(2) || 1)}"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 3, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Energy consumption from diagnostic report" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Life support rating from diagnostic report" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end