/*
    File: fn_initManagedUnit.sqf
    Author: HangoverIt
    Date: 2021-09-19
    Last Update: 2021-09-19
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Initialises unit managed by kill tracker and AIS.
		Added this function to allow all created units to have the same managed code

    Parameter(s):
        _unit       - Created unit              

    Returns:
        Bool
*/
params["_unit"] ;

_unit addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
_unit call AIS_System_fnc_loadAIS; // HangoverIt 13th June 2021 - Added AIS capability hack

private _group = group _unit ;

if (isNull _group || side _group == GRLIB_side_civilian) then {
	_unit setVariable ["I_am_a_civilian", true,true] ; // HangoverIt - Set flag that this is a civilian as ambigious with prisioner AI
};

if (side _group == GRLIB_side_friendly) then {
	_group setVariable ["Vcm_Disable",true,true]; // HangoverIt - Stop VCOM working on friendly side
};

// Process KP object init
[_unit] call KPLIB_fnc_addObjectInit;

true;