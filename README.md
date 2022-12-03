# README

### Architecture of weather app

Project Requirements:
The weather forecast should included the following information:
1. Current temperature
2. Bonus points - Retrieve high/low and/or extended forecast
3. Display the requested forecast details to the user
4. Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
5. Display indicator if result is pulled from cache.


Project Solution:
1. Use https://www.meteomatics.com/ api endpoints for weather information
2. https://home.openweathermap.org/users/sign_up


>> https://api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=f0c14e1f31bc52fa96fcb1c3c0ea46ad
> 
> https://openweathermap.org/forecast5#data

https://docs.google.com/document/d/1M8I04MbydcYQh41jbam3KWoh_62d-69J/edit



### How to implement the solution
1. send user address to google map api service to get `zipcode`, `country code` and `latitude` and `longitude` info
2. use the obtained `zipcode` and `country code`,  and `weather api current weather` endpoint to fetch the
   current address weather.
3. use the obtained `zipcode` and `country code`, and `weather api current weather` endpoint to fetch the
   current address weather forecast.
4. the information fetched with the specified `zipcode` and `country code` should be used to store the weather info
   for 30min. If there are no specific zipcode, use `latitude-longitude` info for the address.









This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
