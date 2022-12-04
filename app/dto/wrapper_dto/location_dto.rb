module WrapperDto
  class LocationDto
    attr_reader :latitude, :longitude, :zip_code, :country_code

    def initialize(latitude:, longitude:, zip_code:, country_code:)
      @latitude = latitude
      @longitude = longitude
      @zip_code = zip_code
      @country_code = country_code
    end
  end
end
