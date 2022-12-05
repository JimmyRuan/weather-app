# frozen_string_literal: true

module WrapperServices
  class AddressWrapper
    GOOGLE_MAP_HOST = 'https://maps.googleapis.com'
    GET_GEO_INFO_PATH = 'maps/api/geocode/json'

    def initialize(api_key: nil)
      @google_map_api_key = api_key || Rails.application.credentials.google_map_key
      raise WrapperErrors::Errors::NoInvalidGoogleMapApiKey unless @google_map_api_key
    end

    def fetch_geo_info(address:)
      raise WrapperErrors::Errors::NoValidAddressProvided unless address

      response = google_map_http_client.get(GET_GEO_INFO_PATH) do |request|
        request.params['key'] = @google_map_api_key
        request.params['address'] = address
      end

      WrapperHelper.handle_error_from_response(response)
      json_response = WrapperHelper.parse_json_response(response)

      if json_response[:results].blank? || !json_response[:results].is_a?(Array)
        raise WrapperErrors::Errors::NoValidGeoInfoFound
      end

      raise WrapperErrors::Errors::AmbiguousAddressProvided if json_response[:results].count > 1

      parse_geo_info(json_response)
    end

    def google_map_http_client
      WrapperHelper.http_client(GOOGLE_MAP_HOST)
    end

    def parse_geo_info(json_response)
      geo_info = json_response[:results][0]
      address_components = geo_info[:address_components]
      zip_code, country_code = zip_and_country_code(address_components)
      lat_long_info = geo_info.dig(:geometry, :location)

      WrapperDto::LocationDto.new(
        latitude: lat_long_info[:lat],
        longitude: lat_long_info[:lng],
        zip_code: zip_code,
        country_code: country_code
      )
    end

    def zip_and_country_code(address_components)
      index = 0
      while index < address_components.count
        address_component = address_components[index]
        address_types = address_component[:types]
        address_value = address_component[:short_name]

        if address_types.include?('postal_code')
          zip_code = address_value
        elsif address_types.include?('country')
          country_code = address_value
        end
        index += 1

        return [zip_code, country_code] if zip_code.present? && country_code.present?
      end

      raise WrapperErrors::Errors::CannotDetermineZipCodeOrCountryCode
    end
  end
end
