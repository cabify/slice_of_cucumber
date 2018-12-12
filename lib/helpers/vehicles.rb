require 'haversine'
require_relative '../database/vehicles'

module Distance
  def self.get_nearest(vehicles, lat, lon)
    nearest = vehicles.first
    best_distance = Haversine.distance(nearest[:lat], nearest[:lon], lat, lon)

    vehicles.each do |v|
      this_distance = Haversine.distance(v[:lat], v[:lon], lat, lon)
      if this_distance < best_distance
        nearest = v
      end
    end

    nearest
  end
end

module Sinatra
  module VehiclesHelper
    def add_vehicle(conn)
      require 'byebug'
      byebug
      request.body.rewind

      vehicle = JSON.parse(request.body.read)
      vehicle = vehicle.transform_keys(&:to_sym)

      vehicle[:state] = "free"
      vehicle[:city] = get_city!(vehicle[:lat], vehicle[:lon]) 

      vehicle_id = conn.insert(vehicle)

      halt(200, conn.where(:id => vehicle_id).first.to_json)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def update_vehicle(conn, values)
      id = params["id"]
      request.body.rewind

      values = JSON.parse(request.body.read)
      values = values.transform_keys(&:to_sym)
      values[:city] = get_city!(vehicle[:lat], vehicle[:lon])
      puts values

      vehicle = conn.where(id: id, state: "free").first

      unless vehicle.nil? 
        conn.where(id: id).update(lon: values[:lon], lat: values[:lat], city: values[:city])
        halt(200, conn.where(id: id).first.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def delete_vehicle(conn, id)
      id = params["id"]
      unless conn.where(id: id).first.nil?
        conn.where(id: id).delete()
        halt(200)
      end
      halt(404)
    end

    def get_vehicle(conn)
      id = params["id"]
      vehicle = conn.where(id: id).first
      unless vehicle.nil?
        halt(200, vehicle.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def get_all_vehicles(conn)
      vehicles = conn.all()
      unless vehicles.nil? || vehicles.empty?
        halt(200, vehicles.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e)
    end

    def get_city_vehicles(conn)
      city = params["city"]
      vehicles = conn.where(city: city, state: "free").all()
      unless vehicles.nil? || vehicles.empty?
        halt(200, vehicles.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def reserve_vehicle(conn)
      request.body.rewind

      from = JSON.parse(request.body.read)
      from = from.transform_keys(&:to_sym)

      puts from

      city = get_city!(from[:lat], from[:lon]) 
      vehicles = conn.where(city: city, state: "free").all()

      unless vehicles.nil? || vehicles.empty?
        nearest = Distance::get_nearest(vehicles, from[:lat], from[:lon])
        conn.where(id: nearest[:id]).update(state: "reserved")

        Thread.new do
          sleep(10)
          puts "freeing vehicle #{nearest[:id]}"
          conn.where(id: nearest[:id]).update(state: "free")
        end
        
        halt(200, conn.where(id: nearest[:id]).first.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end
  end
end