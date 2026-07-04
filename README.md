# WarlockCore v1.7.4
Advanced Combat Automation & Interface for Turtle WoW (Vanilla 1.12.1).

WarlockCore is a high-performance combat suite designed to streamline Warlock gameplay with intelligent automation, resource management, and a premium 5-tab configuration interface.

## 🚀 Key Features

### 🧠 Smart Combat Logic
- **Smart Fear**: Tracks mobs that are immune to Fear (e.g., undead, mechanicals) in real-time and automatically switches to Shadow Bolt when those mobs are targeted.
- **Smart Drain**: Intelligent Drain Soul management with health threshold configuration to ensure clean soul shard generation.
- **Immune Management**: Dynamic management of immune mobs via the "Info" tab.

### 🩸 Resource Automation
- **Auto Stone**: Automatically consumes a Healthstone at a user-defined Health % threshold.
- **Auto Tap**: Intelligently uses Life Tap when mana is low, respecting a safety health threshold to ensure you never tap yourself into danger.

### 🐾 Pet Intelligence
- **Master Assist**: Toggleable pet automation that ensures your pet engages when you do.
- **Smart Targets**: Automatically targets the nearest enemy when triggering your rotation if you don't have a target selected.
- **Fast Attack**: High-priority charge command that sends your pet to the mob instantly on rotation start.

### 🎨 Premium Interface
- **Unified 5-Tab UI**: Clean organization across **Rotation, Pet, Buff, Options, and Info** tabs.
- **Interactive Tooltips**: Hover over any setting in the "Options" tab to see a detailed description of its function.
- **Macro Sync**: Drag-and-drop macros (Rot & Fear) that automatically update their icons in real-time based on your current combat state.

## ⚙️ Configuration Options (Options Tab)
Every setting in the **Options** tab is designed to give you full control over the combat automation:

- **Smart Fear**: Remembers immune mobs (Undead/Mechanical/Bosses) and automatically skips Fear on them to save mana.
- **Smart Drain**: Intelligently manages Drain Soul rank switching and power conflicts for seamless shard farming.
- **Auto Stone**: Uses your Healthstone automatically when your Health falls below your chosen %; simply enter the threshold in the textbox.
- **Auto Tap**: Intelligently uses Life Tap during your rotation if your mana is low, provided your health is above your safety %; enter the safety threshold in the textbox.
- **Pet Assist**: The "Master Switch" for pet automation. When ON, the addon handles pet attacks; when OFF, you control the pet manually.
- **Smart Targets**: Automatically targets the nearest enemy when you press your rotation macro if you don't already have a target.
- **Fast Attack**: When ON, your pet charges the boss instantly on macro press; when OFF, it waits for your first spell to land. (Requires Pet Assist: ON).
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
**Version**: 1.7.4
**Compatibility**: Turtle WoW (Vanilla 1.12.1)
