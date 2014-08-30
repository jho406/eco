module Eco
  class Habitat
    MONTH_SEASONS = [:winter, :winter, :spring, :spring, :spring, :summer, :summer, :summer, :fall, :fall, :fall, :winter]

    attr_reader :inhabitants, :passage_of_time, :temperature, :options
    attr_reader :starved_to_death, :aged_to_death, :froze_to_death, :burned_to_death, :population
    attr_reader :food_stock, :water_stock

    def initialize(passage_of_time, opts = {})
      @options = default_opts.merge(opts)
      @inhabitants = options[:inhabitants].clone
      @passage_of_time = passage_of_time
      set_stock
    end

    def set_stock
      @food_stock = 0
      @water_stock = 0
      # replenish #todo: be sure to call this one tmie in passage of time
    end

    def default_opts
      {
        monthly_food: 10,
        monthly_water: 10,
        summer: 50,
        spring: 50,
        fall: 50,
        winter: 50,
        inhabitants: []
      }
    end

    def add_inhabitant(specie)
      @inhabitants.push(specie)
      @passage_of_time.add_inhabitant(specie)
    end

    def refresh_stats
      stats = @inhabitants.group_by(&:cause_of_death)

      @population = stats.fetch(nil, []).size
      @starved_to_death = stats.fetch(:starvation, []).size
      @aged_to_death = stats.fetch(:age, []).size
      @froze_to_death = stats.fetch(:cold_weather, []).size
      @burned_to_death = stats.fetch(:hot_weather, []).size
    end

    def age!
      # replenish_food
      # set temperature
      # feed_inhabitants
      # sexy_time
      # give_birth #carefull....
      # age_inhabitants
      # refresh_stats
    end

    def set_temperature
      month = @passage_of_time.current_month
      season = MONTH_SEASONS[month]
      base_temp = options[season]

      flucuation = Utils::chance(0.5, success: 15, fail: rand(-5..5))
      @temperature = base_temp + flucuation
    end

    def age_inhabitants
      @inhabitants.each do |ibt|
        ibt.age!
      end
    end

    def sexy_time
      sexes = @inhabitants.group_by(&:sex)
      ovulating = sexes[:f].group_by(&:ovulating)[true]
      num_of_matches = Math.min(ovulating.size, sexes[:m].size)

      impregnable = ovulating.sample(num_of_matches)

      impregnable.each do |ibt|
        ibt.impregnate
      end
    end

    def provision_food(num)
      return false if num > @food_stock
      @food_stock -= num
      true
    end

    def provision_water(num)
      return false if num > @water_stock
      @water_stock -= num
      true
    end

    def feed_inhabitants
      @inhabitants.each do |ibt|
        ibt.consume_food(self)
        ibt.consume_water(self)
      end
    end

    def replenish
      @food_stock += options[:monthly_food]
      @water_stock += options[:monthly_water]
    end
  end
end
