private _resupply_zone_radius = 20;
private _timeOut = 1800 ;
private _maxCrateStorage = 100 ;
private _maxSupply = _maxCrateStorage * 3 ;
private _civCount = ceil(random(5)) + 3;

private _spawn_loc = [ 1000, 5000 ] call KPLIB_fnc_getNearBuildingMissionSpawn;
if ( _spawn_loc isEqualTo [] ) exitWith {
	resources_intel = resources_intel + (GRLIB_secondary_missions_costs select 4); // reimburse players with intel not used
	["Could not find position for civ resupply mission", "ERROR"] call KPLIB_fnc_log;
};

private _mkr = createMarkerLocal ["CIVRESUPPLY", _spawn_loc] ;
_mkr setMarkerPosLocal _spawn_loc ;
_mkr setMarkerType "hd_pickup";

private _mkr_zone = createMarkerLocal ["CIVRESUPPLYZONE", _spawn_loc];
_mkr_zone setMarkerColorLocal "ColorCIV";
_mkr_zone setMarkerShapeLocal "ELLIPSE";
_mkr_zone setMarkerBrushLocal "FDiagonal";
_mkr_zone setMarkerSize [_resupply_zone_radius,_resupply_zone_radius];


secondary_objective_position_marker = _spawn_loc ;
publicVariable "secondary_objective_position_marker";
sleep 1;
GRLIB_secondary_in_progress = 2; publicVariable "GRLIB_secondary_in_progress";
[13] remoteExec ["remote_call_intel"];

private _covertMinSec = {
	_min = str(floor(_this / 60));
	_sec = str(_this % 60) ;
	if (count(_min) <=1) then {_min = "0" + _min};
	if (count(_sec) <=1) then {_sec = "0" + _sec};
	_min + ":" + _sec;
};

private _civilianRecipients = [];
private _grp = createGroup [GRLIB_side_civilian, true];
for [ {_idx=0},{_idx < _civCount},{_idx=_idx+1} ] do {
    _civilianRecipients pushBack ([selectRandom civilians, _spawn_loc, _grp, "PRIVATE", 0.5, false] call KPLIB_fnc_createManagedUnit);
};
_grp setVariable ["Vcm_Disable",true,true];

_opforSector = [2000, _spawn_loc] call KPLIB_fnc_getNearestOpforSector ;
private _spawn_opfor_at = [] ;
if (_opforSector != "") then {
	_spawn_opfor_at = markerPos _opforSector ;
}else{
	_spawn_opfor_at = _spawn_loc;
};

// Create infantry and supporting vehicle for patrol
private _infClasses = [KPLIB_o_inf_classes, militia_squad] select (combat_readiness < 50);
private _vehicle_pool = [opfor_vehicles, opfor_vehicles_low_intensity] select (combat_readiness < 50);
private _grpPatrol = createGroup [GRLIB_side_enemy, true];
for "_i" from 0 to (8) do {
	[selectRandom _infClasses, _spawn_opfor_at, _grpPatrol] call KPLIB_fnc_createManagedUnit;
};
_vehicle = [_spawn_opfor_at, selectRandom _vehicle_pool] call KPLIB_fnc_spawnVehicle;
(crew _vehicle) joinSilent _grpPatrol;
_vehicle = [_spawn_opfor_at, selectRandom _vehicle_pool] call KPLIB_fnc_spawnVehicle;
(crew _vehicle) joinSilent _grpPatrol;

// Clear all waypoints
while {(count (waypoints _grpPatrol)) != 0} do {deleteWaypoint ((waypoints _grpPatrol) select 0);};
_grpPatrol setCombatBehaviour "SAFE" ;
private _triggeredPatrol = false ;
units _grpPatrol doFollow leader _grpPatrol;

while {_timeOut > 0} do {
	_crates = _spawn_loc nearObjects [KP_liberation_supply_crate,_resupply_zone_radius];
	if !(_crates isEqualTo []) then {
		_receivedCrate = false ;
		{
			if (count (attachedObjects _x) == 0 && isNull (ropeAttachedTo _x) && (getPos _x select 2) <= 0.8) then { 
				_supply = _maxCrateStorage min (_x getVariable ["KP_liberation_crate_value",0]);
				_maxSupply = _maxSupply - _supply;
				_gain = floor(KP_liberation_cr_resupply_gain * (_supply / _maxCrateStorage)) ; // full crates provide max points
				[(_gain), false] spawn F_cr_changeCR;
				deleteVehicle _x ;
				_receivedCrate = true ;
			};
		}forEach _crates;
		if (_receivedCrate) then {
			[14] remoteExec ["remote_call_intel"];
		};
	};
	if (_maxSupply <= 0) exitWith {_timeOut = 0};
	
	// Check for bluefor entering area. Trigger patrol
	_men = (_spawn_loc nearObjects ["Man",_resupply_zone_radius*2]) select {side _x == GRLIB_side_friendly};
	if ((count _men > 0) && !_triggeredPatrol) then {
		_triggeredPatrol = true; 
		_wp = _grpPatrol addWaypoint [_spawn_loc,0,0];
		_wp setWaypointType "MOVE";
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointCompletionRadius 50;
	};
	
	if (_timeOut % 60 == 0) then {
		_smoke = createVehicle ["SmokeShellGreen", _spawn_loc, [], 5, "NONE"];
	};
	_mkr setMarkerText "Supplies " + (_timeOut call _covertMinSec);
	_timeOut = _timeOut - 1;
	sleep 1 ;
};

[12] remoteExec ["remote_call_intel"];

deleteMarker _mkr ; 
deleteMarker _mkr_zone ; 
{
	deleteVehicle _x;
}forEach _civilianRecipients;

// Move all soldiers to another target
private _go_to = [ _civcarpos ] call KPLIB_fnc_getNearestFob;
while {(count (waypoints _grpPatrol)) != 0} do {deleteWaypoint ((waypoints _grpPatrol) select 0);};
_wp = _grpPatrol addWaypoint [_go_to,0];
_wp setWaypointType "MOVE";

stats_secondary_objectives = stats_secondary_objectives + 1;

GRLIB_secondary_in_progress = -1; publicVariable "GRLIB_secondary_in_progress";
sleep 1;
doSaveTrigger = true;
