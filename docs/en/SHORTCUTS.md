# Keyboard shortcuts and commands

🇬🇧 **English** | 🇪🇸 [Español](../es/ATAJOS.md) · [← Back to README](../../README.md)

Translated from the original Spanish guide ([`guia-entorno.pdf`](../guia-entorno.pdf)). Shortcuts are defined in `~/.config/sxhkd/sxhkdrc`.

> [!NOTE]
> **Modifier:** every combination uses <kbd>Super</kbd> (the Windows key).

## Basics

| Shortcut | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>Return</kbd> | Open terminal (kitty, single preloaded instance: opens instantly) |
| <kbd>Super</kbd> + <kbd>d</kbd> | Application launcher (rofi drun) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>d</kbd> | List of open windows (rofi window) |
| <kbd>Super</kbd> + <kbd>w</kbd> | Close the focused window |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> | Reload bspwm + sxhkd |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>q</kbd> | Quit bspwm |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>p</kbd> | Power menu (lock / log out / reboot / power off) |
| <kbd>Print</kbd> | Screenshot with `flameshot gui` |
| `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` | Volume up / down / mute |

## Desktops and focus

| Shortcut | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>1…9, 0</kbd> | Go to desktop 1…10 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1…9, 0</kbd> | Move the window to desktop 1…10 |
| <kbd>Super</kbd> + <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd> | Move focus in that direction |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd> | Move (swap) the window in that direction |

## Resize with the keyboard

| Shortcut | Action |
|---|---|
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd> | Wider |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>←</kbd> | Narrower |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↑</kbd> | Taller |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↓</kbd> | Shorter |

Each press is 40 px (hold to repeat). If one side touches the screen edge, the window grows or shrinks from the opposite side. In tiled mode this moves the split with the neighbouring window, so it only changes in directions where there is another window; floating windows respond to all four arrows.

## Window modes and mouse

| Shortcut | Mode | Details |
|---|---|---|
| <kbd>Super</kbd> + <kbd>f</kbd> | **Real fullscreen** | `bspc node -t ~fullscreen`: covers polybar. Press again to go back. |
| <kbd>Super</kbd> + <kbd>m</kbd> | **Monocle** | `bspc desktop -l next`: the window fills the usable area **without** covering the bar. Press again to go back to tiled. |
| <kbd>Super</kbd> + <kbd>s</kbd> | **Floating** | `bspc node -t floating` |
| <kbd>Super</kbd> + <kbd>t</kbd> | **Tiled** | `bspc node -t tiled`: puts a floating window back into the tiling |
| <kbd>Super</kbd> + left click + drag | Move | Moves a floating window; in tiled mode it **swaps** it with the window where you drop it |
| <kbd>Super</kbd> + right click + drag | Resize | Resizes from the nearest corner |
| <kbd>Super</kbd> + wheel click + drag | Resize | Resizes from the nearest side |

## Rofi and the theme selector

- <kbd>Super</kbd> + <kbd>d</kbd> opens the launcher. Type to filter, <kbd>Enter</kbd> to launch and <kbd>Shift</kbd> + <kbd>←</kbd>/<kbd>→</kbd> (or click the bottom tab) to switch between **apps**, **run** and **win**.
- From a terminal: `rofi -show drun`, `rofi -show run` or `rofi -show window`.
- **Change theme on the fly:** run `rofi-theme-selector`. Use the arrows to preview and press <kbd>Alt</kbd> + <kbd>a</kbd> to apply and save (it writes `@theme` into `~/.config/rofi/config.rasi`).
- Bundled themes (besides the system ones):
  - **neon-grid** (default): centred, translucent window, neon-filled selection.
  - **neon-grid-terminal**: compact, opaque variant anchored at the top, console style.
- To go back to the default theme: put `@theme "neon-grid"` on the last line of `config.rasi`.

## Reloading components

| Component | How |
|---|---|
| bspwm + sxhkd | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> |
| sxhkd only | `pkill -USR1 -x sxhkd` |
| Polybar | `~/.config/polybar/launch.sh` (kills running instances and relaunches) |
| Picom | `pkill picom` then <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> (bspwmrc relaunches it with the right config for your GPU) |
| Dunst | `killall dunst; dunst &` |
| kitty | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F5</kbd> inside kitty |
| tmux | `prefix + r` (prefix: <kbd>Ctrl</kbd> + <kbd>a</kbd>) |
| zsh | `source ~/.zshrc` |

## tmux (prefix <kbd>Ctrl</kbd> + <kbd>a</kbd>)

| Keys | Action |
|---|---|
| `prefix` + <kbd>\|</kbd> | Split vertically |
| `prefix` + <kbd>-</kbd> | Split horizontally |
| `prefix` + <kbd>r</kbd> | Reload `~/.tmux.conf` |

Mouse is enabled. The status bar also shows the current target.

## Polybar interactions

| Module | Interaction |
|---|---|
| Launcher (left icon) | Left click opens `rofi -show drun` |
| Centre name | Left click opens the author's GitHub profile |
| `TARGET` | Left click copies the target IP to the clipboard |
| `VOL` | Right click opens `pavucontrol`; wheel changes volume; click mutes |
| Power icon | Left click opens the power menu |

## Custom commands (zsh and bash)

Defined in `~/.config/neon-grid/functions.sh`, which is loaded by `~/.zshrc` and `~/.bashrc`.

| Command | What it does |
|---|---|
| `settarget <IP>` | Saves the IP to `~/.config/polybar/target` and reloads polybar |
| `cleartarget` | Empties the target file and reloads polybar |
| `gettarget` | Prints the target IP and copies it to the clipboard (xclip) |
| `mkt` | Creates `nmap/ content/ exploits/ scripts/` in the current directory |
| `extractPorts <file>` | Extracts open ports from an nmap output (`-oG` or `-oN`), shows IP and ports and copies the `22,80,…` list to the clipboard |

Typical workflow (example IP from a lab):

```bash
settarget 10.10.11.42
mkt && cd nmap
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn $(gettarget) -oG allPorts
extractPorts allPorts
nmap -sCV -p$(xclip -o -sel clip) $(gettarget) -oN targeted
```

Aliases: `ls` / `ll` / `tree` → **eza** with icons · `cat` → **bat** without paging · `vim` → **nvim**.

## Wallpaper

- Regenerate (another seed = other data columns): `python3 ~/.config/wallpapers/src/neon-grid.py 42`
- Change wallpaper: `feh --bg-fill /path/to/image.png`. feh saves the command in `~/.fehbg` and bspwm reapplies it on every start.
- Back to the original: `feh --bg-fill ~/.config/wallpapers/neon-grid.png`
