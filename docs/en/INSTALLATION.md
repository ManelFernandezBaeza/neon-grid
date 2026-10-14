# Installation

🇬🇧 **English** | 🇪🇸 [Español](../es/INSTALACION.md) · [← Back to README](../../README.md)

## Before you start

- **Kali Linux** (rolling) with a desktop already working. On other Debian/apt systems the script shows a warning and tries anyway.
- A **normal user with sudo** rights. Running as root is refused on purpose: the configs must end up in your own `$HOME`.
- **Internet access** for `apt`, the JetBrainsMono Nerd Font download (GitHub releases) and the powerlevel10k `git clone`.
- **LightDM** if you want bspwm set as the default session automatically (Kali uses it by default).
- In a VM, enable **3D acceleration** for blur and full shadows (see [Troubleshooting](TROUBLESHOOTING.md#no-blur-or-the-vm-feels-slow)).

> [!WARNING]
> The script **changes your login shell to zsh** (`chsh`), **overwrites `~/.dmrc`** and replaces `~/.local/share/rofi/themes` with a symlink (only `.rasi` files already in that folder are copied over). Review the [What the script does](../../README.md#-what-the-script-does) section if you have a customised setup.

## Install

```bash
git clone https://github.com/ManelFernandezBaeza/neon-grid.git
cd neon-grid
chmod +x install-neon-grid.sh
./install-neon-grid.sh
```

The script asks for your sudo password once and keeps the sudo session alive in the background until it finishes.

### Options

| Option | Effect |
|---|---|
| `--no-pdf` | Don't generate `~/guia-entorno.pdf` |
| `--no-session` | Don't set bspwm as the default LightDM session (`~/.dmrc` and AccountsService are left alone) |
| `--skip-packages` | Don't install anything with `apt` (useful on re-runs) |
| `-h`, `--help` | Print the help header and exit |

Any other argument stops the script with `Opción desconocida` ("unknown option").

### Re-running

The installer is **idempotent**:

- Packages, the Nerd Font, powerlevel10k and the wallpaper are skipped if already present.
- Config files are only replaced when their content differs; the old version is copied to `~/.neon-grid-backup-<YYYYMMDD-HHMMSS>/` first.
- `~/.zshrc` and `~/.bashrc` are only patched once (it looks for `neon-grid/functions.sh`).
- An existing `~/.config/polybar/target` is never overwritten.

If you run it from inside bspwm, it restarts sxhkd and picom and reloads bspwm at the end.

## First start

1. Log out.
2. On the LightDM screen, open the session selector (top-right icon): **bspwm** is already your default session. XFCE is still listed.
3. Log in.

Without a display manager: go to a TTY with <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F3</kbd>, log in and run `startx` (`~/.xinitrc` runs `exec bspwm`).

On every login `bspwmrc` checks the GPU and starts **sxhkd**, **picom** (full or light config), **dunst**, **nm-applet**, the wallpaper, **polybar** and a hidden, preloaded **kitty**. Everything checks whether it is already running, so reloading never duplicates processes.

Next: learn the [keyboard shortcuts](SHORTCUTS.md).

## Uninstall / going back

There is no automatic uninstaller. Undo the changes manually:

1. **Default session**: pick XFCE (or your previous desktop) in the LightDM session selector. To make it permanent, edit `~/.dmrc` and `/var/lib/AccountsService/users/$USER` (`XSession=`) with your previous session name.
2. **Configs**: copy back what you need from `~/.neon-grid-backup-<date>/`. It only contains files that existed and were different before the install.
3. **Shells**:

   ```bash
   mv ~/.zshrc.bak-pre-neongrid ~/.zshrc
   mv ~/.bashrc.bak-pre-neongrid ~/.bashrc
   ```

4. **Login shell** (if you want bash back):

   ```bash
   chsh -s /bin/bash
   ```

5. **Remove NEON//GRID files** (optional):

   ```bash
   rm -rf ~/.config/{bspwm,sxhkd,polybar,picom,rofi,kitty,dunst,wallpapers,neon-grid}
   rm -rf ~/.powerlevel10k ~/.p10k.zsh ~/.local/share/fonts/JetBrainsMonoNF
   rm -f ~/.local/share/rofi/themes ~/.fehbg ~/.xinitrc ~/guia-entorno.pdf
   fc-cache -f
   ```

   > [!CAUTION]
   > Check `~/.tmux.conf` and `~/.xinitrc` before deleting them if you had your own versions; restore them from the backup folder instead.

6. **Packages** (optional): the script doesn't track which packages were new, so remove only the ones you are sure you don't need with `sudo apt remove <package>`. The `/usr/local/bin/bat` symlink can be removed with `sudo rm /usr/local/bin/bat`.
