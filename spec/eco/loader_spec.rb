require 'test_helper'

describe Eco::Loader do
  let(:loader) { Eco::Loader.new('spec/fixtures/sample.yml') }

  it 'transforms config years into months' do
    loader.yaml['years'] = 2
    loader.load
    loader.config[:months].must_equal 24
  end

  it 'extracts the iterations' do
    loader.yaml['iterations'] = 2
    loader.load
    loader.config[:iterations].must_equal 2
  end

  describe 'load' do

    describe 'extracting species' do
      it 'transforms life_span into months' do
        loader.yaml['species'].first['attributes']['life_span'] = 2
        loader.load
        loader.species.first[:life_span].must_equal 24
      end

      it 'transforms maximum_breeding_age into months' do
        loader.yaml['species'].first['attributes']['maximum_breeding_age'] = 2
        loader.load
        loader.species.first[:maximum_breeding_age].must_equal 24
      end

     it 'transforms minimum_breeding_age into months' do
        loader.yaml['species'].first['attributes']['minimum_breeding_age'] = 2
        loader.load
        loader.species.first[:minimum_breeding_age].must_equal 24
      end

      it 'extracts name, monthly_food_consumption, monthly_water_consumption, gestation_period, minimum_temperature, maximum_temperature' do
        loader.load
        specie = loader.species.first
        specie[:name].wont_be_nil
        specie[:monthly_food_consumption].wont_be_nil
        specie[:monthly_water_consumption].wont_be_nil
        specie[:gestation_period].wont_be_nil
        specie[:minimum_temperature].wont_be_nil
        specie[:maximum_temperature].wont_be_nil
      end
    end

    describe 'extracting habitats' do
      it 'extracts name, monthly_food, monthly_water, summer, spring, fall, winter' do
        loader.load
        habitat = loader.habitats.first
        habitat[:name].wont_be_nil
        habitat[:monthly_food].wont_be_nil
        habitat[:monthly_water].wont_be_nil
        habitat[:summer].wont_be_nil
        habitat[:spring].wont_be_nil
        habitat[:fall].wont_be_nil
        habitat[:winter].wont_be_nil
      end
    end


    describe 'when passing a model' do

      it 'returns an array of simulations' do
        sims = loader.load(Struct.new(:spe, :hbt, :config))
        sims.length.must_be :>, 0
      end
    end
  end
end
