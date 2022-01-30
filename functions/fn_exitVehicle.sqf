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

private _veh = vehicle _unit ;
if (_veh == _unit) exitWith {false;}; // HangoverIT - unit is not in a vehicle

unassignVehicle _unit ;
[_unit] orderGetIn false ;
moveOut _unit ;
//(group _unit) leaveVehicle _veh ; // HangoverIT - causes all units to exit


/* Alternative KP Lib code
			unAssignVehicle _unit;
            _unit action ["eject", vehicle _unit];
            _unit action ["getout", vehicle _unit];
            unAssignVehicle _unit;
*/
true;
