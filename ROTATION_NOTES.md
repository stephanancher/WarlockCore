# Rotation Notes

This file exists to prevent future "fixes" from breaking the working rotation by making incorrect assumptions about how `WarlockCore.lua` actually works.

## Why a previous fix failed

The rotation logic in `WarlockCore.lua` is not a simple "cast the next configured spell" system.

- `GetNextSpell()` returns `Opener` whenever the player is not in combat.
- `Rotation1` to `Rotation6` are only considered after combat starts.
- Several spells are handled as debuffs with extra state tracking, not just direct spell casts.
- The addon uses optimistic DOT tracking through `myDots` immediately after `CastSpellByName()`.
- Failed overwrite attempts are also tracked through `UI_ERROR_MESSAGE`.
- `FastAttack = false` intentionally causes a target-only first press before attacking.

## Important code behavior

Relevant areas in `WarlockCore.lua`:

- `HasDebuff()` checks both live debuffs and local tracking state.
- `GetNextSpell()` uses combat state and special Drain Soul threshold logic.
- `WarlockCore_Rotate()` performs healthstone, life tap, buffing, targeting, pet control, and only then spell selection.

## Rules before changing rotation logic again

- Read `HasDebuff()`, `GetNextSpell()`, and `WarlockCore_Rotate()` together before editing anything.
- Do not assume opener and rotation slots are processed the same way.
- Do not assume a cast succeeded just because `CastSpellByName()` was called.
- Do not remove or bypass `myDots` behavior without replacing the overwrite and retry logic.
- Preserve Malediction detection: talented characters may maintain Curse of Agony alongside Curse of the Elements, while untalented characters must keep first-curse-only behavior to avoid replacement loops.
- Do not treat the first press target-acquire behavior as a bug when `FastAttack` is off.
- Compare any proposed change against the current in-game behavior before calling it a fix.

## Summary

The earlier mistake was treating the addon like a simple priority list. The actual implementation is stateful and depends on combat state, target state, debuff texture matching, and local retry memory.
