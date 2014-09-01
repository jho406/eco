require 'test_helper'

describe Eco::Species do
  class MockPot
    attr_accessor :current_month, :inhabitants, :habitat

    def add_inhabitant(iht)
      (@inhabitants ||=[]).push(iht)
    end

    def current_month
      0
    end
  end

  let(:pot) { MockPot.new }
  let(:habitat) { Eco::Habitat.new(pot, monthly_food: 5, monthly_water: 5, winter: 0) }
  let(:habitat_attrs) { { monthly_food: 5, monthly_water: 5, winter: 0 } }
  let(:attrs) do
    {
      name: 'kitty',
      monthly_food_consumption: 0,
      monthly_water_consumption: 0,
      life_span: 10,
      minimum_breeding_age: 0,
      maximum_breeding_age: 10,
      gestation_period: 2,
      minimum_temperature: -100,
      maximum_temperature: 100,
      sex: :f
    }
  end

  describe '#match' do
    let(:specie) { Eco::Species.new }

    it 'matches the specie for breeding' do
      specie.matched?.must_equal false
      specie.match
      specie.matched?.must_equal true
    end
  end

  describe '#unmatch' do
    let(:specie) { Eco::Species.new }

    it 'matches the specie for breeding' do
      specie.match
      specie.matched?.must_equal true
      specie.unmatch
      specie.matched?.must_equal false
    end
  end

  describe '#legal_for_breeding?' do
    describe 'when the specie is legal' do
      let(:specie) { Eco::Species.new(attrs.merge(minimum_breeding_age: 1, maximum_breeding_age: 2)) }

      it 'returns true' do
        habitat.add_inhabitant(specie)
        specie.age!(habitat)
        specie.legal_for_breeding?.must_equal true
      end
    end

    describe 'when the specie is below or above age requrements' do
      let(:specie) { Eco::Species.new(attrs.merge(minimum_breeding_age: 1, maximum_breeding_age: 2)) }

      it 'returns false' do
        specie.legal_for_breeding?.must_equal false
        habitat.add_inhabitant(specie)
        specie.age!(habitat)
        specie.age!(habitat)
        specie.age!(habitat)
        specie.legal_for_breeding?.must_equal false
      end
    end
  end

  describe '#age!' do
    let(:specie) { Eco::Species.new(attrs) }

    before do
      habitat.add_inhabitant(specie)
    end

    it 'increases its age by one unit' do
      specie.age.must_equal 0
      specie.age!(habitat)
      specie.age.must_equal 1
    end

    describe 'when the specie is exposed to too much cold' do
      let(:specie) { Eco::Species.new(attrs.merge(minimum_temperature: 0)) }
      let(:habitat) { Eco::Habitat.new(pot, winter: -1000) }

      it 'dies' do
        specie.age!(habitat)
        specie.dead?.must_equal true
        specie.cause_of_death.must_equal :cold_weather
      end
    end

    describe 'when the specie is exposed to too much hot' do
      let(:specie) { Eco::Species.new(attrs.merge(maximum_temperature: 1)) }
      let(:habitat) { Eco::Habitat.new(pot, winter: 10000) }

      it 'dies' do
        specie.age!(habitat)
        specie.dead?.must_equal true
        specie.cause_of_death.must_equal :hot_weather

      end
    end

    describe 'when the specie gets too old' do
      let(:specie) { Eco::Species.new(attrs.merge(life_span: 1)) }
      let(:habitat) { Eco::Habitat.new(pot) }

      it 'dies' do
        specie.age!(habitat)
        specie.age!(habitat)
        specie.dead?.must_equal true
        specie.cause_of_death.must_equal :old_age
      end

    end

    describe 'when the specie gets too thirsty' do
      let(:specie) { Eco::Species.new(attrs.merge(monthly_water_consumption: 1000)) }

      it 'dies' do
        specie.age!(habitat)
        specie.age!(habitat)
        specie.dead?.must_equal true
        specie.cause_of_death.must_equal :thirst
      end

    end

    describe 'when the specie gets too hungry' do
      let(:specie) { Eco::Species.new(attrs.merge(monthly_food_consumption: 1000)) }

      it 'dies' do
        specie.age!(habitat)
        specie.age!(habitat)
        specie.age!(habitat)
        specie.age!(habitat)
        specie.dead?.must_equal true
        specie.cause_of_death.must_equal :starvation
      end

    end

    describe 'when the specie is ready to give birth' do
      let(:specie) { Eco::Species.new(attrs.merge(sex: :f, minimum_breeding_age: 0, maximum_breeding_age: 2, monthly_food_consumption: 0, monthly_water_consumption: 0, gestation_period: 2)) }

      it 'gives birth and becomes single(unmatched) again' do
        habitat.inhabitants.size.must_equal 1
        specie.match
        specie.age!(habitat)
        specie.age!(habitat)
        specie.age!(habitat)
        habitat.inhabitants.size.must_equal 2
        specie.pregnant?.must_equal false
        specie.months_in_gestation.must_equal 0
      end
    end

    describe 'when the specie is matched for breeding' do
      describe 'and the specie is female, in a healty habitat' do
        let(:specie) { Eco::Species.new(attrs.merge(sex: :f, minimum_breeding_age: 0, maximum_breeding_age: 2, monthly_food: 0, monthly_water: 0, gestation_period: 2)) }

        it 'pregnants the specie' do
          specie.match
          specie.age!(habitat)
          specie.pregnant?.must_equal true
        end

        it 'adds to the gestation months' do
          specie.months_in_gestation.must_equal 0
          specie.match
          specie.age!(habitat)
          specie.months_in_gestation.must_equal 1
        end
      end

      describe 'and the specie is male' do
        let(:specie) { Eco::Species.new(attrs.merge(sex: :m, minimum_breeding_age: 0, maximum_breeding_age: 2, monthly_food: 0, monthly_water: 0, gestation_period: 2)) }

        it 'does not pregnants the specie' do
          specie.match
          specie.age!(habitat)
          specie.pregnant?.must_equal false
        end
      end
    end
  end
end
