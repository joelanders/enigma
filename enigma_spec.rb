require './enigma.rb'

describe Substitutor do
  it 'inits from string and creates correct mappers' do
    str = 'bcdefghijklmnopqrstuvwxyza'
    sub = Substitutor.fromString(str)
    (0...(str.length)).each do |int|
      expect( sub.rtol[int] ).to \
        eq((int+1) % (str.length))
      expect( sub.rtol[(int-1) % (str.length)]).to \
        eq(int)
    end

    str = 'xyzabcdefghijklmnopqrstuvw'
    sub = Substitutor.fromString(str)
    (0...(str.length)).each do |int|
      expect( sub.rtol[int] ).to \
        eq((int-3) % (str.length))
    end
  end
end

describe Rotor do
  it 'inits a preset and creates correct mappers' do
    r1 = Rotor.fromPreset 1
    expect(r1.rtol[0] ).to eq(4)
    expect(r1.rtol[15]).to eq(7)
    expect(r1.rtol[10]).to eq(13)

    expect(r1.ltor[4] ).to eq(0)
    expect(r1.ltor[20]).to eq(17)
    expect(r1.ltor[23]).to eq(16)
  end
end

describe Reflector do
  it 'inits a preset and creates correct mappers' do
    ref2 = Reflector.fromPreset 2
    expect(ref2.rtol[1] ).to eq(17)
    expect(ref2.rtol[4] ).to eq(16)
    expect(ref2.rtol[17]).to eq(1)
  end
end

describe Enigma do
  it 'steps properly' do
    e = Enigma.fromMostBasicSettings
    expect(e.positions).to eq([0,0,0])
    e.step!                             #R always steps
    expect(e.positions).to eq([1,0,0])
    15.times {e.step!}
    expect(e.positions).to eq([16,0,0])
    e.step!                             #M steps when R at 16
    expect(e.positions).to eq([17,1,0])
    26.times {e.step!}
    expect(e.positions).to eq([17,2,0])
    52.times {e.step!}
    expect(e.positions).to eq([17,4,0])
    e.step!                             #M and L step when M at 4
    expect(e.positions).to eq([18,5,1])
  end

  it 'enciphers a letter correctly' do
    e = Enigma.fromMostBasicSettings
    # 'abcdefg' -> 'fuvepum'
    expect(e.encipher! 0).to eq(5)
    expect(e.encipher! 1).to eq(20)
    expect(e.encipher! 2).to eq(21)
    expect(e.encipher! 3).to eq(4)
    expect(e.encipher! 4).to eq(15)
    expect(e.encipher! 5).to eq(20)
    expect(e.encipher! 6).to eq(12)
  end

  it 'enciphers a string correctly' do
    e = Enigma.fromMostBasicSettings
    # 'thislineissecure' -> 'zpjjtafkabumibsx'
    expect(e.encipher_string!('thislineissecure')).to eq('zpjjtafkabumibsx')
  end

  it 'enciphers a long string correctly' do
    e = Enigma.fromMostBasicSettings
    30.times {e.encipher_string!('thequickbrownfoxjumpsoverthelazydog')}
    expect(e.encipher_string!('enigmaenigmaenigma')
           ).to            eq('jbndqgfwnkuvkdazjj')
  end

  it 'can step like an odometer' do
    e = Enigma.fromMostBasicSettings
    expect( e.positions ).to eq( [0,0,0] )

    25.times {e.step_like_odometer!}
    expect( e.positions ).to eq( [25,0,0] )

    1.times {e.step_like_odometer!}
    expect( e.positions ).to eq( [0,1,0] )

    26.times {e.step_like_odometer!}
    expect( e.positions ).to eq( [0,2,0] )
    
    (26*26).times {e.step_like_odometer!}
    expect( e.positions ).to eq( [0,2,1] )
  end

  it 'can set odometer-like position' do
    e = Enigma.fromMostBasicSettings
    e.set_odo_pos! 4
    expect( e.positions ).to eq( [4,0,0] )

    e.set_odo_pos! 36
    expect( e.positions ).to eq( [10,1,0] )

    e.set_odo_pos! 36
    expect( e.positions ).to eq( [10,1,0] )

    e.set_odo_pos! 10_000
    expect( e.positions ).to eq( [16,20,14] )
  end
end
