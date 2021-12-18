dots = Set({Int32,Int32}).new
folding = false

def fold(dots,axis,n)
  dots.reduce(Set({Int32,Int32}).new) do |memo,(x,y)|
    case axis
    when "x"
      x = x < n ? x : (n - (x - n))
    when "y"
      y = y < n ? y : (n - (y - n))
    end
    memo << {x,y}
  end
end

File.each_line("input/day13") do |line|
  if !folding
    next folding = true if line == ""
    x,y = line.split(',',2).map &.to_i
    dots << {x,y}
  else
    _,axis,n = line.match(/(x|y)=(\d+)/) || {nil,"z",0}
    dots = fold(dots,axis,n.to_i)
    puts "#{dots.size} unique dots"
  end
end

dots.group_by {|(x,y)| y }.to_a.sort.each do |(_,xs)|
  mark = Set.new(xs.map(&.first))
  puts((0..mark.max).map {|i| mark.includes?(i) ? '#' : ' '}.join)
end