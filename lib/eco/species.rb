module Eco
  class Species
    LIFE_FINDS_A_WAY = 0.5

    attr_reader :age, :matched, :attributes, :months_without_food, :months_without_water, :months_in_gestation, :ovulating, :cause_of_death
    attr :habitat

    def initialize(attributes={})
      @attributes = attributes
      @age = 0
      @months_without_food = 0
      @months_without_water = 0
      @months_in_gestation = 0
      @matched = false
      @pregnant = false
      @dead = false
    end

    # def maximum_breeding_age_in_months
    #   maximum_breeding_age * 12
    # end

    # def life_span_in_months
    #   life_span * 12
    # end

    # def minimum_breeding_age_in_months
    #   maximum_breeding_age * 12
    # end

    def matched?
      @matched
    end

    def match
      @matched = true
    end

    def unmatch
      @matched = false
    end

    def age!(habitat)
      return if dead?
      @habitat = habitat
      @age += 1

      consume_food(habitat)
      consume_water(habitat)

      endure_cold
      endure_hot
      endure_old_age
      endure_thirst
      endure_hunger

      impregnate
      gestate
      give_birth
    end

    def dead?
      @dead
    end

    def legal_for_breeding?
      age >= minimum_breeding_age && age <= maximum_breeding_age
    end

    def pregnant?
      @pregnant
    end

    def consume_food(habitat)
      if habitat.provision_food(monthly_food_consumption)
        @months_without_food = 0
      else
        @months_without_food +=1
      end
    end

    def consume_water(habitat)
      if habitat.provision_water(monthly_water_consumption)
        @months_without_water = 0
      else
        @months_without_water +=1
      end
    end

    def male?
      sex == :m
    end

    def female?
      sex == :f
    end

    private

      def endure_cold
        return if habitat.temperature > minimum_temperature

        @dead = true
        @cause_of_death = :cold_weather
      end

      def endure_hot
        return if habitat.temperature < maximum_temperature

        @dead = true
        @cause_of_death = :hot_weather
      end

      def endure_old_age
        return if age <= life_span

        @dead = true
        @cause_of_death = :old_age
      end

      def endure_thirst
        return unless @months_without_water > 1

        @dead = true
        @cause_of_death = :thirst
      end

      def endure_hunger
        return unless @months_without_food > 3

        @dead = true
        @cause_of_death = :starvation
      end

      def method_missing(m, *args, &block)
        return super if !attributes.has_key?(m.to_sym)
        attributes[m.to_sym]
      end

      def impregnate
        return if sex == :m || pregnant? || !legal_for_breeding? || !matched ||dead?

        chance_of_breeding = habitat.healthy? ? 100 : LIFE_FINDS_A_WAY
        @pregnant = Utils::chance(chance_of_breeding)
      end

      def give_birth
        return if !pregnant?
        return unless months_in_gestation == gestation_period

        @months_in_gestation = 0
        @pregnant = false

        baby_sex = Utils::chance(50, success: :m, fail: :f)
        baby = self.class.new(attributes.merge(sex: baby_sex))
        habitat.add_inhabitant(baby)
        unmatch
      end

      def gestate
        return if !pregnant?
        @months_in_gestation += 1
      end
  end
end
