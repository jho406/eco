module Eco
  class Simulator
    attr_reader :stats, :runs

    def initialize(specie_attrs, habitat_attrs, opts)
      @specie_attrs = specie_attrs
      @habitat_attrs = habitat_attrs

      @iterations = opts.fetch(:iterations, 1)
      year_in_months = opts.fetch(:year, 1) * 12
      @months = opts.fetch(:months, year_in_months)

      @runs = []
    end

    def run
      @iterations.times do
        habitat = habitat_with_adam_eve
        @months.times { habitat.age! }
        habitat.refresh_stats
        @runs << habitat
      end

      refresh_stats
    end

    def refresh_stats
      @stats = {
        specie_name: @specie_attrs[:name],
        habitat_name: @habitat_attrs[:name],
        average_population: extract_average_population,
        population: extract_population,
        max_population: extract_max_population,
        mortality_rate: extract_rate(:dead),
        hot_weather_death_rate: extract_rate(:dead_by_hot_weather),
        cold_weather_death_rate: extract_rate(:dead_by_cold_weather),
        starvation_death_rate: extract_rate(:dead_by_starvation),
        thirst_death_rate: extract_rate(:dead_by_thirst),
        old_age_death_rate: extract_rate(:dead_by_old_age)
      }
    end

    private
      def habitat_with_adam_eve
        adam = Species.new(@specie_attrs.merge(sex: :m))
        eve = Species.new(@specie_attrs.merge(sex: :f))
        Habitat.new(@habitat_attrs.merge(inhabitants: [adam, eve]))
      end


      def extract_doa_population
        total_dead = runs.inject(0) do |memo, habitat|
          memo += habitat.inhabitants.size
        end
      end

      def extract_average_population
        extract_population / @iterations.to_f
      end

      def extract_max_population
        runs.map do |habitat|
          habitat.stats[:population]
        end.max
      end

      def extract_rate(type)
        type = type.to_sym
        total_dead = runs.inject(0) do |memo, habitat|
          memo += habitat.stats[type]
        end

        (total_dead.to_f / extract_doa_population) * 100
      end

      def extract_population
        runs.inject(0) do |memo, habitat|
          memo += habitat.stats[:population]
        end
      end
  end
end
