require 'test_helper'

describe Eco::PassageOfTime do

  class MockHabitat
    attr_reader :passage_of_time, :inhabitants, :has_aged
    attr_accessor :population

    def initialize(passage_of_time, inhabitants = [])
      @passage_of_time = passage_of_time
      @inhabitants = inhabitants
      @has_aged = 0
      @population = 0
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

  describe '#pct_starved' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      4.times do
        pot.add_inhabitant(Object.new)
      end

      pot.add_inhabitant(Object.new, :starved)
      pot.add_inhabitant(Object.new, :starved)
    end

    it 'returns the percent of inhabitant who starved to death' do
      pot.pct_starved.must_equal 0.5
    end
  end

  describe '#pct_aged' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      4.times do
        pot.add_inhabitant(Object.new)
      end

      pot.add_inhabitant(Object.new, :aged)
      pot.add_inhabitant(Object.new, :aged)
    end

    it 'returns the percent of inhabitant who aged to death' do
      pot.pct_aged.must_equal 0.5
    end
  end

 describe '#pct_frozen' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      4.times do
        pot.add_inhabitant(Object.new)
      end

      pot.add_inhabitant(Object.new, :frozen)
      pot.add_inhabitant(Object.new, :frozen)
    end

    it 'returns the percent of inhabitant who froze to death' do
      pot.pct_frozen.must_equal 0.5
    end
  end

 describe '#pct_burnt' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      4.times do
        pot.add_inhabitant(Object.new)
      end

      pot.add_inhabitant(Object.new, :burnt)
      pot.add_inhabitant(Object.new, :burnt)
    end

    it 'returns the percent of inhabitant who burned to death' do
      pot.pct_burnt.must_equal 0.5
    end
  end

  describe '#max_population' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      pot.age
      pot.snapshots[0].population = 2
      pot.snapshots[1].population = 4
    end

    it 'retrieves the max population of the snapshots' do
      pot.max_population.must_equal 4
    end
  end

  describe '#average_population' do
    let(:pot) { Eco::PassageOfTime.new(MockSpecie, MockHabitat) }

    before do
      pot.age
      pot.snapshots[0].population = 2
      pot.snapshots[1].population = 4
    end

    it 'averages the habitat population' do
      pot.average_population.must_equal 3.0
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
