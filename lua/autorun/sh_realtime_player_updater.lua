-- By PrikolMen#3372 & Retro#1593

local COLOR = 0
local PLAYERMODEL = 1
local SKIN = 2
local BODYGROUPS = 3
local WEAPON_COLOR = 4

local NET_NAME = "UpdatePlayerInfo"

if (SERVER) then

    local actions = {
        [ SKIN ] = function( ply )
            ply:SetSkin( ply:GetInfoNum( "cl_playerskin", 0 ) )
        end
    }

    do

        local Vector = Vector
        local zero_color = Vector( 0.001, 0.001, 0.001 )

        actions[ WEAPON_COLOR ] = function( ply )
            local col = Vector( ply:GetInfo( "cl_weaponcolor" ) )
            ply:SetWeaponColor( (col:Length() < 0.001) and zero_color or col )
        end

        actions[ COLOR ] = function( ply )
            ply:SetPlayerColor( Vector( ply:GetInfo( "cl_playercolor" ) ) )
        end

    end

    do

        local player_manager_TranslatePlayerModel = player_manager.TranslatePlayerModel
        local util_PrecacheModel = util.PrecacheModel

        actions[ PLAYERMODEL ] = function( ply )
            local modelname = player_manager_TranslatePlayerModel( ply:GetInfo( "cl_playermodel" ) )
            util_PrecacheModel( modelname )
            ply:SetModel( modelname )
            ply:SetupHands()
        end

    end

    do

        local string_Explode = string.Explode
        local tonumber = tonumber

        actions[ BODYGROUPS ] = function( ply )
            local groups = ply:GetInfo( "cl_playerbodygroups" )
            if (groups == nil) then groups = "" end
            groups = string_Explode( " ", groups )

            for k = 0, ply:GetNumBodyGroups() - 1 do
                ply:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
            end
        end

    end

    util.AddNetworkString( NET_NAME )

    local net_ReadUInt = net.ReadUInt

    net.Receive(NET_NAME, function( len, ply )
        if not ply:Alive() then return end

        local action = actions[ net_ReadUInt( 3 ) ]
        if (action == nil) then return end

        timer.Create(NET_NAME .. "_timer", 0.025, 1, function()
            action( ply )
        end)

    end)

end

if (CLIENT) then

    local net_SendToServer = net.SendToServer
    local net_WriteUInt = net.WriteUInt
    local timer_Create = timer.Create
    local net_Start = net.Start

    local function getPlayerUpdateCallback( dataType )
        return function( cvarName, oldValue, newValue )
            timer_Create(cvarName .. "_update", 0.025, 1, function()
                net_Start( NET_NAME )
                    net_WriteUInt( dataType, 3 )
                net_SendToServer()
            end)
        end
    end

    local function registerPlayerUpdateCvar( cvarName, dataType )
        cvars.AddChangeCallback( cvarName, getPlayerUpdateCallback( dataType ), NET_NAME )
    end

    -- Player Color
    registerPlayerUpdateCvar( "cl_playercolor", COLOR )

    -- Player Model
    registerPlayerUpdateCvar( "cl_playermodel", PLAYERMODEL )

    -- Player Skin
    registerPlayerUpdateCvar( "cl_playerskin", SKIN )

    -- Player Bodygroups
    registerPlayerUpdateCvar( "cl_playerbodygroups", BODYGROUPS )

    -- Player Weapon Color
    registerPlayerUpdateCvar( "cl_weaponcolor", WEAPON_COLOR )

end