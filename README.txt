WarlockCore v1.8.0
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
- Smart Fear: Tracks immune mobs and automatically skips Fear on them.
- Smart Drain: Intelligent Drain Soul management.
- Immune Management: Dynamic management of immune mobs via the "Info" tab.

RESOURCE AUTOMATION:
- Auto Stone: Consumes Healthstones at a custom Health % threshold.
- Auto Tap: Safe mana-management logic via Life Tap.

PET INTELLIGENCE:
- Master Assist: Master switch for pet automation.
- Smart Targets: Auto-targets nearest enemy on rotation press.
- Fast Attack: Instant charge mode for aggressive pulls.

PREMIUM INTERFACE:
- Unified 5-Tab UI: Rot, Pet, Buff, Options, and Info tabs.
- Interactive Tooltips: Hover descriptions in the Options tab.
- Macro Sync: Real-time icon updating for Rot and Fear macros.

================================================================================
DETAILED OPTIONS REFERENCE (OPTIONS TAB)
================================================================================
- Smart Fear     : Skips Fear on immune targets (Undead/Mech) to save mana.
- Smart Drain    : Manages Drain Soul rank conflicts for smooth farming.
- Auto Stone     : Automatically uses Healthstone at the chosen HP %.
- Auto Tap       : Safe Life Tap logic (checks both mana and health).
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
Version: 1.8.0
Compatibility: Turtle WoW (1.12.1)
