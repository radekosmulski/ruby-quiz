##
# Encrypting a string

DECK = (1..52).to_a + ["A", "B"]

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

def split(str)
  # discards non-letter characters
  # uppercases all remaining letters
  # splits msg into 5 character groups, padding last group with Xs if necessary
end

def generate_keystream(str)
end

def generate_keystream_letter(char)
end

def convert_to_numbers(str)
  # converts A-Z characters to numbers, with A=1, B=2, etc
end

def add_stream_numbers(str1, str2)
  # presented with two strings containing numbers in groupings seperated by
  # spaces, will sum each pair of numbers together subtracting 26 should
  # a sum exceed 26
end

def key(deck)
  # do nothing - we do not want the deck keyed for testing purposes
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


msg = "something"

def encrypt msg
  msg = split msg
  keystream = generate_keystream msg

  msg = convert_to_numbers msg
  keystream = convert_to_numbers keystream

  add_stream_numbers msg, keystream
end

