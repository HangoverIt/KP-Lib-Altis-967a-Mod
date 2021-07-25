diag_log text "civlian rescue started";

private _spawn_marker = [ 2000, 999999, false ] call KPLIB_fnc_getOpforSpawnPoint;
if ( _spawn_marker == "" ) exitWith {["Could not find position for search and rescue mission", "ERROR"] call KPLIB_fnc_log;};
used_positions pushbackUnique _spawn_marker;

private _civcarpos = (markerPos _spawn_marker) getPos [random 200, random 360];
private _civcar = KPLIB_civ_sar_car createVehicle _civcarpos;
_civcar allowDamage false;
_civcar setPos _civcarpos;
_civcar setPos _civcarpos;
private _civcarDir = (random 360);
_civcar setDir _civcarDir;

private _civLeader = createGroup [GRLIB_side_enemy, true];
private _civLeaderPos = (getpos _civcar) getPos [25, random 360];

["C_Nikos", _civLeaderPos, _civLeader, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
sleep 0.2;

["C_Nikos_aged", _civLeaderPos getPos [1, random 360], _civLeader, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
sleep 2;


// add marker on AO/target
_marker = createMarker ["mIfestiona", _civLeaderPos];
_marker setMarkerType "hd_objective";
_marker setMarkerColor "ColorRed";
_marker setMarkerText "The Civilians";
_marker setMarkerSize [1,1];



private _civUnits = units _civLeader;
{
    [ _x, true ] spawn prisonner_ai;
    _x setDir (random 360);
    sleep 0.5
} foreach (_civUnits);

private _grppatrol = createGroup [GRLIB_side_enemy, true];
private _patrolcorners = [
    [ (getpos _civcar select 0) - 40, (getpos _civcar select 1) - 40, 0 ],
    [ (getpos _civcar select 0) + 40, (getpos _civcar select 1) - 40, 0 ],
    [ (getpos _civcar select 0) + 40, (getpos _civcar select 1) + 40, 0 ],
    [ (getpos _civcar select 0) - 40, (getpos _civcar select 1) + 40, 0 ]
];

{
    [_x, _patrolcorners select 0, _grppatrol, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
} foreach ([] call KPLIB_fnc_getSquadComp);

while {(count (waypoints _grppatrol)) != 0} do {deleteWaypoint ((waypoints _grppatrol) select 0);};
{
    private _nextcorner = _x;
    _waypoint = _grppatrol addWaypoint [_nextcorner,0];
    _waypoint setWaypointType "MOVE";
    _waypoint setWaypointSpeed "LIMITED";
    _waypoint setWaypointBehaviour "SAFE";
    _waypoint setWaypointCompletionRadius 5;
} foreach _patrolcorners;

_waypoint = _grppatrol addWaypoint [(_patrolcorners select 0), 0];
_waypoint setWaypointType "CYCLE";
{_x doFollow (leader _grppatrol)} foreach units _grppatrol;

private _grpsentry = createGroup [GRLIB_side_enemy, true];
private _nbsentry = 2 + (floor (random 3));

for [ {_idx=0},{_idx < _nbsentry},{_idx=_idx+1} ] do {
    [opfor_sentry, _civLeaderPos getPos [1, random 360], _grpsentry, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
};

(leader _grpsentry) setDir (random 360);

(opfor_transport_truck createVehicle ((getpos _civcar) getPos [25, random 360])) setDir random 360;

private _vehicle_pool = opfor_vehicles;
if ( combat_readiness < 50 ) then {
    _vehicle_pool = opfor_vehicles_low_intensity;
};

private _vehtospawn = [];
private _spawnchances = [75,50,15];
{if (random 100 < _x) then {_vehtospawn pushBack (selectRandom _vehicle_pool);};} foreach _spawnchances;
{([(getpos _civcar) getPos [30 + (random 30), random 360], _x, true] call KPLIB_fnc_spawnVehicle) addMPEventHandler ['MPKilled', {_this spawn kill_manager}]; } foreach _vehtospawn;

secondary_objective_position = getpos _civcar;
secondary_objective_position_marker = secondary_objective_position getPos [800, random 360];
publicVariable "secondary_objective_position_marker";
sleep 1;
GRLIB_secondary_in_progress = 2; publicVariable "GRLIB_secondary_in_progress";
[6] remoteExec ["remote_call_intel"];

waitUntil {
    sleep 5;
    { ( alive _x ) && ( _x distance ( [ getpos _x ] call KPLIB_fnc_getNearestFob ) > 50 ) } count _civUnits == 0
};

sleep 5;

private _alive_crew_count = { alive _x } count _civUnits;
if ( _alive_crew_count == 0 ) then {
    [7] remoteExec ["remote_call_intel"];
} else {
    [8] remoteExec ["remote_call_intel"];
    private _grp = createGroup [GRLIB_side_friendly, true];
    { [_x ] joinSilent _grp; } foreach _civUnits;
    while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
    {_x doFollow (leader _grp)} foreach units _grp;
    { [ _x ] spawn { sleep 600; deleteVehicle (_this select 0) } } foreach _civUnits;
};

[(KP_liberation_cr_mission_gain), false] spawn F_cr_changeCR;
stats_secondary_objectives = stats_secondary_objectives + 1;

GRLIB_secondary_in_progress = -1; publicVariable "GRLIB_secondary_in_progress";
sleep 1;
doSaveTrigger = true;
