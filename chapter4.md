# Moar scenarios!

So now we have run our first scenario, and we are able to confirm that the system does not allow us to register a vehicle that has an empty value for the plate number. What about the other mandatory fields? Do we have to write another full scenario just to change the value of the model for example? 

Luckily no, we don't have to. For these situations, we can use `scenario outlines` and `examples`. Let's see what they are and how they can be useful.

Open again the `/features/registering_vehicles.feature` file, and modify our scenario:

```
Scenario Outline: Check mandatory fields when registering a new vehicle.
  Given a vehicle with the following details, model: '<model>', plate_number: '<plate_number>', lat: '<lat>', lon: '<lon>'
  When a user registers the vehicle
  Then the registration is rejected with the message '<message>'
  Examples:
  | model      | plate_number | lat   | lon   | message        |
  |            | 1111X        | 40.40 | -3.72 | missing fields |
  | Opel Corsa |              | 40.40 | -3.72 | missing fields |
  | Opel Corsa | 1111X        |       | -3.72 | missing fields |
  | Opel Corsa | 1111X        | 40.40 |       | missing fields |
```

What we are doing here is telling `cucumber` that we want to execute one scenario with different data sets. And what `cucumber` does is just that, check it out:
```
Feature: Registering vehicles.
A user can register any number of vehicles by providing the following info for any of them:
- model
- plate number
- coordinates where the vehicle is parked (lat and lon)

  Scenario Outline: Check mandatory fields when registering a new vehicle.                                                   # features/registering_vehicles.feature:7
    Given a vehicle with the following details, model: '<model>', plate_number: '<plate_number>', lat: '<lat>', lon: '<lon>' # features/registering_vehicles.feature:8
    When a user registers the vehicle                                                                                        # features/registering_vehicles.feature:9
    Then the registration is rejected with the message '<message>'                                                           # features/registering_vehicles.feature:10

    Examples:
      | model      | plate_number | lat   | lon   | message        |
      |            | 1111X        | 40.40 | -3.72 | missing fields |
      | Opel Corsa |              | 40.40 | -3.72 | missing fields |
      | Opel Corsa | 1111X        |       | -3.72 | missing fields |
      | Opel Corsa | 1111X        | 40.40 |       | missing fields |

4 scenarios (4 passed)
12 steps (12 passed)
0m0.131s
```

You can see that `cucumber` is telling us it has executed 4 scenarios, not 1 as before. And did you notice something? We have not modified our ruby code. The step definitions are working as before. Yay!