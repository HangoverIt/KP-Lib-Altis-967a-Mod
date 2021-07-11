

// params old loadout, new loadout
params ["_old_ld", "_new_ld"];

diag_log text "in calculate loadout cost";
diag_log _old_ld;
diag_log _new_ld;

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
        //diag_log format ["%1 : %2", _new_ld_section, _itemtype];
      
        if(_itemtype select 0 == "Weapon") then {
                  
          if((_itemtype select 1) in WeaponLoadoutCost) then {
            // diag_log (WeaponLoadoutCost get (_itemtype select 1));
            // diag_log (WeaponLoadoutCost get (_itemtype select 1)) select 0;
            
            private _updated_cost = (_ld_costs select 0) + ((WeaponLoadoutCost get (_itemtype select 1)) select 0);
            _ld_costs set [0, _updated_cost];          

            diag_log format ["New thing %1 : %2,  cost = %3", _new_ld_section, _itemtype, _ld_costs];
          };          
        };
        
        if (_itemtype select 0 == "Item") then {
          if((_itemtype select 1) in ItemLoadoutCost) then {
            
            private _count = 1;
            if (_i == 0 && count _new_ld == 2) then {

              if (typeName (_new_ld select (_i + 1)) == "SCALAR") then {
                 _count = _new_ld select (_i + 1); 
                 diag_log _count;                
              };

              // diag_log (ItemLoadoutCost get (_itemtype select 1));
              // diag_log (ItemLoadoutCost get (_itemtype select 1)) select 0;  
            
              private _updated_cost = (_ld_costs select 0) + ((ItemLoadoutCost get (_itemtype select 1)) select 0);
              _ld_costs set [0, _updated_cost];          

              diag_log format ["New thing %1 : %2,  cost = %3", _new_ld_section, _itemtype, _ld_costs];

            };
            
          };          
          
        };
        
        if (_itemtype select 0 == "Equipment") then {

          if((_itemtype select 1) in EquipmentLoadoutCost) then {
          
            // diag_log (EquipmentLoadoutCost get (_itemtype select 1));
            // diag_log (EquipmentLoadoutCost get (_itemtype select 1)) select 0;

            private _updated_cost = (_ld_costs select 0) + ((EquipmentLoadoutCost get (_itemtype select 1)) select 0);
            _ld_costs set [0, _updated_cost];          

            diag_log format ["New thing %1 : %2,  cost = %3", _new_ld_section, _itemtype, _ld_costs];
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
        diag_log format ["_updated_cost supplies = %1", _updated_cost];
        _ld_costs set [0, _updated_cost];
        
        _updated_cost = (_ld_costs select 1) + (_sub_costs select 1);
        diag_log format ["_updated_cost ammo = %1", _updated_cost];
        _ld_costs set [1, _updated_cost];

      };
    };
    
  };
};

_ld_costs;