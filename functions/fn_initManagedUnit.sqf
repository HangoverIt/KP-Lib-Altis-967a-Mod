/*
    File: fn_initManagedUnit.sqf
    Author: HangoverIt
    Date: 2021-09-19
    Last Update: 2022-01-30
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Initialises unit managed by kill tracker, AIS and VCOM.
		Added this function to allow all created units to have the same managed code

    Parameter(s):
        _unit       		- Created unit 
		_independent		- Set to true if unit is VCOM controlled

    Returns:
        Bool
*/
params["_unit","_independent"] ;

_unit addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
_unit call AIS_System_fnc_loadAIS; // HangoverIt 13th June 2021 - Added AIS capability hack

private _group = group _unit ;

if (isNull _group || side _group == GRLIB_side_civilian) then {
	_unit setVariable ["I_am_a_civilian", true,true] ; // HangoverIt - Set flag that this is a civilian as ambigious with prisioner AI
};

if (side _group == GRLIB_side_friendly) then {
	// HangoverIt - All friendly AI can have the additional capability to capture vehicles
	_unit addEventHandler ["GetInMan", {[_this select 2] call KPLIB_fnc_setVehiclesSeized;}];
	_unit addEventHandler ["GetInMan", {[_this select 2] call KPLIB_fnc_setVehicleCaptured;}];
};

if (!_independent) then {
	_group setVariable ["Vcm_Disable",true,true]; // HangoverIt - Stop VCOM working on units that are not independent
};

// Process KP object init
[_unit] call KPLIB_fnc_addObjectInit;

true;