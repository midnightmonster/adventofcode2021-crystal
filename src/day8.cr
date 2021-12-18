require "option_parser"
require "./line_enumerator"

class Readouts < LineEnumerator({Array(Set(Char)),Array(Set(Char))})
  protected def line(line_str : String) : {Array(Set(Char)),Array(Set(Char))}
    patterns,readout = line_str.split(" | ",2).map do |str|
      str.split(' ').map {|group| Set(Char).new(group.chars)}
    end
    {patterns,readout}
  end
end

def part1(filename)
  sum = Readouts.new(filename).reduce(0) do |sum,(_,readout)|
    sum + readout.count {|n| {2,3,4,7}.includes?(n.size) }
  end
  puts "Number of digits 1, 4, 7, 8: #{sum}"
end

def part2(filename)
  sum = Readouts.new(filename).reduce(0) do |sum,(patterns,readout)|
    cfreq = patterns.reduce(Hash(Char, Int32).new(0, 7)) do |freq, pat|
      pat.each { |c| freq[c] += 1 }
      freq
    end
    pmap = {
      1 => patterns.find(Set(Char).new) { |p| p.size == 2 },
      4 => patterns.find(Set(Char).new) { |p| p.size == 4 },
      7 => patterns.find(Set(Char).new) { |p| p.size == 3 },
      8 => patterns.find(Set(Char).new) { |p| p.size == 7 },
    }
    patterns.delete(pmap[1])
    patterns.delete(pmap[4])
    patterns.delete(pmap[7])
    patterns.delete(pmap[8])
    cmap = {
      'e' => cfreq.key_for(4),
      'b' => cfreq.key_for(6),
      'f' => cfreq.key_for(9),
    }
    cmap['c'] = pmap.values.reduce { |memo, pat| memo & pat }.find { |c| c != cmap['f'] } || raise "wtf"
    pmap[2] = patterns.find { |p| !p.includes?(cmap['f']) } || raise "wtf"
    patterns.delete(pmap[2])
    pmap[9] = patterns.find { |p| p.size == 6 && !p.includes?(cmap['e']) } || raise "wtf"
    patterns.delete(pmap[9])
    pmap[6] = patterns.find { |p| p.size == 6 && !p.includes?(cmap['c']) } || raise "wtf"
    patterns.delete(pmap[6])
    pmap[0] = patterns.find { |p| p.size == 6 } || raise "wtf"
    patterns.delete(pmap[0])
    pmap[3] = patterns.find { |p| !p.includes?(cmap['b']) } || raise "wtf"
    patterns.delete(pmap[3])
    pmap[5] = patterns.first || raise "wtf"
    numbers = pmap.invert
    value = readout.reverse.each_with_index.reduce(0) {|memo,(pattern,index)| memo + numbers[pattern] * (10 ** index) }
    puts value
    sum + value
  end
  puts "The sum of all readouts is #{sum}"
end

OptionParser.parse do |parser|
  parser.banner = "Advent of Code 2021 - Day 8, Parts 1 & 2"
  parser.on "-1 FILENAME", "--part1=FILENAME", "Count 1, 4, 7, 8" do |filename|
    part1(filename)
    exit
  end
  parser.on "-2 FILENAME", "--part2=FILENAME", "Sum of all mixed-up readouts" do |filename|
    part2(filename)
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
