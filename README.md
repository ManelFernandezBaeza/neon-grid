<div align="center">

<img src="assets/banner.svg" alt="NEON//GRID" width="100%">

**A green cyberpunk bspwm desktop for Kali Linux, installed with a single script.**

🇬🇧 **English** | 🇪🇸 [Español](README.es.md)

<br>

![Kali Linux](https://img.shields.io/badge/Kali_Linux-rolling-00ff9c?style=for-the-badge&logo=kalilinux&logoColor=white&labelColor=0a0e0a)
![Bash](https://img.shields.io/badge/Bash-script-39ff14?style=for-the-badge&logo=gnubash&logoColor=white&labelColor=0a0e0a)
![bspwm](https://img.shields.io/badge/WM-bspwm-00d9a3?style=for-the-badge&labelColor=0a0e0a)
![sxhkd](https://img.shields.io/badge/hotkeys-sxhkd-1fb58f?style=for-the-badge&labelColor=0a0e0a)
<br>
![Platform](https://img.shields.io/badge/platform-Linux-00ffff?style=for-the-badge&logo=linux&logoColor=white&labelColor=0a0e0a)
![Version](https://img.shields.io/badge/version-1.0.0-ff00ff?style=for-the-badge&labelColor=0a0e0a)
![License](https://img.shields.io/badge/license-GPL--3.0--or--later-ff00ff?style=for-the-badge&logo=gnu&logoColor=white&labelColor=0a0e0a)

</div>

---

## Table of contents

1. [What is NEON//GRID?](#-what-is-neongrid)
2. [Screenshots](#-screenshots)
3. [Features](#-features)
4. [Requirements](#-requirements)
5. [Quick install](#-quick-install)
6. [What the script does](#-what-the-script-does)
7. [First start](#-first-start)
8. [Main keyboard shortcuts](#-main-keyboard-shortcuts)
9. [Uninstall / going back](#-uninstall--going-back)
10. [Troubleshooting](#-troubleshooting)
11. [Repository structure](#-repository-structure)
12. [Author and license](#-author-and-license)

---

## 🟢 What is NEON//GRID?

**NEON//GRID** turns a Kali Linux install into a tiling desktop built on **bspwm**, with its own green cyberpunk theme: a procedurally generated grid wallpaper, a glowing **polybar**, custom **rofi** themes, a tuned **kitty** terminal, a green **powerlevel10k** prompt and a handful of shell helpers for pentesting workflows.

Everything is done by one idempotent Bash script, [`install-neon-grid.sh`](install-neon-grid.sh). It backs up your previous configs before overwriting them and can be run again safely.

Palette: background `#0a0e0a` · neon `#00ff9c` · accent `#39ff14` · secondary `#1f7a4d` · alert `#ffb000`. Font: **JetBrainsMono Nerd Font**.

> [!NOTE]
> The original user guide, [`docs/guia-entorno.pdf`](docs/guia-entorno.pdf), is written in **Spanish**. The full keyboard shortcut reference in English is in [`docs/en/SHORTCUTS.md`](docs/en/SHORTCUTS.md).

## 📸 Screenshots

<div align="center">

<img src="assets/screenshots/tiling.png" alt="Three kitty terminals tiled by bspwm" width="100%">

<sub><b>Tiling</b> — three kitty terminals arranged by bspwm</sub>

</div>

<br>

| Clean desktop | Terminal |
|:---:|:---:|
| <img src="assets/screenshots/desktop.png" alt="Clean desktop with the NEON//GRID wallpaper and polybar"> | <img src="assets/screenshots/terminal.png" alt="kitty terminal showing the sxhkd config"> |
| **App launcher (rofi)** | **Power menu** |
| <img src="assets/screenshots/launcher.png" alt="rofi application launcher"> | <img src="assets/screenshots/powermenu.png" alt="rofi power menu"> |
| **Monocle layout** | |
| <img src="assets/screenshots/monocle.png" alt="A single window in monocle layout"> | |

## ✨ Features

- **bspwm + sxhkd** tiling with 10 desktops, 12 px gaps, green borders and mouse move/resize with <kbd>Super</kbd>.
- **GPU-aware compositing**: on every login `bspwmrc` checks OpenGL with `glxinfo` and picks the full **picom** config (glx, blur, shadows) or a light one (xrender, no blur) for VMs without 3D.
- **polybar** with icon + label modules: desktops, active window, LAN/VPN IP, `TARGET`, CPU, RAM, temperature, load, network speed, volume, clock, tray and a power button.
- **rofi** launcher with two custom themes (`neon-grid` and `neon-grid-terminal`) and a rofi-based power menu.
- **kitty** terminal preloaded hidden at startup, so <kbd>Super</kbd>+<kbd>Return</kbd> opens instantly.
- **zsh + powerlevel10k** (green "lean" prompt), zsh-autosuggestions and zsh-syntax-highlighting; a matching prompt for bash.
- **tmux** with a green theme and the `Ctrl+a` prefix.
- **dunst** notifications, **flameshot** screenshots, volume keys.
- **Pentesting helpers**: `settarget`, `cleartarget`, `gettarget`, `mkt` and `extractPorts`, with the current target shown in polybar and tmux.
- **Original procedural wallpaper** generated with Python + ImageMagick.
- **Safe re-runs**: changed configs are backed up to `~/.neon-grid-backup-<date>/`.

## 📋 Requirements

| Requirement | Details |
|---|---|
| OS | **Kali Linux** (rolling). Other Debian/apt systems get a warning but the script still tries. |
| User | A **normal user with sudo**. The script refuses to run as root. |
| Internet | Required: `apt`, the JetBrainsMono Nerd Font download and the powerlevel10k `git clone`. |
| Display manager | **LightDM** to set bspwm as the default session automatically (Kali's default). `startx` from a TTY also works. |
| Architecture | 64-bit **amd64** (x86_64) |
| CPU | **4 cores** (2 processors × 2 cores), as in Kali's VM guide · Kali sets no official minimum |
| RAM | **2 GB** minimum · more is better if your host can spare it |
| Disk | **20 GB** minimum · Kali's VM guide uses **80 GB** |
| Versions | `picom.conf` uses the `rules` syntax (picom **v12+**) and polybar uses `internal/tray` (polybar **3.7+**). Current kali-rolling ships compatible versions. |

Hardware values follow Kali's official [installation requirements](https://www.kali.org/docs/installation/hard-disk-install/) for a desktop install and its [VMware guest guide](https://www.kali.org/docs/virtualization/install-vmware-guest-vm/).

> [!TIP]
> In a virtual machine, enable **3D acceleration** to get blur and full shadows. Without it NEON//GRID still works with the light picom config.

## 🚀 Quick install

```bash
git clone https://github.com/ManelFernandezBaeza/neon-grid.git
cd neon-grid
chmod +x install-neon-grid.sh
./install-neon-grid.sh
```

Options:

| Option | Effect |
|---|---|
| `--no-pdf` | Don't generate the PDF guide (`~/guia-entorno.pdf`) |
| `--no-session` | Don't set bspwm as the default LightDM session |
| `--skip-packages` | Don't install packages with `apt` |
| `-h`, `--help` | Show the help header |

> [!WARNING]
> Run it as your **normal user**, not with `sudo ./install-neon-grid.sh`. It asks for your sudo password when needed and keeps sudo alive while it runs. It also **changes your login shell to zsh**.

Full guide: [`docs/en/INSTALLATION.md`](docs/en/INSTALLATION.md).

## 🔧 What the script does

| # | Step | Details |
|:-:|---|---|
| 0 | **Checks** | Not root, Kali detected (warning otherwise), `apt-get` and `sudo` available. Keeps sudo alive in the background. |
| 1 | **Packages** | Installs only the missing ones with `apt` (see list below). Links `batcat` → `/usr/local/bin/bat` if needed. |
| 2 | **Font** | Downloads the latest **JetBrainsMono Nerd Font** to `~/.local/share/fonts/JetBrainsMonoNF` and refreshes the font cache. |
| 3 | **powerlevel10k** | `git clone --depth=1` into `~/.powerlevel10k`. |
| 4 | **Configs** | Writes bspwm, sxhkd, polybar (+ scripts), picom, rofi (+ themes), kitty, dunst, wallpaper generator, helper functions, guide sources, p10k, tmux, `.xinitrc` and `.fehbg`. Any file that would change is first copied to `~/.neon-grid-backup-<date>/`. Links `~/.local/share/rofi/themes` → `~/.config/rofi/themes`. |
| 5 | **Shells** | Hooks the helpers and powerlevel10k into `~/.zshrc` and the helpers + a green prompt into `~/.bashrc` (backups: `*.bak-pre-neongrid`). Sets **zsh** as your login shell with `chsh`. |
| 6 | **Wallpaper** | Generates `~/.config/wallpapers/neon-grid.png` (2560×1440) if it doesn't exist. |
| 7 | **Session** | Writes `~/.dmrc` and `/var/lib/AccountsService/users/$USER` so LightDM starts **bspwm** by default (skipped with `--no-session`). |
| 8 | **PDF guide** | Builds `~/guia-entorno.pdf` with pandoc + weasyprint (skipped with `--no-pdf`). |
| 9 | **Reload** | If you are already inside bspwm, restarts sxhkd/picom and reloads bspwm. |

<details>
<summary><b>Packages installed with apt</b></summary>

| Category | Packages |
|---|---|
| Desktop | `bspwm` `sxhkd` `polybar` `picom` `rofi` `feh` `kitty` `dunst` `lxappearance` `network-manager-gnome` `pavucontrol` |
| X base / utilities | `xorg` `xinit` `xclip` `xdotool` `jq` `curl` `git` `unzip` `imagemagick` `mesa-utils` |
| Fonts | `fonts-jetbrains-mono` `fontconfig` |
| Terminal / QoL | `zsh` `zsh-autosuggestions` `zsh-syntax-highlighting` `tmux` `btop` `ripgrep` `fzf` `bat` `eza` `neovim` |
| Pentesting / network | `nmap` `net-tools` `seclists` `flameshot` |
| Documentation | `pandoc` `weasyprint` |

</details>

<details>
<summary><b>Files created or modified</b></summary>

| Path | Purpose |
|---|---|
| `~/.config/bspwm/bspwmrc` | bspwm: gaps, borders, mouse, rules, autostart |
| `~/.config/sxhkd/sxhkdrc` | Keyboard shortcuts |
| `~/.config/polybar/config.ini`, `launch.sh`, `scripts/*.sh`, `target` | Bar, launcher, modules, current target IP |
| `~/.config/picom/picom.conf`, `picom-lite.conf` | Compositor with / without GPU |
| `~/.config/rofi/config.rasi`, `themes/neon-grid*.rasi` | rofi config and themes |
| `~/.config/kitty/kitty.conf` | Terminal and green ANSI palette |
| `~/.config/dunst/dunstrc` | Notifications |
| `~/.config/wallpapers/neon-grid.png`, `src/neon-grid.py` | Wallpaper and its generator |
| `~/.config/neon-grid/functions.sh` | Pentesting helpers and aliases |
| `~/.config/neon-grid/doc/` | Guide sources (Markdown + CSS) |
| `~/.p10k.zsh`, `~/.powerlevel10k/` | powerlevel10k config and theme |
| `~/.tmux.conf`, `~/.xinitrc`, `~/.fehbg` | tmux, `startx`, last wallpaper |
| `~/.zshrc`, `~/.bashrc` | Modified (backups `*.bak-pre-neongrid`) |
| `~/.dmrc`, `/var/lib/AccountsService/users/$USER` | Default session = bspwm |
| `~/.local/share/fonts/JetBrainsMonoNF/` | Nerd Font |
| `~/.local/share/rofi/themes` | Symlink to `~/.config/rofi/themes` |
| `/usr/local/bin/bat` | Symlink to `batcat` (if needed) |
| `~/guia-entorno.pdf` | Generated guide (Spanish) |

</details>

## 💻 First start

1. **Log out** when the script finishes.
2. On the **LightDM** login screen, open the session selector (icon in the top-right corner). **bspwm** is already selected as your default session; XFCE is still available in the same menu.
3. Log in. `bspwmrc` detects your GPU and starts sxhkd, picom, dunst, nm-applet, the wallpaper, polybar and a hidden, preloaded kitty.

Without a display manager: switch to a TTY (<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F3</kbd>), log in and run `startx` (it uses `~/.xinitrc`, which runs `exec bspwm`).

> [!NOTE]
> All shortcuts use the <kbd>Super</kbd> key (the Windows key) as modifier.

## ⚡ Main keyboard shortcuts

| Shortcut | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>Return</kbd> | Open terminal (kitty) |
| <kbd>Super</kbd> + <kbd>d</kbd> | App launcher (rofi drun) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>d</kbd> | Open windows list (rofi window) |
| <kbd>Super</kbd> + <kbd>w</kbd> | Close focused window |
| <kbd>Super</kbd> + <kbd>1…9, 0</kbd> | Go to desktop 1…10 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1…9, 0</kbd> | Send window to desktop 1…10 |
| <kbd>Super</kbd> + <kbd>←↓↑→</kbd> | Move focus |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>←↓↑→</kbd> | Swap window in that direction |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>←↓↑→</kbd> | Resize window (40 px per press) |
| <kbd>Super</kbd> + <kbd>f</kbd> | Real fullscreen (covers the bar) |
| <kbd>Super</kbd> + <kbd>m</kbd> | Toggle monocle layout |
| <kbd>Super</kbd> + <kbd>s</kbd> / <kbd>t</kbd> | Floating / tiled |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> | Reload bspwm + sxhkd |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>p</kbd> | Power menu |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>q</kbd> | Quit bspwm |
| <kbd>Print</kbd> | Screenshot (`flameshot gui`) |

📖 Full reference (mouse, rofi, reload commands, tmux, helper commands): [`docs/en/SHORTCUTS.md`](docs/en/SHORTCUTS.md).

## 🔙 Uninstall / going back

The script has **no automatic uninstaller**, but it keeps everything you need to go back:

1. **Switch session**: on the LightDM login screen pick **XFCE** (or your previous desktop) in the session selector.
2. **Restore configs**: copy your files back from `~/.neon-grid-backup-<date>/` (created only for files that were overwritten).
3. **Restore shells**: `mv ~/.zshrc.bak-pre-neongrid ~/.zshrc` and `mv ~/.bashrc.bak-pre-neongrid ~/.bashrc`.
4. **Login shell**: `chsh -s /bin/bash` if you prefer bash again.
5. **Optional cleanup**: remove `~/.config/{bspwm,sxhkd,polybar,picom,rofi,kitty,dunst,wallpapers,neon-grid}`, `~/.powerlevel10k`, `~/.p10k.zsh`, `~/.local/share/fonts/JetBrainsMonoNF` and run `fc-cache -f`.

Step-by-step details: [`docs/en/INSTALLATION.md`](docs/en/INSTALLATION.md#uninstall--going-back).

## 🧯 Troubleshooting

| Problem | Quick fix |
|---|---|
| No blur / VM feels slow | Enable 3D acceleration in the VM; check with `glxinfo -B \| grep -E "renderer\|core profile"` |
| `TEMP` shows `N/A` | Normal in VMs without temperature sensors |
| Square icons in the bar | The Nerd Font is missing: `fc-list : family \| grep -i "JetBrainsMono Nerd"` |
| bspwm not in LightDM | Check that the `bspwm` package is installed and its session file exists in `/usr/share/xsessions/` |
| Polybar doesn't show | Run `~/.config/polybar/launch.sh` and read `/tmp/polybar-*.log` |
| PDF guide not generated | `pandoc`/`weasyprint` are missing; install them or use `--no-pdf` |

More problems and solutions: [`docs/en/TROUBLESHOOTING.md`](docs/en/TROUBLESHOOTING.md).

## 📁 Repository structure

```text
neon-grid/
├── install-neon-grid.sh          # the installer
├── README.md                     # English (this file)
├── README.es.md                  # Spanish
├── LICENSE                       # GNU GPL v3
├── CHANGELOG.md
├── docs/
│   ├── guia-entorno.pdf          # original guide (Spanish)
│   ├── en/                       # INSTALLATION · SHORTCUTS · TROUBLESHOOTING
│   └── es/                       # INSTALACION · ATAJOS · SOLUCION-PROBLEMAS
├── assets/
│   ├── banner.svg
│   └── screenshots/
└── .github/workflows/shellcheck.yml
```

## 👤 Author and license

Made by **[ManelFernandezBaeza](https://github.com/ManelFernandezBaeza)**.

Released under the **GNU General Public License v3.0 or later** (`GPL-3.0-or-later`). See [`LICENSE`](LICENSE).

<div align="center">

<sub><code>kali://bspwm :: sys.online :: trace.active</code></sub>

</div>
