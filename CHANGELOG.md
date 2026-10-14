# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 - 2026-10-14

### Added

- `install-neon-grid.sh`: idempotent installer for the NEON//GRID bspwm desktop on Kali Linux, with `--no-pdf`, `--no-session` and `--skip-packages` options.
- bspwm, sxhkd, polybar, picom (full and light), rofi (two themes), kitty, dunst, tmux and powerlevel10k configurations with a green cyberpunk palette.
- GPU detection at login to pick the right picom config and kitty rendering mode.
- Procedurally generated wallpaper (Python + ImageMagick).
- Pentesting helpers: `settarget`, `cleartarget`, `gettarget`, `mkt` and `extractPorts`.
- Automatic backups of overwritten configs in `~/.neon-grid-backup-<date>/`.
- Original user guide in Spanish (`docs/guia-entorno.pdf`).
- Bilingual documentation (English and Spanish): README, installation, shortcuts and troubleshooting.
- Screenshots of the environment.
- ShellCheck workflow for GitHub Actions.
