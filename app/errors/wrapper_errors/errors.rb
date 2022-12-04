# frozen_string_literal: true
module WrapperErrors
  module Errors; end
end

module WrapperErrors::Errors
  class BaseError < StandardError
    def api_context
      'Generic API endpoint'
    end

    def message
      'Unable to fetch necessary info from the third party endpoints'
    end
  end

  class NoJsonResponse < BaseError
    def message
      'The response is not json parsable'
    end
  end

  class GenericApiError < BaseError
    def message
      'Invalid Response coming from api endpoint'
    end
  end

  class AddressWrapperError < BaseError
    def api_context
      'Google Map API endpoint'
    end
  end

  class WeatherWrapperError < BaseError
    def api_context
      'Open Weather Map API endpoint'
    end
  end

  ### Below are the errors for the open weather api errors
  class NoInvalidOpenWeatherApiKey < WeatherWrapperError
    def message
      'The open weather api key is invalid'
    end
  end

  class NoMainWeatherInfo < WeatherWrapperError
    def message
      'There are no valid current weather info available'
    end
  end




  ### Below are the errors for Google Map errors

  class NoInvalidGoogleMapApiKey < AddressWrapperError
    def message
      'The google map api key is invalid'
    end
  end

  class NoValidAddressProvided < AddressWrapperError
    def message
      'The address is invalid'
    end
  end

  class NoValidGeoInfoFound < AddressWrapperError
    def message
      'Cannot determine the Geo info from the provided address'
    end
  end

  class AmbiguousAddressProvided < AddressWrapperError
    def message
      'The specified Address is ambiguous'
    end
  end

  class CannotDetermineZipCodeOrCountryCode < AddressWrapperError
    def message
      'Cannot determine the zip code and/or country code'
    end
  end

end
