class Enigma
  attr_accessor :rotors, :positions, :reflector
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

  def encipher(entrance_pos)
    t = (entrance_pos + positions[0])%26   # R position on first rotor
    puts t
    t = rotors[0].rtol[ t ]                # L position on first rotor
    t = (t - positions[0])%26   #enigma-relative position after first rotor

    t = (t + positions[1])%26              # R position on second rotor
    puts t
    t = rotors[1].rtol[ t ]                # L position on second rotor
    t = (t - positions[1])%26   #enigma-relative position after second rotor

    t = (t + positions[2])%26              # R position on third rotor
    puts t
    t = rotors[2].rtol[ t ]                # L position on third rotor
    t = (t - positions[2])%26   #enigma-relative position after third rotor

    puts t
    t = reflector.rtol[ t ]     #enigma-relative position after reflector

    t = (t - positions[2])%26              # L position on third rotor
    puts t
    t = rotors[2].ltor[ t ]                # R position on third rotor
    t = (t + positions[2])%26   #enigma-relative position after third rotor (rightward)

    t = (t - positions[1])%26              # L position on second rotor
    puts t
    t = rotors[1].ltor[ t ]                # R position on second rotor
    t = (t + positions[1])%26   #enigma-relative position after second rotor (rightward)

    t = (t - positions[0])%26              # L position on first rotor
    puts t
    t = rotors[0].ltor[ t ]                # R position on first rotor
    t = (t + positions[0])%26   #enigma-relative position after first rotor (rightward)

    t
  end
end


#converts right-side position to left-side position
#  and vice versa
class Substitutor
  attr_accessor :rtol, :ltor
  Alphabet = 'abcdefghijklmnopqrstuvwxyz'
  AlphabetInts = 0..Alphabet.length
  AlphabetLetterToInt = Hash[ Alphabet.split('').zip(AlphabetInts) ]
  AlphabetIntToLetter = Hash[ AlphabetInts.zip(Alphabet.split('')) ]

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

  # number is indexed starting from 1 (convention)
  def self.fromPreset(number)
    Substitutor.fromString( Presets[number - 1] )
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
    Substitutor.fromString( Presets[number - 1] )
  end
end

class Plugboard < Substitutor
  #like a rotor with no notches whose internal wiring
  #  is not fixed, but decided at runtime
end
