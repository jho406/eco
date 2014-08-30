require 'debugger'
module Eco
  class PassageOfTime

    attr_reader :snapshots
    attr_reader :all_inhabitants, :frozen_inhabitants,
      :burnt_inhabitants, :aged_inhabitants, :starved_inhabitants

    def initialize(species_klass, habitat_klass = Habitat)
      @all_inhabitants = []

      habitat = habitat_klass.new(self)
      habitat.add_inhabitant(species_klass.new(sex: :m))
      habitat.add_inhabitant(species_klass.new(sex: :f))
      habitat.refresh_stats
      @snapshots = [habitat]
    end

    def age
      snapshot = snapshots.last.class.new(self, all_inhabitants)
      snapshot.age
      @snapshots.push(snapshot)
    end

    def average_population
      total = snapshots.inject(0) do |memo, obj|
        memo += obj.population
      end

      total.to_f / snapshots.size
    end

    def max_population
      snapshots.max_by(&:population).population
    end

    def add_inhabitant(ibt, type=:all)
      instance_eval("@#{type}_inhabitants.push(ibt)")
    end

    def pct_starved
    end


    def pct_aged
    end

    def pct_frozen
    end

    def pct_burnt
    end
  end
end
