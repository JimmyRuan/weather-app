module WrapperServices
  class WrapperHelper
    USER_AGENT = 'Weather App Agent'

    class << self
      def http_client(host)
        Faraday.new(
          url: host,
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
        return if response.status < 400

        error_str = "API error with http_code=#{response.status} has #{response.body}"
        error = WrapperErrors::Errors::GenericApiError.new(error_str)
        Rails.logger.error(error_str)
        raise error
      end
    end
  end
end
