module Eco
  class Species
    attr_reader :attributes, :months_without_food, :months_without_water, :gestating, :ovulating

    def initialize(attributes={})
      @attributes = attributes
      @age = 0
      @months_without_food = 0
      @months_without_water = 0
      @months_in_gestation = 0
      @sex = attributes[:sex]
    end

    def maximum_breeding_age_in_months
      attributes[:maximum_breeding_age] * 12
    end

    def life_span_in_months
      attributes[:life_span] * 12
    end

    def minimum_breeding_age_in_months
      attributes[:maximum_breeding_age] * 12
    end

    def age!
      @age += 1
    end

    def ovulating
      breeding_start = attributes[:minimum_breeding_age]
      breeding_end = attributes[:maximum_breeding_age]
      !gestating && age >= breeding_start && age <=breeding_end
    end

    def impregnate
      return if !ovulating
      @months_in_gestation = 1
    end

    def give_birth
      gestation_period = attributes[:gestating_period]
      return unless @months_in_gestation >= gestating_period

      self.class.new(attributes)
      @months_in_gestation = 0
    end

    def gestating?
      @months_in_gestation > 0
    end

    def pregnant?
      gestating?
    end

    def consume_food(habitat)
      portion = attributes[:monthly_food_consumption]

      if habitat.provision_food(portion)
        @months_without_food = 0
      else
        @months_without_food +=1
      end
    end

    def consume_water(habitat)
      portion = attributes[:monthly_water_consumption]

      if habitat.provision_water(portion)
        @months_without_water = 0
      else
        @months_without_water +=1
      end
    end
  end
end
