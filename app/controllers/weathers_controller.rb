class WeathersController < ApplicationController
  def weather_by_address
    weather_summary = WeatherService.new.weather_summary(address: address_params)
    render json: weather_summary, status: :ok
  rescue StandardError => e
    Rails.logger.error({
                         error_location: 'WeathersController#weather_by_address',
                         error_class: e.class,
                         error_message: e.message,
                         error_backtrace: e.backtrace
                       })
    render json: { error: e.message }, status: :bad_request
  end

  def address_params
    params.require(:address)
  end
end
