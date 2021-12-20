INPUT = File.read("input/day14")
initial,rules_lines = INPUT.split("\n\n",2)
rules = rules_lines.split("\n").reduce(Hash({Char,Char},Char).new) do |memo,line|
  x,d = line.split(" -> ",2)
  a,b = x.chars
  memo[{a,b}] = d.chars[0]
  memo
end

chars = initial.chars
last_char = chars[chars.size-1]
pair_counts = Hash({Char,Char},Int64).new(0,rules.size)
(0...(chars.size - 1)).each do |i|
  pair_counts[{chars[i],chars[i+1]}] += 1
end

def polymerize(pair_counts,rules)
  pair_counts.reduce(Hash({Char,Char},Int64).new(0,rules.size)) do |memo,(pair,count)|
    y = rules[pair]
    memo[{pair[0],y}] += count
    memo[{y,pair[1]}] += count
    memo
  end
end

def count_elements(pair_counts,last_char)
  counts = Hash(Char,Int64).new(0,10)
  counts[last_char] += 1
  counts = pair_counts.reduce(counts) do |memo,(pair,count)|
    memo[pair[0]] += count
    memo
  end
end

10.times { pair_counts = polymerize(pair_counts,rules) }
min,max = count_elements(pair_counts,last_char).values.minmax
puts "After 10: Most common - least common = #{max-min}"

30.times { pair_counts = polymerize(pair_counts,rules) }
min,max = count_elements(pair_counts,last_char).values.minmax
puts "After 40: Most common - least common = #{max-min}"
