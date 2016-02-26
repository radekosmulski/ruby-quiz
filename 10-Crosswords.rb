class Square
  attr_reader :row, :column, :visible
  attr_accessor :north, :south, :east, :west, :blank

  def initialize(row, column, blank = true)
    @row, @column = row, column
    @blank = blank
  end

  def neighbors
    list = []
    list << north if north
    list << south if south
    list << east if east
    list << west if west
    list
  end

  def visible
    return true if blank
    return false
  end
end

class Crossword

  def initialize(line_ary)
    prepare_grid(line_ary)
    @rows = @grid.size
    @columns = @grid[0].size

    configure_squares
  end

  def prepare_grid(line_ary)
    @grid = line_ary.each_with_index.map do |line, i|
      line.split.each_with_index.map do |char, j|
        if char == ?_
          Square.new(i, j)
        elsif char == ?X
          Square.new(i, j, false)
        end
      end
    end
  end

  def configure_squares
    each_square do |square|
      row, col = square.row, square.column

      square.north = self[row - 1, col]
      square.south = self[row + 1, col]
      square.west = self[row, col - 1]
      square.east = self[row, col + 1]
    end
  end

  def [](row, column)
    return nil unless row.between?(0, @rows - 1)
    return nil unless column.between?(0, @grid[row].count - 1)
    @grid[row][column]
  end

  def each_row
    @grid.each do |row|
      yield row
    end
  end

  def each_square
    each_row do |row|
      row.each do |square|
        yield square
      end
    end
  end

  def to_s
    # We can divide outputted characters per square as follows:
    #
    # top   =  1| 2  |3
    #          --------
    # mid   =  4| 5  |6
    # mid   =   |    |
    #          --------
    # bot   =  7| 8  |9
    #
    #   1 - top_left
    #   2 - top_mid
    #   3 - top_right
    #   4 - mid_left
    #   ...etc
    #

    output =  ''

    each_row do |row|
      top= ''
      mid = ''
      bot = ''

      row.each do |sq|
        top += top_left(sq) + top_mid(sq) + top_right(sq)
        mid += mid_left(sq) + mid_mid(sq) + mid_right(sq)
        bot += bot_left(sq) + bot_mid(sq) + bot_right(sq)
      end

      output << top << "\n" << mid << "\n" << mid << "\n"
      output << bot << "\n" unless bot.empty?
    end
    output

  end

  def top_left(sq)
    if sq.visible
      '#'
    else
      if sq.west.visible || (sq.north && sq.north.visible) \
              || (sq.north && sq.north.west && sq.north.west.visible)
        '#'
      else
        ' '
      end
    end
  end

  def top_mid(sq)
    if sq.visible || (sq.north && sq.north.visible)
      '####'
    else
      '    '
    end
  end

  def top_right(sq)
    unless sq.east
      if sq.visible
        '#'
      elsif sq.north && sq.north.visible
        '#'
      else
        ' '
      end
    else
      ''
    end
  end

  def mid_left(sq)
    if sq.visible
      '#'
    else
      if sq.west.visible
        '#'
      else
        ' '
      end
    end
  end

  def mid_mid(sq)
    if sq.visible
      '    '
    else
      '    '
    end
  end

  def mid_right(sq)
    unless sq.east
      if sq.visible
        '#'
      else
        ' '
      end
    else
      ''
    end
  end

  def bot_left(sq)
    unless sq.south
      if sq.visible || sq.west && sq.west.visible
        '#'
      else
        ' '
      end
    else
      ''
    end
  end

  def bot_mid(sq)
    unless sq.south
      if sq.visible
        '####'
      else
        '    '
      end
    else
      ''
    end
  end

  def bot_right(sq)
    unless sq.south or sq.east
      if sq.visible
        '#'
      else
        ' '
      end
    else
      ''
    end
  end

end

ARGV << 'quiz_data/ruby-quiz.layout' if ARGV.empty?
line_ary = ARGF.readlines

crossword = Crossword.new(line_ary)

puts crossword
