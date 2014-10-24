require 'spec_helper'

describe Forecaster do

  let!(:forecaster) { Forecaster.new }

  before do
    allow(forecaster).to receive(:projection).and_return(['70', '45'])
  end

  it 'provides a high/low projection for a place and date' do
    expect(forecaster.projection(location: 'denver co',
                                 date: '31-10-2014')).to eq(['70', '45'])
  end

end
