# Regexp.build is a class method that takes an arbitrary number of parameters.
# Parameters can either be integers or ranges of integers.
#
# A string can be matched against the returned object using String#=~ and will
# return true if it matches and false otherwise (as per the examples provided).
#
# The reasonable way to solve the quiz would be getting Regexp.build to return
# an instance of class Regexp... I however wanted to see if I can
# achieve the desired behavior in a slightly more roundabout though probably
# easier to implement way.
#
# Desired behavior:
#
#  lucky = Regexp.build( 3, 7 )
#  "7" =~ lucky # => true
#  "13" =~ lucky # => false
#  "3" =~ lucky # => true
#
#  month = Regexp.build( 1..12 )
#  "0" =~ month # => false
#  "1" =~ month # => true
#  "12" =~ month # => true
#  day = Regexp.build( 1..31 )
#  "6" =~ day # => true
#  "16" =~ day # => true
#  "Tues" =~ day # => false
#  year = Regexp.build( 98, 99, 2000..2005 )
#  "04" =~ year # => false
#  "2004" =~ year # => true
#  "99" =~ year # => true
#
#  num = Regexp.build( 0..1_000_000 )
#  "-1" =~ num # => false

class Regexp
  def self.build(*args)
    IntegerMatcher.new(*args)
  end
end

class IntegerMatcher
  def initialize(*args)
    @args = args
  end

  def match(int)
    @args.each do |arg|
      if arg.instance_of? Fixnum
        return true if int == arg
      elsif arg.instance_of? Range
        return true if arg.member? int
      end
    end

    false
  end
end

class String
  alias_method :old_match, :=~

  def =~(obj)
    if obj.instance_of? IntegerMatcher
      int = Integer(self) rescue nil
      return false unless int

      obj.match(int)
    else
      old_match(obj)
    end
  end
end

