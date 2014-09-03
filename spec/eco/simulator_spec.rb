require 'test_helper'

describe Eco::Simulator do
  let(:specie_attrs) do
    {
      name: 'bear',
      monthly_food_consumption: 0,
      monthly_water_consumption: 0,
      life_span: 20,
      minimum_breeding_age: 0,
      maximum_breeding_age: 10,
      gestation_period: 1,
      minimum_temperature: -100,
      maximum_temperature: 100
    }
  end

  let(:habitat_attrs) do
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

  let(:sim) { Eco::Simulator.new(specie_attrs, habitat_attrs, months: 1, iterations: 2) }

  describe '#run' do
    it 'creates iterations' do
      sim.run
      sim.runs.size.must_equal 2
    end

    it 'ages the pot' do
      sim.run
      sim.runs.first.age.must_equal 1
      sim.runs.last.age.must_equal 1
    end

    describe 'extracting stats from the habitats' do
      let(:run1) { sim.runs.first }
      let(:run2) { sim.runs.last }

      before do
        sim.run
      end

      it 'calculates max population' do
        max = [run1.stats[:population], run2.stats[:population]].max
        sim.stats[:max_population].must_equal max
      end

      it 'calculates total population' do
        total = run1.stats[:population] + run2.stats[:population]
        sim.stats[:population].must_equal total
      end

      it 'calculates the average population' do
        total = run1.stats[:population] + run2.stats[:population]
        sim.stats[:average_population].must_equal total/sim.runs.size
      end

      it 'calculates the mortality rate' do
        total = run1.inhabitants.size + run2.inhabitants.size

        run1.inhabitants[0].stub :cause_of_death, :hot_weather do
          run1.refresh_stats
          sim.refresh_stats

          sim.stats[:mortality_rate].must_equal (1.to_f/total * 100)
        end
      end

      it 'calculates the hot weather death rate' do
        total = run1.inhabitants.size + run2.inhabitants.size

        run1.inhabitants[0].stub :cause_of_death, :hot_weather do
          run1.refresh_stats
          sim.refresh_stats

          sim.stats[:hot_weather_death_rate].must_equal (1.to_f/total * 100)
        end
      end

      it 'calculates the cold weather death rate' do
        total = run1.inhabitants.size + run2.inhabitants.size

        run1.inhabitants[0].stub :cause_of_death, :cold_weather do
          run1.refresh_stats
          sim.refresh_stats

          sim.stats[:cold_weather_death_rate].must_equal (1.to_f/total * 100)
        end
      end

      it 'calculates the starvation death rate' do
        total = run1.inhabitants.size + run2.inhabitants.size

        run1.inhabitants[0].stub :cause_of_death, :starvation do
          run1.refresh_stats
          sim.refresh_stats

          sim.stats[:starvation_death_rate].must_equal (1.to_f/total * 100)
        end
      end

      it 'calculates the thirst death rate' do
        total = run1.inhabitants.size + run2.inhabitants.size
        run1.inhabitants[0].stub :cause_of_death, :thirst do
          run1.refresh_stats
          sim.refresh_stats

          sim.stats[:thirst_death_rate].must_equal (1.to_f/total * 100)
        end
      end

      it 'calculates the old_age death rate' do
        total = run1.inhabitants.size + run2.inhabitants.size

        run1.inhabitants[0].stub :cause_of_death, :old_age do
          run1.refresh_stats
          sim.refresh_stats

          sim.stats[:old_age_death_rate].must_equal (1.to_f/total * 100)
        end
      end
    end
  end
end
