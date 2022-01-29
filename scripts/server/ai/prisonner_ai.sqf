params ["_unit", ["_force_surrender", false], ["_nointel", false]];

if ((!_force_surrender) && ((random 100) > GRLIB_surrender_chance)) exitWith {};

if ((_unit isKindOf "Man") && (alive _unit) && (side group _unit == GRLIB_side_enemy)) then {

    if (vehicle _unit != _unit) then {
		deleteVehicle _unit
	}else{

		sleep (random 5);

		// HangoverIt - check if AIS variable set for injured soldier
		_AISCHECK = _unit getVariable "ais_unconscious" ;
		_AISINJURED = !(isNil "_AISCHECK");
		if (_AISINJURED) then {
			// Unit will die
			_unit setDamage 1;
		};
		
		if (alive _unit) then {

			removeAllWeapons _unit;
			if (typeof _unit != pilot_classname) then {
				removeHeadgear _unit;
			};
			removeBackpack _unit;
			removeVest _unit;
			_unit unassignItem "NVGoggles_OPFOR";
			_unit removeItem "NVGoggles_OPFOR";
			_unit unassignItem "NVGoggles_INDEP";
			_unit removeItem "NVGoggles_INDEP";
			_unit setUnitPos "UP";
			sleep 1;
			private _grp = createGroup [GRLIB_side_civilian, true]; 
			[_unit] joinSilent _grp;
			_grp setVariable ["Vcm_Disable",true,true]; // HangoverIt disable Vcom on prisoners
		
			if (KP_liberation_ace) then {
				["ace_captives_setSurrendered", [_unit, true], _unit] call CBA_fnc_targetEvent;
			} else {
				_unit disableAI "ANIM";
				_unit disableAI "MOVE";
				_unit playmove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
				sleep 2;
				_unit setCaptive true;
			};
		
			waitUntil {sleep 1;
				!alive _unit || _unit getVariable ["ais_unconscious", false] || side group _unit == GRLIB_side_friendly
			};

			// HangoverIt - if prisioner falls unconcious in AIS then they will die - fixes issues with rescue missions
			if (_unit getVariable ["ais_unconscious", false]) then {
				_unit setDamage 1 ;
			};

			if (alive _unit) then {
				if (KP_liberation_ace) then {
					["ace_captives_setSurrendered", [_unit, false], _unit] call CBA_fnc_targetEvent;
				} else {
					// HangoverIt - enableAI and setCaptive should be run on local client who has captured the prisioner
					[_unit, "ANIM"] remoteExec ["enableAI", _unit] ;
					[_unit, "MOVE"] remoteExec ["enableAI", _unit] ;
					[_unit, false] remoteExec ["setCaptive", _unit] ;
				};
				sleep 1;
				if (!_nointel) then {
					[_unit] remoteExec ["remote_call_prisonner", _unit];
				};
			};
		};
	};
};
