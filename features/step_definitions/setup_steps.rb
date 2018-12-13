require 'httparty'

Before do
  vehicles = HTTParty.get("#{BASE_URL}/vehicles")
  vehicles.each do |v|
    HTTParty.delete("#{BASE_URL}/vehicle/#{v["plate_number"]}")
  end
end