//   check we hgave enough resources to load a loadout
params ["_player"];

private _hasResources = false;

diag_log format ["KPLIB_isNearStart is %1", player getVariable "KPLIB_isNearStart"];

if (player getVariable "KPLIB_isNearStart" == false) then {

  private _nearestFob = [] call KPLIB_fnc_getNearestFob;
  ([_nearestFob] call KPLIB_fnc_getFobResources) params ["", "_supplies", "_ammo", "_fuel", "_hasAir", "_hasRecycling"];

  diag_log format ["Resources at %1: supplies %2 ammo %3", _nearestFob, _supplies, _ammo];

  _storage_areas = (_nearestFob nearobjects (GRLIB_fob_range * 2)) select {(_x getVariable ["KP_liberation_storage_type",-1]) == 0};
  [10, 10, 0, "", 99, _storage_areas] remoteExec ["build_remote_call", 2];
};

_hasResources;
