# Sprintware — Changelog

## v1.0.0 — Initial implementation

- Native Settings UI with **Speed Boost** slider: additive bonus from 0.0 to +15.0 m/s, step 0.5, default +8.0.
- Configurable keybind (Codeware) toggles the boost on/off; defaults to unbound. Boost ignored when not in-game.
- Boost applies a `gamedataStatType.MaxSpeed` `Additive` modifier via `RPGManager.CreateStatModifier` + `StatsSystem:AddModifier`.
- Live slider edits while the boost is active swap the modifier without stacking, and queue a notification for when the menu closes.
- Boost always starts off when the game loads (no session persistence).
- Netrunner-themed top-center notification banner + quickhack-access sound on enable / disable / reconfigure.
- "About the Cap" subcategory documents the 15 m/s engine cap.
- Debug logging toggle (off by default) — also enables an in-game Probe overlay (live MaxSpeed stat, velocity, Reflexes).
