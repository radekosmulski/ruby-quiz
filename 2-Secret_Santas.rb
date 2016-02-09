# The most trivial, simple implementation possible...
# May the power of randomness be on our side

SecretSanta = Struct.new(:first_name, :last_name, :email) do
  def to_s
    "#{first_name} #{last_name}"
  end

  def same_family_as?(santa)
    # this will also capture a situation where a person
    # gets assigned to themselves
    last_name == santa.last_name
  end
end

santa_pick_pool = []

File.open('quiz_data/secret_santas.txt') do |file|
  file.each_line do |line|
    matchdata = line.match(/(^\w+)\s(\w+)\s<(.+)>/).to_a
    santa_pick_pool << SecretSanta.new(*matchdata[1..3])
  end
end

while true do
  assignments = santa_pick_pool.dup.shuffle

  break if santa_pick_pool.zip(assignments).none? do |santa, giftee| 
    santa.same_family_as? giftee
  end
end

puts "Santas have been assigned the following giftees:"
santa_pick_pool.zip(assignments).each do |santa, giftee|
  puts "#{santa} => #{giftee}"
end
