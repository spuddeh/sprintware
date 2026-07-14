-- ======================================================================================
-- Mod Name: Sprintware
-- Author: Spuddeh
-- Description: Codeware key listener that toggles the boost on the configured key.
-- Mod Version: 1.0.0
-- Credits: Pattern adapted from RAMpocalypse2077 input listener.
-- ======================================================================================

local Utils = require("modules/Utils")
local Core = require("modules/Core")
local Settings = require("modules/Settings")

local Input = {
    listeningKeybindWidget = nil,  -- set while NS keybind picker is active
    inputListener = nil,
}

local function onKey(event)
    local key = event:GetKey().value
    local action = event:GetAction().value

    -- Suppress while the player is rebinding the key in NS (gamepad path)
    if Input.listeningKeybindWidget and key:find("IK_Pad") and action == "IACT_Release" then
        Input.listeningKeybindWidget:OnKeyBindingEvent(KeyBindingEvent.new({ keyName = key }))
        Input.listeningKeybindWidget = nil
        return
    elseif Input.listeningKeybindWidget and action == "IACT_Release" then
        Input.listeningKeybindWidget = nil
        return
    end

    if action ~= "IACT_Release" then return end

    local boundKey = Settings:GetToggleKey()
    if not boundKey or boundKey == "IK_None" then return end
    if key ~= boundKey then return end

    Core:Toggle()
end

function Input:Setup()
    if not Codeware then
        Utils.Error("Codeware not found. Keybind disabled.")
        return
    end

    -- Track the NS keybind picker so we don't fire while binding.
    Observe("SettingsSelectorControllerKeyBinding", "ListenForInput", function(this)
        Input.listeningKeybindWidget = this
    end)

    self.inputListener = NewProxy({
        OnKeyInput = {
            args = { "handle:KeyInputEvent" },
            callback = onKey,
        }
    })

    local function register()
        local cbSystem = Game.GetCallbackSystem()
        if cbSystem then
            cbSystem:RegisterCallback("Input/Key",
                self.inputListener:Target(),
                self.inputListener:Function("OnKeyInput"))
            Utils.Debug("Input callback registered.")
        end
    end

    ObserveBefore("PlayerPuppet", "OnGameAttached", register)

    -- Hot reload: register immediately if already in-game.
    if Game.GetPlayer() then register() end

    ObserveBefore("PlayerPuppet", "OnDetach", function()
        local cbSystem = Game.GetCallbackSystem()
        if cbSystem and self.inputListener then
            cbSystem:UnregisterCallback("Input/Key", self.inputListener:Target())
            Utils.Debug("Input callback unregistered.")
        end
    end)
end

return Input
