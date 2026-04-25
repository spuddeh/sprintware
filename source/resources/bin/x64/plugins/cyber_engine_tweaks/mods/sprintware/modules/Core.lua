-- ======================================================================================
-- Mod Name: Sprintware
-- Author: Spuddeh
-- Description: Apply / remove an Additive MaxSpeed bonus on the player.
-- Mod Version: 1.0.0
-- Credits: --
-- ======================================================================================

local Utils = require("modules/Utils")

local Core = {
    speedBoost = 8.0,    -- additive m/s, runtime value driven by Settings slider
    isActive = false,    -- runtime toggle (never persisted)
    inGame = false,      -- session gate (set by GameSession OnStart/OnEnd)
    _modifier = nil,     -- handle to the live stat modifier (for removal)
}

local function getPlayerAndSystem()
    local player = Game.GetPlayer()
    if not player then return nil, nil, nil end
    local statsSystem = Game.GetStatsSystem()
    if not statsSystem then return nil, nil, nil end
    return player, statsSystem, player:GetEntityID()
end

local function removeModifier()
    if not Core._modifier then return end
    local _, statsSystem, playerID = getPlayerAndSystem()
    if statsSystem and playerID then
        statsSystem:RemoveModifier(playerID, Core._modifier)
    end
    Core._modifier = nil
end

local function applyModifier()
    local _, statsSystem, playerID = getPlayerAndSystem()
    if not statsSystem or not playerID then
        Utils.Warn("Cannot apply boost: player or stats system not ready.")
        return false
    end
    local modifier = RPGManager.CreateStatModifier(
        gamedataStatType.MaxSpeed,
        gameStatModifierType.Additive,
        Core.speedBoost
    )
    statsSystem:AddModifier(playerID, modifier)
    Core._modifier = modifier
    return true
end

function Core:Enable()
    if not self.inGame then return end
    if self.isActive then
        removeModifier()
    end
    if applyModifier() then
        self.isActive = true
        Utils.Log(string.format("Boost ON (+%.1f m/s)", self.speedBoost))
        Utils.NotifyInfo(string.format("> SPRINTWARE.exe // UPLOADED [+%.1f m/s]", self.speedBoost), 2.5)
        Utils.PlaySound("ui_hacking_access_granted")
    end
end

function Core:Disable()
    if not self.inGame then return end
    removeModifier()
    self.isActive = false
    Utils.Log("Boost OFF")
    Utils.NotifyInfo("> SPRINTWARE.exe // TERMINATED", 2.5)
    Utils.PlaySound("ui_hacking_access_denied")
end

function Core:Toggle()
    if not self.inGame then return end
    if self.isActive then self:Disable() else self:Enable() end
end

function Core:NotifyCurrentBoost()
    if not self.inGame or not self.isActive then return end
    Utils.NotifyInfo(string.format("> SPRINTWARE.exe // RECONFIGURED [+%.1f m/s]", self.speedBoost), 2.5)
    Utils.PlaySound("ui_hacking_access_granted")
end

function Core:SetBoost(value)
    self.speedBoost = value
    if self.isActive then
        removeModifier()
        applyModifier()
        Utils.Debug(string.format("Live boost updated to +%.1f m/s", value))
    end
end

-- Called when the game session ends so the modifier handle isn't left dangling.
function Core:Reset()
    removeModifier()
    self.isActive = false
end

return Core
