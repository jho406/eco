module Eco
  class PassageOfTime

    attr_reader :snapshots, :current_month, :stats, :age
    attr_reader :all_inhabitants, :frozen_inhabitants,
      :burnt_inhabitants, :aged_inhabitants, :starved_inhabitants

    def initialize(opts={})
      @species_klass = opts.fetch(:species_klass, Species)
      @habitat_klass = opts.fetch(:habitat_klass, Habitat)
      @current_month = 0
      @age = 0

      specie_attrs = opts.fetch(:species_options, {})
      habitat_attrs = opts.fetch(:habitat_options, {})

      habitat = @habitat_klass.new(self, habitat_attrs)
      @snapshots = [habitat]

      adam = @species_klass.new(specie_attrs.merge(sex: :m))
      eve = @species_klass.new(specie_attrs.merge(sex: :f))
      [adam, eve].each{ |spe| habitat.add_inhabitant(spe) }
    end

    def all_inhabitants
      snapshots.last.inhabitants || []
    end

    def age!
      @age +=1
      @current_month = @age%12
      snapshot = snapshots.last.clone
      snapshot.age!
      @snapshots.push(snapshot)
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
        causes = all_inhabitants.group_by do |obj|
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
  end
end
