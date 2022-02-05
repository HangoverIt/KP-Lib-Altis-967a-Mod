params ["_sector"];

if (_sector in sectors_bigtown || _sector in sectors_capture) then {
    private _penalty = 0;

    {
        if (_sector == (_x select 0)) exitWith {
			_buildings = ([_sector] call F_cr_getBuildings);
			_penalty = (_x select 1) - _buildings;
			_x set[1,_buildings]; // HangoverIt - update the count of alive or non-damaged buildings in case sector is lost and recaptured in same game
		};
    } forEach KP_liberation_cr_sectorbuildings;

    stats_civilian_buildings_destroyed = stats_civilian_buildings_destroyed + _penalty;

    _penalty = _penalty * KP_liberation_cr_building_penalty;

    if (_penalty > 0) then {
        [1, [(_penalty / KP_liberation_cr_building_penalty)]] remoteExec ["KPLIB_fnc_crGlobalMsg"];
    };

    if (_sector in sectors_bigtown) then {
        [(2 * KP_liberation_cr_sector_gain - _penalty), false] spawn F_cr_changeCR;
    } else {
        [(KP_liberation_cr_sector_gain - _penalty), false] spawn F_cr_changeCR;
    };

	diag_log format ["HangoverIt: Civilian sector %1 (%2) captured. Destroyed Buildings = %3", markerText _sector, _sector, _penalty] ;
    [format ["Civilian sector %1 (%2) captured. Penalty: %3", markerText _sector, _sector, _penalty], "CIVREP"] call KPLIB_fnc_log;
};
