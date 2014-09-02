module Eco
  class PassageOfTime

    attr_reader :snapshots, :current_month
    attr_reader :all_inhabitants, :frozen_inhabitants,
      :burnt_inhabitants, :aged_inhabitants, :starved_inhabitants

    def initialize(opts={})
      @species_klass = opts.fetch(:species_klass, Species)
      @habitat_klass = opts.fetch(:habitat_klass, Habitat)
      @current_month = 0

      specie_attrs = opts.fetch(:species_options, {})
      habitat_attrs = opts.fetch(:habitat_options, {})

      habitat = @habitat_klass.new(self, habitat_attrs)
      @snapshots = [habitat]

      adam = @species_klass.new(specie_attrs.merge(sex: :m))
      eve = @species_klass.new(specie_attrs.merge(sex: :f))

      [adam, eve].each{ |spe| habitat.add_inhabitant(spe) }

      habitat.refresh_stats
    end

    def all_inhabitants
      snapshots.last.inhabitants || []
    end

    def age!
      snapshot = snapshots.last.clone
      snapshot.age!
      @snapshots.push(snapshot)
    end

    def stats
      cause_of_deaths = extract_cause_of_death

      {
        average_population: extract_average_population,
        max_population: extract_max_population,
        mortality_rate: extract_mortality_rate,
        hot_weather_death_rate: cause_of_deaths[:hot_weather] / all_inhabitants.size,
        cold_weather_death_rate: cause_of_deaths[:cold_weather] / all_inhabitants.size,
        starvation_death_rate: cause_of_deaths[:starvation] / all_inhabitants.size,
        thirst_death_rate: cause_of_deaths[:thirst] / all_inhabitants.size,
        old_age_death_rate: cause_of_deaths[:old_age] / all_inhabitants.size
      }
    end

    private

      def extract_average_population
        total = snapshots.inject(0) do |memo, snp|
          memo += snp.stats[:population]
        end

        total.to_f / snapshots.size
      end

      def extract_max_population
        snapshots.map do |snp|
          snp.stats[:population]
        end.max
      end

      def extract_mortality_rate
        total = all_inhabitants.select do |obj|
          obj.dead?
        end.size

        total.to_f / all_inhabitants.size
      end


      def extract_cause_of_death
        causes = all_inhabitants.group_by do |obj|
          obj.cause_of_death
        end

        {
          hot_weather: causes.fetch(:hot_weather, []).size.to_f,
          cold_weather: causes.fetch(:cold_weather, []).size.to_f,
          old_age: causes.fetch(:old_age, []).size.to_f,
          starvation: causes.fetch(:starvation, []).size.to_f,
          thirst: causes.fetch(:thirst, []).size.to_f
        }
      end
  end
end
