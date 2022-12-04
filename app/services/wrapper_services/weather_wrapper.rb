module WrapperServices
  class WeatherWrapper
    WEATHER_API_HOST = 'http://api.openweathermap.org'
    CURRENT_WEATHER_PATH = 'data/2.5/weather'
    WEATHER_FORECAST_PATH = 'data/2.5/forecast'

    # 3 hours per interval, 5 days is equal to 24*5/3 = 40 units
    MAXIMUM_FORECAST_ITEMS = 2
    WEATHER_FORECAST_UNIT = 'imperial'

    def initialize(api_key: nil)
      @weather_map_api_key = api_key || Rails.application.credentials.open_weather_api_key
      raise WrapperErrors::Errors::NoInvalidOpenWeatherApiKey unless @weather_map_api_key
    end

    def current_weather(latitude:, longitude:)
      response = weather_client.get(CURRENT_WEATHER_PATH) do |request|
        request.params['appid'] = @weather_map_api_key
        request.params['unit'] = WEATHER_FORECAST_UNIT
        request.params['lat'] = latitude
        request.params['lon'] = longitude
      end

      WrapperHelper.handle_error_from_response(response)
      json_response = WrapperHelper.parse_json_response(response)
      main_weather = json_response[:main]
      raise WrapperErrors::Errors::NoMainWeatherInfo.new if main_weather.blank?

      WrapperDto::CurrentWeatherDto.new(
        current_temp: main_weather[:temp],
        min_temp: main_weather[:temp_min],
        max_temp: main_weather[:temp_max],
        humidity: main_weather[:humidity]
      )
    end

    def weather_forecast(latitude:, longitude:)
      response = weather_client.get(WEATHER_FORECAST_PATH) do |request|
        # total number of forecast items for every 3 hours, maximum 5 days in total
        request.params['cnt'] = MAXIMUM_FORECAST_ITEMS
        request.params['appid'] = @weather_map_api_key
        request.params['unit'] = WEATHER_FORECAST_UNIT
        request.params['lat'] = latitude
        request.params['lon'] = longitude
      end

      WrapperHelper.handle_error_from_response(response)
      json_response = WrapperHelper.parse_json_response(response)

    end

    def weather_client
      WrapperHelper.http_client(WEATHER_API_HOST)
    end
  end
end
