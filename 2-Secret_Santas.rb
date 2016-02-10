# The most trivial, simple implementation possible...
# May the power of randomness be on our side

SecretSanta = Struct.new(:first_name, :last_name, :email) do
  def to_s
    "#{first_name} #{last_name}"
  end

  def can_be_santa_of?(santa)
    last_name != santa.last_name
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

  break if santa_pick_pool.zip(assignments).all? do |santa, giftee| 
    santa.can_be_santa_of? giftee
  end
end

puts "Santas have been assigned the following giftees:"
santa_pick_pool.zip(assignments).each do |santa, giftee|
  puts "#{santa} => #{giftee}"
end
