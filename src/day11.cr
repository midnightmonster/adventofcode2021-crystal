class OctoGrid
  @grid : Array(Array(Octopus))

  def initialize(input : String)
    @grid = input.split("\n").map {|line| line.chars.map {|c| Octopus.new(c.to_i) } }
  end

  def width
    @grid[0].size
  end

  def height
    @grid.size
  end

  def [](x : Int32, y : Int32) : Octopus | Nil
    return nil if x < 0 || y < 0
    @grid[y]?.try {|row| row[x]? }
  end

  def points
    xmax = width - 1
    ymax = height - 1
    x = -1
    y = 0
    Iterator.of do
      x += 1
      if x > xmax
        x = 0
        y += 1
      end
      next Iterator.stop if y > ymax
      {self[x,y], x, y}
    end
  end

  def incr_all
    points.each {|oct,_,_| oct.try &.incr }
  end

  def all_flashes
    count = 0
    while((more = flash_pass) > 0)
      count += more
    end
    count
  end

  def flash_pass
    points.reduce(0) do |memo,(oct,x,y)|
      next memo unless oct.try &.flash!
      (-1..1).each do |dx|
        (-1..1).each do |dy|
          next if dx==0 && dy==0
          self[x+dx,y+dy].try &.boost
        end
      end
      memo + 1
    end
  end
end

class Octopus
  def initialize(@energy : Int32)
  end

  def incr
    @energy += 1
  end

  def boost
    @energy += 1 unless @energy == 0
  end

  def flash!
    return false unless @energy > 9
    @energy = 0
    return true
  end

  def to_s
    @energy
  end
end

INPUT = "5651341452
1381541252
1878435224
6814831535
3883547383
6473548464
1885833658
3732584752
1881546128
5121717776"

grid = OctoGrid.new(INPUT)

# Part 1
# flashes = 100.times.reduce(0) do |sum,_|
#   grid.incr_all
#   sum + grid.all_flashes
# end
# puts "#{flashes}"

# Part 2
sync_step = (1..).find do |step|
  grid.incr_all
  grid.all_flashes == 100
end
puts "Sync on #{sync_step}"