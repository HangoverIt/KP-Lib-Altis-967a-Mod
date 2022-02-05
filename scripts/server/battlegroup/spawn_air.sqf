params ["_first_objective"];

if (opfor_air isEqualTo []) exitWith {false};

private _planes_number = ((floor linearConversion [40, 100, combat_readiness, 1, 3]) min 3) max 0;

if (_planes_number < 1) exitWith {};

private _class = selectRandom opfor_air;
private _spawnPoint = ([sectors_airspawn, [_first_objective], {(markerPos _x) distance _input0}, "ASCEND"] call BIS_fnc_sortBy) select 0;
private _spawnPos = [];
private _plane = objNull;
private _grp = createGroup [GRLIB_side_enemy, true];

for "_i" from 1 to _planes_number do {
    _spawnPos = markerPos _spawnPoint;
    _spawnPos = [(((_spawnPos select 0) + 500) - random 1000), (((_spawnPos select 1) + 500) - random 1000), 200];
    _plane = createVehicle [_class, _spawnPos, [], 0, "FLY"];
    createVehicleCrew _plane;
    _plane flyInHeight (120 + (random 180));
    _plane addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
    [_plane] call KPLIB_fnc_addObjectInit;
    {[_x,true] call KPLIB_fnc_initManagedUnit ;} forEach (crew _plane); // HangoverIt - updated to general init for created units
    (crew _plane) joinSilent _grp;
    sleep 1;
	
	// HangoverIt - make the planes a bit more intelligent against targets
	_plane setVehicleRadar 1;
	_plane setVehicleReceiveRemoteTargets true ;
	_plane setVehicleReportRemoteTargets true ;
};

while {!((waypoints _grp) isEqualTo [])} do {deleteWaypoint ((waypoints _grp) select 0);};
sleep 1;
{_x doFollow leader _grp} forEach (units _grp);
sleep 1;

private _waypoint = _grp addWaypoint [_first_objective, 500];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointSpeed "FULL";
_waypoint setWaypointBehaviour "AWARE";
_waypoint setWaypointCombatMode "RED";

_waypoint = _grp addWaypoint [_first_objective, 500];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointSpeed "FULL";
_waypoint setWaypointBehaviour "AWARE";
_waypoint setWaypointCombatMode "RED";

_waypoint = _grp addWaypoint [_first_objective, 500];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointSpeed "FULL";
_waypoint setWaypointBehaviour "AWARE";
_waypoint setWaypointCombatMode "RED";

for "_i" from 1 to 6 do {
    _waypoint = _grp addWaypoint [_first_objective, 500];
    _waypoint setWaypointType "SAD";
};

_waypoint = _grp addWaypoint [_first_objective, 500];
_waypoint setWaypointType "CYCLE";

_grp setCurrentWaypoint [_grp, 2];
