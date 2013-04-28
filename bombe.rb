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
    loop do
      if test_position(4)
        return iteration
        break
      else
        iteration += 1
        step_all!
      end
    end
  end

end
