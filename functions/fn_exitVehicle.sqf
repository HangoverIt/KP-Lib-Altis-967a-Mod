/*
    File: fn_exitVehicle.sqf
    Author: HangoverIT
    Date: 2022-01-30
    Last Update: 2022-01-30
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Get a unit out of a vehicle

    Parameter(s):
        unit

    Returns:
        BOOL
*/
params["_unit"];

unassignVehicle _unit ;
[_unit] orderGetIn false ;
moveOut _unit ;

/*
			unAssignVehicle _unit;
            _unit action ["eject", vehicle _unit];
            _unit action ["getout", vehicle _unit];
            unAssignVehicle _unit;
*/
true;
