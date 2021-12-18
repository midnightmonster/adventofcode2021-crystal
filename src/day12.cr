INPUT = "yw-MN
wn-XB
DG-dc
MN-wn
yw-DG
start-dc
start-ah
MN-start
fi-yw
XB-fi
wn-ah
MN-ah
MN-dc
end-yw
fi-end
th-fi
end-XB
dc-XB
yw-XN
wn-yw
dc-ah
MN-fi
wn-DG"

cons = INPUT.split(/\n|-/).in_groups_of(2,"").reduce(
  Hash(String,Set(String)).new {|h,k| h[k] = Set(String).new }
) do |h,(a,b)|
  # two-way connections except never link back to start
  h[a] << b unless "start" == b
  h[b] << a unless "start" == a
  h
end

def traverse(cons,node,visited = Set(String).new)
  return 1 if node == "end"
  possible = cons[node]
  available = possible - visited
  return 0 if available.size == 0
  visited << node unless /^[A-Z]+$/.match(node)
  return available.sum {|n| traverse(cons,n,visited.dup) }
end

puts "#{traverse(cons,"start")} possible paths"

def traverse2(cons,node,visited = Set(String).new)
  return 1 if node == "end"
  possible = cons[node]
  visited << node unless /^[A-Z]+$/.match(node)
  return possible.sum do |n|
    next traverse2(cons,n,visited.dup) unless visited.includes?(n)
    traverse(cons,n,visited.dup)
  end
end

puts "#{traverse2(cons,"start")} possible paths when revisiting one small cave"