module StateHelper
  BASE_URL = "http://localhost:4567"
  
  attr_accessor :vehicle
  attr_accessor :response
end

module VehicleHelper
  def register_vehicle(vehicle)
    HTTParty.put("#{BASE_URL}/vehicle", body: vehicle.to_json)
  end

  def get_vehicle(plate_number)
    HTTParty.get("#{BASE_URL}/vehicle/#{plate_number}")
  end

  def reserve_vehicle(lat, lon)
    location = { :lat => lat, :lon => lon }
    HTTParty.post("#{BASE_URL}/vehicles/reserve", body: location.to_json)
  end

  def get_vehicles_in_city(city)
    HTTParty.get("#{BASE_URL}/vehicles/#{city}")
  end
end

World(StateHelper, VehicleHelper)