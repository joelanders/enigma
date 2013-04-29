require './enigma.rb'

class Bombe
  attr_accessor :db, :banks, :plug_halves

  # let's try the crib 'afeturh' -> 'feturhe',
  # which has a cycle e-2-t-3-u-4-r-5-h-6-e
  def self.testConfig
    bombe = Bombe.new
    bombe.db = DiagonalBoard.new
    bombe.db.add_plugs [[4,19,2], [19,20,3], [20,17,4], [17,7,5], [7,4,6]]
    bombe
  end

  def to_s
    'a bombe'
  end

end

#with stecker
#let's call them 'banks' on the diagonal board (the capital letters in the diagram)
#each bank knows its 'connected to other bank X via enigma Y' pairings and has
#    26 true/false registers representing the possible stecker values.
#bank with most conncted enigmas is the 'test bank'
#pick a letter on the test bank, and for each connected enigma, encrypt it and set
#    the bank/register on the other end AND the register in the other bank
#    that's steckered to this one. (eg. set the X-y register and the Y-x register.)
#    if it wasn't already set, recursively repeat this propagation.
#now, in the test register, if there are:
#   26 live registers: this rotor state is not self-consistent
#   1 live register: this rotor state may be (not necessarily) correct
#   else, the above should be repeated but check one of the registers
#       that is now unset (this would have been a manual check)
###
#
#So let's input the menu as a bunch of triplets. Eg. [[a,j,5],...] would
#mean A and J cipher to each other at relative position 5.
#Internally, for each input triplet, we make a reference in bank A and
#in bank J to the enigma with displacement 5 and to other bank. (so
#the entry in bank A would be like [enigma5, J] and the entry in bank
#J would be like [enigma5, A].
#
#To begin, we find the bank with the most references, and set some
#stecker-register within it to true ALONG WITH the register in the
#associated bank according to the diagonal board. Now, send that letter
#through the first enigma in that bank. We get a ciphered letter, which
#is the register in the target bank that we want to set to true. If
#it is already true, stop (and continue with remaining enigmas). Else,
#repeat this procedure recursively from that bank/register.
#
#After we've sent the test letter through every enigma in the test bank,
#and have propogated the result, we do the check on the number of live
#registers in the test bank.

class DiagonalBoard
  attr_accessor :banks, :enigmas

  def initialize
    @banks = []
    26.times do
      banks << Bank.new
    end

    @enigmas = []
  end

  # plugs look like [[x, y, 5], ...]
  def add_plugs(plugs)
    plugs.each do |a, b, pos|
      enigma = Enigma.fromMostBasicSettings
      enigma.set_odo_pos!(pos)
      enigmas << enigma

      banks[a].plug_halves << PlugHalf.new(enigma, b, self)
      banks[b].plug_halves << PlugHalf.new(enigma, a, self)
    end
  end
  
  def set_diagonal_pair(a, b)
    banks[a].set_register(b)
    banks[b].set_register(a)
  end

  def test_hypothesis(b_num, r_num)
    set_diagonal_pair(b_num, r_num)
    banks[b_num].num_of_live_wires < 26
  end

  def test_until_stop(b_num, r_num)
    unless test_hypothesis(b_num, r_num)
      enigmas.each {|e| e.step_like_odometer}
    end
  end
end

class Bank
  attr_accessor :plug_halves, :registers

  def initialize
    @plug_halves = []
    @registers = Array.new(26)
  end

  def set_register(r_num)
    unless registers[r_num]
      registers[r_num] = true
      plug_halves.each {|ph| ph.encipher_and_set_diagonal_pair(r_num)}
    end
  end

  def num_of_live_wires
    registers.select {|r| !!r}.count
  end
end

class PlugHalf
  attr_accessor :enigma, :target_bank, :diagonal_board

  def initialize(enigma, target_bank, diagonal_board)
    @enigma = enigma
    @target_bank = target_bank
    @diagonal_board = diagonal_board
  end

  def encipher_and_set_diagonal_pair(letter)
    enciphered_letter = enigma.encipher_without_step(letter)
    diagonal_board.set_diagonal_pair(target_bank, enciphered_letter)
  end
end
