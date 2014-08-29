require 'test_helper'

describe Eco::PassageOfTime do

  class MockHabitat
    attr_reader :passage_of_time, :inhabitants, :has_aged

    def initialize(passage_of_time, inhabitants = [])
      @passage_of_time = passage_of_time
      @inhabitants = inhabitants
      @has_aged = 0
    end

    def add_inhabitant(hab)
      @inhabitants.push(hab)
    end

    def age
      @has_aged = true
    end
  end

  class MockSpecie
    attr_accessor :sex

    def initialize(args)
      @sex = args[:sex]
    end
  end

  describe '#add_inhabitant' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }
    let(:inhabitant) { Object.new }

    it 'should add to its inhabitant pool' do
      pot.add_inhabitant(inhabitant)
      pot.all_inhabitants.first.must_equal inhabitant
    end
  end


  describe '#age' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      pot.age
    end

    it 'should age the habitat' do
      pot.snapshots.last.has_aged.must_equal true
    end

    it 'should add a new snapshot' do
      pot.snapshots.size.must_equal 2
    end
  end
end
