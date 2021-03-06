// TODO Refactor and create function
params [
    ["_spawn_marker", "", [""]],
    ["_infOnly", false, [false]],
	["_fobAttack", false, [false]] // HangoverIt: new parameter for FOB attacks
];


if (GRLIB_endgame == 1) exitWith {};

_spawn_marker = [[2000, 1000] select _infOnly, 3000, false, markerPos _spawn_marker] call KPLIB_fnc_getOpforSpawnPoint;

if (_fobAttack) then {
	// HangoverIt - further distance usually for a FOB so don't spawn infantry only
	_infOnly = false ;
};
diag_log format["HangoverIt: Spawning battlegroup at position: %1, as infantry: %2, attacking FOB: %3", markerPos _spawn_marker, _infOnly, _fobAttack] ;

if !(_spawn_marker isEqualTo "") then {
    GRLIB_last_battlegroup_time = diag_tickTime;

    private _bg_groups = [];
    private _selected_opfor_battlegroup = [];
    private _target_size = (ceil (GRLIB_battlegroup_size * ([] call KPLIB_fnc_getOpforFactor) * (sqrt GRLIB_csat_aggressivity))) min 16;
    if (combat_readiness < 70) then {
		_reduction_factor = (combat_readiness max 35) / 100 ; // HangoverIt - some better scaling of battle group size according to readiness
		_target_size = ceil (_target_size * _reduction_factor);
	};

    [_spawn_marker] remoteExec ["remote_call_battlegroup"];

    if (worldName in KP_liberation_battlegroup_clearance) then {
        [markerPos _spawn_marker, 15] call KPLIB_fnc_createClearance;
    };

    if (_infOnly) then {
        // Infantry units to choose from
        private _infClasses = [KPLIB_o_inf_classes, militia_squad] select (combat_readiness < 50);
		diag_log format ["DEBUG: Battle group spawning infantry only"] ;

        // Adjust target size for infantry
        _target_size = 12 max (_target_size * 4);

        // Create infantry groups with up to 8 units per squad
        private _grp = createGroup [GRLIB_side_enemy, true];
        for "_i" from 0 to (_target_size - 1) do {
            if (_i > 0 && {(_i % 8) isEqualTo 0}) then {
                _bg_groups pushBack _grp;
                _grp = createGroup [GRLIB_side_enemy, true];
            };
            [selectRandom _infClasses, markerPos _spawn_marker, _grp] call KPLIB_fnc_createManagedUnit;
        };
        _bg_groups pushBack _grp;
    } else {
        private _vehicle_pool = [opfor_battlegroup_vehicles, opfor_battlegroup_vehicles_low_intensity] select (combat_readiness < 50);

        while {count _selected_opfor_battlegroup < _target_size} do {
            _selected_opfor_battlegroup pushback (selectRandom _vehicle_pool);
        };

        private ["_nextgrp", "_vehicle"];
        {
            _nextgrp = createGroup [GRLIB_side_enemy, true];
            _vehicle = [markerpos _spawn_marker, _x] call KPLIB_fnc_spawnVehicle;

            sleep 0.5;

            (crew _vehicle) joinSilent _nextgrp; // HangoverIt - specify location
            _bg_groups pushback _nextgrp;

			diag_log format ["HangoverIt: checking %1 is in %2 for troop transport", _x, opfor_troup_transports] ;
            if ((_x in opfor_troup_transports) && ([] call KPLIB_fnc_getOpforCap < GRLIB_battlegroup_cap)) then {
                if (_vehicle isKindOf "Air") then {
					if (_fobAttack) then {
						[[markerPos _spawn_marker] call KPLIB_fnc_getNearestFob, _vehicle] spawn send_paratroopers;
					}else{
						[[markerPos _spawn_marker] call KPLIB_fnc_getNearestBluforObjective, _vehicle] spawn send_paratroopers;
					};
                } else {
					if (_fobAttack) then {
						[_vehicle,[markerPos _spawn_marker] call KPLIB_fnc_getNearestFob] spawn troup_transport;
					}else{
						[_vehicle,[markerPos _spawn_marker] call KPLIB_fnc_getNearestBluforObjective] spawn troup_transport;
					};
                };
            };
        } forEach _selected_opfor_battlegroup;

        if (GRLIB_csat_aggressivity > 0.9) then {
			if (_fobAttack) then {
				[[markerPos _spawn_marker] call KPLIB_fnc_getNearestFob] spawn spawn_air;
			}else{
				[[markerPos _spawn_marker] call KPLIB_fnc_getNearestBluforObjective] spawn spawn_air;
			};
        };
    };

    sleep 3;

    combat_readiness = (combat_readiness - (round ((count _bg_groups) + (random (count _bg_groups))))) max 0;
    stats_hostile_battlegroups = stats_hostile_battlegroups + 1;

    {
		[_x, markerpos _spawn_marker, _fobAttack] spawn battlegroup_ai; // HangoverIt - moved AI line to end - fixes issue with infantry not having battlegroup_ai commands
        if (local _x) then {
            _headless_client = [] call KPLIB_fnc_getLessLoadedHC;
            if (!isNull _headless_client) then {
                _x setGroupOwner (owner _headless_client);
            };
        };
        sleep 1;
    } forEach _bg_groups;
};
