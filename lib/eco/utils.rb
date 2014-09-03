module Eco
  module Utils
    def self.chance(pct, opts={})
      success = opts.fetch(:success, true)
      fail = opts.fetch(:fail, false)
      roll = rand * 100
      roll <= pct ? success : fail
    end

    def self.render_stats(stats)
      stat = <<stat
Species: #{ stats[:specie_name] }
  Habitat: #{ stats[:habitat_name] }
    a) Average Population: #{ stats[:average_population] }
    b) Max Population: #{ stats[:max_population] }
    c) Mortality Rate: #{ stats[:mortality_rate] }%
    d) Causes of Death:
      #{ stats[:starvation_death_rate] }% starvation
      #{ stats[:thirst_death_rate] }% thirst
      #{ stats[:old_age_death_rate] }% age
      #{ stats[:cold_weather_death_rate] }% cold_weather
      #{ stats[:hot_weather_death_rate] }% hot_weather
stat

    end
  end
end
