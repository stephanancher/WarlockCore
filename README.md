# WarlockCore v1.2.3 (Turtle WoW)

A premium combat rotation and utility addon for Warlocks on the Turtle WoW (1.12.1) client. Designed for maximum responsiveness, safety, and a beautiful dark aesthetic.

## 🚀 Key Features

- **Priority-Based Rotation**: Intelligent spell selection (Slot 1-4) with automatic debuff checking to prevent redundant casting.
- **Immediate Pet Engagement**: Bypasses the 1.12 "casting lock" by sending the pet at the exact millisecond you press the macro, ensuring your pet and spells hit simultaneously.
- **Safety Valve (Fast Attack Mode)**: Optional safety setting. When OFF, requires a hardware confirmation (two clicks) to initiate combat on a new target.
- **Isolated Buff Logic**: Prioritizes Armor buffs (Demon Skin/Armor) without triggering attacks or targeting.
- **Premium Dark UI**: A bespoke, shadow-purple "Void" interface with glassmorphism effects and custom buttons.
- **Class Lock**: Automatically disables itself on non-Warlock characters to keep your UI clean.

## 🛠 How to Use

1. **Installation**: Download the `WarlockCore` folder and place it in your `Interface\AddOns\` directory.
2. **First Login**: Log in as a Warlock. You will see the purple Summon Imp icon on your minimap.
3. **Setup Rotation**: 
   - Open the menu by clicking the Minimap button.
   - Go to the **Rotation** tab and select your spells.
4. **The Macro**:
   - Go to the **Info** tab.
   - Drag the macro icon directly onto your Action Bar.
   - (Alternatively, manually create a macro named `WarlockRot` with the text: `/script WarlockCore_Rotate()`).
5. **Start Combat**: Simply press your Action Bar button. The addon will handle targeting, pet orders, and your optimized spell priority.

## ⚙️ Settings
- **Rotation**: Define your Opener and Priority list.
- **Pet**: Toggle "Pet Assist" and "Fast Attack Mode".
- **Buff**: Select your preferred Armor buff.
- **Info**: Drag the macro, toggle Debug mode, or Reload UI.

---
*Created by stephanancher for the Turtle WoW community.*
