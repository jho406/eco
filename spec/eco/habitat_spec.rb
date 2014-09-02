require 'test_helper'

describe Eco::Habitat do

  class MockSpecies < Eco::Species
    attr_accessor :cause_of_death
  end

  let(:pot) do
    Class.new(Eco::PassageOfTime) do
      attr_accessor :snapshots, :all_inhabitants, :current_month

      def all_inhabitants
        @all_inhabitants
      end
    end.new
  end

  let(:specie) { MockSpecies.new }
  let(:specie_attrs) do
    {
      name: 'kitty',
      monthly_food_consumption: 0,
      monthly_water_consumption: 0,
      life_span: 10,
      minimum_breeding_age: 0,
      maximum_breeding_age: 10,
      gestation_period: 2,
      minimum_temperature: -100,
      maximum_temperature: 100,
      sex: :f
    }
  end

  let(:attrs) { { monthly_food: 5, monthly_water: 5, winter: 0 } }
  let(:habitat) { Eco::Habitat.new(pot, attrs) }

  describe '#clone' do
    it 'also shallow copies its inhabitants' do
      clone = habitat.clone
      habitat.inhabitants.must_equal clone.inhabitants
      habitat.inhabitants.object_id.wont_equal clone.inhabitants.object_id
    end
  end

  describe '#add_inhabitant' do
    it 'adds a new inhabitant' do
      habitat.add_inhabitant(specie)
      habitat.inhabitants.size.must_equal 1
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
      habitat.stats[:population].must_equal 2
    end

    it 'populates starved_to_death' do
      specie1.cause_of_death = :starvation
      specie2.cause_of_death = :starvation

      habitat.refresh_stats
      habitat.stats[:starved_to_death].must_equal 2
    end

    it 'populates aged_to_death' do
      specie1.cause_of_death = :old_age
      specie2.cause_of_death = :old_age

      habitat.refresh_stats
      habitat.stats[:aged_to_death].must_equal 2
    end

    it 'populates froze_to_death' do
      specie1.cause_of_death = :cold_weather
      specie2.cause_of_death = :cold_weather

      habitat.refresh_stats
      habitat.stats[:froze_to_death].must_equal 2
    end

    it 'populates burned_to_death' do
      specie1.cause_of_death = :hot_weather
      specie2.cause_of_death = :hot_weather

      habitat.refresh_stats
      habitat.stats[:burned_to_death].must_equal 2
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

  describe '#provision_food' do
    let(:habitat) { Eco::Habitat.new(pot, attrs.merge({ monthly_food: 10 })) }

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

  describe '#healthy?' do
    let(:habitat) { Eco::Habitat.new(pot, monthly_food: 10, monthly_water: 10 ) }
    let(:specie_attrs) { { monthly_water_consumption: 5, monthly_food_consumption: 5 } }

    describe 'when there is enough food and water to go around' do
      before do
        habitat.replenish
        habitat.add_inhabitant(MockSpecies.new(specie_attrs))
        habitat.add_inhabitant(MockSpecies.new(specie_attrs))
      end

      it 'returns true' do
        habitat.healthy?.must_equal true
      end
    end

    describe 'when there is not enough food to go around' do
      before do
        habitat.replenish
        habitat.add_inhabitant(MockSpecies.new(specie_attrs))
        habitat.add_inhabitant(MockSpecies.new(specie_attrs))
        habitat.add_inhabitant(MockSpecies.new(specie_attrs))
      end

      it 'returns false' do
        habitat.healthy?.must_equal false
      end
    end
  end

  describe '#age!' do
    let(:habitat) { Eco::Habitat.new(pot, attrs.merge({ winter: 50, monthly_water: 15, monthly_food: 10 })) }
    let(:male) { MockSpecies.new(specie_attrs.merge(sex: :m)) }
    let(:female) { MockSpecies.new(specie_attrs.merge(sex: :f)) }
    let(:other_female) { MockSpecies.new(specie_attrs.merge(sex: :f)) }

    before do
      habitat.add_inhabitant(male)
      habitat.add_inhabitant(female)
      habitat.add_inhabitant(other_female)
    end

    it 'replenishes resources' do
      habitat.age!
      habitat.age!

      habitat.food_stock.must_equal 20
      habitat.water_stock.must_equal 30
    end

    it 'refreshes statistics' do
      habitat.stats[:population].must_equal 0
      habitat.age!
      habitat.stats[:population].must_equal 3
    end

    it 'sets a new temperature with a fluxuation' do
      previous_temperature = habitat.temperature
      habitat.age!
      habitat.temperature.wont_equal previous_temperature
      habitat.temperature.must_be_close_to 50, 15
    end

    it 'ages the inhabitants' do
      habitat.inhabitants.first.age.must_equal 0
      habitat.age!
      habitat.inhabitants.first.age.must_equal 1
    end

    it 'matches for breeding' do
      habitat.age!
      (female.pregnant? || other_female.pregnant?).must_equal true
      (female.pregnant? && other_female.pregnant?).must_equal false
    end
  end
end
