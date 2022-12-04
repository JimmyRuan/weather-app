module WrapperDto
  class CurrentWeatherDto
    attr_reader :current_temp, :min_temp, :max_temp, :humidity

    def initialize(current_temp:, min_temp:, max_temp:, humidity:)
      @current_temp = current_temp
      @min_temp = min_temp
      @max_temp = max_temp
      @humidity = humidity
    end
  end
end
