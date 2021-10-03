sleep (900 / GRLIB_csat_aggressivity);
private _sleeptime = 0;
while {GRLIB_csat_aggressivity > 0.9 && GRLIB_endgame == 0} do {
    _sleeptime =  (1800 + (random 1800)) / (([] call KPLIB_fnc_getOpforFactor) * GRLIB_csat_aggressivity);

    if (combat_readiness >= 80) then {_sleeptime = _sleeptime * 0.75;};
    if (combat_readiness >= 90) then {_sleeptime = _sleeptime * 0.75;};
    if (combat_readiness >= 95) then {_sleeptime = _sleeptime * 0.75;};

    sleep _sleeptime;

    if (!isNil "GRLIB_last_battlegroup_time") then {
        waitUntil {
            sleep 5;
            diag_tickTime > (GRLIB_last_battlegroup_time + (2100 / GRLIB_csat_aggressivity))
        };
    };

	diag_log format["HangoverIt: assessing battlegroup spawning. All players: %1, CSAT Aggression: %2, Opfor cap: %3, Battlegroup cap: %4, FPS: %5 (15.0 threshold)",
		count (allPlayers - entities "HeadlessClient_F"),
		GRLIB_csat_aggressivity,
		[] call KPLIB_fnc_getOpforCap,
		GRLIB_battlegroup_cap,
		diag_fps] ;
    if (
        (count (allPlayers - entities "HeadlessClient_F") >= (6 / GRLIB_csat_aggressivity))
        && {combat_readiness >= (60 - (5 * GRLIB_csat_aggressivity))}
        && {[] call KPLIB_fnc_getOpforCap < GRLIB_battlegroup_cap}
        && {diag_fps > 15.0}
    ) then {
        ["", (random 100) < 45, (random 100) > (20 * GRLIB_csat_aggressivity)] spawn spawn_battlegroup;
    };
};
