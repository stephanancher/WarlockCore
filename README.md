# WarlockCore v1.10.2
Advanced Combat Automation & Interface for Turtle WoW (Vanilla 1.12.1).

WarlockCore is a high-performance combat suite designed to streamline Warlock gameplay with intelligent automation, resource management, and a premium 5-tab configuration interface.

## 🚀 Key Features

### 🧠 Smart Combat Logic
- **Smart Fear**: Tracks mobs that are immune to Fear (e.g., undead, mechanicals) in real-time and automatically switches to Shadow Bolt when those mobs are targeted. Players and player-controlled pets/guardians are excluded.
- **Nightfall Bolt**: Detects the Shadow Trance buff from Nightfall and makes your next **Rot** or **Fear** press cast Shadow Bolt before every other action.
- **Smart Drain**: Forces Drain Soul at the chosen target-health threshold without disabling a selected rotation slot above the threshold.
- **Six Rotation Slots**: Configure up to six combat abilities in priority order.
- **Wait Icon**: Shows a pocket watch on the Rotation macro when all selected DoTs are active and no filler or drain is configured.
- **Immune Management**: Dynamic management of immune mobs via the "Info" tab.
- **PvP Mode**: With a living enemy targeted, skips openers, buffs, and stone maintenance and immediately uses combat rotation logic.

### 🩸 Resource Automation
- **Auto Stone**: Consumes a Healthstone at a user-defined Health % threshold in combat.
- **Healthstone**: Optional out-of-combat maintenance that keeps the highest available Healthstone rank in your bags without consuming it.
- **Five Buff Slots**: Choose and prioritize up to five buffs. The rotation casts the first eligible missing buff in slot order.
- **Soulstone**: Out of combat, uses a Soulstone when its buff is missing and creates a replacement when possible. Optional Group Mode prioritizes visible Priest, Paladin, then Shaman and reports the chosen recipient.
- **Felstone**: Out of combat, uses a Felstone when its buff is missing and creates a replacement when possible.
- **Auto Tap**: Intelligently uses Life Tap on Rotation and Fear macro presses when mana is low, respecting a safety health threshold.

### 🐾 Pet Intelligence
- **Master Assist**: Toggleable pet automation that ensures your pet engages when you do.
- **Smart Targets**: Automatically targets the nearest enemy when triggering your rotation if you don't have a target selected.
- **Fast Attack**: High-priority charge command that sends your pet to the mob instantly on rotation start.

### 🎨 Premium Interface
- **Unified 5-Tab UI**: Clean organization across **Rotation, Pet, Buff, Options, and Info** tabs.
- **Interactive Tooltips**: Hover over any setting in the "Options" tab to see a detailed description of its function.
- **Macro Sync**: Character-specific drag-and-drop macros for Rot, Fear, and pet summoning that automatically update their icons in real-time.
- **Personal Drain Macros**: Drag separate Drain Life and Drain Soul macros that ignore repeated presses for the entire active channel.

## ⚙️ Configuration Options
Settings are grouped by purpose across the **Pet**, **Buff**, and **Options** tabs:

- **Smart Fear**: Remembers immune mobs (Undead/Mechanical/Bosses) and automatically skips Fear on them to save mana. Players and player-controlled pets/guardians are excluded.
- **Nightfall Bolt**: When ON, Shadow Trance overrides both Rot and Fear with Shadow Bolt on your next keypress. Turn it OFF to keep the normal rotation and Fear behavior during Nightfall procs.
- **Smart Drain**: Overrides the normal slot order with Drain Soul at the chosen target-health threshold. When Drain Soul is selected in a rotation slot, that slot remains active at every target-health level. Nightfall Shadow Bolt keeps first priority.
- **Drain Priority**: Selected curses and other damage-over-time spells are maintained first. With Malediction, Curse of Agony and Curse of the Elements are maintained independently; without it, only the first configured curse is used. Active Curse of Exhaustion suppresses automatic Curse of the Elements refreshes. A selected Drain Soul or Drain Life becomes the fallback after those effects are active, regardless of its slot number.
- **Channel Recovery**: Drain eligibility follows the live channel state, so an interrupted or completed drain cannot leave the rotation waiting on a stale debuff timer.
- **Reliable DoT Detection**: Normalizes legacy aura texture paths so visible curses and DoTs correctly allow the rotation to advance to its drain fallback.
- **Wait Icon**: The Rotation macro shows a pocket watch when no spell needs casting, then restores the next spell icon when a DoT needs refreshing.
- **Drain Soul**: Controls automatic opener and threshold behavior. Selecting Drain Soul in a rotation slot always enables that explicit slot, even when this option is OFF.
- **PvP Mode**: When enabled, targeting a living enemy creates a combat state. The addon skips every buff and out-of-combat maintenance action and uses the combat rotation immediately.
- **Felstone**: Uses an existing Felstone when its buff is missing, then creates a replacement when possible.
- **Auto Stone**: Uses a Healthstone when your Health reaches the chosen threshold on Rotation, Drain Life, or Drain Soul macro presses—even during an active drain channel.
- **Healthstone**: When enabled, creates the highest available Healthstone rank outside combat when none is in your bags. It never consumes the newly created stone.
- **Buff Slots 1-5**: Order Demon Skin, Demon Armor, Unending Breath, Detect Lesser Invisibility, and Shadow Ward however you prefer. Unending Breath and Detect Lesser Invisibility temporarily target you for the cast, then restore your previous target.
- **Reactive Shadow Ward**: The Shadow Ward toggle under Buffs casts the ward during Rotation presses only when a Priest or Warlock shadow-damage DoT is active on you and the ward is missing.
- **Auto Tap**: Uses Life Tap on Rotation or Fear macro presses if your mana is below 150 and your health is above the configured safety %.
- **Pet Assist (Pet tab)**: The "Master Switch" for pet automation. When ON, the addon handles pet attacks; when OFF, you control the pet manually.
- **Smart Targets**: Automatically targets the nearest enemy when you press your rotation macro if you don't already have a target.
- **Fast Attack (Pet tab)**: When ON, your pet charges the boss instantly on macro press; when OFF, it waits for your first spell to land. (Requires Pet Assist: ON).
- **Auto Fel Domination (Pet tab)**: Casts Fel Domination first when using the summon macro if the spell is ready.
- **Debug Mode**: Prints the addon's internal logic and decision-making to the chat window (useful for troubleshooting, but spammy).
- **Drain Soul Threshold**: A slider to set the target health % at which the addon will prioritize finishing the mob with Drain Soul.

## 🛠 Installation
1. Download the repository.
2. Place the `WarlockCore` folder into your `C:\Games\TurtleWoW\Interface\AddOns\` directory.
3. Restart or Reload your WoW client.

## ⌨️ Commands
- `/wrc`: Toggle the main configuration window.
- `/wrc reset`: Clear the current list of tracked immune mobs.
- `/wrc clear [Name]`: Remove a specific mob from the immunity list.

## 📦 Dependencies
- **None**. WarlockCore is a completely standalone addon built using native 1.12.1 API calls.

---
**Author**: Stephan
**Version**: 1.10.2
**Compatibility**: Turtle WoW (Vanilla 1.12.1)
