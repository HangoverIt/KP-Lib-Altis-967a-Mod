params [ "_minimum_readiness", "_is_infantry" ];
private [ "_headless_client" ];

private _timeOutPatrol = 900;

waitUntil { !isNil "blufor_sectors" };
waitUntil { !isNil "combat_readiness" };

while { GRLIB_endgame == 0 } do {
	[format["HangoverIt: Patrol management on %1 - waiting for bluefor_sectors count %2 over 2 and combat_readiness %3 greater than or equal to %4, difficulty factor %5", clientOwner, count blufor_sectors, combat_readiness, (_minimum_readiness / GRLIB_difficulty_modifier), GRLIB_difficulty_modifier]] remoteExec ["diag_log", 2] ;
    waitUntil { sleep 0.3; count blufor_sectors >= 3; };
    waitUntil { sleep 0.3; combat_readiness >= (_minimum_readiness / GRLIB_difficulty_modifier); };

    sleep (random 30);

    while {  [] call KPLIB_fnc_getOpforCap > GRLIB_patrol_cap } do {
            sleep (random 30);
    };

    _grp = grpNull;

    _spawn_marker = "";
    while { _spawn_marker == "" } do {
        _spawn_marker = [2000,5000,true] call KPLIB_fnc_getOpforSpawnPoint;
        if ( _spawn_marker == "" ) then {
            sleep (150 + (random 150));
        };
    };

    _sector_spawn_pos = [(((markerpos _spawn_marker) select 0) - 500) + (random 1000),(((markerpos _spawn_marker) select 1) - 500) + (random 1000),0];

    if (_is_infantry) then {
        _grp = createGroup [GRLIB_side_enemy, false];
        _squad = [] call KPLIB_fnc_getSquadComp;
        {
            [_x, _sector_spawn_pos, _grp, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
        } foreach _squad;
    } else {

        private [ "_vehicle_object" ];
		// HangoverIt - reduced combat_readiness requirement based on difficulty
        if ((combat_readiness >= (75 / GRLIB_difficulty_modifier)) && ((random 100) > 85) && !(opfor_choppers isEqualTo [])) then {
			_air_class = [opfor_choppers, opfor_air] select ((random 100) > 50);
			if (_air_class isEqualTo []) then { // Revert to vehicle if preset is empty
				_vehicle_object = [_sector_spawn_pos, [] call KPLIB_fnc_getAdaptiveVehicle] call KPLIB_fnc_spawnVehicle;
			}else{
				// Spawn air unit
				_vehicle_object = [_sector_spawn_pos, selectRandom _air_class] call KPLIB_fnc_spawnVehicle;
			};
        } else {
            _vehicle_object = [_sector_spawn_pos, [] call KPLIB_fnc_getAdaptiveVehicle] call KPLIB_fnc_spawnVehicle;
        };

        sleep 5;
        _grp = group ((crew _vehicle_object) select 0);
    };

    [_grp] spawn patrol_ai;

    _started_time = time;
    _patrol_continue = true;

	[format["HangoverIt: Created patrol on %1 - is infantry %2, Group %3, Unit Count %4", clientOwner, _is_infantry, _grp, count (units _grp)]] remoteExec ["diag_log", 2] ;

/*  Disable the management of patrol to a headless client. HC now owns the whole manage_one_patrol script
    if ( local _grp ) then {
        _headless_client = [] call KPLIB_fnc_getLessLoadedHC;
        if ( !isNull _headless_client ) then {
            _grp setGroupOwner ( owner _headless_client );
        };
		diag_log format["HangoverIt: Patrol group %1 transferred to HC %2", _grp, _headless_client];
    };
*/

	// HangoverIt: updated to prevent _grp being nil when patrol is destroyed
    while { _patrol_continue } do {
        sleep 60;
		if !(isNil "_grp") then {
			_leaderpos = getpos (leader _grp);
			if ( {alive _x} count (units _grp) == 0  ) then {
				_patrol_continue = false;
			} else {
				if ( time - _started_time > _timeOutPatrol ) then {
					if ( [ _leaderpos , 4000 , GRLIB_side_friendly ] call KPLIB_fnc_getUnitsCount == 0 ) then {
						_patrol_continue = false;
					};
				};
			};
		}else{
			_patrol_continue = false; // group is nil so must be destroyed
		};
    };
	
	// HangoverIt - Clean up group
	[format["HangoverIt: Removed patrol on %1 - is infantry %2, Group %3, Unit Count %4", clientOwner, _is_infantry, _grp, count (units _grp)]] remoteExec ["diag_log", 2] ;
	{
		if ( vehicle _x != _x ) then {
			[(vehicle _x)] call KPLIB_fnc_cleanOpforVehicle;
		};
		deleteVehicle _x;
	} foreach (units _grp);
	deleteGroup _grp ;

    if ( !([] call KPLIB_fnc_isBigtownActive) ) then {
		[format["HangoverIt: Patrol management on %1 - sleeping for %2", clientOwner, 600.0 / GRLIB_difficulty_modifier]] remoteExec ["diag_log", 2] ;
        sleep (600.0 / GRLIB_difficulty_modifier);
    };

};
