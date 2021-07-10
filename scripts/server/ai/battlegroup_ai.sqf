params [
    ["_grp", grpNull, [grpNull]], ["_loc", [], [[]]]
];
if (count _loc == 0) then { // HangoverIt - added new loc param to be precise about getNearestBluforObjective
  _loc = getPos (leader _grp);
}; 
// HangoverIt - VCOM setting to prevent wandering groups
_grp setVariable ["VCM_NORESCUE", true] ; // prevent responding to calls for backup

if (isNull _grp) exitWith {};
if (isNil "reset_battlegroups_ai") then {reset_battlegroups_ai = false};

sleep (5 + (random 5));

private _objPos = [_loc] call KPLIB_fnc_getNearestBluforObjective;

[_objPos] remoteExec ["remote_call_incoming"];

private _startpos = getPos (leader _grp);

// Delete previous waypoints
while {!((waypoints _grp) isEqualTo [])} do {deleteWaypoint ((waypoints _grp) select 0);};
{_x doFollow leader _grp} forEach units _grp;

private _waypoint = [];
_waypoint = _grp addWaypoint [_objPos, 50];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointSpeed "NORMAL";
_waypoint setWaypointBehaviour "AWARE";
_waypoint setWaypointCombatMode "YELLOW";
_waypoint setWaypointCompletionRadius 30;

sleep 120 ;

// HangoverIt - Keep attacking squad with refreshed waypoints at the attack location
while {({alive _x} count (units _grp) > 0) && !reset_battlegroups_ai} do {
	
	if ((currentWaypoint _grp) >= (count (waypoints _grp))) then {
		
		// Delete previous waypoints
		while {!((waypoints _grp) isEqualTo [])} do {deleteWaypoint ((waypoints _grp) select 0);};
		{_x doFollow leader _grp} forEach units _grp;

		_startpos = getPos (leader _grp);

		_waypoint = _grp addWaypoint [_objPos, 50];
		_waypoint setWaypointType "SAD";
		_waypoint = _grp addWaypoint [_objPos, 50];
		_waypoint setWaypointType "SAD";
		_waypoint = _grp addWaypoint [_objPos, 50];
		_waypoint setWaypointType "SAD";

	};
	sleep 5;
};

sleep (10 + (random 5));
reset_battlegroups_ai = false;

if (!((units _grp) isEqualTo []) && (GRLIB_endgame == 0)) then {
    [_grp,_objPos] spawn battlegroup_ai;
};
