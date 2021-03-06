/*
    File: fn_spawnFixedEmplacement.sqf
    Author: HangoverIt
    Date: 2021-10-16
    Last Update: 2021-10-16
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Spawns a fixed emplacement weapon with crew (opfor)

    Parameter(s):
        _pos - Center position of the area to spawn fixed emplacements
		_fixed - (optional) list of fixed emplacements. One will be spwaned at random
		_onroad - (optional) boolean flag set to true if fixed position is along a road or around position

    Returns:
        Spawned units [ARRAY]
*/

params [
    ["_pos", [0, 0, 0], [[]]],
	["_fixed", ["O_HMG_01_high_F", "O_GMG_01_high_F", "O_Mortar_01_F", "O_static_AT_F"], [[]]],
	["_onroad", true, [true]]
];

if (_pos isEqualTo [0, 0, 0]) exitWith {["No or zero pos given"] call BIS_fnc_error; []};

private _spawn = selectRandom _fixed; 
private _roads = _pos nearRoads GRLIB_capture_size ;
private _sizefixed = ((sizeOf _spawn) *  0.5) + 1 ; // Convert to radius and add margin
private _trypos = [] ;
private _maxattempts = 20 ;
private _spawnedunits = [] ;
private _dir = 0 ;

if (count _roads > 0 && _onroad) then {	
	private _info = [] ;
	private _rbeg = [] ;
	private _rend = [] ;
	private _s1 = [] ;
	private _s2 = [];
	
	while {count _trypos == 0 && _maxattempts > 0} do {
		private _road = selectRandom _roads ;
		_info = getRoadInfo _road ;
		_rbeg = _info select 6;
		_rend = _info select 7;
		_width = _info select 1;
		_v = _rbeg vectorFromTo _rend ; // normalised vector
		_s1 = [(_v select 1) * -1,(_v select 0) * 1,0]; // normalised perpendicular vector 1
		_s2 = [(_v select 1) * 1,(_v select 0) * -1,0]; // normalised perpendicular vector 2
		
		// Try halfway along roads
		_diff = _rbeg vectorDiff _rend ;
		_diff = _diff vectorMultiply 0.5 ;
		_vmid = _rbeg vectorAdd _diff ;
	
		_trypos = _vmid vectorAdd (_s1 vectorMultiply (_sizefixed + _width)) ;
		_trypos = _trypos findEmptyPosition [0,0,_spawn] ;
		_isOnRoad = false ;
		if (count _trypos > 0) then {_isOnRoad = isOnRoad _trypos;};
		if (count _trypos == 0 || _isOnRoad) then {
			_trypos = _vmid vectorAdd (_s2 vectorMultiply (_sizefixed + _width));
			_trypos = _trypos findEmptyPosition [0,0,_spawn] ;
			if (count _trypos == 0) then {
				_trypos = [] ;
			}else{
				if (isOnRoad _trypos) then {
					_trypos = [] ;
				};
			};
		};
		_maxattempts = _maxattempts -1;
		//diag_log format ["HangoverIt: Fixed emplacement attempts remaining %1, spawn at %2, s1 %3, s2 %4", _maxattempts, _trypos,_s1,_s2] ;
	};
	_dir = _rbeg getDir _rend;

}else{
	// No roads so find a safe place
	_trypos = [_pos, 10, GRLIB_capture_size * 0.66, _sizefixed, 0, 0.1, 0, [], _pos] call BIS_fnc_findSafePos;
	_trypos pushBack 0; // add z position
	
	_dir = _pos getDir _trypos;
};

if (count _trypos > 0) then {
	// Found position. Spawn units
	_fixedobj = [_trypos, _spawn, true] call KPLIB_fnc_spawnVehicle;
	_fixedobj setDir (_dir) ;
	waitUntil {sleep 0.2; count (crew _fixedobj) >0;};
	_grp = group ((crew _fixedobj) select 0) ;
	_unit1 = [opfor_rifleman, _trypos, _grp] call KPLIB_fnc_createManagedUnit;
	_grp addVehicle _fixedobj ;
	_spawnedunits = [_unit1, _fixedobj] ;
};

_spawnedunits;
