module Eco
  class Loader
    attr_reader :yaml, :species, :habitats, :config

    def initialize(path)
      @yaml = YAML.load_file(path)
      @config = {}
    end

    def load(model=nil)
      extract
      transform_species
      transform_habitats

      return if model.nil?
      load_simulations(model)
    end

    private

      def extract
        @species = @yaml['species']
        @habitats = @yaml['habitats']

        @config[:months] = yaml['years'] * 12
        @config[:iterations] = yaml['iterations']
      end

      def transform_species
        @species = @species.map do |specie|
          {
            name: specie['name'],
            monthly_food_consumption: specie['attributes']['monthly_food_consumption'],
            monthly_water_consumption: specie['attributes']['monthly_water_consumption'],
            life_span: specie['attributes']['life_span'] * 12,
            minimum_breeding_age: specie['attributes']['minimum_breeding_age'] * 12,
            maximum_breeding_age: specie['attributes']['maximum_breeding_age'] * 12,
            gestation_period: specie['attributes']['gestation_period'],
            minimum_temperature: specie['attributes']['minimum_temperature'],
            maximum_temperature: specie['attributes']['maximum_temperature'],
          }
        end
      end

      def transform_habitats
        @habitats = @habitats.map do |hbt|
          {
            name: hbt['name'],
            monthly_food: hbt['monthly_food'],
            monthly_water: hbt['monthly_water'],
            summer: hbt['average_temperature']['summer'],
            spring: hbt['average_temperature']['spring'],
            fall: hbt['average_temperature']['fall'],
            winter: hbt['average_temperature']['winter'],
          }
        end
      end

      def load_simulations(model)
        simulations = []
        @species.each do |spe|
          @habitats.each do |hbt|
            simulations << model.new(spe, hbt, config)
          end
        end

        simulations
      end
  end
end
