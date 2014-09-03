require 'test_helper'
require 'set'

describe Eco::PassageOfTime do

  let(:specie_attrs) do
    {
      name: 'bear',
      monthly_food_consumption: 0,
      monthly_water_consumption: 0,
      life_span: 20,
      minimum_breeding_age: 0,
      maximum_breeding_age: 10,
      gestation_period: 1,
      minimum_temperature: 0,
      maximum_temperature: 10
    }
  end

  let(:habitat_options) do
    {
      name: 'plains',
      monthly_food: 10,
      monthly_water: 10,
      summer: 0,
      spring: 0,
      fall: 0,
      winter: 0,
    }
  end

  let(:pot) { Eco::PassageOfTime.new(species_options: specie_attrs, habitat_options: habitat_options) }

  describe '#initialize' do
    it 'creates adam and eve in the new habitat' do
      pot.all_inhabitants.size.must_equal 2
      pot.all_inhabitants.map(&:sex).to_set.must_equal [:m, :f].to_set
    end
  end

  describe '#age!' do
    it 'ages the habitat' do
      pot.snapshots.last.age.must_equal 0
      pot.age!
      pot.snapshots.last.age.must_equal 1
    end

    it 'creates a new cloned snapshot' do
      pot.snapshots.size.must_equal 1
      pot.age!
      pot.snapshots.size.must_equal 2
    end
  end

  describe '#stats' do
    let(:pot) do
      Class.new(Eco::PassageOfTime) do
        attr_accessor :snapshots, :all_inhabitants

        def all_inhabitants
          @all_inhabitants
        end
      end.new
    end

    it 'returns the number of population(alive)' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :hot_weather),
         OpenStruct.new(dead?: true, cause_of_death: :hot_weather),
         OpenStruct.new(dead?: false, cause_of_death: nil)
      ]

      pot.refresh_stats
      pot.stats[:population].must_equal 1
    end

    it 'returns the number of dead' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :hot_weather),
         OpenStruct.new(dead?: true, cause_of_death: :hot_weather),
         OpenStruct.new(dead?: false)
      ]

      pot.refresh_stats
      pot.stats[:dead].must_equal 2
    end

    it 'returns the hot weather death' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :hot_weather),
         OpenStruct.new(dead?: true, cause_of_death: :hot_weather),
         OpenStruct.new(dead?: false)
      ]

      pot.refresh_stats
      pot.stats[:dead_by_hot_weather].must_equal 2
    end

    it 'returns the cold weather death' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :cold_weather),
         OpenStruct.new(dead?: true, cause_of_death: :cold_weather),
         OpenStruct.new(dead?: false)
      ]

      pot.refresh_stats
      pot.stats[:dead_by_cold_weather].must_equal 2
    end

    it 'returns the old age death' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :old_age),
         OpenStruct.new(dead?: true, cause_of_death: :old_age),
         OpenStruct.new(dead?: false)
      ]

      pot.refresh_stats
      pot.stats[:dead_by_old_age].must_equal 2
    end

    it 'returns the starvation death' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :starvation),
         OpenStruct.new(dead?: true, cause_of_death: :starvation),
         OpenStruct.new(dead?: false)
      ]

      pot.refresh_stats
      pot.stats[:dead_by_starvation].must_equal 2
    end

    it 'returns the thirst death' do
      pot.all_inhabitants = [
         OpenStruct.new(dead?: true, cause_of_death: :thirst),
         OpenStruct.new(dead?: true, cause_of_death: :thirst),
         OpenStruct.new(dead?: false)
      ]

      pot.refresh_stats
      pot.stats[:dead_by_thirst].must_equal 2
    end
  end
end
