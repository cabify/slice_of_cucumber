Feature: Reserving vehicles

A user can reserve the nearest vehicle to his location, but only if user and vehicle are in the same city.
A user can reserve as many vehicles as desired.
A reserved vehicle will be free again after 10 seconds.

@reserve
@nearest
@fast
Scenario: A user can reserve the nearest vehicle to his location.
	Given there are vehicles registered with the following details:
		| model 		 | plate_number | lat   | lon   |
		| Opel Corsa | 1111X 				| 40.40 | -3.7  |
		| Renault 5  | 2222X				| 40.41 | -3.71 |
	When a user reserves a vehicle at coordinates '40.40', '-3.7'
	Then the vehicle with the plate number '1111X' must have state 'reserved'
	And the vehicle with the plate number '2222X' must have state 'free'

@reserve
@fast
@same_city
Scenario Outline: A user can reserve the nearest vehicle to his location, but only if user and vehicle are in the same city.
	Given there are vehicles registered with the following details:
		| model 	| plate_number 	 | lat 	 | lon 	 |
		| <model> | <plate_number> | <lat> | <lon> |
	When a user reserves a vehicle at coordinates '40.40', '-3.7'
	Then the vehicle with the plate number '<plate_number>' must have state '<state>'
	Examples:
		| model 		 | plate_number | lat   | lon  | state 		|
		| Opel Corsa | 1111X 			  | 40.40 | -3.7 | reserved |
		| Renault 5  | 2222X 				| 41.38 | 2.17 | free  		|

@reserve
Scenario: A user can reserve as many vehicles as desired, but only if user and vehicle are in the same city.
	Given there are vehicles registered with the following details:
		| model 		  | plate_number | lat   | lon   |
		| Opel Corsa  | 1111X 			 | 40.40 | -3.7  |
		| Renault 5   | 2222X				 | 40.41 | -3.71 |
		| Ford Fiesta | 3333X 			 | 41.38 | 2.17	 |
	When a user reserves a vehicle at coordinates '40.40', '-3.7'
	And a user reserves a vehicle at coordinates '40.40', '-3.7' 
	And a user reserves a vehicle at coordinates '40.40', '-3.7' 
	Then the vehicle with the plate number '1111X' must have state 'reserved'
	And the vehicle with the plate number '2222X' must have state 'reserved'
	And the vehicle with the plate number '3333X' must have state 'free'

@reserve
@slow
Scenario: A reserved vehicle will be free again after 10 seconds.
	Given there are vehicles registered with the following details:
		| model 		 | plate_number | lat   | lon  |
		| Opel Corsa | 1111X 			  | 40.40 | -3.7 |
	When a user reserves a vehicle at coordinates '40.40', '-3.7'
	And the user waits for '11' seconds
	Then the vehicle with the plate number '1111X' must have state 'free'
