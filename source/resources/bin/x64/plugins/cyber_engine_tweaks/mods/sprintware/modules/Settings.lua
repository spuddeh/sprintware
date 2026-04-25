-- ======================================================================================
-- Mod Name: Sprintware
-- Author: Spuddeh
-- Description: Native Settings UI + config persistence (speed boost and keybind only).
-- Mod Version: 1.0.0
-- Credits: --
-- ======================================================================================

local Utils = require("modules/Utils")
local Core = require("modules/Core")

local Settings = {
    config = {
        speedBoost = 8.0,
        toggleKey = "IK_None",
        debug = false,
    },
    nativeSettings = nil,
    sliderOption = nil,
    keybindOption = nil,
    pendingNotify = false,  -- set when slider changes mid-menu, fired on menu close
}

local CONFIG_PATH = "config.json"
local PATH = "/sprintware"

local function clampBoost(v)
    if v < 0.0 then return 0.0 end
    if v > 15.0 then return 15.0 end
    return v
end

function Settings:LoadConfig()
    local f = io.open(CONFIG_PATH, "r")
    if not f then return end
    local raw = f:read("*a")
    f:close()
    if not raw or raw == "" then return end
    local ok, data = pcall(json.decode, raw)
    if not ok or type(data) ~= "table" then
        Utils.Warn("Failed to parse config.json — using defaults.")
        return
    end
    self.config.speedBoost = clampBoost(tonumber(data.speedBoost) or 8.0)
    self.config.toggleKey  = type(data.toggleKey) == "string" and data.toggleKey or "IK_None"
    self.config.debug      = data.debug == true
    Utils.debug = self.config.debug
end

function Settings:SaveConfig()
    local f = io.open(CONFIG_PATH, "w")
    if not f then
        Utils.Error("Failed to open config.json for writing.")
        return
    end
    f:write(json.encode(self.config))
    f:close()
end

function Settings:Build()
    self.nativeSettings = GetMod("nativeSettings")
    if not self.nativeSettings then
        Utils.Error("Native Settings not found. UI disabled.")
        return
    end

    self.nativeSettings.addTab(PATH, "Sprintware")

    self.nativeSettings.addSubcategory(PATH .. "/main", "Boost")

    self.sliderOption = self.nativeSettings.addRangeFloat(
        PATH .. "/main",
        "Speed Boost",
        "Extra running speed while the boost is on (m/s). The game caps your total "
            .. "speed at 15 m/s. That cap already includes your base sprint speed and "
            .. "Reflexes bonus, so you may hit it before reaching the maximum slider value.",
        0.0, 15.0, 0.5,
        "+%.1f m/s",
        self.config.speedBoost, 8.0,
        function(value)
            self.config.speedBoost = clampBoost(value)
            Core:SetBoost(self.config.speedBoost)
            self:SaveConfig()
            -- Queue a "reconfigured" notification for when the menu closes
            -- (only meaningful if boost is currently active).
            if Core.isActive then
                self.pendingNotify = true
            end
        end
    )

    self.keybindOption = self.nativeSettings.addKeyBinding(
        PATH .. "/main",
        "Toggle Boost",
        "Press to toggle the speed boost on or off. Boost always starts off when the game loads.",
        self.config.toggleKey,
        "IK_None",
        false,
        function(key)
            self.config.toggleKey = key
            self:SaveConfig()
            Utils.Log("Toggle key set to " .. tostring(key))
        end
    )

    self.nativeSettings.addSubcategory(PATH .. "/info", "About the Cap")
    self.nativeSettings.addSwitch(
        PATH .. "/info",
        "Engine Cap: 15 m/s",
        "Cyberpunk 2077 hard-clamps the player's movement speed at 15 m/s (roughly "
            .. "54 km/h). The cap is enforced at multiple layers in the engine, including "
            .. "native physics code that no script-side mod can reach. The slider applies "
            .. "an additive bonus on top of your current sprint speed; once the total "
            .. "reaches 15 m/s further boost has no effect. This switch is informational "
            .. "only and does nothing.",
        false, false,
        function() end
    )

    self.nativeSettings.addSubcategory(PATH .. "/debug", "Debug")
    self.nativeSettings.addSwitch(
        PATH .. "/debug",
        "Debug Logging",
        "Print extra log lines to cyber_engine_tweaks.log and show the live "
            .. "Sprintware Probe overlay (MaxSpeed stat, player velocity, Reflexes).",
        self.config.debug, false,
        function(state)
            self.config.debug = state
            Utils.debug = state
            self:SaveConfig()
        end
    )

    Core.speedBoost = self.config.speedBoost
    Utils.Log(string.format("Settings loaded (boost=+%.1f m/s, key=%s)",
        self.config.speedBoost, self.config.toggleKey))
end

function Settings:GetToggleKey()
    return self.config.toggleKey
end

return Settings
