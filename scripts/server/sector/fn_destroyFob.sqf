/*
    File: fn_destroyFob.sqf
    Author: KP Liberation Dev Team - https://github.com/KillahPotatoes
    Date: 2020-04-28
    Last Update: 2020-04-29
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Removes all player built buildings (from build list) inside the FOB radius of given position.
        Also removes possible clearances from given position.

    Parameter(s):
        _fobPos - Center position [ARRAY, defaults to []]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_fobPos", [], [[]]]
];

private _buildings = [toLower FOB_typename];
_buildings append KPLIB_b_buildings_classes;

{
    // HangoverIt - remove building destroy and remove everything not enemy or resistance - 18th June 2021
    //if ((toLower (typeOf _x)) in _buildings) then {
	if (!(side _x == GRLIB_side_enemy) && !( side _x == GRLIB_side_resistance)) then {
        _x spawn {
            sleep ((random 4) + (random 4));
            _this setDamage 1;
        };
    };
} forEach ((_fobPos nearObjects (GRLIB_fob_range * 1.2)) select {getObjectType _x >= 8});

// HangoverIt - added removal and destruction of resources at FOB
_nearstorageareas = nearestObjects [_fobPos, KPLIB_storageBuildings, (GRLIB_fob_range * 1.2)];
{
	_stor = _x ;
	{
        switch ((typeOf _x)) do {
            case KP_liberation_supply_crate: {[KP_liberation_supply_crate, _stor, true] call KPLIB_fnc_crateFromStorage;};
            case KP_liberation_ammo_crate: {[KP_liberation_ammo_crate, _stor, true] call KPLIB_fnc_crateFromStorage;};
            case KP_liberation_fuel_crate: {[KP_liberation_fuel_crate, _stor, true] call KPLIB_fnc_crateFromStorage;};
            default {[format ["Invalid object (%1) cannot destroy at storage area", (typeOf _x)], "ERROR"] call KPLIB_fnc_log;};
        };
		_x spawn {
            sleep ((random 4) + (random 4));
            _this setDamage 1;
			deleteVehicle _this ;
			"r_80mm_he" createVehicle (getPos _this);
        };
    } forEach (attachedObjects _x);
} forEach _nearstorageareas ;

KP_liberation_clearances deleteAt (KP_liberation_clearances findIf {(_x select 0) isEqualTo _fobPos});
publicVariable "KP_liberation_clearances";

true
