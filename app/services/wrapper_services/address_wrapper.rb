# frozen_string_literal: true

module WrapperServices
  class AddressWrapper
    GOOGLE_MAP_HOST = 'https://maps.googleapis.com'
    GET_GEO_INFO_PATH = 'maps/api/geocode/json'
    USER_AGENT = 'Weather App Agent'

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

      handle_error_from_response(response)
      json_response = parse_json_response(response)

      raise WrapperErrors::Errors::NoValidGeoInfoFound if json_response[:results].blank? || !json_response[:results].is_a?(Array)

      raise WrapperErrors::Errors::AmbiguousAddressProvided if json_response[:results].count > 1

      parse_geo_info(json_response)
    end

    def google_map_http_client
      Faraday.new(
        url: GOOGLE_MAP_HOST,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'User-Agent' => USER_AGENT
        }
      ) do |faraday|
        faraday.adapter :net_http
      end
    end

    def parse_json_response(response)
      begin
        json_response = JSON.parse(response.body)
        json_response = json_response.deep_symbolize_keys
      rescue JSON::ParserError => _e
        error_str = "the response is not json parsable. It has http_code = #{response.status}, response_body=#{response.body}"
        error = WrapperErrors::Errors::NoJsonResponse.new(error_str)
        Rails.logger.error(error_str)
        raise error
      end

      json_response
    end

    def handle_error_from_response(response)
      if response.status >= 400
        error_str = "API error with http_code=#{response.status} has #{response.body}"
        error = WrapperErrors::Errors::GenericApiError.new(error_str)
        Rails.logger.error(error_str)
        raise error
      end
    end

    def parse_geo_info(json_response)
      geo_info = json_response[:results][0]
      address_components = geo_info[:address_components]
      index = 0
      zip_code = nil
      country_code = nil
      while index < address_components.count
        address_component = address_components[index]
        case address_component[:types]
        when ['postal_code']
          zip_code = address_component[:short_name]
        when %w[country political]
          country_code = address_component[:short_name]
        end
        index += 1

        if zip_code.present? && country_code.present?
          return [zip_code, country_code].map(&:downcase)
        end
      end

      raise WrapperErrors::Errors::CannotDetermineZipCodeOrCountryCode
    end
  end
end
