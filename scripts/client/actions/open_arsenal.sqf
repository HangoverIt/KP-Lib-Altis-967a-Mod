if (KPLIB_directArsenal) exitWith {
    if (KP_liberation_ace && KP_liberation_arsenal_type) then {
        [player, player, false] call ace_arsenal_fnc_openBox;
    } else {
        ["Open", false] spawn BIS_fnc_arsenal;
    };
};

load_loadout = 0;
edit_loadout = 0;
respawn_loadout = 0;
load_from_player = -1;
exit_on_load = 0;
createDialog "liberation_arsenal";

private _backpack = backpack player;

private _old_loadout = getUnitLoadout player;

private ["_loadouts_data"];
// Get loadouts either from ACE or BI arsenals
if (KP_liberation_ace && KP_liberation_arsenal_type) then {
    _loadouts_data = +(profileNamespace getVariable ["ace_arsenal_saved_loadouts", []]);
} else {
    private _saved_loadouts = +(profileNamespace getVariable "bis_fnc_saveInventory_data");
    _loadouts_data = [];
    private _counter = 0;
    if (!isNil "_saved_loadouts") then {
        {
            if (_counter % 2 == 0) then {
                _loadouts_data pushback _x;
            };
            _counter = _counter + 1;
        } forEach _saved_loadouts;
    };
};

waitUntil { dialog };

if ( count _loadouts_data > 0 ) then {

    { lbAdd [201, _x param [0]]} foreach _loadouts_data;

    if ( lbSize 201 > 0 ) then {
        ctrlEnable [ 202, true ];
        lbSetCurSel [ 201, 0 ];
    } else {
        ctrlEnable [ 202, false ];
    };

} else {
    ctrlEnable [ 202, false ];
};

private _loadplayers = [];
{
    if ( !(name _x in [ "HC1", "HC2", "HC3" ]) )  then {
        _loadplayers pushback [ name _x, _x ];
    };
} foreach ( allPlayers - [ player ] );

if ( count _loadplayers > 0 ) then {

    {
        private _nextplayer = _x select 1;
        private _namestr = "";
        if(count (squadParams _nextplayer) != 0) then {
            _namestr = "[" + ((squadParams _nextplayer select 0) select 0) + "] ";
        };
        _namestr = _namestr + name _nextplayer;

        lbAdd [ 203, _namestr ];
        lbSetCurSel [ 203, 0 ];
    } foreach _loadplayers;

} else {
    ctrlEnable [ 203, false ];
    ctrlEnable [ 204, false ];
};

((findDisplay 5251) displayCtrl 201) ctrlAddEventHandler [ "mouseButtonDblClick" , { exit_on_load = 1; load_loadout = 1; } ];

while { dialog && (alive player) && edit_loadout == 0 } do {

    if ( load_loadout > 0 ) then {
        private _loaded_loadout = _loadouts_data select (lbCurSel 201);
        if (KP_liberation_ace && KP_liberation_arsenal_type) then {
            player setUnitLoadout (_loaded_loadout select 1);
        } else {
            [player, [profileNamespace, _loaded_loadout]] call BIS_fnc_loadInventory;
        };

        if (KP_liberation_arsenalUsePreset) then {
        
            if ([_backpack] call KPLIB_fnc_checkGear) then {
              hint format [ localize "STR_HINT_LOADOUT_LOADED", _loaded_loadout param [0]];             
            };
            
        } else {
            hint format [ localize "STR_HINT_LOADOUT_LOADED", _loaded_loadout param [0]];
        };

        if ( exit_on_load == 1 ) then {
            closeDialog 0;
        };
        load_loadout = 0;
    };

    if ( respawn_loadout > 0 ) then {
        GRLIB_respawn_loadout = [ player, ["repetitive"] ] call KPLIB_fnc_getLoadout;
        hint localize "STR_MAKE_RESPAWN_LOADOUT_HINT";
        respawn_loadout = 0;
    };

    if ( load_from_player >= 0 ) then {
        private _playerselected = ( _loadplayers select load_from_player ) select 1;
        if ( alive _playerselected ) then {
            [player,  [_playerselected, ["repetitive"]] call KPLIB_fnc_getLoadout] call KPLIB_fnc_setLoadout;
            hint format [ localize "STR_LOAD_PLAYER_LOADOUT_HINT", name _playerselected ];
        };
        load_from_player = -1;
    };

    sleep 0.1;
};

if ( edit_loadout > 0 ) then {
    closeDialog 0;
    waitUntil { !dialog };
    if (KP_liberation_ace && KP_liberation_arsenal_type) then {
        [player, player, false] call ace_arsenal_fnc_openBox;
    } else {
        [ "Open", false ] spawn BIS_fnc_arsenal;
    };

    if (KP_liberation_arsenalUsePreset) then {
        uiSleep 5;
        private _arsenalDisplay = ["RSCDisplayArsenal", "ace_arsenal_display"] select (KP_liberation_ace && KP_liberation_arsenal_type);
        waitUntil {sleep 1; isNull (uinamespace getvariable [_arsenalDisplay, displayNull])};
        [_backpack] call KPLIB_fnc_checkGear;        
    };
};

// Mark Bennett changes
//   check we hgave enough resources to load a new loadout, reset to old loadout if not
diag_log text "calculating and applying loadout cost here";

// get the players new loadout
private _new_loadout = getUnitLoadout player;

// final cost of taking a new loadout [supplies, ammo, fuel]
private _costs = [0, 0, 0];

// apply costs only if either the player is not on the carrier or the loadout has changed
if (player getVariable "KPLIB_isNearStart" == false && _old_loadout isNotEqualTo _new_loadout) then {

  [_old_loadout, _new_loadout] call KPLIB_fnc_calculateLoadoutCost;
  
  
  
  
  // private _index = 0;
  
  // while {_index < (count _new_loadout) && _index < (count _old_loadout)} do
  // {
  
  
    // private _new_ld_section = (_new_loadout select _index);
    // private _curr_ld_section = (_old_loadout select _index);

    // if(_new_ld_section isNotEqualTo _curr_ld_section) then
    // {
      // private _new_item = _new_ld_section select 0;
      // private _curr_item = _curr_ld_section select 0;

      // diag_log text "started handling section";
      // diag_log _curr_ld_section;
      // diag_log _new_item;
      // diag_log _curr_item;

      // switch(_index) do
      // {
        //primary weapon slot
        // case 0:{
          // diag_log text "in the switch";
          // diag_log _new_item;
          // diag_log _curr_item;
          
          // if (_new_item isNotEqualTo _curr_item) then {
            
            // if (typeName _new_item == "STRING") then {
            
              // diag_log text "what is the value of _new_item";
              // diag_log _new_item;
              // private _itemtype = _new_item call BIS_fnc_itemType;
              // diag_log text "what is the type of _new_item";
              // diag_log _itemtype;
              
              //add up cost in supplies
              // private _amt = (LoadoutCost select 0);
              //_amt *= 1;
              // _costs set [0, _amt];
              
              // diag_log (_costs select 0);
            // };
          // };
          

        // };
          
          
      // };
    // };
    // _index = _index + 1; 
  // };
  
  
  
  // apply loadout cost to nearst FOB
  private _nearestFob = [] call KPLIB_fnc_getNearestFob;
  ([_nearestFob] call KPLIB_fnc_getFobResources) params ["", "_supplies", "_ammo", "_fuel", "_hasAir", "_hasRecycling"];

  if(_supplies > (LoadoutCost select 0) && _ammo > (LoadoutCost select 1)) then {
  
    _storage_areas = (_nearestFob nearobjects (GRLIB_fob_range * 2)) select {(_x getVariable ["KP_liberation_storage_type",-1]) == 0};
    [LoadoutCost select 0, LoadoutCost select 1, 0, "", 99, _storage_areas] remoteExec ["build_remote_call", 2];
    
    hint format ["cost %1 supplies and %2 ammo", LoadoutCost select 0, LoadoutCost select 1];
    
  }else{
  
    player setUnitLoadout _old_loadout;
    hint "Not enough resources, loadout not changed";
  };  
};



