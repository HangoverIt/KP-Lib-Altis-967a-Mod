/*
    File: fn_getNearBuildingMissionSpawn.sqf
    Author: HangoverIt
    Date: 2022-10-03
    Last Update: 2022-10-03
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Gets a random building location outside opfor sectors:
        * Distance to blufor FOBs and sectors is more than given min distance
        * Distance to blufor FOBs and sectors is less than given max distance
        * At a distance of sector activation - withinRange

    Parameter(s):
        _min        - Minimum distance to any blufor sector or FOB                      [NUMBER, defaults to 2000]
        _max        - Maximum distance to any blufor sector or FOB                      [NUMBER, defaults to 20000]
        _withinRange- Find building within this distance from sector spawn              [NUMBER, defaults to 150]

    Returns:
        Location or [] if not found
*/
params [
    ["_min", 2000, [0]],
    ["_max", 20000, [0]],
	["_withinRange", 150, [0]]
];


// Only check for opfor spawn points which aren't used already in the current session
private _spawnsToCheck = sectors_allSectors - blufor_sectors;
if (!isNil "used_positions") then {
    _spawnsToCheck = _spawnsToCheck - used_positions;
};

private _allLocs = (blufor_sectors apply {(markerPos _x)}) + GRLIB_all_fobs;
//diag_log format ["All locations are: %1", _allLocs] ;
private _spawnOptions = [] ;
{
	private _valid = false ;
	private _current = _x;
	private _locCurrent = markerPos _current; 
	{
		//diag_log format["Checking against bluefor location %1, marker pos %2", _x, markerPos _x] ;
		// if spawn is too close then exit and fail check
		if ((_locCurrent distance2d _x) < _min) exitWith {_valid = false}; // Too close to a blufor location
		// If spawn is within max distance then it's a candidate
		if ((_locCurrent distance2d _x) < _max) then {_valid = true};
	}forEach _allLocs;
	
	if (_valid) then {
		_spawnOptions pushBack _current ;
	};

} forEach _spawnsToCheck;

if (_spawnOptions isEqualTo []) exitWith {["No mission spawn point found 1", "WARNING"] call KPLIB_fnc_log; []};


_houses = [] ;
{
	_houseReturnLimit = 20 ; // only process the first 20 found to reduce computation
	_spawnMkr = _x ;
	_spawnPos = markerPos _x ;
	_nearHouses = _spawnPos nearObjects ["House", GRLIB_sector_size + _withinRange];
	{
		if (!(_x in KP_liberation_cr_ign_buildings) && ((_x distance2d _spawnPos) > (GRLIB_sector_size))) then {
			_houses pushBack [_x, _spawnMkr];
		};
		_houseReturnLimit = _houseReturnLimit - 1;
		if (_houseReturnLimit <= 0) exitWith {};
	}forEach _nearHouses;
	
}forEach _spawnOptions;

diag_log format["Found %1 houses from %2 spawn options", count _houses, count _spawnOptions] ;

// Check if house is truely on outskirts of all spawn locations
_validHouses = [] ;
{
	_h = _x select 0 ;
	_spawnMkr = _x select 1;
	_houseValid = true ;
	{
		if (_x != _spawnMkr) then { // don't check spawn location associated with the house
			if ((_h distance2d (markerPos _x)) <= GRLIB_sector_size ) exitWith {_houseValid=false;}; // Exclude houses within another sector activation
		};
	}forEach _spawnOptions;
	if (_houseValid) then {
		_validHouses pushBack _h ;
	};
}forEach _houses;

if (_validHouses isEqualTo []) exitWith {["No mission spawn point found 2", "WARNING"] call KPLIB_fnc_log; []};

private _thisHouse = selectRandom _validHouses ;

getPos _thisHouse ;
