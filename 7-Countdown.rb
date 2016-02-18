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
# orders in which the terms could be combined via mathematical
# operations.
#
# This, assuming source numbers are all unique, gives us 224876 unique partitions.
#
# We then take each of those partitions and transform them into string such as
# "(10 2) 3 (8 5 100)"
#
# Now it is just a matter of replacing each whitespace with a mthematical operator
# and evaluating the expressions...
#
# (there will be unnecessary duplicated calculations where parenthesis do not
# change anything such as "(1 + 2) + 3" and "1 + (2 + 3)")
#
# Also, this approach will give you the right answer but it is so inefficient
# and the search space is so big you might want to grab a coffee... preferably
# a tall one :P Given the parentheses and strings approach there is no simple
# way that I can think of to prune the search space...

require 'set'

class Partitions
  # this whole class is a mess... would warrant refactoring, likely to Partition
  # class and having some reasonable way of working with collections of instances
  # of class Partition...
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

class Calculation
  def initialize(calc_string)
    @str = calc_string
  end

  def value
    @value ||= eval(@str)
  end

  def str
    @str
  end
end

OPERATIONS = ['+', '-', '*', '.to_f/']
def str_to_calcs(str)
  calcs = [str]
  results = []

  5.times do
    calcs.each do |str|
      OPERATIONS.each do |op|
        results << str.sub(/ /, op)
      end
    end
    calcs = results
    results = []
  end
  calcs.map { |str| Calculation.new(str) }
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

partitions = Partitions.new(permutations)

strs = partitions.to_str_ary
# we have a large array of strs here, where each
# string in the array is of the format
# "(1 1) 1 (1 1 1)" (parentheses can vary), we now
# need to replace blank spaces with mathematical
# operations...

calculations = []
strs.each_with_index do |str, i|
  calculations.concat(str_to_calcs(str))
end

delta = Float::INFINITY
solutions = []

calculations.each do |c|
  next if c.value < 100
  next if c.value % 1 != 0 # we don't want fractional results

  current_delta = (target - c.value).abs

  if current_delta < delta
    delta = current_delta
    solutions = [c]
  elsif current_delta == delta
    solutions << c
  end
end

puts "Smallest delta achieved: #{delta}"
puts "Solutions found: #{solutions.count}"
puts "10 example solutions (if at least that many were found):"
solutions.take(10).each_with_index { |s, i| puts "#{i + 1}. #{s.str}" }

