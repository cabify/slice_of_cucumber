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
      request.body.rewind

      vehicle = JSON.parse(request.body.read)
      vehicle = vehicle.transform_keys(&:to_sym)

      puts "add vehicle #{vehicle}"

      required_fields_presence = [:model, :plate_number, :lat, :lon].map do |field|
        vehicle.keys.include?(field) &&
        !vehicle[field].empty? &&
        !vehicle[field].nil?
      end

      unless required_fields_presence.include?(false)
        vehicle[:state] = "free"
        vehicle[:city] = get_city!(vehicle[:lat], vehicle[:lon]) 

        conn.insert(vehicle)

        halt(200, conn.where(:plate_number => vehicle[:plate_number]).first.to_json)
      end
      halt(400, "missing fields".to_json)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def update_vehicle(conn)
      plate_number = params["plate_number"]
      request.body.rewind

      values = JSON.parse(request.body.read)
      values = values.transform_keys(&:to_sym)

      values[:city] = get_city!(values[:lat], values[:lon])

      vehicle = conn.where(plate_number: plate_number, state: "free").first

      unless vehicle.nil? 
        conn.where(plate_number: plate_number).update(lon: values[:lon], lat: values[:lat], city: values[:city])
        puts "updated vehicle #{vehicle}"
        halt(200, conn.where(plate_number: plate_number).first.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def delete_vehicle(conn)
      plate_number = params["plate_number"]
      unless conn.where(plate_number: plate_number).first.nil?
        conn.where(plate_number: plate_number).delete()
        puts "deleted vehicle #{plate_number}"
        halt(200)
      end
      halt(404)
    end

    def get_vehicle(conn)
      plate_number = params["plate_number"]
      vehicle = conn.where(plate_number: plate_number).first
      unless vehicle.nil?
        halt(200, vehicle.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end

    def get_all_vehicles(conn)
      halt(200, conn.all().to_json)
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

      puts "requested reservation, coordinates: [#{from[:lat]},#{from[:lon]}]"

      city = get_city!(from[:lat], from[:lon]) 
      vehicles = conn.where(city: city, state: "free").all()

      unless vehicles.nil? || vehicles.empty?
        nearest = Distance::get_nearest(vehicles, from[:lat].to_f, from[:lon].to_f)
        conn.where(plate_number: nearest[:plate_number]).update(state: "reserved")

        Thread.new do
          sleep(10)
          puts "freeing vehicle #{nearest[:plate_number]}"
          conn.where(plate_number: nearest[:plate_number]).update(state: "free")
        end
        
        halt(200, conn.where(plate_number: nearest[:plate_number]).first.to_json)
      end
      halt(404)
    rescue StandardError => e
      halt(500, e.to_json)
    end
  end
end