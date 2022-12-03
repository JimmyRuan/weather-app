# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WrapperServices::AddressWrapper do
  describe "#fetch_geo_code" do
    context 'valid address is provided' do
      it 'fetches the geo_code info from the address' do
        puts 'this is banana time'
        expect('banana').to eq('banan')
      end
    end
  end
end
