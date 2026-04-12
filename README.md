# WarlockCore v1.6.9
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
**Version**: 1.6.9
**Compatibility**: Turtle WoW (Vanilla 1.12.1)
