-- ======================================================================================
-- Mod Name: Sprintware
-- Author: Spuddeh
-- Description: Debug ImGui readout: live MaxSpeed stat, player velocity, Reflexes.
--              Used to characterise the engine's MaxSpeed clamp (15 m/s) and find
--              the practical speed-boost ceiling at the user's Reflexes level.
-- Mod Version: 1.0.0
-- Credits: --
-- ======================================================================================

local Core = require("modules/Core")
local Settings = require("modules/Settings")

local Probe = {
    _peakVelocity = 0,
}

local WINDOW_FLAGS = ImGuiWindowFlags.AlwaysAutoResize
    + ImGuiWindowFlags.NoNav
    + ImGuiWindowFlags.NoFocusOnAppearing

function Probe:Reset()
    self._peakVelocity = 0
end

function Probe:Draw()
    if not Settings.config.debug then return end
    if not Core.inGame then return end

    local player = Game.GetPlayer()
    if not player then return end
    local statsSystem = Game.GetStatsSystem()
    if not statsSystem then return end

    local playerID = player:GetEntityID()
    ---@diagnostic disable: param-type-mismatch
    local maxSpeed = statsSystem:GetStatValue(playerID, gamedataStatType.MaxSpeed)
    local reflexes = statsSystem:GetStatValue(playerID, gamedataStatType.Reflexes)
    ---@diagnostic enable: param-type-mismatch

    local v = player:GetVelocity()
    local hSpeed = math.sqrt(v.x * v.x + v.y * v.y)
    local vSpeed = math.abs(v.z)
    if hSpeed > self._peakVelocity then
        self._peakVelocity = hSpeed
    end

    ImGui.SetNextWindowPos(20, 200, ImGuiCond.FirstUseEver)
    ---@diagnostic disable-next-line: param-type-mismatch
    if ImGui.Begin("Sprintware Probe", WINDOW_FLAGS) then
        ImGui.Text(string.format("Reflexes (attr)   : %.1f", reflexes))
        ImGui.Text(string.format("MaxSpeed (stat)   : %.2f m/s   [clamp 0..15]", maxSpeed))
        ImGui.Separator()
        ImGui.Text(string.format("Velocity horiz    : %.2f m/s", hSpeed))
        ImGui.Text(string.format("Velocity vert     : %.2f m/s", vSpeed))
        ImGui.Text(string.format("Peak horiz (sess) : %.2f m/s", self._peakVelocity))
        ImGui.Separator()
        ImGui.Text(string.format("Speed Boost       : +%.1f m/s   [active=%s]",
            Core.speedBoost, tostring(Core.isActive)))
        if ImGui.Button("Reset peak") then
            self:Reset()
        end
    end
    ImGui.End()
end

return Probe
