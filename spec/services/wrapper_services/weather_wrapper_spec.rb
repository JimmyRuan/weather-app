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

        stub_request(:get, "#{expected_host}/#{current_weather_path}?appid=#{weather_api_key}&units=imperial&lat=#{latitude}&lon=#{longitude}").
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

        expect(result.class).to eq(WrapperDto::WeatherDto)
        expect(result.current_temp).to eq(48.45)
        expect(result.min_temp).to eq(46.22)
        expect(result.max_temp).to eq(51.89)
        expect(result.humidity).to eq(94)
        expect(result.weather_type).to eq('Mist')
        expect(result.timestamp).to be_nil
        expect(result.timezone).to be_nil
      end
    end
  end

  describe '#weather_forecast' do
    context 'valid latitude and longitude is provided' do
      it 'returns valid weather forecast info' do
        longitude = -122.0841877
        latitude = 37.4223878
        weather_api_key = 'valid-api-key'
        expected_host = WrapperServices::WeatherWrapper::WEATHER_API_HOST
        weather_forecast_path = WrapperServices::WeatherWrapper::WEATHER_FORECAST_PATH
        json_response_str = File.read("#{Rails.root}/spec/fixtures/weather_forecast_example.json")

        Rails.application.credentials.open_weather_api_key = weather_api_key

        stub_request(:get, "#{expected_host}/#{weather_forecast_path}?appid=#{weather_api_key}&lat=#{latitude}&lon=#{longitude}&units=imperial").
          with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Weather App Agent'
            }).
          to_return(status: 200, body: json_response_str, headers: {})


        weather_wrapper = WrapperServices::WeatherWrapper.new
        results = weather_wrapper.weather_forecast(latitude: latitude, longitude: longitude)

        expect(results.class).to eq(Array)
        expect(results.count).to eq(40)
        expect(results[0].class).to eq(WrapperDto::WeatherDto)

        weather_dto = results[0]

        expect(weather_dto.current_temp).to eq(48.85)
        expect(weather_dto.min_temp).to eq(48.07)
        expect(weather_dto.max_temp).to eq(48.85)
        expect(weather_dto.humidity).to eq(94)
        expect(weather_dto.weather_type).to eq('Rain')
        expect(weather_dto.timestamp).to eq('2022-12-04 09:00:00')
        expect(weather_dto.timezone).to eq(-28800)
      end
    end
  end

  describe '#weather_summary' do
    context 'valid current weather and weather forecast available' do
      it 'returns weather summary' do
        current_time = Time.now.utc
        Timecop.freeze(current_time)
        longitude = -122.0841877
        latitude = 37.4223878
        weather_api_key = 'valid-api-key'
        json_response_str1 = File.read("#{Rails.root}/spec/fixtures/current_weather_example.json")
        json_response_str2 = File.read("#{Rails.root}/spec/fixtures/weather_forecast_example.json")

        stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?appid=valid-api-key&lat=37.4223878&lon=-122.0841877&units=imperial").
          with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Weather App Agent'
            }).
          to_return(status: 200, body: json_response_str1, headers: {})

        stub_request(:get, "http://api.openweathermap.org/data/2.5/forecast?appid=valid-api-key&lat=37.4223878&lon=-122.0841877&units=imperial").
          with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Weather App Agent'
            }).
          to_return(status: 200, body: json_response_str2, headers: {})

        Rails.application.credentials.open_weather_api_key = weather_api_key

        weather_wrapper = WrapperServices::WeatherWrapper.new
        weather_summary = weather_wrapper.weather_summary(latitude: latitude, longitude: longitude)
        expected_current_weather = {
          current_temperature: 48.45,
          minimum_temperature: 46.22,
          maximum_temperature: 51.89,
          weather_condition: "Mist"
        }

        expected_forecast_keys = %i[current_temperature minimum_temperature maximum_temperature weather_condition timestamp timezone]

        expect(weather_summary.keys).to eq(%i[current_weather forecasts created_at])
        expect(weather_summary[:current_weather]).to eq(expected_current_weather)
        expect(weather_summary[:forecasts].count).to eq(40)
        expect(weather_summary[:forecasts][0].keys).to eq(expected_forecast_keys)
        expect(weather_summary[:created_at]).to eq(current_time.to_s(:d))
      end
    end
  end
end
