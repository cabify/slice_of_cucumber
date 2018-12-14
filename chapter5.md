# Another feature

Let's start describing another feature of our system: the `Reserving Vehicles` feature.

We said before that:
* A user can reserve the nearest free vehicle to a given location.

So let's write a scenario for this. Create a new file `/features/reserving_vehicles.feature`, and write the following content:
```
Feature: Reserving vehicles.
A user can reserve the nearest free vehicle to a given location.

Scenario: A user can reserve the nearest free vehicle to a location.
  Given there are vehicles registered with the following details:
    | model      | plate_number | lat   | lon   |
    | Opel Corsa | 1111X        | 40.40 | -3.72 |
    | Renault 5  | 2222X        | 40.51 | -3.85 |
  When a user reserves a vehicle at coordinates '40.40, '-3.72'
  Then the vehicle with the plate number '1111X' must have state 'reserved'
  And the vehicle with the plate number '2222X' must have state 'free'
```

We have a new element in this scenario. It look slike the `Examples` we used before, but not completely the same. 
Wait, what is this table below the `Given`? Isn't this a scenario outline? Aren't those values examples?

No they aren't. That is a DataTable. We use one of them when we want to have several sets of values **in the same scenario**. Remember that each line of the `Examples` table generated a different scenario. Let's see how can we access the data of this table.

Create a file `/features/steps_definitions/reserving_vehicles_steps.rb` with the content:
```
Given("there are vehicles registered with the following details:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

When("a user reserves a vehicle at coordinates {string},{float}") do |string, string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("the vehicle with the plate number {string} must have state {string}") do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end
```

Let's implement the `Given` step. In this step we want to register a set of vehicles with some given attributes, so we can reserve one of them in the next step. For that we need to access to the data contained in the scenario table. This is how we do it:
```
Given("there are vehicles registered with the following details:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  #when calling 'hashes' method we get an array of hash objects with the structure { 'header' => 'row1_value }, { 'header' => 'row2_value } and so on
  table.hashes.each do |row|
    #row is a hash object with the same keys and structure of the payload we use to register a vehicle => easy!
    HTTParty.put('http://localhost:4567/vehicle', body: row.to_json)
  end
end
```

Now those 2 amazing vehicles will be registered in the system and ready to be reserved by a user in the next step. In fact they are in the system now and until someone decides to remove them. Does this mean that if I run this scenario twice in a row, those vehicles will be there the second time? What happens then? Will I have two fantastic but too similar 'Renault 5'? And with the same plate number?

## A little break now.

Answers: In fact the plate_number field is a primary key in our vehicles table. This means that no, we won't have 2 Renault 5 (I'm sorry). What would happen is that the DDBB would raise an error, because we are repeating a value in a column that is meant to only contain unique values. So in fact, our test would fail the second time, when trying to re-register the same vehicle (actually it wouldn't fail because we are not checking the response code of our PUT operation, but if we were checking it and expecting a 200 OK, that would be a reasonable expectation, the test would fail). 

The thing is, right now it actually doesn't matter whether the test would fail the second time or not, what matters is the **independence from the order of execution** of our testing scenarios. Remember that we use our `Given` steps to put the application in an initial state that we considered the best for our tests? Well, when we start our testing we shouldn't have issues because in a previous scenario (or previous execution of the same scenario) we just created some data that we forgot to clean.

We could solve this by implementing a step that cleans our `vehicles` table and makes it ready to start testing. But this solution would force us to copy-paste the same step in all of our scenarios. To avoid this we have `hooks` in `cucumber`.

`Hooks` are special steps that are executed `before`, `after` or `around` a scenario. There are also `before_step`, `after_step` and `around_step` hooks but we are not using them now.

How are we using these `hooks`? We will implement one that cleans the `vehicles` table before each scenario execution, so we are completely sure that the only data in the table is the one we insert during our test. Obviously we can do this because we are using a local testing database. This is not the way to go in big shared preproduction environments.

Create a new file `/features/step_definitions/setup_steps.rb` with the following content:
```
Before do
  vehicles = HTTParty.get("http://localhost:4567/vehicles")
  vehicles.each do |vehicle|
    HTTParty.delete("http://localhost:4567/vehicle/#{vehicle["plate_number"]}")
  end
end

```

Now we can always be sure to start our scenarios with a clean `vehicles` table.

What about the other 2 steps? You can implement them now, you have all the necessary tools to do it ;)

# Further work

Well we have written some scenarios, implemented the steps required to execute them and learned a lot of new concepts.

Now you should continue working on the definition of the behaviour of our API on your own. Think about all the rules we defined for our system on previous chapters. How can you better describe them using what you know by now?

Here there are some Scenario headers you can work with:

```
Scenario: The city of a vehicle will always be calculated from its parking coordinates.
Scenario: The application only works for three cities: Madrid, Barcelona and Sevilla. The parking coordinates for a vehicle must always correspond to one of those cities.
Scenario: A user can reserve the nearest free vehicle to a location, but only if user and vehicle are in the same city.
Scenario: A user can reserve as many vehicles as desired, but only if they are in the same city as the user is.
Scenario: Any reserved vehicle will be free again after 10 seconds.
```
