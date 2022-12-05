Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'weather_by_address', to: 'weathers#weather_by_address'
end
