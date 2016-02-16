class MoveNotPermitted < Exception; end

class Map
  def initialize(str)
    @str = str
    @map = map_from_str(str)
  end

  Position = Struct.new(:x, :y) do
    def north
      Position.new(x, y-1)
    end

    def south
      Position.new(x, y+1)
    end

    def east
      Position.new(x+1, y)
    end

    def west
      Position.new(x-1, y)
    end
  end

  def reset
    @map = map_from_str(@str)
  end

  def move_player(direction)
    # We are using a standard array to model the two dimensional grid,
    # hence the vertical dimension is expressed as rows appended to
    # the array and horizontal dimension is expressed as values
    # appended to the row array.
    #
    # Thus, to move north, you would 'climb' the stack of rows by one,
    # that is move to the y-1 row vs current row y, and same with the
    # west <-> east direction, west being -1 and east being +1 vs
    # current index of the position within a given row.

    position = player_position
    new_position = position.send(direction)


    # moving the player if possible
    case self[new_position]
    when :empty_space
      self[new_position] = :player
    when :storage
      self[new_position] = :player_on_storage
    when :crate
      move_crate(new_position, direction)
      self[new_position] = :player
    when :crate_on_storage
      move_crate(new_position, direction)
      self[new_position] = :player_on_storage
    when :wall
      raise MoveNotPermitted
    end

    # updating previous player position to hold correct value
    case self[position]
    when :player
      self[position] = :empty_space
    when :player_on_storage
      self[position] = :storage
    end
  end

  def victory?
    @map.each_with_index do |v, i|
      return false if v.include? :crate
    end
    true
  end

  private

  def move_crate(position, direction)
    new_position = position.send(direction)

    # moving the crate if possible
    case self[new_position]
    when :empty_space
      self[new_position] = :crate
    when :storage
      self[new_position] = :crate_on_storage
    else
      raise MoveNotPermitted
    end

    # updating previous crate position to hold correct value
    case self[position]
    when :storage
      self[position] = :player
    when :crate_on_storage
      self[position] = :player_on_storage
    end
  end

  def player_position
    @map.each_with_index do |v, i|
      return Position.new(v.index(:player), i) if v.include? :player
      return Position.new(v.index(:player_on_storage), i) if v.include? :player_on_storage
    end
  end

  def map_from_str(str)
    map = []
    str.each_line do |line|
      map << line.rstrip.chars.map { |char| legend[char] }
    end
    map
  end

  def [](position)
    @map[position.y][position.x]
  end

  def []=(position, value)
    @map[position.y][position.x] = value
  end

  def to_s
    str = ""
    @map.each do |row|
      str << row.map { |cell| legend.invert[cell] }.join("") << "\n"
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

class Game
  def initialize(map)
    @map = map
  end

  def play
    until map.victory?
      puts "\n#{map}\n"
      puts "Use WSAD keys to move, press x to exit or r to restart level"
      begin
        move(read_char)
      rescue MoveNotPermitted
        puts "\n\n!!! Move not permitted, try again !!!"
      end
    end

    puts "\n#{map}\n"
    puts "Congratulations! You've won!!!" and return
  end

  private
  attr_reader :map

  # Move player with the WSAD buttons
  def move(char)
    case char.downcase
    when 'w'
      map.move_player(:north)
    when 's'
      map.move_player(:south)
    when 'a'
      map.move_player(:west)
    when 'd'
      map.move_player(:east)
    when 'd'
      map.move_player(:east)
    when 'r'
      map.reset
    when 'x'
      exit
    else
      raise MoveNotPermitted
    end
  end

  def read_char
    system "stty raw -echo"
    STDIN.getc
  ensure
    system "stty -raw echo"
  end
end

map_str = ""
File.open('quiz_data/sokoban_levels.txt').each_line do |line|
  unless line.chomp.empty?
    map_str << line
  else
    game = Game.new(Map.new(map_str))
    game.play
    map_str = ""
  end
end

