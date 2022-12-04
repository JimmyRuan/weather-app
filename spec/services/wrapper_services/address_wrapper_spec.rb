# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WrapperServices::AddressWrapper do
  describe "#fetch_geo_code" do
    context 'valid address is provided' do
      it 'fetches the geo_code info from the address' do

        address = '1600 Amphitheatre Parkway Mountain View, CA 94043'
        google_map_key = 'valid-google-map-key'
        expected_host = WrapperServices::AddressWrapper::GOOGLE_MAP_HOST
        expected_get_geo_path = WrapperServices::AddressWrapper::GET_GEO_INFO_PATH

        json_response_str = File.read("#{Rails.root}/spec/fixtures/google_map_info_example.json")
        geo_info_json = JSON.parse(json_response_str)

        Rails.application.credentials.google_map_key = google_map_key

        stub_request(:get, "#{expected_host}/#{expected_get_geo_path}?address=#{address}&key=#{google_map_key}").
          with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Weather App Agent'
            }).
          to_return(status: 200, body: json_response_str, headers: {})


        zip_code, country_code = WrapperServices::AddressWrapper.new.fetch_geo_info(address: address)

        expect(zip_code).to eq('94043')
        expect(country_code).to eq('us')
      end
    end
  end
end
