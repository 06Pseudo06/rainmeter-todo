# ♡ Cute Rainmeter To-Do

> A minimal, aesthetic Rainmeter productivity widget designed to keep your daily tasks visible without taking over your desktop.

A tiny, aesthetic desktop to-do widget for Windows — simple enough to stay out of your way, useful enough to keep you on track.

---

## ✦ Preview

![Cute Rainmeter To-Do](<img width="557" height="763" alt="image" src="https://github.com/user-attachments/assets/1f19b9cc-9d5b-4b41-8965-c5a40233cde5" />
)


---

## ✨ Features

- **✓ Click-to-complete tasks** — Check off items as you finish them with subtle visual feedback.
- **＋ Add tasks directly from the widget** — Click `+ New task` to input items with on-screen prompt.
- **↕ Reorder tasks** — Move tasks up or down effortlessly with directional arrows.
- **★ Mark important tasks** — Highlight priority tasks with a distinct accent color.
- **↻ Recurring tasks** — Tag recurring daily habits and routines.
- **🗑 Delete tasks** — Clean up completed or obsolete items with one click.
- **↩ Undo deleted tasks** — Quick restore button for recently deleted tasks from the trash history.
- **📊 Dynamic completion progress** — Real-time progress percentage and smooth visual progress bar.
- **♡ Discreet collapsed mode** — One-click minimize to a compact, cute heart badge.
- **💾 Local task persistence** — All tasks are saved locally on your machine in plain text.
- **🎨 Warm cream / blush minimal aesthetic** — Clean typography inspired by modern Notion & Pinterest desktop setups.
- **⚡ Lightweight Rainmeter implementation** — Minimal CPU and memory footprint.

---

## 🌷 What it looks like

### Expanded
![Expanded widget](<img width="557" height="763" alt="image" src="https://github.com/user-attachments/assets/22d6814e-025f-474e-91a7-4fc5ded34c36" />
)

### Collapsed
![Collapsed widget](<img width="145" height="127" alt="Screenshot 2026-09-06 194843" src="https://github.com/user-attachments/assets/cd1cb055-7458-4c8e-a141-5c2902c981e5" />
)

---

## 🌱 Installation

### 1. Install Rainmeter
Download and install the latest release of [Rainmeter](https://www.rainmeter.net/) (Windows 7/8/10/11 supported).

### 2. Install the Skin
1. Download or clone this repository:
   ```bash
   git clone https://github.com/06Pseudo06/rainmeter-todo.git
   ```
2. Move the skin folder into your Rainmeter Skins directory:
   ```text
   Documents\Rainmeter\Skins\rainmeter-todo\
   ```
   The resulting folder structure should look like:
   ```text
   Rainmeter/
   └── Skins/
       └── rainmeter-todo/
           ├── todo/
           └── @Resources/
   ```

### 3. Load the Skin
1. Right-click the Rainmeter tray icon and select **Manage**.
2. Expand the `rainmeter-todo` skin list in the left panel.
3. Select `todo` → `todo.ini` and click **Load**.

### 4. Setup Your Tasks
The widget will automatically initialize your tasks file when you add your first task. You can also rename `todo/tasks.example.txt` to `todo/tasks.txt` to start with sample items.

---

## 🌸 Usage

| Action | How to use |
| :--- | :--- |
| **Add a Task** | Click **`+ New task`** at the bottom, enter your task name in the input dialog, and press Enter. |
| **Complete a Task** | Click the circular checkmark icon on the left of any task item. |
| **Mark as Important** | Click the star icon (★) to toggle high-priority highlight. |
| **Set Recurring** | Click the repeat icon (↻) to mark habitual or daily recurring tasks. |
| **Reorder Tasks** | Use the up (↑) and down (↓) arrows next to any task to change its position. |
| **Delete Task** | Click the trash icon (🗑) next to the task. |
| **Undo Deletion** | Click the restore icon (↩) in the footer to bring back the last deleted task. |
| **Collapse / Expand** | Click the heart icon (♡) in the header or the collapse button (⇲) in the top-right corner to toggle between expanded list and the compact badge. |
| **Refresh Widget** | Click the refresh icon (↻) in the bottom right to reload the skin. |

---

## 🎀 Customization

You can personalize the visual style by editing the `[Variables]` section in `todo/todo.ini`:

```ini
[Variables]
; --- Layout & Sizing ---
SkinWidth=340
COLLAPSED=0
SHOW_RECURRING=1
SHOW_IMPORTANT=1
TRASH_LIMIT=10

; --- Color Palette (R,G,B,A) ---
BG_COLOR=252,250,246,245
BORDER_COLOR=232,226,218,255
TEXT_PRIMARY=48,42,40,240
TEXT_MUTED=160,152,145,210
ACCENT_COLOR=225,120,135,255
CHECKBOX_COLOR=190,180,172,255
IMPORTANT_COLOR=235,160,70,255
RECURRING_COLOR=135,165,145,255
ICON_INACTIVE=218,212,204,140
ICON_ACTION=175,165,158,230
PROGRESS_BAR_BG=238,233,226,255
PROGRESS_BAR_FILL=225,120,135,255
```

> **Warning:** Do **not** manually edit `@Resources/DynamicMeters.inc`. This file is dynamically generated and overwritten by the Lua controller script (`MeasureDynamicTasks.lua`) whenever your tasks change.

---

## 📁 Project Structure

```text
rainmeter-todo/
├── @Resources/
│   ├── Fonts/
│   │   ├── inter-regular.ttf        # UI font for labels and dates
│   │   ├── materialicons.ttf        # Icons for checkmarks, stars & actions
│   │   └── roboto-regular.ttf       # Alternate clean font
│   ├── DynamicMeters.inc            # Dynamically generated UI meters (auto-managed)
│   ├── MeasureDynamicTasks.lua      # Core Lua engine for state, tasks & rendering
│   ├── MUI.inc                      # Material Icons unicode definitions
│   └── nircmd.exe                   # Helper utility for input prompt handling
├── todo/
│   ├── tasks.example.txt            # Example task list template
│   └── todo.ini                     # Main skin configuration, variables & layout
├── .gitignore                       # Git ignore configuration
├── LICENSE                          # GNU General Public License v3
└── README.md                        # Documentation and guide
```

---

## ♡ Why?

> *Keep your tasks close, but keep them quiet.*

Most to-do apps demand too much attention or get buried under browser tabs. This widget lives quietly on your desktop background—accessible in a fraction of a second, aesthetic enough to complement your setup, and collapsible when you need pure focus.

---

## 🛠 Built With

- **[Rainmeter](https://www.rainmeter.net/)** — Desktop customization tool for Windows
- **Rainmeter Lua Scripting** — Dynamic meter rendering & task storage management
- **Rainmeter INI Configuration** — Declarative UI definitions and styles
- **Material Icons** — Clean vector action and status icons
- **Inter Font** — Modern, readable typography

---

## Credits

This project is a modified and redesigned version of the Rainmeter To-Do Skin originally created by **Alperen Ozlu**.

- Original Author: **Alperen Ozlu**
- License: **GNU General Public License Version 3 (GPLv3)**

All modifications, visual redesigns, and extensions in this repository preserve the original GPLv3 terms.

---

## 🤍 Contributing

Contributions, feedback, and suggestions are warmly welcome!
- Found a bug? Open an issue on GitHub.
- Want to improve or add features? Fork the repository, create a branch, and submit a pull request.

---

## 🌱 Possible Future Improvements

- [ ] Additional curated color themes (Dark minimal, Matcha green, Lavender dusk)
- [ ] Alternative compact badge modes (progress ring / mini indicator)
- [ ] Optional motivational daily quote display
- [ ] In-skin settings panel
- [ ] Customizable sound notifications on task completion

---

## License

This project is distributed under the terms of the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for full license details.
