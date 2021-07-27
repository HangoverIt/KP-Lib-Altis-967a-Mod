private _spawn_marker = [ 2000, 999999, false ] call KPLIB_fnc_getOpforSpawnPoint;
if ( _spawn_marker == "" ) exitWith {["Could not find position for civ search and rescue mission", "ERROR"] call KPLIB_fnc_log;};
used_positions pushbackUnique _spawn_marker;

private _civcarpos = (markerPos _spawn_marker) getPos [random 200, random 360];
private _civcar = KPLIB_civ_sar_car createVehicle _civcarpos;

_civcar setPos _civcarpos;
_civcar setPos _civcarpos;
private _civcarDir = (random 360);
_civcar setDir _civcarDir;

private _civLeader = createGroup [GRLIB_side_enemy, true];
private _civLeaderPos = (getpos _civcar) getPos [25, random 360];

private _nonvip = ["C_Nikos", _civLeaderPos, _civLeader, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
sleep 0.2;

private _vip = ["C_Nikos_aged", _civLeaderPos getPos [1, random 360], _civLeader, "PRIVATE", 0.5] call KPLIB_fnc_createManagedUnit;
sleep 2;

private _civUnits = units _civLeader;
{
    [ _x, true, true ] spawn prisonner_ai;
    _x setDir (random 360);
    sleep 0.5
} foreach (_civUnits);

// Disable any VCOM on the civilians (i.e. don't steal cars)
_civLeader setVariable ["Vcm_Disable",true];


//_marker = createMarker ["mIfestiona", _civLeaderPos]; // DEBUG
//_marker setMarkerType "hd_objective";
//_marker setMarkerColor "ColorRed";
//_marker setMarkerText "Civs";
//_marker setMarkerSize [1,1];



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

private _vehicles = [] ;
private _vehtospawn = [];
private _spawnchances = [75,50,15];
{if (random 100 < _x) then {_vehtospawn pushBack (selectRandom _vehicle_pool);};} foreach _spawnchances;
{
	private _v = ([(getpos _civcar) getPos [30 + (random 30), random 360], _x, true] call KPLIB_fnc_spawnVehicle) ;
	_v addMPEventHandler ['MPKilled', {_this spawn kill_manager}]; 
	_vehicles pushBack _v;
} foreach _vehtospawn;

secondary_objective_position = getpos _civcar;
secondary_objective_position_marker = secondary_objective_position getPos [800, random 360];
publicVariable "secondary_objective_position_marker";
sleep 1;
GRLIB_secondary_in_progress = 2; publicVariable "GRLIB_secondary_in_progress";
[9] remoteExec ["remote_call_intel"];

waitUntil {
    sleep 5;
    ({( alive _x ) && ( _x distance ( [ getpos _x ] call KPLIB_fnc_getNearestFob ) > 50 )} count _civUnits == 0) || !(alive _vip)
};

sleep 5;

if ( !alive _vip) then {
    [10] remoteExec ["remote_call_intel"];
} else {
    [11] remoteExec ["remote_call_intel"];
    private _grp = createGroup [GRLIB_side_friendly, true];
    { [_x ] joinSilent _grp; } foreach _civUnits;
    while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
    {_x doFollow (leader _grp)} foreach units _grp;
	private _gain = KP_liberation_cr_mission_gain;
	if (alive _nonvip) then {
		_gain = _gain + floor(KP_liberation_cr_mission_gain/2);
	};
	[(_gain), false] spawn F_cr_changeCR;
	
	// Clean up mission actors
	{ [ _x ] spawn { sleep 600; deleteVehicle (_this select 0) } } foreach _civUnits;
	//{ [ _x ] spawn { sleep 600; deleteVehicle (_this select 0) } } foreach units _grppatrol;
	//{ [ _x ] spawn { sleep 600; deleteVehicle (_this select 0) } } foreach units _grpsentry;
	// Delete vehicles - complex - what if player captures? What if empty and crew got out?
	//{ [ _x ] spawn { sleep 600; {deleteVehicleCrew _x} forEach crew (_this select 0) ;deleteVehicle (_this select 0) } } foreach _vehicles;
	//[_civcar] spawn { sleep 600; deleteVehicle (_this select 0) };
	
};

// Have remaining AI enemy go to FOB - they want their man back / revenge!
private _go_to = [ _civcarpos ] call KPLIB_fnc_getNearestFob;
{
	if (side (leader _x ) == GRLIB_side_enemy) then {
		while {(count (waypoints (group leader _x))) != 0} do {deleteWaypoint ((waypoints (group leader _x)) select 0);};
		private _wp = (group leader _x) addWaypoint [_go_to,0];
		_wp setWaypointType "MOVE";
	};
}forEach _vehicles ;

{
	while {(count (waypoints _x)) != 0} do {deleteWaypoint ((waypoints _x) select 0);};
	private _wp = _x addWaypoint [_go_to,0];
	_wp setWaypointType "MOVE";
}forEach [ _grppatrol, _grpsentry] ;

//deleteMarker _marker ; // DEBUG

stats_secondary_objectives = stats_secondary_objectives + 1;

GRLIB_secondary_in_progress = -1; publicVariable "GRLIB_secondary_in_progress";
sleep 1;
doSaveTrigger = true;
