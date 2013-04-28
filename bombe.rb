require './enigma.rb'

class Bombe
  attr_accessor :array
  # let's try the crib 'afeturh' -> 'feturhe',
  # which has a cycle e-2-t-3-u-4-r-5-h-6-e
  # we need 5 enigmas, spaced one apart from each other
  # (one apart due to the way I found that crib)
  def self.testConfig
    array = (1..5).map {Enigma.fromMostBasicSettings}
    array.each_with_index do |enigma, index|
      index.times {enigma.step!}
    end
    new_bombe = self.new
    new_bombe.array = array
    new_bombe
  end

  def test_position(orig_position)
    temp_position = orig_position
    (0..4).each do |i|
      temp_position = array[i].encipher_without_step(temp_position)
    end
    temp_position == orig_position #if false, current state non-self-consistent
  end

  def step_all!
    array.each {|e| e.step!}
  end

  def test_until_valid!
    iteration = 0
    good = []
    # actual bombe didn't step rotors like the enigma did,
    # but rather like an odometer would, so this isn't quite
    # correct.
    17576.times do
      if test_position(4)
        good << iteration
      end
      iteration += 1
      step_all!
    end
   good
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
    attr_accessor :banks

    def set_register_pair(b_num, r_num)
      banks[b_num].set_register(r_num)
      banks[r_num].set_register(b_num)
    end

    def test_hypothesis(b_num, r_num)
      set_register_pair(b_num, r_num)
      banks[b_num].num_of_live_wires < 26
    end
  end

  class Bank
    attr_accessor :number, :plug_halves, :registers

    def set_register(r_num)
      unless registers[r_num]
        set_register_pair(number, r_num) #TODO: better OO here?
        plug_halves.each {|ph| ph.encipher_and_set_target_register(r_num)}
      end
    end

    def num_of_live_wires
      registers.select {|r| !!r}.count
    end
  end

  class PlugHalf
    attr_accessor :enigma, :target_bank

    def encipher_and_set_target_register(letter)
      target_bank.set_register( enigma.encipher_without_step(letter) )
    end
  end

end
