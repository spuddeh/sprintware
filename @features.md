# Sprintware — Features

## Implemented

- Toggleable player speed boost via configurable hot key.
- Additive **Speed Boost** slider (+0 to +15 m/s, step 0.5) in Native Settings — directly maps to the `MaxSpeed` stat bonus.
- Affects player movement only (walk/run/sprint via `MaxSpeed`); does not alter game time, vehicles, or NPCs.
- Live boost updates while active; slider changes mid-menu queue a notification fired on menu close.
- Boost auto-disables on every game load (intentional).
- Engine cap (15 m/s of total player movement) documented in the UI's "About the Cap" subcategory.
- Netrunner-themed HUD notification on toggle (`> SPRINTWARE.exe // UPLOADED [+Nm/s]` / `// TERMINATED` / `// RECONFIGURED [+Nm/s]`) plus quickhack-access sound cue.
- Debug logging toggle, which also enables an in-game ImGui Probe overlay (MaxSpeed stat, player velocity, Reflexes).

## Not Implemented (out of scope)

- "Hold to boost" mode (current keybind is a toggle).
- Vehicle speed boost.
- Per-state multipliers (separate walk/sprint/swim values).
- Stamina or animation-speed compensation.
- Bypassing the 15 m/s engine cap (would require a RED4ext native hook).
