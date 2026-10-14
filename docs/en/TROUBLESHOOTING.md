# Troubleshooting

🇬🇧 **English** | 🇪🇸 [Español](../es/SOLUCION-PROBLEMAS.md) · [← Back to README](../../README.md)

## The script stops right away

| Message | Cause and fix |
|---|---|
| `Ejecuta el script como tu usuario normal, no como root` | You ran it as root or with `sudo`. Run `./install-neon-grid.sh` as your normal user. |
| `Se necesita apt-get.` | Not a Debian/apt system. NEON//GRID targets Kali Linux. |
| `Se necesita sudo.` | Your user can't use sudo, or the password was wrong. |
| `Opción desconocida: …` | Unsupported argument. Valid options: `--no-pdf`, `--no-session`, `--skip-packages`, `-h`. |
| `No parece Kali Linux…` | Only a warning: the script continues on other Debian/apt systems. |

## No blur or the VM feels slow

`bspwmrc` checks the GPU with `glxinfo` on every login and chooses:

| OpenGL available | picom | kitty |
|---|---|---|
| ≥ 3.3 in hardware (3D enabled, recent hardware compatibility) | `picom.conf`: glx + blur + full shadows | GPU |
| Software only (llvmpipe, VM without 3D) | `picom-lite.conf`: xrender, no blur | software |
| Hardware < 3.3 (VMware 3D with old compatibility) | `picom-lite.conf` | forced software (`LIBGL_ALWAYS_SOFTWARE=1`) |

**VMware:** to get blur and the real GPU, power off the VM, enable *Settings → Display → Accelerate 3D graphics* and raise *VM → Manage → Change Hardware Compatibility* to the latest version. Check with:

```bash
glxinfo -B | grep -E "renderer|core profile"
```

Unfocused windows are dimmed on purpose (`dim = 0.35` in picom's `rules`); change the value to taste.

## picom doesn't start

`picom.conf` and `picom-lite.conf` use the `rules = (...)` syntax, which needs **picom v12 or newer**. Check with `picom --version`. On an outdated system, update it (`sudo apt update && sudo apt full-upgrade`).

## Polybar is missing or incomplete

- Relaunch it: `~/.config/polybar/launch.sh`.
- Read the logs: `/tmp/polybar-<monitor>.log` or `/tmp/polybar.log`.
- The `tray` module uses `internal/tray`, which requires **polybar 3.7+** (`polybar --version`).
- `TEMP` shows `N/A` in virtual machines without temperature sensors. This is expected.
- `TARGET none` means no target is set: use `settarget <IP>`.

## Icons show as squares or are missing

The JetBrainsMono Nerd Font is not installed or not cached:

```bash
fc-list : family | grep -i "JetBrainsMono Nerd"
fc-cache -f
```

If nothing is listed, run the installer again with internet access (it downloads the font from the nerd-fonts GitHub releases).

## bspwm is not offered at login / XFCE still starts

- The session file comes from the `bspwm` package: check `/usr/share/xsessions/` for a bspwm entry.
- The default session is written to `~/.dmrc` and `/var/lib/AccountsService/users/$USER` (`XSession=bspwm`). If you used `--no-session`, pick bspwm manually in the LightDM session selector.
- With a display manager other than LightDM (e.g. GDM), choose the session from its own menu.
- Without a display manager, use `startx` from a TTY.

## The terminal shortcut does nothing

- Check that sxhkd is running: `pgrep -x sxhkd`. Reload with <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd>.
- In a VM, make sure the host is not capturing the <kbd>Super</kbd> key.

## The prompt looks wrong or zsh isn't the shell

- Log out and back in after the install: `chsh` only takes effect on a new login.
- Reload: `source ~/.zshrc`.
- Your previous config is in `~/.zshrc.bak-pre-neongrid`.

## The PDF guide wasn't generated

The script prints `faltan pandoc/weasyprint; PDF omitido` or `no se pudo generar el PDF`. Install the tools and rebuild it:

```bash
sudo apt install pandoc weasyprint
cd ~/.config/neon-grid/doc
pandoc guia-entorno.md -s --css guia.css --pdf-engine=weasyprint -o ~/guia-entorno.pdf
```

Or skip it with `--no-pdf`. A copy of the guide is also in this repo: [`docs/guia-entorno.pdf`](../guia-entorno.pdf) (Spanish).

## `bat` command not found

On Debian/Kali the binary is called `batcat`. The installer creates `/usr/local/bin/bat` pointing to it; if it's missing:

```bash
sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
```
