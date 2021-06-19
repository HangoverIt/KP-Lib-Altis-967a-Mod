/*
 * Author: Psycho
 
 * Check Unit if is in range of a medevac object. 
 
 * Arguments:
	0: Unit (Object)
	1: Injured (Object)
 
 * Return value:
	Bool
 */
 
params ["_player", "_injured"];

private _return = false;
{
	_x params [["_obj", objNull], ["_radius", 0, [0]]];
	if (_return) exitWith {true};
	if (typeName _obj == "STRING" || typeName _obj == "OBJECT") then {
		if (_radius > 0) then {
			// Updated code - HangoverIt 16th Jun 2021 - allow class names for objects as well as variables
			if (typeName _obj == "STRING") then{
				// Not an object but a class name
				_return = count (nearestObjects [_player, [_obj], _radius, false]) > 0;
			}else{
				if ([_obj, _radius] call AIS_Core_fnc_inRange) exitWith {_return = true};
			};
		};
	};
} count AIS_MEDEVAC_STATIONS;


_return