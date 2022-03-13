params [ "_sector" ];
private [ "_attacktime", "_ownership", "_grp", "_squad_type" ];

sleep 5;
private _building_range = 50;

_ownership = [ markerpos _sector ] call KPLIB_fnc_getSectorOwnership;
if ( _ownership != GRLIB_side_enemy ) exitWith {};

_squad_type = blufor_squad_inf_light;
if ( _sector in sectors_military ) then {
    _squad_type = blufor_squad_inf;
};

if ( GRLIB_blufor_defenders ) then {
	_sectorpos = markerPos _sector;
	_allbuildings = (nearestObjects [_sectorpos, ["House"], _building_range]) select {alive _x};
	_buildingpositions = [];
	{
		_buildingpositions = _buildingpositions + ([_x] call BIS_fnc_buildingPositions);
	} forEach _allbuildings;
    _grp = creategroup [GRLIB_side_friendly, true];
    {
        _unit = [_x, markerPos _sector, _grp, "PRIVATE", 20, true] call KPLIB_fnc_createManagedUnit;
		if (random 100 >= 20) then { // 80% chance to spawn in building
			_unit setDir (random 360);
			if (count _buildingpositions > 0) then {
				_unit setPos (_buildingpositions deleteAt (random (floor (count _buildingpositions) - 1)));
			};
			[_unit, _sector, GRLIB_side_friendly] spawn building_defence_ai;
		};
    } foreach _squad_type;
    sleep 3;
    _grp setBehaviour "COMBAT";
};

sleep 60;

_ownership = [ markerpos _sector ] call KPLIB_fnc_getSectorOwnership;
if ( _ownership == GRLIB_side_friendly ) exitWith {
    if ( GRLIB_blufor_defenders ) then {
        {
            if ( alive _x ) then { deleteVehicle _x };
        } foreach units _grp;
    };
};

[_sector, 1] remoteExec ["remote_call_sector"];
_attacktime = GRLIB_vulnerability_timer;

while { _attacktime > 0 && ( _ownership == GRLIB_side_enemy || _ownership == GRLIB_side_resistance ) } do {
    _ownership = [markerpos _sector] call KPLIB_fnc_getSectorOwnership;
    _attacktime = _attacktime - 1;
    sleep 1;
};

waitUntil {
    sleep 1;
    [markerpos _sector] call KPLIB_fnc_getSectorOwnership != GRLIB_side_resistance;
};

if ( GRLIB_endgame == 0 ) then {
    if ( _attacktime <= 1 && ( [markerpos _sector] call KPLIB_fnc_getSectorOwnership == GRLIB_side_enemy ) ) then {
        blufor_sectors = blufor_sectors - [ _sector ];
        publicVariable "blufor_sectors";
        [_sector, 2] remoteExec ["remote_call_sector"];
        reset_battlegroups_ai = true;
        [] spawn KPLIB_fnc_doSave;
        stats_sectors_lost = stats_sectors_lost + 1;
        {
            if (_sector in _x) exitWith {
                if ((count (_x select 3)) == 3) then {
                    {
                        detach _x;
                        deleteVehicle _x;
                    } forEach (attachedObjects ((nearestObjects [((_x select 3) select 0), [KP_liberation_small_storage_building], 10]) select 0));

                    deleteVehicle ((nearestObjects [((_x select 3) select 0), [KP_liberation_small_storage_building], 10]) select 0);
                };
                KP_liberation_production = KP_liberation_production - [_x];
            };
        } forEach KP_liberation_production;
    } else {
        [_sector, 3] remoteExec ["remote_call_sector"];
        {[_x] spawn prisonner_ai;} foreach (((markerpos _sector) nearEntities ["Man", GRLIB_capture_size * 0.8]) select {side group _x == GRLIB_side_enemy});
    };
};

sleep 60;

if ( GRLIB_blufor_defenders ) then {
    {
        if ( alive _x ) then { deleteVehicle _x };
    } foreach units _grp;
};
