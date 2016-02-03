class Deck
  def initialize
    @cards = (1..52).to_a + ["A", "B"] # A and B being jokers,
                                       # both with a value of 53
  end

  def move_joker_A
    # Moves joker A down 1 card
    joker_i = @cards.index("A")
    if joker_i == 53
      @cards.pop
      @cards.insert(1, "A")
    else
      @cards.delete_at(joker_i)
      @cards.insert(joker_i + 1, "A")
    end
  end

  def move_joker_B
    # Moves joker B down 2 cards
    joker_i = @cards.index("B")
    if joker_i == 53
      @cards.pop
      @cards.insert(2, "B")
    elsif joker_i == 52
      @cards.delete_at(joker_i)
      @cards.insert(1, "B")
    else
      @cards.delete_at(joker_i)
      @cards.insert(joker_i + 2, "B")
    end
  end

  def triple_cut
    # Perform a triple cut around the two jokers. All cards above the top joker
    # move to below the bottom joker and vice versa. The jokers and the cards
    # between them do not move.
    i_A = @cards.index("A")
    i_B = @cards.index("B")

    smaller_i = i_A < i_B ? i_A : i_B
    bigger_i = smaller_i == i_B ? i_A : i_B

    cards_above_top_joker = @cards.slice!(0..smaller_i-1)
    cards_below_bottom_joker = @cards.slice!(bigger_i+1-smaller_i..54)

    @cards.unshift(*cards_below_bottom_joker)
    @cards.concat(cards_above_top_joker)
  end

  def count_cut
    # Perform a count cut using the value of the bottom card. Cut the bottom
    # card's value in cards off the top of the deck and reinsert them just above
    # the bottom card
    cut_value = card_value(@cards[-1])

    cards_off_top = @cards.slice!(0...cut_value)
    @cards.insert(-2, *cards_off_top)
  end

  def card_value(card)
    card_value = card.to_i

    return 53 if card_value == 0 # 0 means we got one of the jokers
    card_value
  end

  def output_card
    @_output_card ||= @cards[card_value(top_card)]
  end

  def output_card_value
    # not outputting anything when we get a joker
    if output_card == 'A' or output_card == 'B'
      nil
    else
      card_value(output_card)
    end
  end

  def next_output_card_value
    move_joker_A
    move_joker_B
    triple_cut
    count_cut

    if output_card_value
      output_card
    else
      next_output_card_value
    end
  end

  def top_card
    @cards[0]
  end
end

class Encrypter
  def initialize
    @deck = Deck.new
  end

  def encrypt(msg)
    str = prepare_for_encryption(msg)
    keystream = generate_keystream_for(str)

    str = letters_to_numbers(str)
    keystream = letters_to_numbers(keystream)

    numbers_to_letters(combine_streams(str, keystream, :sum))
  end

  def decrypt(encrypted_msg)
    keystream = generate_keystream_for(encrypted_msg)

    str = letters_to_numbers(encrypted_msg)
    keystream = letters_to_numbers(keystream)

    numbers_to_letters(combine_streams(str, keystream, :difference))
  end

  def reset_deck
    @deck = Deck.new
  end

  private

  def prepare_for_encryption(msg)
    # preparing the msg for encryption
    msg.gsub!(/[^a-z]/i, "") # removing non letter characters
    msg.upcase!

    # splitting the message into groups of 5 characters padded
    # with Xs if necessary, ie: RADEK ISAWE SOMEX
    ary = msg.scan(/\w{1,#{5}}/)
    ary[-1] = ary[-1].ljust(5, 'X')
    ary.join(" ")
  end

  def generate_keystream_for(str)
    chars_needed = str.gsub(/\s/, "").size
    keystream = ""

    until keystream.size == chars_needed
      keystream += to_letter(@deck.next_output_card_value)
    end

    keystream.scan(/.{5}/).join(" ")
  end

  def to_number(char)
    char.ord - 64
  end

  def to_letter(n)
    n -= 26 if n > 26
    (n+64).chr
  end

  def letters_to_numbers(str)
    str.chars.map do |char|
      if char == " "
        " "
      else
        " #{to_number(char)} "
      end
    end.join
  end

  def numbers_to_letters(str)
    str.scan(/\d+/).map do |str|
      to_letter(str.to_i)
    end.join.scan(/.{5}/).join(" ")
  end

  def combine_streams(keystream1, keystream2, operation=:sum)
    # presented with two strings containing numbers in groupings seperated by
    # spaces, will sum each pair of numbers together subtracting 26 should
    # a sum exceed 26, or perform the operation in the other direction (subtraction)
    case operation
    when :sum
      calculation = ->(v1, v2) { v1 += v2; v1 -= 26 if v1 > 26; " #{v1} " }
    when :difference
      calculation = ->(v1, v2) { v1 -= v2; v1 += 26 if v1 < 26; " #{v1} " }
    end

    keystream1 = keystream1.split.map { |str| str.to_i }
    keystream2 = keystream2.split.map { |str| str.to_i }

    keystream1.zip(keystream2).map do |v1, v2|
      calculation.call(v1, v2)
    end.each_slice(5).to_a.map { |slice| slice.join() }.join(" ")
  end
end

e = Encrypter.new
msg = "I like milk chocolate!"
puts "Original message: #{msg}"
encrypted_msg = e.encrypt msg
puts "Encrypted message: #{encrypted_msg}"
e.reset_deck
decrypted_msg =  e.decrypt encrypted_msg
puts "Decrypted message: #{decrypted_msg}"
