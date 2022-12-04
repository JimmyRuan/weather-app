# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WrapperServices::WeatherWrapper do
  describe '#current_weather' do
    context 'valid latitude and longitude is provided' do
      it 'returns valid weather info' do
        longitude = -122.0841877
        latitude = 37.4223878
        weather_api_key = 'valid-api-key'
        expected_host = WrapperServices::WeatherWrapper::WEATHER_API_HOST
        current_weather_path = WrapperServices::WeatherWrapper::CURRENT_WEATHER_PATH
        json_response_str = File.read("#{Rails.root}/spec/fixtures/current_weather_example.json")

        Rails.application.credentials.open_weather_api_key = weather_api_key

        stub_request(:get, "#{expected_host}/#{current_weather_path}?appid=#{weather_api_key}&unit=imperial&lat=#{latitude}&lon=#{longitude}").
          with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Weather App Agent'
            }).
          to_return(status: 200, body: json_response_str, headers: {})


        weather_wrapper = WrapperServices::WeatherWrapper.new
        result = weather_wrapper.current_weather(latitude: latitude, longitude: longitude)

        expect(result.class).to eq(WrapperDto::CurrentWeatherDto)
        expect(result.current_temp).to eq(48.45)
        expect(result.min_temp).to eq(46.22)
        expect(result.max_temp).to eq(51.89)
        expect(result.humidity).to eq(94)
      end
    end
  end
end
