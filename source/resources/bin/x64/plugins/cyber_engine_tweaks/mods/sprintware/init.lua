-- ======================================================================================
-- Mod Name: Sprintware
-- Author: Spuddeh
-- Description: Toggle an additive player MaxSpeed bonus with a configurable hot key.
-- Mod Version: 1.0.0
-- Credits: --
-- ======================================================================================

local Utils, Core, Settings, Input, GameSession, Probe

registerForEvent("onInit", function()
    Utils       = require("modules/Utils")
    Core        = require("modules/Core")
    Settings    = require("modules/Settings")
    Input       = require("modules/Input")
    GameSession = require("modules/GameSession")
    Probe       = require("modules/Probe")

    Settings:LoadConfig()
    Settings:Build()
    Input:Setup()

    GameSession.OnStart(function()
        Core.inGame = true
        Core.isActive = false  -- never persist boost across sessions
    end)

    GameSession.OnEnd(function()
        Core:Reset()
        Core.inGame = false
    end)

    -- Menu close: fire any queued slider-change notification while the player
    -- can actually see it.
    GameSession.OnResume(function()
        if Settings.pendingNotify then
            Settings.pendingNotify = false
            Core:NotifyCurrentBoost()
        end
    end)

    -- Hot reload: if we're already in-game when the mod loads, sync state.
    if GameSession.IsLoaded() then
        Core.inGame = true
    end

    Utils.Log("Loaded.")
end)

registerForEvent("onDraw", function()
    if Probe then Probe:Draw() end
end)

registerForEvent("onShutdown", function()
    if Core then Core:Reset() end
end)
