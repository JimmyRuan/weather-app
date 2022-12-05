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

    def weather_summary(latitude:, longitude:)
      current_weather = current_weather(latitude: latitude, longitude: longitude)
      weather_forecast_list = weather_forecast(latitude: latitude, longitude: longitude)

      {
        current_weather: current_weather.to_hash,
        forecasts: weather_forecast_list.map(&:to_hash),
        created_at: Time.now.utc.to_s(:d)
      }
    end

    def current_weather(latitude:, longitude:)
      response = weather_client.get(CURRENT_WEATHER_PATH) do |request|
        request.params['appid'] = @weather_map_api_key
        request.params['units'] = WEATHER_FORECAST_UNIT
        request.params['lat'] = latitude
        request.params['lon'] = longitude
      end

      WrapperHelper.handle_error_from_response(response)
      json_response = WrapperHelper.parse_json_response(response)
      main_weather = json_response[:main]
      weather_type = json_response.dig(:weather, 0, :main)
      raise WrapperErrors::Errors::NoMainWeatherInfo if main_weather.blank? || weather_type.blank?

      WrapperDto::WeatherDto.new(
        current_temp: main_weather[:temp],
        min_temp: main_weather[:temp_min],
        max_temp: main_weather[:temp_max],
        humidity: main_weather[:humidity],
        weather_type: weather_type,
        timestamp: nil,
        timezone: nil
      )
    end

    def weather_forecast(latitude:, longitude:)
      response = weather_client.get(WEATHER_FORECAST_PATH) do |request|
        # total number of forecast items for every 3 hours, maximum 5 days in total
        # request.params['cnt'] = MAXIMUM_FORECAST_ITEMS
        request.params['appid'] = @weather_map_api_key
        # request.params['cnt'] = determine_total_forecasts(total_forecasts)
        request.params['units'] = WEATHER_FORECAST_UNIT
        request.params['lat'] = latitude
        request.params['lon'] = longitude
      end

      WrapperHelper.handle_error_from_response(response)
      json_response = WrapperHelper.parse_json_response(response)

      raise WrapperErrors::Errors::NoWeatherForecastInfo if json_response[:list]&.count != 40
      raise WrapperErrors::Errors::NoTimeInfoForWeather if json_response.dig(:city, :timezone).blank?

      timezone = json_response.dig(:city, :timezone)
      forecast_list = json_response[:list]
      formatted_forecast_list = []

      forecast_list.each do |forecast_info|
        if forecast_info[:main].nil? || forecast_info.dig(:weather, 0, :main).nil? || forecast_info[:dt_txt].nil?
          raise WrapperErrors::Errors::NoWeatherForecastInfo
        end

        main_weather = forecast_info[:main]
        formatted_forecast_list << WrapperDto::WeatherDto.new(
          current_temp: main_weather[:temp],
          min_temp: main_weather[:temp_min],
          max_temp: main_weather[:temp_max],
          humidity: main_weather[:humidity],
          weather_type: forecast_info.dig(:weather, 0, :main),
          timestamp: forecast_info[:dt_txt],
          timezone: timezone
        )
      end

      formatted_forecast_list
    end

    def weather_client
      WrapperHelper.http_client(WEATHER_API_HOST)
    end

    def determine_total_forecasts(provided_total)
      return MAXIMUM_FORECAST_ITEMS if provided_total.nil? || provided_total > MAXIMUM_FORECAST_ITEMS

      provided_total
    end
  end
end
