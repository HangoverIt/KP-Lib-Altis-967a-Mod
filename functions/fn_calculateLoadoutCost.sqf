

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
  
  private _new_ld_section = (_new_ld select _i);

  if (_old_ld_section isNotEqualTo _new_ld_section) then {

    switch(typeName _new_ld_section) do
    {
      case "STRING": {
        if (_new_ld_section != "") then {          
          private _itemtype = _new_ld_section call BIS_fnc_itemType;
          diag_log format ["%1 is a type %2", _new_ld_section, _itemtype];
        };
      };
      case "SCALAR": {
        diag_log format ["count is %1", _new_ld_section];
      };
      case "ARRAY": {
        if(count _new_ld_section > 0) then {
          diag_log format ["array is %1", _new_ld_section];

          [_old_ld_section, _new_ld_section] call KPLIB_fnc_calculateLoadoutCost;

        };
      };
      
      
    };
    
    
    
  };
};
