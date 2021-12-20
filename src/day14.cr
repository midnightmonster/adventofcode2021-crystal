INPUT = File.read("input/day14")
initial,rules_lines = INPUT.split("\n\n",2)
polymer = initial.chars
rules = rules_lines.split("\n").reduce(Hash({Char,Char},Char).new) do |memo,line|
  x,d = line.split(" -> ",2)
  a,b = x.chars
  memo[{a,b}] = d.chars[0]
  memo
end

10.times do 
  p2 = Array(Char).new(polymer.size * 2)
  (0...(polymer.size - 1)).each do |i|
    p2 << polymer[i]
    p2 << rules[{polymer[i],polymer[i+1]}]
  end
  p2 << polymer.last(1)[0]
  polymer = p2
end

counts = polymer.reduce(Hash(Char,Int32).new {|h,k| h[k] = 0}) do |memo,char|
  memo[char] += 1
  memo
end.values

min,max = counts.minmax

puts "Most common - least common = #{max-min}"