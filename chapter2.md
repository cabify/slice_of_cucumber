# Knowing our API

## Our own car sharing app

Before continuing we need to know the API we are going to work with. We have started the implementation of a car sharing application with an yet-to-decide name. This app will allow us to register vehicles we want to share, and retrieve and reserve vehicles that other users in the community are sharing. Of course, this is a WIP, so don't expect fancy features such as user authentication (nor user management, of course), data persistence, or even that vehicles really exist. But, it will serve to our purposes in its current state.

### Specifications

These are some rules that our system must follow (specifications):

* The application only works for three cities: Madrid, Barcelona and Sevilla. This means that the parking coordinates for a vehicle must always correspond to one of those cities.
* A user can register any number of vehicles by providing the following info for any of them:
  - model
  - plate number
  - coordinates where the vehicle is parked (lat and lon)
* When a vehicle is registered, its initial state will be `free`, and its initial city will be calculated from its parking coordinates.
* A user can retrieve a list of all the vehicles in the system.
* A user can retrieve a list of all the free vehicles in a city.
* A user can retrieve the details of any vehicle in the system.
* A user can reserve the nearest vehicle to a given location, but only if the user and the car are in the same city.
* A user can reserve as many vehicles as desired.
* A reserved vehicle will be free again after 10 seconds.

### Endpoints

The system exposes the following endpoints:

- /vehicle - PUT:
  Creates a new vehicle in the system. Its initial state will be `free`, and its city will be calculated from the parking coordinates.
  Request payload (all the fields are mandatory):
  ```
  {
      "model": "Opel Corsa",
      "lat": 40.40,
      "lon": -3.71,
      "plate_number": "1111X"
  }
  ```
  Response payload:
  ```
  {
      "city": "Madrid",
      "lat": 40.4,
      "lon": -3.71,
      "model": "Opel",
      "plate_number": "1111X",
      "state": "free"
  }  
  ```

- /vehicle/<plate_number> - POST:
  Updates the parking coordinates of a vehicle in the system.
  Request payload (all the fields are mandatory):
  ```
  {
      "lat": 40.42,
      "lon": -3.72
  }
  ```
  Response payload:
  ```
  {
    "city": "Madrid",
    "lat": 40.42,
    "lon": -3.72,
    "model": "Opel",
    "plate_number": "1111X",
    "state": "free"
  }
  ```

- /vehicle/<plate_number> - GET:
  Returns the details of the vehicle with <plate_number>.
  Response payload:
  ```
  {
      "city": "Madrid",
      "lat": 40.42,
      "lon": -3.72,
      "model": "Opel",
      "plate_number": "1111X",
      "state": "free"
  }
  ```
- /vehicle/<plate_number> - DELETE:
  Removes from the system the vehicle with <plate_number>

- /vehicles - GET:
  Returns a list containing all the vehicles in the system (this will be used by admins maybe).
  Response payload:
  ```
  [
      {
          "city": "Madrid",
          "lat": 40.42,
          "lon": -3.72,
          "model": "Opel Corsa",
          "plate_number": "1111X",
          "state": "free"
      },
      {
          "city": "Barcelona",
          "lat": 41.38,
          "lon": 2.17,
          "model": "Renault 5",
          "plate_number": "2222X",
          "state": "free"
      }
  ]
  ```

- /vehicles/<city> - GET:
  Returns a list with all the free vehicles in <city> (this will be used by final users, to find cars where they are or something).
  Response payload:
  ```
  [
      {
          "city": "Madrid",
          "lat": 40.42,
          "lon": -3.72,
          "model": "Opel Corsa",
          "plate_number": "1111X",
          "state": "free"
      }
  ]
  ```

- /vehicles/reserve - POST:
  Tries to reserve the nearest free vehicle to the requested coordinates, given user and vehicle are in the same city.
  Request payload:
  ```
  {
      "lat": 40.57,
      "lon": -3.68
  }
  ```
  Response payload:
  ```
  {
      "city": "Madrid",
      "lat": 40.42,
      "lon": -3.72,
      "model": "Opel Corsa",
      "plate_number": "1111X",
      "state": "reserved"
  }
  ```
  After 10 seconds, the vehicle's state will be `free` again. Short time, I know.

## Run the app!

Ok, let's run the app. The application code is contained in the `lib` folder. Now, install its dependencies and start it:
```
bundle install
./bin/start
```

This will start a server listening at `http://localhost:4567`. You can use any tool sucha as [Postman](https://www.getpostman.com/) or [httpie](https://httpie.org/) to interact with it. It uses an in-memory database, so if you restart the application all the data in your database will be lost.

### And now?

And now, we can start writing some scenarios describing our systems's behaviour. These scenarios will serve us as:
- Non ambiguous executable specification.
- Automated behaviour tests when executed by `cucumber`.
- Documentation about how the system really behaves.

When these scenarios are written we will have established a contract with our system:
- If the behaviour of the app changes at any moment (hope it does it for the better, but it can be because of **bugs**), our Gherkin scenarios will start failing, so we will have to check them and investigate what is happening.
- Or we may update the scenarios in a pre-implementation phase, so they describe the **future desired** behaviour of the application, and our tests will be failing until the application conforms to the contract.

Let's write our first scenario.
