# Our first scenario

On the previous chapter we introduced some rules that describe the behaviour of our system, for instance:
* A user can register any number of vehicles by providing the following info for any of them:
  - model
  - plate number
  - coordinates where the vehicle is parked (lat and lon)

We will start by writing an scenario that describes this rule.

## Writing Gherkin

Create the file `registering_vehicles.feature` under the `features` folder you should have in your project. Write the following content:

```
Feature: Registering vehicles.
A user can register any number of vehicles by providing the following info for any of them:
- model
- plate number
- coordinates where the vehicle is parked (lat and lon)

Scenario: Check mandatory fields when registering a new vehicle.
  Given a vehicle with the following details, model: 'Opel Corsa', plate_number: '', lat: '40.40', lon: '-3.72'
  When a user registers the vehicle
  Then the registration is rejected with the message 'missing fields'
```

As we saw, we have 3 types of steps in this scenario:
- `Given` steps are used to declare the `pre-conditions` the system must satisfy before we act on it.
- `When` steps are used to declare the actions we want to perform on the system, given the starting conditions.
- `Then` steps are used to check that the actions we performed at the `When` steps have caused the expected results. Here we check the `post-conditions`.


Now save the file and run `cucumber`
```
Feature: Registering vehicles.
A user can register any number of vehicles by providing the following info for any of them:
- model
- plate number
- coordinates where the vehicle is parked (lat and lon)

  Scenario: Check mandatory fields when registering a new vehicle.                                                # features/registering_vehicles.feature:7
    Given a vehicle with the following details, model: 'Opel Corsa', plate_number: '', lat: '40.40', lon: '-3.72' # features/registering_vehicles.feature:8
    When a user registers the vehicle                                                                             # features/registering_vehicles.feature:9
    Then the registration is rejected with the message 'missing fields'                                           # features/registering_vehicles.feature:10

1 scenario (1 undefined)
3 steps (3 undefined)
0m0.071s

You can implement step definitions for undefined steps with these snippets:

Given("a vehicle with the following details, model: {string}, plate_number: {string}, lat: {string}, lon: {string}") do |string, string2, string3, string4|
  pending # Write code here that turns the phrase above into concrete actions
end

When("a user registers the vehicle") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the registration is rejected with the message {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
```

The tool has parsed our scenario and actually execute it! Sadly, there is no code for it to run, so it just let us know the steps of the scenario are currently undefined.

Fortunately `cucumber` always tries to help us, so it has provided some code for us to start implementing our steps.

## Writing Ruby

Now create a new file `features/step_definitions/registering_vehicles_steps.rb` and paste in it the snippets cucumber generated. You should have a file like this:

```
Given("a vehicle with the following details, model: {string}, plate_number: {string}, lat: {string}, lon: {string}") do |string, string2, string3, string4|
  pending # Write code here that turns the phrase above into concrete actions
end

When("a user registers the vehicle") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the registration is rejected with the message {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
```

This is the ruby code `cucumber` is going to run whenever we execute our scenario. You can see that what `cucumber` does is nothing but mapping the steps we defined using natural language to some ruby methods, passing them whatever arguments we did consider important when writing the scenario. The `{string}` thing is the argument type `cucumber` has inferred for us.

Well, so far we have written our first scenario and created a ruby file containing the very basic definitions of our scenario's steps.

## Adding some actions

Our Given step is actually declaring the values of the vehicle we have to register, to ensure the scenario works as intended. For the next step (the `When` one) to have access to the declared vehicle, we need to make it available somewhere. For these situations we use the `World` object.

All steps in a scenario are executed inside an instance of a `World`, so when we call `self` inside any step, we are actually accessing this `World` object. There should be not much shared state between steps, but sometimes we need a var here and there. 

Open the file `/features/support/env.rb` and write the following content:

```
module StateHelper
  attr_accesor :vehicle
end

World(StateHelper) //here we are telling our World to use the StateHelper module
```

Now we can access the attribute `@vehicle` from any step. As we said before, the `World` instance is a new one for each scenario. Let's write our `Given` step:
```
Given("a vehicle with the following details, model: {string}, plate_number: {string}, lat: {string}, lon: {string}") do |model, plate_number, lat, lon|
  @vehicle = {
    :model => model,
    :plate_number => plate_number,
    :lat => lat,
    :lon => lon
  }
end
```

Now for the `When`. In this case we have to get the vehicle previously declared, and try to register it in the system. The app exposes an endpoint for that `/vehicle - PUT`, so we need to make an http call to it. We'll use the library [HTTParty]() to help us with all these REST calls. We will need to save the response of our request for the next step, so we are adding it to our `StateHelper` module too.

First of all, add the library to our dependencies:
```
bundle add httparty
```

Now for the code itself:
```
module StateHelper
  attr_accessor :vehicle
  attr_accessor :last_response
end
```

```
require 'httparty' #at the top of the file

When("a user registers the vehicle") do
  @last_response = HTTParty.put('http://localhost:4567/vehicle', body: @vehicle)
end
```

So far we have declared a vehicle, tried to register it and saved the response for later. Let's check now what has been the system's response. We have to read the response, and somehow tell `cucumber` what are we expecting it to be. For this we are using [rspec-expectations](), so we can easily express our expectations on the system's response.

```
bundle add rspec-expectations
```

Cucumber detects we have installed this library, so we can use it automatically:

```
Then("the registration is rejected with the message {string}") do |message|
  response = @last_response.parsed_response
  
  expect(response).to eq message //this expectation will raise an error when not met
end
```

The expectation will raise an error if not met. This is the way of letting `cucumber` know that this step must be considered a failure. So now our file `features/step_definitions/registering_vehicles-steps.rb` should look more or less like this:

```
require 'httparty'

Given("a vehicle with the following details, model: {string}, plate_number: {string}, lat: {string}, lon: {string}") do |model, plate_number, lat, lon|
  @vehicle = {
    :model => model,
    :plate_number => plate_number,
    :lat => lat,
    :lon => lon
  }
end

When("a user registers the vehicle") do
  @last_response = HTTParty.put('http://localhost:4567/vehicle', body: @vehicle)
end

Then("the registration is rejected with the message {string}") do |message|
  response = @last_response.parsed_response
  
  expect(response).to eq message #this expectation will raise an error when not met
end
```

and our `/features/support/env.rb`:

```
module StateHelper
  attr_accessor :vehicle
  attr_accessor :last_response
end

World(StateHelper)
```

Let's try now. First, start the app if you haven't done it yet. When the app is running, go to another terminal, cd into the project folder and run `cucumber`

```
Feature: Registering vehicles.
A user can register any number of vehicles by providing the following info for any of them:
- model
- plate number
- coordinates where the vehicle is parked (lat and lon)

  Scenario: Check mandatory fields when registering a new vehicle.                                                # features/registering_vehicles.feature:7
    Given a vehicle with the following details, model: 'Opel Corsa', plate_number: '', lat: '40.40', lon: '-3.72' # features/step_definitions/registering_vehicles_steps.rb:3
    When a user registers the vehicle                                                                             # features/step_definitions/registering_vehicles_steps.rb:12
    Then the registration is rejected with the message 'missing fields'                                           # features/step_definitions/registering_vehicles_steps.rb:16

1 scenario (1 passed)
3 steps (3 passed)
0m0.046s
```

Congrats! You have written your first API test scenario with `cucumber`.