# There are horrible, horrible things that are happening here...
#
# On a high level, we start with an array of 6 source numbers.
#
# We then generate an array of all possible permutations, which
# brings us to a collection of 1956 arrays of variable length.
#
# For each of the permutations we then generate partitons to reflect
# all the possible orders of mathematical operations.
#
# We then take each of those arrays and
# for each of them we generate all the possible groupings of parentheses /
# groupings of order in which the terms could be combined via mathematical
# operations.
#
# This, assuming source numbers are all unique, gives us 224876 unique partitions.
#
# We then take each of those partitions and transform them into string such as
# "(10 2) 3 (8 5 100)"
#
# Now it is just a matter of gene

require 'set'

class Partitions
  def initialize(permutations)
    @partitions = Set.new

    permutations.each do |source_numbers|
      n = source_numbers.pop
      partition(source_numbers, [n])
      partition(source_numbers, [[n]])
    end
  end

  def to_str_ary
    @partitions.map { |p| partition_to_s(p) }
  end

  private

  def partition(available_numbers, result)
    if available_numbers.empty?
      # Here we have arrays such us [[1, 5], 2, [3], [8, 4]]
      # Single element arrays just cause duplicate calculations
      # down the road, hence better to remove those.
      #
      # We want to go from [[1, 5], 2, [3], [8, 4]] to
      # [[1, 5], 2, 3, [8, 4]]

      @partitions << flatten(result)
    else
      n = available_numbers[-1]
        partition(available_numbers[0...-1], result + [n])
      if result[-1].instance_of? Array
        last_element = result.pop
        partition(available_numbers[0...-1], result << (last_element + [n]))
      else
        partition(available_numbers[0...-1], result + [[n]])
      end
    end
  end

  def flatten(obj)
    if obj.size == 1
      if obj[0].instance_of? Array
        obj[0][0]
      else
        obj[0]
      end
    elsif obj.size == 8 # we got a Fixnum
      obj
    else
      obj.map! { |e| flatten(e) }
    end
  end

  def partition_to_s(p)
    return p.to_s if p.instance_of? Fixnum

    str = ""
    p.each do |e|
      case e
      when Fixnum
        str += "#{e} "
      when Array
        str += '(' + e.join(' ' ) + ') '
      end
    end
    str.chomp(' ')
  end
end

module CalcGenerator
  @@calc = 123
end

rng = Random.new

puts "Generating random values..."
source_numbers = [rng.rand(1..4) * 25]
5.times { source_numbers << rng.rand(1..10) }
puts "Source numbers: " << source_numbers.join(", ")
target = rng.rand(100..999)
puts "Target number: " << target.to_s

permutations = []

1.upto(6) { |i| permutations += source_numbers.permutation(i).to_a }

p permutations.count

partitions = Partitions.new(permutations)
strs = partitions.to_str_ary

p strs[-1]
p CalcGenerator.calc
