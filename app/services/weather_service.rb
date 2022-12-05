class WeatherService
  WEATHER_CACHING_DURATION = 30.minutes

  def weather_summary(address:)
    weather_with_cache = weather_summary_with_cache(address: address)
    weather_with_cache[:is_cached] = @is_data_cache

    weather_with_cache
  end

  def weather_summary_with_cache(address:)
    location_dto = WrapperServices::AddressWrapper.new.fetch_geo_info(address: address)

    if location_dto.zip_code.present? && location_dto.country_code.present?
      @is_data_cache = true
      caching_key = "weather-info:#{location_dto.zip_code}-#{location_dto.country_code}"
      Rails.cache.fetch(caching_key, expires_in: WEATHER_CACHING_DURATION) do
        @is_data_cache = false
        fetch_weather_info(location_dto)
      end
    else
      fetch_weather_info(location_dto)
    end
  end

  def fetch_weather_info(location_dto)
    WrapperServices::WeatherWrapper.new.weather_summary(
      latitude: location_dto.latitude,
      longitude: location_dto.longitude
    )
  end
end
