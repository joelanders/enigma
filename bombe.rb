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
  #    the bank/register on the other end to true. if it wasn't already set,
  #    recursively repeat this propagation.
  #now, in the test register, if there are:
  #   26 live registers: this rotor state is not self-consistent
  #   1 live register: this rotor state may be (not necessarily) correct
  #   else, the above should be repeated but check one of the registers
  #       that is now unset (this would have been a manual check)

end
