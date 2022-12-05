# README

### Architecture of weather app
### How to implement the solution
1. send user address to google map api service to get `zipcode`, `country code` and `latitude` and `longitude` info
2. use the obtained `zipcode` and `country code`,  and `weather api current weather` endpoint to fetch the
   current address weather.
3. use the obtained `zipcode` and `country code`, and `weather api current weather` endpoint to fetch the
   current address weather forecast.
4. the information fetched with the specified `zipcode` and `country code` should be used to store the weather info
   for 30min. If there are no specific zipcode, use `latitude-longitude` info for the address.


