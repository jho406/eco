module Eco
  class PassageOfTime

    attr_reader :snapshots
    attr_reader :all_inhabitants, :frozen_inhabitants,
      :burnt_inhabitants, :aged_inhabitants, :starved_inhabitants

    def initialize(species_klass, habitat_klass = Habitat)
      set_inhabitants

      habitat = habitat_klass.new(self)
      habitat.add_inhabitant(species_klass.new(sex: :m))
      habitat.add_inhabitant(species_klass.new(sex: :f))

      @snapshots = [habitat]
    end

    def age
      snapshot = snapshots.last.class.new(self, all_inhabitants)
      snapshot.age
      @snapshots.push(snapshot)
    end

    def add_inhabitant(ibt, type=:all)
      instance_eval("@#{type}_inhabitants.push(ibt)")
    end

    private

    def set_inhabitants
      @all_inhabitants = []
      @starved_inhabitants = []
      @aged_inhabitants = []
      @frozen_inhabitants = []
      @burnt_inhabitants = []
    end
  end
end
