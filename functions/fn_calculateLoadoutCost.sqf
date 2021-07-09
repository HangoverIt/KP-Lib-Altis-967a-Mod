

// params old loadout, new loadout
params ["_old_ld", "_new_ld"];

diag_log text "in calculate loadout cost";
private _ld_costs = [0, 0, 0];


// for each section in new loadout
for [{private _i = 0}, {_i < count _new_ld}, {_i = _i + 1}] do {
  private _old_ld_section = (_old_ld select _i);
  private _new_ld_section = (_new_ld select _i);

          // diag_log text "old section";
          // diag_log _old_ld_section;
          
          // diag_log text "new section";
          // diag_log _new_ld_section;

  if (_old_ld_section isNotEqualTo _new_ld_section) then {

    diag_log text "old section";
    diag_log _old_ld_section;
    
    diag_log text "new section";
    diag_log _new_ld_section;

    switch(typeName _new_ld_section) do
    {
      case "STRING": {
        if (_new_ld_section != "") then {          
          private _itemtype = _new_ld_section call BIS_fnc_itemType;
          diag_log format ["%1 is a type %2", _new_ld_section, _itemtype];
        };
      };
      case "SCALAR": {
        if (_new_ld_section != "") then {
          diag_log format ["count is %1", _new_ld_section];

        };
      };
      case "ARRAY": {
        if(count _new_ld_section > 0) then {
          diag_log text "array";
          
          if(count _old_ld_section > 0) then {
            [_old_ld_section, _new_ld_section] call KPLIB_fnc_calculateLoadoutCost;
          
          // everything is new
          } else {
            {
              private _itemtype = _x call BIS_fnc_itemType;
              diag_log format ["%1 is a type %2", _x, _itemtype];
            } forEach _new_ld_section;            
          };
        };
      };
      
      
    };
  };
};

          
          
          
  // private _index = 0;          
          
 // while {_index < (count _new_ld) && _index < (count _currentLoadout)} do
  // {
  
  
    // private _new_ld_section = (_new_ld select _index);
    // private _curr_ld_section = (_currentLoadout select _index);

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