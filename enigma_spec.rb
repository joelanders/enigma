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
