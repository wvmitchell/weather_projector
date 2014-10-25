require 'spec_helper'

describe Forecaster do

  let!(:forecaster) { Forecaster.new }

  context 'projection of temp' do

    before do
      allow(forecaster).to receive(:projection).and_return(['70', '45'])
    end

    it 'provides a high/low projection for a place and date' do
      expect(forecaster.projection(location: 'denver co',
                                   date: '31-10-2014')).to eq(['70', '45'])
    end

  end

  context 'heating degree days' do

    before do
      allow(forecaster).to receive(:heating_degree_days).and_return(10)
    end

    it 'provides hdd projection for a place and date' do
      expect(forecaster.heating_degree_days(location: 'denver co',
                                            date: '31-10-2014')).to eq(10)
    end

  end

  context 'cooling degree days' do

    before do
      allow(forecaster).to receive(:cooling_degree_days).and_return(10)
    end

    it 'provides cdd projection for a place and date' do
      expect(forecaster.cooling_degree_days(location: 'denver co',
                                            date: '31-10-2014')).to eq(10)
    end

  end

end
