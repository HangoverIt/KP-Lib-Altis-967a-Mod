/*
 * Author: Psycho
 
 * Searching for the best helper in the near of a player.
 
 * Arguments:
	0: Unit (Object) (Unit which called for help)
	1: Helper (Object (AI which can help)
 
 * Return value:
	Nothing
*/

params [
	["_injured", objNull, [objNull]],
	["_helper", objNull, [objNull]]
];

// 

// start searching for a match
if (isNull _helper) then {

    _isStabil = _target getVariable ["ais_stabilized",false];

	// looking for a valid AI group member.
	private _all_members = (units group _injured) - [_injured];
	if (count _all_members > 0) then {
		private _matching_members_array = [];
		{if (!(_x getVariable ["ais_unconscious", false]) && {!isPlayer _x}) then {_matching_members_array pushBack _x};true} count _all_members;
	
		if (count _matching_members_array > 0) then {
			{if (_x call AIS_System_fnc_isMedic) exitWith {_helper = _x};true} count _matching_members_array;
			// Removed random non-medic from reviving - HangoverIt 16th Jun 2021
			// Could run another check - if injured has not been stabilised and education is medic only for revive then send non-medic
			// else if education is non medic then just send regardless of being stablised
			if (AIS_MEDICAL_EDUCATION == 2 && !_isStabil || AIS_MEDICAL_EDUCATION != 2) then {
				diag_log format["AIS: No medic found in group to help %1", _injured];
				if (isNull _helper) then {_helper = selectRandom _matching_members_array};
			};
		};
	};
	
	// if no valid AI group member was found looking for close AI units of the same side
	if (isNull _helper) then {
		private _allMenNear = [];
		if (AIS_AI_HELP_RADIUS > 200) then {AIS_AI_HELP_RADIUS = 200};	// max 200 metres
		_allMenNear = (position _injured) nearEntities ["CAManBase", AIS_AI_HELP_RADIUS];
		_allMenNear = _allMenNear - [_injured];
		if (count _allMenNear > 0) then {
			private _matching_side_array = [];
			private _side = _injured getVariable ["ais_side", civilian];	// needed, because the injured can be captive (captive == side civilian)
			{if ((_side isEqualTo (side _x)) && {!(_x getVariable ["ais_unconscious", false])} && {!isPlayer _x}) then {_matching_side_array pushBack _x};true} count _allMenNear;
			if (count _matching_side_array > 0) then {
				{if (_x call AIS_System_fnc_isMedic) exitWith {_helper = _x};true} count _matching_side_array;
				// Removed random non-medic from reviving - HangoverIt 16th Jun 2021
				if (AIS_MEDICAL_EDUCATION == 2 && !_isStabil || AIS_MEDICAL_EDUCATION != 2) then {
					diag_log format["AIS: No medic found outside of group to help %1", _injured];
					if (isNull _helper) then {_helper = _matching_side_array select 0};	// no random value to pick the closest one	
				};
			};
		};
	};
};

// if no match...
if (isNull _helper) exitWith {};

// ...otherwise our new helper will make his way to the injured unit.
private _acc_time = diag_tickTime + 1;
if (local _helper) then {
	[{diag_tickTime > (_this select 2)}, {_this call AIS_System_fnc_moveAIHelper}, [_injured, _helper, _acc_time]] call AIS_Core_fnc_waitUntilAndExecute;
} else {
	[{diag_tickTime > (_this select 2)}, {
		[_this select 0, _this select 1] remoteExecCall ["AIS_System_fnc_moveAIHelper", 2];	
	}, [_injured, _helper, _acc_time]] call AIS_Core_fnc_waitUntilAndExecute;
};


true