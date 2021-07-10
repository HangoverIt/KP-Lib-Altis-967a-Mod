

// params old loadout, new loadout
params ["_old_ld", "_new_ld"];

diag_log text "in calculate loadout cost";
private _ld_costs = [0, 0, 0];

private _i = 0;
// for each section in new loadout
for [{private _i = 0}, {_i < count _new_ld}, {_i = _i + 1}] do {

  private _old_ld_section = [];
  // if there's somthing in the old, pass it on in the recursion
  if(_i < count _old_ld) then {
    _old_ld_section = _old_ld select _i;
  };
  
  private _new_ld_section = _new_ld select _i;

  if (_old_ld_section isNotEqualTo _new_ld_section) then {
  
    if (typeName _new_ld_section == "STRING") then {
    
      if (_new_ld_section != "") then {

        private _itemtype = _new_ld_section call BIS_fnc_itemType;
        diag_log format ["%1 : %2", _new_ld_section, _itemtype];
      
        if(_itemtype select 0 == "Weapon") then {
        
          diag_log format ["a weapon %1", _itemtype select 1];
          
          if((_itemtype select 1) in WeaponLoadoutCost) then {
            diag_log (WeaponLoadoutCost get (_itemtype select 1));
            diag_log (WeaponLoadoutCost get (_itemtype select 1)) select 0;
            _ld_costs set [0, (WeaponLoadoutCost get (_itemtype select 1)) select 0];          
          };
        };
      
      };
    };

    if (typeName _new_ld_section == "ARRAY") then{    
      if (count _new_ld_section > 0) then {
      
        private _sub_costs = [_old_ld_section, _new_ld_section] call KPLIB_fnc_calculateLoadoutCost;
        
        diag_log format ["_ld_costs = %1", _ld_costs];
        diag_log format ["_sub_costs = %1", _sub_costs];

        private _updated_cost = (_ld_costs select 0) + (_sub_costs select 0);
        diag_log _updated_cost;
        _ld_costs set [0, _updated_cost];
        
      };
    };
    
  };
};

_ld_costs;