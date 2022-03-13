/*
    File: fn_getNearestOpforSector.sqf
    Author: HangoverIt
    Date: 2022-03-12
    Last Update: 2022-03-12
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Gets the marker of the nearest opfor sector from given position inside given radius.

    Parameter(s):
        _radius - Radius in which to look for the nearest sector    [NUMBER, defaults to 1000]
        _pos    - Position to look from for the nearest sector      [POSITION, defaults to getPos player]

    Returns:
        Marker of nearest opfor sector [STRING]
*/

params [
    ["_radius", 1000, [0]],
    ["_pos", getPos player, [[]], [2, 3]]
];

private _sectors = (sectors_allSectors - blufor_sectors) select {((markerPos _x) distance2d _pos) < _radius};

if (_sectors isEqualTo []) exitWith {""};

_sectors = _sectors apply {[(markerPos _x) distance2d _pos, _x]};
_sectors sort true;

(_sectors select 0) select 1
