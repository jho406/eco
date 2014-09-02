module Eco
  class Habitat
    MONTH_SEASONS = [:winter, :winter, :spring, :spring, :spring, :summer, :summer, :summer, :fall, :fall, :fall, :winter]

    attr_reader :inhabitants, :passage_of_time, :temperature, :options
    attr_reader :food_stock, :water_stock
    attr_reader :age, :stats

    def initialize(passage_of_time, opts = {})
      @options = default_opts.merge(opts)
      @inhabitants = options[:inhabitants].clone
      @passage_of_time = passage_of_time

      @age = 0
      set_stock
      @stats = {
        population: 0,
        starved_to_death: 0,
        aged_to_death: 0,
        froze_to_death: 0,
        burned_to_death: 0
      }
      set_temperature
    end

    def add_inhabitant(specie)
      @inhabitants.push(specie)
    end

    def refresh_stats
      stats = @inhabitants.group_by(&:cause_of_death)
      @stats = {
        population: stats.fetch(nil, []).size,
        starved_to_death: stats.fetch(:starvation, []).size,
        aged_to_death: stats.fetch(:old_age, []).size,
        froze_to_death: stats.fetch(:cold_weather, []).size,
        burned_to_death: stats.fetch(:hot_weather, []).size
      }
    end

    def replenish
      @food_stock += options[:monthly_food]
      @water_stock += options[:monthly_water]
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

    def healthy?
      food_appetite = @inhabitants.size * @inhabitants.first.monthly_food_consumption
      water_appetite = @inhabitants.size * @inhabitants.first.monthly_water_consumption

      @food_stock >= food_appetite && @water_stock >= water_appetite
    end

    def age!
      @age += 1
      replenish
      set_temperature

      match_for_breeding
      age_inhabitants
      refresh_stats
    end

    private

      def set_stock
        @food_stock = 0
        @water_stock = 0
      end

      def set_temperature
        month = @passage_of_time.current_month
        season = MONTH_SEASONS[month]
        base_temp = options[season]

        flucuation = Utils::chance(0.5, success: rand(-15..15), fail: rand(-5..5))
        @temperature = base_temp + flucuation
      end

      def age_inhabitants
        @inhabitants.clone.each do |ibt|
          ibt.age!(self)
        end
      end

      def match_for_breeding
        sexes = @inhabitants.select(&:breedable?).group_by(&:sex)
        females = sexes.fetch(:f, [])
        males = sexes.fetch(:m,[])
        num_of_matches = [females.size, males.size].min

        females.sample(num_of_matches).each(&:match)
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

      def initialize_copy(orig)
       super
       @inhabitants = orig.inhabitants.clone
      end
  end
end
