Feature: Registering vehicles

A user can register a vehicle by providing its model, plate number and parking coordinates.
A user can register any number of vehicles.
When a vehicle is registered, its initial state must be "free" and its city must correspond to the coordinates in where it is parked.

@register
@negative
Scenario Outline: A user can register any number of vehicles by providing their model, plate number and parking coordinates (latitude and longitude).
	Given a vehicle with the following details:
		| model 	| plate_number   | lat 	 | lon 	|
		| <model> | <plate_number> | <lat> | <lon> |
	When the user registers the vehicle
	Then the registration is rejected with the message '<message>'
	Examples:
		| model 		 | plate_number | lat   | lon   | message 			 |
		|            | 111X 				| 40.40 | -3.71 | missing fields |
		| Opel Corsa | 							| 40.40 | -3.71 | missing fields |
		| Opel Corsa | 1111X 				| 			| -3.71 | missing fields |
		| Opel Corsa | 1111X 				| 40.40 |		    | missing fields |


@register
@positive
Scenario Outline: When a vehicle is registered, its initial state must be "free" and its city must correspond to the coordinates in where it is parked.
	Given a vehicle with the following details:
		| model   | plate_number   | lat   | lon   |
		| <model> | <plate_number> | <lat> | <lon> |		
	When the user registers the vehicle
	Then the vehicle with the plate number '<plate_number>' must have state '<state>' and city '<city>'
	And the vehicle with the plate number '<plate_number>' must appear when viewing all the vehicles in the city '<city>'
	Examples:
		| model 		 	| plate_number | lat   | lon   | state  | city 			|
		| Opel Corsa 	| 1111X 			 | 40.40 | -3.71 | free 	| Madrid 		|
		| Renault 5 	| 2222X 			 | 41.38 | 2.17  | free 	| Barcelona |
		| Ford Fiesta | 3333X 			 | 37.39 | -5.98 | free 	| Sevilla 	|