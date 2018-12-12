require 'sinatra/base'
require_relative 'database/vehicles'
require_relative 'helpers/address'
require_relative 'helpers/vehicles'

class App < Sinatra::Base
  DB = Database::Vehicles.new()

  helpers Sinatra::AddressHelper
  helpers Sinatra::VehiclesHelper

  before '/*' do
    content_type :json
  end

  not_found do
    status = { :status => 'not found' }
    status.to_json
  end

  error do
    status = { :status => 'internal error' }
    status.to_json
  end

  put('/vehicle') { add_vehicle(DB.conn()) }
  post('/vehicle/:id') { update_vehicle(DB.conn()) }
  delete('/vehicle/:id') { delete_vehicle(DB.conn()) }
  get('/vehicle/:id') { get_vehicle(DB.conn()) }

  get('/vehicles') { get_all_vehicles(DB.conn()) } 
  get('/vehicles/:city') { get_city_vehicles(DB.conn()) }
  post('/vehicles/reserve_now') { reserve_vehicle(DB.conn()) }

  run!
end