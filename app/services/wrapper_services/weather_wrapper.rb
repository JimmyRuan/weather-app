module ApiServices
  class WeatherApiService
    WEATHER_API_HOST = 'http://api.openweathermap.org'
    CURRENT_WEATHER_PATH = '/data/2.5/weather'
    WEATHER_FORECAST_PATH = '/data/2.5/forecast'

    # 3 hours per interval, 5 days is equal to 60*60*24/3 = 28800
    MAXIMUM_FORECAST_ITEMS = 2
    WEATHER_FORECAST_UNIT = 'imperial'

    def initialize(api_key: nil)
      @weather_map_api_key = api_key || Rails.application.credentials.open_weather_api_key
      raise WrapperErrors::Errors::NoInvalidOpenWeatherApiKey unless @weather_map_api_key
    end

    def current_weather(latitude:, longitude:)
      response = weather_client.get(GET_GEO_INFO_PATH) do |request|
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
