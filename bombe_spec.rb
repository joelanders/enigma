require './bombe.rb'

describe Bombe do
  it 'creates a spaced-out array' do
    b = Bombe.testConfig
    expect(b.array.map &:positions).to eq([[0,0,0],[1,0,0],[2,0,0],[3,0,0],[4,0,0]])
  end
  it 'tests if current state is self-consistent' do
    b = Bombe.testConfig
    expect( b.test_position(4) ).to be_false
    3.times {b.step_all!} #it's 3 instead of 2 because normally there's a step before encipherment
    expect( b.test_position(4) ).to be_true
  end
  it 'returns the first self-consistent state' do
    b = Bombe.testConfig
    expect( b.test_until_valid! ).to eq(3)
  end
end
