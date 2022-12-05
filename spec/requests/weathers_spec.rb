require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /weather_by_address" do
    context 'valid address is provided, and the weather and geo location service is available' do
      it 'returns valid weather info' do
        Rails.application.credentials.google_map_key = 'valid-google-map-key'
        Rails.application.credentials.open_weather_api_key = 'valid-weather-api-key'
        address_str = '1600 Amphitheatre Parkway Mountain View, CA 94043'
        time_now = Time.now.utc.to_s(:d)
        location_dto = WrapperDto::LocationDto.new(
          latitude: 123,
          longitude: 456,
          zip_code: 94043,
          country_code: 'us'
        )

        weather_dto = WrapperDto::WeatherDto.new(
          current_temp: 45,
          min_temp: 42,
          max_temp: 60,
          humidity: 90,
          weather_type: 'Sunny',
          timestamp: Time.now.to_s(:d),
          timezone: 3939
        )


        expect_any_instance_of(WrapperServices::AddressWrapper).to receive(:fetch_geo_info).
          with(address: address_str).and_return(location_dto)

        expect_any_instance_of(WrapperServices::WeatherWrapper).to receive(:weather_summary).with(
          latitude: location_dto.latitude,
          longitude: location_dto.longitude
        ).and_return({
                       current_weather: weather_dto.to_hash,
                       forecasts: [weather_dto].map(&:to_hash),
                       created_at: time_now
                     })


        get '/weather_by_address', params: {address: address_str}

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response.keys).to eq(%w[current_weather forecasts created_at is_cached])
      end
    end
  end
end
