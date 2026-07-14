-- ======================================================================================
-- Mod Name: Sprintware
-- Author: Spuddeh
-- Description: Toggleable player speed boost with Native Settings UI.
-- Mod Version: 1.0.0
-- Credits: --
-- ======================================================================================

local Utils = { debug = false }

local LOG_PREFIX = IconGlyphs.RunFast .. " [Sprintware] "

function Utils.Log(msg)
    print(LOG_PREFIX .. "[INFO] " .. tostring(msg))
end

function Utils.Warn(msg)
    print(LOG_PREFIX .. "[WARN] " .. tostring(msg))
end

function Utils.Error(msg)
    local line = LOG_PREFIX .. "[ERROR] " .. tostring(msg)
    print(line)
    if spdlog and spdlog.error then spdlog.error(line) end
end

function Utils.Debug(msg)
    if Utils.debug then
        print(LOG_PREFIX .. "[DEBUG] " .. tostring(msg))
    end
end

-- Blue/cyan top-center banner. Sent on the WarningMessage blackboard channel
-- with type=Neutral, which routes through warningMessage.swift's UpdateNeutralType
-- and switches the banner widget to the "Neutral" state (cyan/blue).
function Utils.NotifyInfo(text, duration)
    if not text or text == "" then return end
    local message = SimpleScreenMessage.new()
    message.message = text
    message.duration = duration or 2.5
    message.isShown = true
    message.type = gameSimpleMessageType.Neutral
    local defs = Game.GetAllBlackboardDefs()
    Game.GetBlackboardSystem():Get(defs.UI_Notifications):SetVariant(
        defs.UI_Notifications.WarningMessage,
        ToVariant(message),
        true
    )
end

function Utils.PlaySound(eventName)
    local player = Game.GetPlayer()
    if not player then return end
    local audio = Game.GetAudioSystem()
    if not audio then return end
    local ok, err = pcall(function()
        audio:Play(eventName, player:GetEntityID(), "V")
    end)
    if not ok then
        Utils.Error("PlaySound failed: " .. tostring(err))
    end
end

return Utils
