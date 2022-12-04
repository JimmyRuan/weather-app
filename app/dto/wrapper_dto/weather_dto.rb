module WrapperDto
  class WeatherDto
    attr_reader :current_temp, :min_temp, :max_temp, :humidity, :weather_type, :timestamp, :timezone

    def initialize(current_temp:, min_temp:, max_temp:, humidity:, weather_type:, timestamp:, timezone:)
      @current_temp = current_temp
      @min_temp = min_temp
      @max_temp = max_temp
      @humidity = humidity
      @weather_type = weather_type
      @timestamp = timestamp
      @timezone = timezone
    end
  end
end
