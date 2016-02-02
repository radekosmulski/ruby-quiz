##
# Encrypting a string

deck = (1..52).to_a + ["A", "B"]

##
# A bit of background on how the deck of cards works:
#
# "Solitaire needs a full deck of 52 cards and the two jokers. The jokers need
# to be visually distinct and I'll refer to them below as A and B. Some steps
# involve assigning a value to the cards. In those cases, use the cards face
# value as a base, Ace = 1, 2 = 2... 10 = 10, Jack = 11, Queen = 12, King = 13.
# Then modify the base by the bridge ordering of suits, Clubs is simply the
# base value, Diamonds is base value + 13, Hearts is base value + 26, and
# Spades is base value + 39. Either joker values at 53. When the cards must
# represent a letter Clubs and Diamonds values are taken to be the number of
# the letter (1 to 26), as are Hearts and Spades after subtracting 26 from
# their value (27 to 52 drops to 1 to 26)."

def prepare_for_encryption(msg)
  str = remove_non_letter_characters(msg)
  str.upcase!
  split_into_char_groups(str, 5, 'X')
end

def remove_non_letter_characters(str)
  str.gsub(/[^a-z]/i, "")
end


def split_into_char_groups(str, chars_per_group, padding_char)
  ary = str.scan(/.{1,#{chars_per_group}}/)
  ary[-1] = ary[-1].ljust(5, 'X')
  ary.join(" ")
end

def convert_to_number char
  char.ord - 64
end

def convert_to_letter n
  n -= 26 if n > 26
  (n+64).chr
end

def convert_to_numbers str
  str.chars.map do |char| 
    if char == " "
      " "
    else
      " #{convert_to_number(char)} " 
    end
  end.join
end

def convert_to_letters str
  str.scan(/\d+/).map do |str| 
    convert_to_letter(str.to_i)
  end.join.scan(/.{5}/).join(" ")
end

def generate_keystream(str, deck)
  chars_needed = str.gsub(/\s/, "").size
  keystream = ""
  
  deck = key(deck)

  until keystream.size == chars_needed
    move_joker_A(deck)
    move_joker_B(deck)
    deck = triple_cut(deck)
    deck = count_cut(deck)
    output_letter = find_output_letter(deck)
    keystream += output_letter if output_letter
  end
  
  keystream.scan(/.{5}/).join(" ")
end

def add_streams(keystream1, keystream2)
  # presented with two strings containing numbers in groupings seperated by
  # spaces, will sum each pair of numbers together subtracting 26 should
  # a sum exceed 26
  keystream1 = keystream1.split.map { |str| str.to_i }
  keystream2 = keystream2.split.map { |str| str.to_i }
  
  keystream1.zip(keystream2).map do |v1, v2|
    v1 += v2 
    v1 -= 26 if v1 > 26
    " #{v1} "
  end.each_slice(5).to_a.map { |slice| slice.join() }.join(" ")
end

def key(deck)
  # do nothing - we do not want the deck keyed for testing purposes
   deck
end

def move_joker_A(deck)
  # Moves joker A down 1 card
  joker_i = deck.index("A")
  if joker_i == 53
    deck.pop
    deck.insert(1, "A")
  else
    deck.delete_at(joker_i)
    deck.insert(joker_i + 1, "A")
  end
end

def move_joker_B(deck)
  # Moves joker B down 2 cards
  joker_i = deck.index("B")
  if joker_i == 53
    deck.pop
    deck.insert(2, "B")
  elsif joker_i == 52
    deck.delete_at(joker_i)
    deck.insert(1, "B")
  else
    deck.delete_at(joker_i)
    deck.insert(joker_i + 2, "B")
  end
end

def triple_cut(deck)
  # Perform a triple cut around the two jokers. All cards above the top joker
  # move to below the bottom joker and vice versa. The jokers and the cards
  # between them do not move.
  i_A = deck.index("A")
  i_B = deck.index("B")

  smaller_i = i_A < i_B ? i_A : i_B
  bigger_i = smaller_i == i_B ? i_A : i_B

  cards_above_top_joker = deck.slice!(0..smaller_i-1)
  cards_below_bottom_joker = deck.slice!(bigger_i+1-smaller_i..54)

  deck.unshift(*cards_below_bottom_joker)
  deck.concat(cards_above_top_joker)
end

def count_cut(deck)
  # Perform a count cut using the value of the bottom card. Cut the bottom
  # card's value in cards off the top of the deck and reinsert them just above
  # the bottom card.
  cut_value = card_value(deck[-1])

  cards_off_top = deck.slice!(0...cut_value)
  deck.insert(-2, *cards_off_top)
end

def card_value(card)
  card_value = card.to_i

  return 53 if card_value == 0 # 0 means we got one of the jokers
  card_value
end

def find_output_letter(deck)
  cards_to_count_down = card_value(deck[0])
  output_card = deck[cards_to_count_down]

  if output_card == 'A' or output_card == 'B'
    nil
  else
    convert_to_letter(card_value(output_card))
  end
end

def encrypt msg, deck
  msg = prepare_for_encryption msg
  keystream = generate_keystream msg, deck

  msg = convert_to_numbers msg
  keystream = convert_to_numbers keystream
  
  str = add_streams msg, keystream

  convert_to_letters str
end

msg = "YOURC IPHER ISWOR KINGX"
puts encrypt(msg, deck)
