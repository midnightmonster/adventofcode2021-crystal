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
  h[a] << b
  h[b] << a
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

paths = traverse(cons,"start")

puts "#{paths} possible paths"