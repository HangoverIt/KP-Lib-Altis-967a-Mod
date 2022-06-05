_combat_triggers = [20,40,50,65,80,95];
if ( GRLIB_unitcap < 0.9 ) then { _combat_triggers = [20,45,90]; };
if ( GRLIB_unitcap > 1.3 ) then { _combat_triggers = [15,25,40,65,75,85,95]; };

_combat_triggers_infantry = [15,35,45,60,70,85];
if ( GRLIB_unitcap < 0.9 ) then { _combat_triggers_infantry = [15,40,80]; };
if ( GRLIB_unitcap > 1.3 ) then { _combat_triggers_infantry = [10,20,35,55,70,80,90]; };

sleep 5;

waitUntil { sleep 0.3; !isNil "blufor_sectors" };
waitUntil { sleep 0.3; count blufor_sectors > 3 };

if (worldName != "song_bin_tanh") then {
    {
		// Execute patrols direct with headless clients - HangoverIt
		_headless_client = [] call KPLIB_fnc_getLessLoadedHC;
		if !(isNull _headless_client) then {
			(owner _headless_client) publicVariableClient "GRLIB_difficulty_modifier";
			[_x, false] remoteExec ["manage_one_patrol", _headless_client];
		}else{
			[_x, false] spawn manage_one_patrol;
		};
        sleep 1;
    } foreach _combat_triggers;
};

{
	// Execute patrols direct with headless clients - HangoverIt
	_headless_client = [] call KPLIB_fnc_getLessLoadedHC;
	if !(isNull _headless_client) then {
		(owner _headless_client) publicVariableClient "GRLIB_difficulty_modifier";
		[_x, true] remoteExec ["manage_one_patrol", _headless_client];
	}else{
		[_x, true] spawn manage_one_patrol;
	};
    
    sleep 1;
} foreach _combat_triggers_infantry;
