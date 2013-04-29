Alphabet = 'abcdefghijklmnopqrstuvwxyz'
AlphabetInts = 0..Alphabet.length
AlphabetLetterToInt = Hash[ Alphabet.split('').zip(AlphabetInts) ]
AlphabetIntToLetter = Hash[ AlphabetInts.zip(Alphabet.split('')) ]

class Enigma
  attr_accessor :rotors, :positions, :reflector, :plugboard
  NumOfRotors = 3
  #knows rotors, relative positions, reflector
  #knows how to step rotors

  def self.fromMostBasicSettings
    rotors = [ Rotor.fromPreset(1),
               Rotor.fromPreset(2),
               Rotor.fromPreset(3) ]
    positions = [0,0,0]
    reflector = Reflector.fromPreset(2)
    new_enigma = self.new
    new_enigma.rotors = rotors
    new_enigma.positions = positions
    new_enigma.reflector = reflector
    new_enigma
  end

  def self.basic_with_plugs
    enigma = self.fromMostBasicSettings
    enigma.plugboard = Plugboard.ten_plugs
    enigma
  end

  def set_odo_pos!(pos)
    self.positions = [0,0,0]
    pos.times {step_like_odometer!}
  end

  def step_like_odometer!
    positions[0] = (positions[0] + 1) % 26
    if positions[0] == 0
      positions[1] = (positions[1] + 1) % 26
      if positions[1] == 0
        positions[2] = (positions[2] + 1) % 26
      end
    end
  end

  def encipher_string!(string)
    string.downcase.split('').map{|c| AlphabetLetterToInt[c]}.
                              map{|c| encipher!(c)}.
                              map{|c| AlphabetIntToLetter[c]}.join
  end

  def encipher!(entrance_pos)
    step! #the rotors step before enchiphering
    encipher_without_step(entrance_pos)
  end

  def encipher_without_step(entrance_pos)
    if plugboard
      t = plugboard.rtol[ entrance_pos ]
    else
      t = entrance_pos
    end

    t = (t + positions[0])%26              # R position on first rotor
    t = rotors[0].rtol[ t ]                # L position on first rotor
    t = (t - positions[0])%26   #enigma-relative position after first rotor

    t = (t + positions[1])%26              # R position on second rotor
    t = rotors[1].rtol[ t ]                # L position on second rotor
    t = (t - positions[1])%26   #enigma-relative position after second rotor

    t = (t + positions[2])%26              # R position on third rotor
    t = rotors[2].rtol[ t ]                # L position on third rotor
    t = (t - positions[2])%26   #enigma-relative position after third rotor

    t = reflector.rtol[ t ]     #enigma-relative position after reflector

    t = (t + positions[2])%26              # L position on third rotor
    t = rotors[2].ltor[ t ]                # R position on third rotor
    t = (t - positions[2])%26   #enigma-relative position after third rotor (rightward)

    t = (t + positions[1])%26              # L position on second rotor
    t = rotors[1].ltor[ t ]                # R position on second rotor
    t = (t - positions[1])%26   #enigma-relative position after second rotor (rightward)

    t = (t + positions[0])%26              # L position on first rotor
    t = rotors[0].ltor[ t ]                # R position on first rotor
    t = (t - positions[0])%26   #enigma-relative position after first rotor (rightward)

    if plugboard
      t = plugboard.ltor[ t ]
    end

    t
  end

  # rightmost rotor always steps, middle rotor steps when it or the
  # rightmost rotor is at a notch, leftmost rotor steps if the middle
  # rotor is at a notch
  def step!
    if rotors[1].notches.include? positions[1]        #if middle rotor at a notch
      positions[2] = (positions[2] + 1) % 26          #step leftmost rotor
    end
    if ((rotors[1].notches.include? positions[1]) ||  #if middle rotor at a notch OR
       ( rotors[0].notches.include? positions[0]))    #if rightmost rotor at a notch
      positions[1] = (positions[1] + 1) % 26          #step middle rotor
    end
    positions[0] = (positions[0] + 1) % 26            #always step rightmost rotor
  end
end


#converts right-side position to left-side position
#  and vice versa
class Substitutor
  attr_accessor :rtol, :ltor

  # eg. input of "CAB" would make a substitutor whose
  # RToL map would be A -> C, B -> A, C -> B, and whose
  # LToR map would be A -> B, B -> C, C -> A
  # (they are inverse mappings of each other)
  # (input rep.s the L-side 'output' for every pos.
  #   given Alphabet as R-side 'input.'
  def self.fromString(string)
    in_ints = string.downcase.split('').map {|c| AlphabetLetterToInt[c] }
    rtol = Hash[ AlphabetInts.zip(in_ints) ]
    ltor = Hash[ in_ints.zip(AlphabetInts) ]
    new_sub = self.new
    new_sub.rtol = rtol
    new_sub.ltor = ltor
    new_sub
  end
end

class Rotor < Substitutor
  attr_accessor :notches
  #doesn't know its stepping position relative to other rotors.
  #knows its notches
  #only knows position -> position mapping 'within' itself

  Presets = [ 'EKMFLGDQVZNTOWYHXUSPAIBRCJ',
              'AJDKSIRUXBLHWTMCQGZNPYFVOE',
              'BDFHJLCPRTXVZNYEIWGAKMUSQO',
              'ESOVPZJAYQUIRHXLNFTGKDCMWB',
              'VZBRGITYUPSDNHLXAWMJQOFECK',
              'JPGVOUMFYQBENHZRDKASXLICTW',
              'NZJHGRCXMYSWBOUFAIVLPEKQDT',
              'FKQHTLXOCBJSPDZRAMEWNIUYGV' ]

  # for now, pretend there is only this one combination of notches.
  Notches = [ [16], [4], [0] ] #third notch not used

  # number is indexed starting from 1 (convention)
  def self.fromPreset(number)
    new_rotor = self.fromString( Presets[number - 1] )
    new_rotor.notches = Notches[number -1]
    new_rotor
  end
end

class Reflector < Substitutor
  #like a rotor with no notches?
  #also, there's only 1 direction TODO: deal with this
  #additional constraint that a position on one side
  #  must not map to the same position on the other side

  Presets = [ 'EJMZALYXVBWFCRQUONTSPIKHGD',
              'YRUHQSLDPXNGOKMIEBFZCWVJAT',
              'FVPJIAOYEDRZXWGCTKUQSBNMHL' ]

  # reflectors referred to as A, B, C, but let's call
  # them 1, 2, 3 for now
  def self.fromPreset(number)
    self.fromString( Presets[number - 1] )
  end
end

class Plugboard < Substitutor
  #like a rotor with no notches whose internal wiring
  #  is not fixed, but decided at runtime
  #additional constraint that ltor and rtol mappings
  #  are the same.
  def self.ten_plugs
    self.fromString( 'ZYXWVFGHIJKLMNOPQRSTUEDCBA' )
  end
end
