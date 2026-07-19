WarlockCore v1.10.1
Advanced Combat Automation & Interface for Turtle WoW (Vanilla 1.12.1)

================================================================================
DESCRIPTION
================================================================================
WarlockCore is a high-performance combat suite designed to streamline Warlock 
gameplay with intelligent automation, resource management, and a premium 5-tab 
configuration interface.

================================================================================
KEY FEATURES
================================================================================

SMART COMBAT LOGIC:
- Smart Fear: Tracks immune mobs and automatically skips Fear on them. Players and player-controlled pets/guardians are excluded.
- Nightfall Bolt: Shadow Trance makes the next Rot or Fear press cast Shadow Bolt
  before every other action.
- Smart Drain: Forces Drain Soul at its HP threshold without disabling a selected rotation slot.
- Six Rotation Slots: Configure up to six combat abilities in priority order.
- Wait Icon: Shows a pocket watch on the Rotation macro when all selected DoTs are active and no filler or drain is configured.
- Immune Management: Dynamic management of immune mobs via the "Info" tab.
- PvP Mode: With a living enemy targeted, skips openers, buffs, and stone maintenance and immediately uses combat rotation logic.

RESOURCE AUTOMATION:
- Auto Stone: Consumes a Healthstone at a custom Health % threshold in combat.
- Healthstone: Optional out-of-combat maintenance that keeps the highest available rank in your bags without consuming it.
- Five Buff Slots: Choose and prioritize up to five buffs; the first eligible missing buff is cast in slot order.
- Soulstone: Out of combat, uses a Soulstone when its buff is missing and creates a replacement when possible. Optional Group Mode prioritizes visible Priest, Paladin, then Shaman and reports the chosen recipient.
- Felstone: Out of combat, uses a Felstone when its buff is missing and creates a replacement when possible.
- Auto Tap: Safe Life Tap logic on Rotation and Fear macro presses.

PET INTELLIGENCE:
- Master Assist: Master switch for pet automation.
- Smart Targets: Auto-targets nearest enemy on rotation press.
- Fast Attack: Instant charge mode for aggressive pulls.

PREMIUM INTERFACE:
- Unified 5-Tab UI: Rot, Pet, Buff, Options, and Info tabs.
- Interactive Tooltips: Hover descriptions in the Options tab.
- Macro Sync: Character-specific Rot, Fear, and pet macros with real-time icons.
- Personal Drain Macros: Spam-safe Drain Life and Drain Soul character macros.

================================================================================
DETAILED OPTIONS REFERENCE (OPTIONS TAB)
================================================================================
- Smart Fear     : Skips Fear on immune targets (Undead/Mech) to save mana. Players and player-controlled pets/guardians are excluded.
- Nightfall Bolt : When ON, Shadow Trance overrides the next Rot or Fear press
                   with Shadow Bolt. OFF keeps their normal behavior.
- Smart Drain    : Forces Drain Soul at its threshold; a selected rotation slot remains active at every target HP.
- Drain Priority : Selected DoTs are maintained first. Malediction builds maintain both Curse of Agony and Curse of the Elements; otherwise only the first configured curse is used. Active Curse of Exhaustion suppresses automatic Curse of the Elements refreshes. Selected drains then become the fallback.
- Channel Recovery: Completed or interrupted drains immediately become eligible again without waiting on a stale debuff timer.
- Reliable DoTs  : Normalizes legacy aura textures so curses and DoTs correctly advance the rotation to drains.
- Wait Icon      : The Rotation macro shows a pocket watch when no spell needs casting. It restores the next spell icon when a DoT needs refreshing.
- Drain Soul     : Controls automatic opener and threshold behavior; an explicit rotation slot always remains enabled.
- PvP Mode       : When enabled, a living enemy target creates a combat state that skips every buff and maintenance action and uses your rotation.
- Felstone       : Uses and recreates your Felstone outside combat.
- Auto Stone     : Uses a Healthstone at the chosen HP % on Rotation or personal drain macro presses, even while channeling.
- Healthstone    : When enabled, creates the highest available rank outside combat when missing and never consumes it.
- Buff Slots 1-5 : Order Demon Skin, Demon Armor, Unending Breath, Detect Lesser Invisibility, and Shadow Ward. Targeted buffs temporarily target you, cast, then restore your previous target.
- Shadow Ward     : When enabled under Buffs, Rotation casts it only while a Priest or Warlock shadow-damage DoT is active on you and the ward is missing.
- Auto Tap       : Safe Life Tap logic on Rotation and Fear presses (checks mana and health).
- Pet Assist     : Master Switch. When OFF, addon will NOT touch pet bar.
- Smart Targets  : Auto-targets nearest enemy if you have none selected.
- Fast Attack    : If ON, pet charges instantly; if OFF, waits for spell hit.
- Debug Mode     : Performance logging to chat (very spammy).
- Drain Soul Thresh: Target HP % to start finishing the mob with Drain Soul.

================================================================================
INSTALLATION
================================================================================
1. Place the 'WarlockCore' folder into your 'Interface\AddOns\' directory.
2. Restart or Reload WoW.

================================================================================
COMMANDS
================================================================================
- /wrc            : Toggle the configuration menu.
- /wrc reset      : Clear the immune mob list.
- /wrc clear [Name]: Remove a specific mob from the list.

================================================================================
DEPENDENCIES
================================================================================
NONE. Standalone and lightweight.

================================================================================
CONTACT & VERSION
================================================================================
Author: Stephan
Version: 1.10.1
Compatibility: Turtle WoW (1.12.1)
