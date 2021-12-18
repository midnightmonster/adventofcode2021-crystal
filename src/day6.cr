# Tired of the command line ceremony. This input is short so I'll just include it.

INPUT = "1,4,1,1,1,1,1,1,1,4,3,1,1,3,5,1,5,3,2,1,1,2,3,1,1,5,3,1,5,1,1,2,1,2,1,1,3,1,5,1,1,1,3,1,1,1,1,1,1,4,5,3,1,1,1,1,1,1,2,1,1,1,1,4,4,4,1,1,1,1,5,1,2,4,1,1,4,1,2,1,1,1,2,1,5,1,1,1,3,4,1,1,1,3,2,1,1,1,4,1,1,1,5,1,1,4,1,1,2,1,4,1,1,1,3,1,1,1,1,1,3,1,3,1,1,2,1,4,1,1,1,1,3,1,1,1,1,1,1,2,1,3,1,1,1,1,4,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,5,1,1,1,2,2,1,1,3,5,1,1,1,1,3,1,3,3,1,1,1,1,3,5,2,1,1,1,1,5,1,1,1,1,1,1,1,2,1,2,1,1,1,2,1,1,1,1,1,2,1,1,1,1,1,5,1,4,3,3,1,3,4,1,1,1,1,1,1,1,1,1,1,4,3,5,1,1,1,1,1,1,1,1,1,1,1,1,1,5,2,1,4,1,1,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,1,1,1,1,1,2,1,4,4,1,1,1,1,1,1,1,5,1,1,2,5,1,1,4,1,3,1,1"

class Lanternfish
  @population : Array(Int64)

  def initialize(input : String)
    @population = empty_population
    input.split(',').map(&.to_i).each do |i|
      @population[i] += 1
    end
  end

  def day
    tomorrow = empty_population
    @population.each_with_index do |v,i|
      case i
      when 0
        tomorrow[8] += v
        tomorrow[6] += v
      else
        tomorrow[i-1] += v
      end
    end
    @population = tomorrow
  end

  def total
    @population.sum
  end

  def empty_population
    Array(Int64).new(9,0)
  end
end

fish = Lanternfish.new(INPUT)
(1..256).each do |day|
  fish.day
  puts "Population: #{fish.total} after #{day} days" if day == 80 || day == 256
end
