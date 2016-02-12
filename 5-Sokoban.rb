class Map
  def initialize(str)
    @map = map_from_str(str)
  end

  private

  def map_from_str(str)
    map = []
    str.each_line do |line|
      map << line.rstrip.chars.map { |char| legend[char] }
    end
    map
  end

  def to_s
    str = ""
    @map.each do |row|
      str << row.map! { |cell| legend.invert[cell] }.join("") << "\n"
    end
    str
  end

  def legend
    {'@' => :player,
     'o' => :crate,
     '#' => :wall,
     ' ' => :empty_space,
     '.' => :storage,
     '*' => :crate_on_storage,
     '+' => :player_on_storage}
  end
end

map_str = ""
File.open('quiz_data/sokoban_levels.txt').each_line do |line|
  unless line.chomp.empty?
    map_str << line
  else
    puts Map.new(map_str)
    break
  end
end

