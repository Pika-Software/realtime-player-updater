local cvars_AddChangeCallback = cvars.AddChangeCallback
local net_SendToServer = net.SendToServer
local net_WriteUInt = net.WriteUInt
local timer_Create = timer.Create
local timer_Remove = timer.Remove
local net_Start = net.Start

local addonName = "Realtime Player Updater"

local function getPlayerUpdateCallback( index )
    return function( cvarName )
        local timerName = addonName .. " / CVar - " .. cvarName
        timer_Create( timerName, 0.01, 1, function()
            timer_Remove( timerName )
            net_Start( addonName )
                net_WriteUInt( index, 3 )
            net_SendToServer()
        end )
    end
end

local index = 0
local function registerCVar( cvarName )
    index = index + 1
    cvars_AddChangeCallback( cvarName, getPlayerUpdateCallback( index ), addonName )
end

-- Player skin
registerCVar( "cl_playerskin" )

-- Player weapon color
registerCVar( "cl_weaponcolor" )

-- Player model color
registerCVar( "cl_playercolor" )

-- Player model
registerCVar( "cl_playermodel" )

-- Player model bodygroups
registerCVar( "cl_playerbodygroups" )