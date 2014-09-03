require 'test_helper'

describe Eco::Utils do
  describe '.show_results' do
    let(:stats) do
      {
        specie_name: 'foo',
        habitat_name: 'bar',
        average_population: 1,
        population: 2,
        max_population: 3,
        mortality_rate: 4,
        hot_weather_death_rate: 5,
        cold_weather_death_rate: 6,
        starvation_death_rate: 7,
        thirst_death_rate: 8,
        old_age_death_rate: 9
      }
    end
    it 'render_stats' do
      output = Eco::Utils.render_stats(stats)
      stat = <<stat
Species: foo
  Habitat: bar
    a) Average Population: 1
    b) Max Population: 3
    c) Mortality Rate: 4%
    d) Causes of Death:
      7% starvation
      8% thirst
      9% age
      6% cold_weather
      5% hot_weather
stat

      output.must_equal stat
    end
  end
end
