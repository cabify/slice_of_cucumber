Given("a vehicle with the following details:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  @vehicle = table.hashes.first
end

When("the user registers the vehicle") do
  @response = register_vehicle(@vehicle)
end

Then("the registration is rejected with the message {string}") do |message|
  expect(@response.parsed_response).to eq message
end

Then("the vehicle with the plate number {string} must have state {string} and city {string}") do |plate_number, state, city|
  vehicle = get_vehicle(plate_number).parsed_response

  expect(vehicle['state']).to eq state
  expect(vehicle['city']).to eq city
end

Then("the vehicle with the plate number {string} must appear when viewing all the vehicles in the city {string}") do |plate_number, city|
  vehicles = get_vehicles_in_city(city)
  plate_numbers = vehicles.map { |v| v['plate_number'] }

  expect(plate_numbers).to include(plate_number)
end