require 'httparty'

module Sinatra
  module AddressHelper
    def get_address(lat, lon)
      response = HTTParty.get("https://nominatim.openstreetmap.org/reverse?format=json&lat=#{lat}&lon=#{lon}")
      address = JSON.parse(response.body)["address"]
      puts "coordinates [#{lat},#{lon}], address: #{address}"
      address
    end

    def valid_address?(address)
      ["Madrid", "Barcelona", "Sevilla"].include?(address["city"])
    end

    def get_city!(lat, lon)
      address = get_address(lat, lon)
      unless valid_address?(address)
        halt(400, "bad_location".to_json)
      end
      address["city"]
    end
  end
end
