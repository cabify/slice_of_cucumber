Given("there are vehicles registered with the following details:") do |table|
  table.hashes.each do |row|
    register_vehicle(row)
  end
end

When("a user reserves a vehicle at coordinates {string}, {string}") do |latitude, longitude|
  reserve_vehicle(latitude, longitude)
end

When("the user waits for {string} seconds") do |seconds|
  sleep(seconds.to_i)
end

Then("the vehicle with the plate number {string} must have state {string}") do |plate_number, state|
  vehicle = get_vehicle(plate_number).parsed_response

  expect(vehicle['state']).to eq state
end
