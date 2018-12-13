require 'sequel'

module Database
  class Vehicles
    def initialize()
      @db = Sequel.sqlite
      @db.create_table :vehicles do
        String :plate_number, primary_key: true
        String :model
        String :city
        String :state
        Float :lat
        Float :lon
      end
    end

    def conn()
      @db[:vehicles]
    end
  end
end
