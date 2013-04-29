require './bombe.rb'

describe Bombe do
  it 'does shit' do
    b = Bombe.testConfig
  end
end

#this is a lot of work to test not very much...
describe PlugHalf do
  context 'given some fake surroundings' do
    let(:enigma)  { double :enigma, :encipher_without_step => 7 }
    let(:t_bank)  { double :t_bank }
    let(:d_board) { double :d_board }

    it 'sends a letter through the enigma to the diagonal board' do
      enigma.should_receive(:encipher_without_step).with(4)
      d_board.should_receive(:set_diagonal_pair).with(t_bank, 7)

      ph = PlugHalf.new(enigma, t_bank, d_board)
      ph.encipher_and_set_diagonal_pair(4)
    end
  end
end

#again feels like I'm just testing implementation details
describe Bank do
  context 'given some fake surroundings' do
    let(:ph1)  { double :plug_half }
    let(:ph2)  { double :plug_half }

    it 'sends a letter to its connected plug halves' do
      ph1.should_receive(:encipher_and_set_diagonal_pair).with(4)
      ph2.should_receive(:encipher_and_set_diagonal_pair).with(4)

      b = Bank.new
      b.plug_halves << ph1
      b.plug_halves << ph2
      b.set_register(4)
    end

    it 'counts the number of live registers' do
      b = Bank.new
      expect(b.num_of_live_wires).to eq(0)
      b.registers[1] = true
      b.registers[4] = true
      expect(b.num_of_live_wires).to eq(2)
    end
  end
end

describe DiagonalBoard do
  before :each do
    @db = DiagonalBoard.new
    @db.add_plugs( [[1, 2, 16], [3, 4, 12], [2, 5, 8]] )
  end

  it 'has 26 banks' do
    expect( @db.banks.count ).to eq(26)
  end

  it 'makes enigmas for plugs' do
    expect(@db.enigmas[0].positions).to  eq([16,0,0])
    expect(@db.enigmas[1].positions).to eq([12,0,0])
  end

  it 'makes plug halves correctly' do
    expect(@db.banks[1].plug_halves.count).to eq(1)
    expect(@db.banks[2].plug_halves.count).to eq(2)
  end

  it 'sets diagonal pairs' do
    @db.set_diagonal_pair(1, 5)
    expect(@db.banks[1].registers[5]).to be_true
    expect(@db.banks[5].registers[1]).to be_true
  end
end
