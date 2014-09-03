module Eco
  class Habitat
    MONTH_SEASONS = [:winter, :winter, :spring, :spring, :spring, :summer, :summer, :summer, :fall, :fall, :fall, :winter]

    attr_reader :inhabitants, :temperature, :options
    attr_reader :food_stock, :water_stock
    attr_reader :age, :stats

    def initialize(opts = {})
      @options = default_opts.merge(opts)
      @inhabitants = opts.fetch(:inhabitants, [])
      @age = 0
      @stats = {}
      set_stock
      set_temperature
    end

    def add_inhabitant(specie)
      @inhabitants.push(specie)
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
    end

    def current_month
      @age%12
    end

    def refresh_stats
      cause_of_deaths = extract_cause_of_death
      alive = cause_of_deaths.fetch(:none, 0)
      dead = cause_of_deaths.values.inject(:+) - alive

      @stats = {
        population: alive,
        dead: dead,
        dead_by_hot_weather: cause_of_deaths[:hot_weather],
        dead_by_cold_weather: cause_of_deaths[:cold_weather],
        dead_by_starvation: cause_of_deaths[:starvation],
        dead_by_thirst: cause_of_deaths[:thirst],
        dead_by_old_age: cause_of_deaths[:old_age]
      }
    end

    private

      def extract_cause_of_death
        causes = inhabitants.group_by do |obj|
          obj.cause_of_death
        end

        {
          none: causes.fetch(nil, []).size.to_f,
          hot_weather: causes.fetch(:hot_weather, []).size.to_f,
          cold_weather: causes.fetch(:cold_weather, []).size.to_f,
          old_age: causes.fetch(:old_age, []).size.to_f,
          starvation: causes.fetch(:starvation, []).size.to_f,
          thirst: causes.fetch(:thirst, []).size.to_f
        }
      end

      def set_stock
        @food_stock = 0
        @water_stock = 0
      end

      def set_temperature
        month = current_month
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
