// Recursively search loadout array filtering any differences between the old and the new loadouts and
// applying a cost to everything unique to the new loadout
// Costs are obtained from the kp_liberation_config file in the WeaponLoadoutCost, ItemLoadoutCost, EquipmentLoadoutCost, MagazineLoadoutCost and MineLoadoutCost hash maps

// params old loadout, new loadout
params ["_old_ld", "_new_ld"];

private _ld_costs = [0, 0, 0];
private _total_supplies_cost = 0;
private _total_ammo_cost = 0;
private _count = 0;

private _i = 0;

// for each section in the new loadout
for [{private _i = 0}, {_i < count _new_ld}, {_i = _i + 1}] do {

  private _old_ld_section = [];
  // if there's somthing in the old, pass it on in the recursion
  if(_i < count _old_ld) then {
    _old_ld_section = _old_ld select _i;
  };
  
  private _new_ld_section = _new_ld select _i;
  
  // only evaluate things that differ or have a count value
  private _has_count = false;
  if( typeName (_new_ld select _i) == "SCALAR" || ((count _new_ld > _i + 1) && typeName (_new_ld select _i + 1) == "SCALAR")) then {
    _has_count = true;
  };
  
  if (_old_ld_section isNotEqualTo _new_ld_section || _has_count) then {
  
    // should be an identifier
    if (typeName _new_ld_section == "STRING") then {
    
      if (_new_ld_section != "") then {

        private _itemtype = _new_ld_section call BIS_fnc_itemType;
        
        // thee's got to be at least one thing if we got here
        _count = 1;
        
        if(_itemtype select 0 == "Weapon") then {
                  
          if((_itemtype select 1) in WeaponLoadoutCost) then {
          
            _total_supplies_cost = _total_supplies_cost + (_ld_costs select 0) + ((WeaponLoadoutCost get (_itemtype select 1)) select 0);

          };          
        };
        
        if (_itemtype select 0 == "Item") then {
        
          if((_itemtype select 1) in ItemLoadoutCost) then {

            _total_supplies_cost = _total_supplies_cost + (_ld_costs select 0) + ((ItemLoadoutCost get (_itemtype select 1)) select 0);

          };                    
        };
        
        if (_itemtype select 0 == "Equipment") then {

          if((_itemtype select 1) in EquipmentLoadoutCost) then {
          
            _total_supplies_cost = _total_supplies_cost +  (_ld_costs select 0) + ((EquipmentLoadoutCost get (_itemtype select 1)) select 0);

          };          
        
        };
        
        
        if (_itemtype select 0 == "Magazine") then {
          
          if((_itemtype select 1) in MagazineLoadoutCost) then {
          
            _total_ammo_cost = _total_ammo_cost +  (_ld_costs select 1) + ((MagazineLoadoutCost get (_itemtype select 1)) select 1);

          };          
        
        };              

        if (_itemtype select 0 == "Mine") then {
          
          if((_itemtype select 1) in MineLoadoutCost) then {
          
            _total_ammo_cost = _total_ammo_cost +  (_ld_costs select 1) + ((MineLoadoutCost get (_itemtype select 1)) select 1);

          };                  
        };        
      };
    };
    
    // some items have a seperate count value
    if (typeName _new_ld_section == "SCALAR") then {
    
      if(_i == 1) then {

        _count = _new_ld select _i; 
      
      };

      // some items have an additional magazine size
      if(_i == 2) then {

        _count = _count * (_new_ld select _i);
      
      };
    };

    // its an array, let us recurse
    if (typeName _new_ld_section == "ARRAY") then{    
      if (count _new_ld_section > 0) then {
      
        // evaluate sub-array
        private _sub_costs = [_old_ld_section, _new_ld_section] call KPLIB_fnc_calculateLoadoutCost;
        
        // add the sub-array costs into the current costs
        private _updated_cost = (_ld_costs select 0) + (_sub_costs select 0);
        _ld_costs set [0, _updated_cost];
        
        _updated_cost = (_ld_costs select 1) + (_sub_costs select 1);
        _ld_costs set [1, _updated_cost];

      };
    };
   
  };
};

// calculate the final costs and apply them to the costs array
_total_supplies_cost = _total_supplies_cost * _count;
_total_ammo_cost = _total_ammo_cost * _count;

private _old_costs = _ld_costs select 0;
_ld_costs set [0, _old_costs + _total_supplies_cost];

private _old_costs = _ld_costs select 1;
_ld_costs set [1, _old_costs + _total_ammo_cost];

// return the costs array
_ld_costs;