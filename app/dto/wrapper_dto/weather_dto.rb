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

    def to_hash
      weather_hash = {
        current_temperature: @current_temp,
        minimum_temperature: @min_temp,
        maximum_temperature: @max_temp,
        weather_condition: @weather_type
      }

      if @timestamp.present? && @timezone.present?
        return weather_hash.merge({ timestamp: @timestamp, timezone: @timezone })
      end

      weather_hash
    end
  end
end
