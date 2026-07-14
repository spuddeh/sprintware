# Sprintware

*Quickhack your own legs.*

A small Cyber Engine Tweaks mod for Cyberpunk 2077 that adds a configurable speed boost you can
toggle with a hot key. Bind a key, press it, run faster; press it again, run normally. That is the
entire mod.

**Nexus:** [Sprintware](https://www.nexusmods.com/cyberpunk2077/mods/29163)

Made on request for [TheRealJonCross](https://www.nexusmods.com/profile/TheRealJonCross).

## Features

- **Toggle keybind** and a **Speed Boost slider** (0 to +15 m/s, default +8), both set in Native
  Settings.
- **Live updates.** Change the slider while the boost is on and the new value applies immediately,
  without stacking modifiers.
- **Boost starts off on every load.** Deliberate — it stops you sprinting off a balcony you forgot
  you had enabled. There is no session persistence.
- **Optional debug overlay.** A small on-screen readout of your current `MaxSpeed`, velocity and
  Reflexes. Off by default.

## How it works

The boost applies an `Additive` `gamedataStatType.MaxSpeed` stat modifier to the player, via
`RPGManager.CreateStatModifier` and `StatsSystem:AddModifier`. It affects player movement only —
walk, run and sprint. It does **not** touch game time, vehicles, or NPCs.

### About the 15 m/s cap

**Player movement is capped at roughly 15 m/s by the engine, and that ceiling is enforced in more
than one layer** — raising the stat alone does not get past it. The slider is therefore expressed
as a real m/s value rather than a multiplier, so it reflects what the game will actually give you
instead of promising a number it will silently ignore. Lifting the cap would need a RED4ext native
hook, which is out of scope here.

## Requirements

- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780) (for the keybind)
- Native Settings (for the settings UI)

## Install

Unpack into your Cyberpunk 2077 game directory, so the mod lands in
`bin\x64\plugins\cyber_engine_tweaks\mods\sprintware\`.

## Status

Feature-complete at v1.0.0 and not under active development. It does what it says; there is no
roadmap. Issues are welcome, but a fix is not promised.

## Credits

- [psiberx](https://www.nexusmods.com/profile/psiberx/mods) for Codeware and the CET kit
  (`GameSession.lua` is used verbatim).
- [TheRealJonCross](https://www.nexusmods.com/profile/TheRealJonCross), who asked for it.

## License

Licensed under the [PolyForm Noncommercial License 1.0.0](LICENSE). You may use, modify, and
share this mod and its source for any noncommercial purpose, as long as you credit the
original creator. Commercial use, including paid mods or selling, is not permitted.

## Disclaimer

This mod was developed with the assistance of an LLM. All in-game testing and code
validation was performed by a human. No rogue AIs were permitted through the Blackwall.
