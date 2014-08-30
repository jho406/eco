require 'test_helper'
require 'ostruct'
require 'debugger'

describe Eco::Habitat do
  class MockPot
    attr_accessor :current_month, :inhabitants, :habitat

    def add_inhabitant(iht)
      (@inhabitants ||=[]).push(iht)
    end
  end

  class MockSpecies < Eco::Species
    attr_accessor :age, :habitat, :cause_of_death, :sex, :attributes, :months_without_food, :months_without_water
  end

  let(:pot) { MockPot.new }
  let(:specie) { MockSpecies.new }
  let(:habitat) { Eco::Habitat.new(pot) }

  describe '#add_inhabitant' do
    it 'adds a new inhabitant' do
      habitat.add_inhabitant(specie)
      habitat.inhabitants.size.must_equal 1
    end

    it 'adds the specie to the passage of time' do
      habitat.add_inhabitant(specie)
      pot.inhabitants.size.must_equal 1
    end
  end

  describe '#refresh_stats' do
    let(:specie1) { MockSpecies.new }
    let(:specie2) { MockSpecies.new }

    before do
      habitat.add_inhabitant(specie1)
      habitat.add_inhabitant(specie2)
    end

    it 'populates population' do
      habitat.refresh_stats
      habitat.population.must_equal 2
    end

    it 'populates starved_to_death' do
      specie1.cause_of_death = :starvation
      specie2.cause_of_death = :starvation

      habitat.refresh_stats
      habitat.starved_to_death.must_equal 2
    end

    it 'populates aged_to_death' do
      specie1.cause_of_death = :age
      specie2.cause_of_death = :age

      habitat.refresh_stats
      habitat.aged_to_death.must_equal 2
    end

    it 'populates froze_to_death' do
      specie1.cause_of_death = :cold_weather
      specie2.cause_of_death = :cold_weather

      habitat.refresh_stats
      habitat.froze_to_death.must_equal 2
    end

    it 'populates burned_to_death' do
      specie1.cause_of_death = :hot_weather
      specie2.cause_of_death = :hot_weather

      habitat.refresh_stats
      habitat.burned_to_death.must_equal 2
    end
  end

  describe '#set_temperature' do
    let(:habitat) { Eco::Habitat.new(pot, {winter: 100}) }

    before do
      pot.current_month = 1
    end

    it 'sets the temperature with a fluxuation' do
      habitat.temperature.must_be_nil
      habitat.set_temperature
      habitat.temperature.must_be_kind_of Numeric
      habitat.temperature.wont_equal 100
    end
  end


  describe '#replenish' do
    let(:habitat) { Eco::Habitat.new(pot, monthly_food: 100, monthly_water: 50) }

    it 'adds to the habitat food supply' do

      habitat.replenish
      habitat.replenish
      habitat.food_stock.must_equal 200
      habitat.water_stock.must_equal 100
    end
  end
#####
  describe '#feed_inhabitants' do
    let(:habitat) { Eco::Habitat.new(pot, {monthly_food: 2, monthly_water: 4}) }
    let(:specie1) { MockSpecies.new(monthly_food_consumption: 1, monthly_water_consumption: 2) }
    let(:specie2) { MockSpecies.new(monthly_food_consumption: 1, monthly_water_consumption: 2) }

    before do
      habitat.add_inhabitant(specie1)
      habitat.add_inhabitant(specie2)
    end

    it 'should feed the inhabitants' do
      habitat.feed_inhabitants
      specie1.months_without_food.must_equal 1
      specie1.months_without_water.must_equal 1

      habitat.replenish
      habitat.feed_inhabitants
      specie1.months_without_food.must_equal 0
      specie1.months_without_water.must_equal 0
    end
  end

  describe '#age_inhabitants' do
    let(:habitat) { Eco::Habitat.new(pot, {monthly_food: 2, monthly_water: 4}) }
    let(:specie) { MockSpecies.new }

    before do
      habitat.add_inhabitant(specie)
    end

    it 'ages the inhabitants' do
      specie.age.must_equal 0
      habitat.age_inhabitants
      specie.age.must_equal 1
    end
  end

  describe '#provision_food' do
    let(:habitat) { Eco::Habitat.new(pot, { monthly_food: 10 }) }

    before do
      habitat.replenish
    end

    describe 'when there is enough food' do
      it 'decrements food and returns true' do
        habitat.provision_food(10).must_equal true
        habitat.food_stock.must_equal 0
      end
    end

    describe 'when there is not enough food' do
      it 'returns false' do
        habitat.provision_food(11).must_equal false
        habitat.food_stock.must_equal 10
      end
    end
  end

  describe '#provision_water' do
    let(:habitat) { Eco::Habitat.new(pot, { monthly_water: 10 }) }

    before do
      habitat.replenish
    end

    describe 'when there is enough water' do
      it 'decrements water and returns true' do
        habitat.provision_water(10).must_equal true
        habitat.water_stock.must_equal 0
      end
    end

    describe 'when there is not enough water' do
      it 'returns false' do
        habitat.provision_water(11).must_equal false
        habitat.water_stock.must_equal 10
      end
    end
  end

  describe '#sexy_time' do
    let(:male) { MockSpecies.new(sex: :m, minimum_breeding_age: 0, maximum_breeding_age: 10) }
    let(:female) { MockSpecies.new(sex: :f, minimum_breeding_age: 0, maximum_breeding_age: 10) }
    let(:other_female) { MockSpecies.new(sex: :f, minimum_breeding_age: 0, maximum_breeding_age: 10) }
    let(:out_of_range_female) { MockSpecies.new(sex: :f, minimum_breeding_age: 9, maximum_breeding_age: 10) }

    before do
      habitat.add_inhabitant(male)
      habitat.add_inhabitant(female)
      habitat.add_inhabitant(other_female)
      habitat.add_inhabitant(out_of_range_female)
    end

    it 'impregnates the pairable females' do
      habitat.sexy_time
      (female.pregnant? || other_female.pregnant?).must_equal true
      (female.pregnant? && other_female.pregnant?).must_equal false
      out_of_range_female.pregnant?.must_equal false
    end
  end
end
