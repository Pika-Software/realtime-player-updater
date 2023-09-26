--[[

    Title: Realtime Player Updater
    Authors: Retro & PrikolMen:-b

    Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2807143051
    GitHub: https://github.com/Pika-Software/realtime-player-updater

--]]

local addonName = 'Realtime Player Updater'
util.AddNetworkString( addonName )
local actions = {}

local function addAction( func )
    actions[ #actions + 1 ] = func
end

-- Player skin
addAction( function( ply )
    ply:SetSkin( ply:GetInfoNum( 'cl_playerskin', 0 ) )
end )

do

    local Vector = Vector
    local zero_color = Vector( 0.001, 0.001, 0.001 )

    -- Player weapon color
    addAction( function( ply )
        local col = Vector( ply:GetInfo( 'cl_weaponcolor' ) )
        ply:SetWeaponColor( ( col:Length() < 0.001 ) and zero_color or col )
    end )

    -- Player model color
    addAction( function( ply )
        ply:SetPlayerColor( Vector( ply:GetInfo( 'cl_playercolor' ) ) )
    end )

end

-- Player model
do

    local player_manager_TranslatePlayerModel = player_manager.TranslatePlayerModel
    local Model = Model

    addAction( function( ply )
        ply:SetModel( Model( player_manager_TranslatePlayerModel( ply:GetInfo( 'cl_playermodel' ) ) ) )
        ply:SetupHands()
    end )

end

-- Player model bodygroups
do

    local string_Explode = string.Explode
    local tonumber = tonumber

    addAction( function( ply )
        local groups = ply:GetInfo( 'cl_playerbodygroups' )
        if (groups == nil) then groups = '' end
        groups = string_Explode( ' ', groups )

        for group = 0, ply:GetNumBodyGroups() - 1 do
            ply:SetBodygroup( group, tonumber( groups[ group + 1 ] ) or 0 )
        end
    end )

end

local getIndex = FindMetaTable( "Entity" ).EntIndex
local isAlive = FindMetaTable( "Player" ).Alive
local timer_Create = timer.Create
local timer_Remove = timer.Remove
local net_ReadUInt = net.ReadUInt

net.Receive( addonName, function( _, ply )
    if not isAlive( ply ) then return end

    local func = actions[ net_ReadUInt( 3 ) ]
    if not func then return end

    local timerName = addonName .. " / Player - " .. getIndex( ply )
    timer_Create( timerName, 0.01, 1, function()
        timer_Remove( timerName )
        func( ply )
    end )
end )
