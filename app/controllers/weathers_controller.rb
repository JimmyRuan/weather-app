class WeathersController < ApplicationController
  def weather_by_address
    weather_summary = WeatherService.new.weather_summary( address: address_params )
    render json: weather_summary, status: :ok
  rescue => error
    Rails.logger.error({
                         error_location: 'WeathersController#weather_by_address',
                         error_class: error.class,
                         error_message: error.message,
                         error_backtrace: error.backtrace
                       })
    render json: {error: error.message}, status: :bad_request
  end

  def address_params
    params.require(:address)
  end
end
