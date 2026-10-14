#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════
#  NEON//GRID · instalador del entorno bspwm cyberpunk verde para Kali
#  github.com/ManelFernandezBaeza
#
#  Uso (como usuario normal, NO root, en una Kali con Internet):
#     chmod +x install-neon-grid.sh && ./install-neon-grid.sh
#
#  Opciones:
#     --no-pdf         no generar la guía PDF (~/guia-entorno.pdf)
#     --no-session     no poner bspwm como sesión por defecto en LightDM
#     --skip-packages  no instalar paquetes con apt
#
#  Idempotente: se puede relanzar. Las configs previas se guardan en
#  ~/.neon-grid-backup-<fecha>/ antes de sobrescribirse.
# ════════════════════════════════════════════════════════════════════
set -euo pipefail

DO_PDF=1; DO_SESSION=1; DO_PKGS=1
for a in "$@"; do
  case "$a" in
    --no-pdf) DO_PDF=0 ;;
    --no-session) DO_SESSION=0 ;;
    --skip-packages) DO_PKGS=0 ;;
    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "Opción desconocida: $a"; exit 1 ;;
  esac
done

G=$'\e[38;2;0;255;156m'; D=$'\e[38;2;31;122;77m'; A=$'\e[38;2;255;176;0m'; R=$'\e[0m'
step() { printf '\n%s▶ %s%s\n' "$G" "$*" "$R"; }
info() { printf '%s  · %s%s\n' "$D" "$*" "$R"; }
warn() { printf '%s  ! %s%s\n' "$A" "$*" "$R"; }
die()  { printf '%s✗ %s%s\n' "$A" "$*" "$R"; exit 1; }

# ── 0. Comprobaciones ───────────────────────────────────────────────
step "Comprobaciones"
[ "$(id -u)" -eq 0 ] && die "Ejecuta el script como tu usuario normal, no como root (usará sudo cuando haga falta)."
grep -qi kali /etc/os-release || warn "No parece Kali Linux; se intentará igualmente (requiere Debian/apt)."
command -v apt-get >/dev/null || die "Se necesita apt-get."
sudo -n true 2>/dev/null || sudo -v || die "Se necesita sudo."
# Mantener sudo vivo durante la instalación
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
info "usuario: $USER · home: $HOME"

BACKUP="$HOME/.neon-grid-backup-$(date +%Y%m%d-%H%M%S)"
# put <ruta relativa a $HOME> <modo>  (contenido por stdin)
put() {
  local dst="$HOME/$1" mode="$2" tmp
  tmp=$(mktemp); cat > "$tmp"
  if [ -e "$dst" ] && ! cmp -s "$tmp" "$dst"; then
    mkdir -p "$BACKUP/$(dirname "$1")"; cp -a "$dst" "$BACKUP/$1"
  fi
  mkdir -p "$(dirname "$dst")"; mv "$tmp" "$dst"; chmod "$mode" "$dst"
}

# ── 1. Paquetes ─────────────────────────────────────────────────────
PKGS=(bspwm sxhkd picom polybar rofi feh kitty dunst imagemagick lxappearance
      xorg xinit network-manager-gnome pavucontrol xclip xdotool jq curl git unzip
      mesa-utils fonts-jetbrains-mono fontconfig
      zsh zsh-autosuggestions zsh-syntax-highlighting
      tmux btop ripgrep fzf bat eza neovim flameshot net-tools nmap seclists
      pandoc weasyprint)
if [ "$DO_PKGS" = 1 ]; then
  step "Paquetes"
  MISSING=()
  for p in "${PKGS[@]}"; do
    dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "ok installed" || MISSING+=("$p")
  done
  if [ ${#MISSING[@]} -gt 0 ]; then
    info "instalando: ${MISSING[*]}"
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${MISSING[@]}" >/dev/null
  else
    info "todo instalado ya"
  fi
  [ -e /usr/local/bin/bat ] || { command -v batcat >/dev/null && sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat; }
fi

# ── 2. Fuente JetBrainsMono Nerd Font ───────────────────────────────
step "JetBrainsMono Nerd Font"
if [ "$(fc-list : family 2>/dev/null | grep -ci "JetBrainsMono Nerd Font")" -gt 0 ]; then
  info "ya instalada"
else
  T=$(mktemp -d)
  curl -fsSL -o "$T/jb.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNF"
  unzip -oq "$T/jb.zip" '*.ttf' -d "$HOME/.local/share/fonts/JetBrainsMonoNF"
  rm -rf "$T"; fc-cache -f >/dev/null
  info "instalada en ~/.local/share/fonts/JetBrainsMonoNF"
fi

# ── 3. powerlevel10k ────────────────────────────────────────────────
step "powerlevel10k"
if [ -d "$HOME/.powerlevel10k" ]; then info "ya presente"
else git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k"; info "clonado en ~/.powerlevel10k"; fi

# ── 4. Ficheros de configuración ────────────────────────────────────
step "Configuraciones"
put ".config/bspwm/bspwmrc" 755 <<'NEONGRID_EOF'
#!/bin/sh
# ── bspwmrc · tema NEON//GRID (cyberpunk verde) ──

# Entorno (rofi-theme-selector necesita XDG_DATA_DIRS)
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CURRENT_DESKTOP=bspwm

# ── Detección de GPU (se evalúa en cada inicio de sesión) ──
#  · OpenGL >= 3.3 por hardware      -> picom completo (glx + blur + sombras)
#  · Solo render por software        -> picom ligero (xrender, sin blur)
#  · GPU con OpenGL < 3.3 (VMware 3D antiguo) -> picom ligero + kitty por software
PICOM_CONF="$HOME/.config/picom/picom-lite.conf"
if command -v glxinfo >/dev/null 2>&1; then
  GLINFO=$(env -u LIBGL_ALWAYS_SOFTWARE glxinfo -B 2>/dev/null)
  GLREN=$(printf '%s\n' "$GLINFO" | sed -n 's/^OpenGL renderer string: //p')
  GLVER=$(printf '%s\n' "$GLINFO" | sed -n 's/^ *Max core profile version: //p')
  case "$GLREN" in
    *llvmpipe*|*softpipe*|"") : ;;
    *) if [ "$(printf '%s\n3.3\n' "${GLVER:-0.0}" | sort -V | head -1)" = "3.3" ]; then
         PICOM_CONF="$HOME/.config/picom/picom.conf"
       else
         export LIBGL_ALWAYS_SOFTWARE=1
       fi ;;
  esac
fi

# Monitor / escritorios
bspc monitor -d 1 2 3 4 5 6 7 8 9 10

# Geometría
bspc config border_width          2
bspc config window_gap            12
bspc config top_padding           0
bspc config split_ratio           0.52
bspc config borderless_monocle    true
bspc config gapless_monocle       false
bspc config single_monocle        false
bspc config focus_follows_pointer true

# Colores de borde
bspc config normal_border_color   "#1f7a4d"
bspc config active_border_color   "#00ff9c"
bspc config focused_border_color  "#b8ffdf"
bspc config presel_feedback_color "#39ff14"

# Ratón: Super + clic izq = mover/intercambiar, Super + clic der = redimensionar
bspc config pointer_modifier mod4
bspc config pointer_action1  move
bspc config pointer_action3  resize_corner

# Reglas
bspc rule -a Pavucontrol state=floating
bspc rule -a Lxappearance state=floating
bspc rule -a flameshot state=floating
bspc rule -a Nm-connection-editor state=floating

# ── Autostart (sin duplicados al recargar) ──
pgrep -x sxhkd   >/dev/null || sxhkd &
pgrep -x picom   >/dev/null || picom --config "$PICOM_CONF" &
pgrep -x dunst   >/dev/null || dunst &
pgrep -x nm-applet >/dev/null || nm-applet &
"$HOME/.fehbg" 2>/dev/null || feh --no-fehbg --bg-fill "$HOME/.config/wallpapers/neon-grid.png" &
"$HOME/.config/polybar/launch.sh" &
# kitty precargado (oculto): la primera terminal con Super+Return abre al instante
pgrep -f "kitty --single-instance --start-as=hidden" >/dev/null || kitty --single-instance --start-as=hidden &
NEONGRID_EOF
put ".config/sxhkd/sxhkdrc" 644 <<'NEONGRID_EOF'
# ── sxhkdrc · NEON//GRID ──

# Terminal
super + Return
	kitty --single-instance

# Lanzador de aplicaciones
super + d
	rofi -show drun

# Cambiar de ventana / ejecutar comando
super + shift + d
	rofi -show window

# Cerrar ventana
super + w
	bspc node -c

# Recargar sxhkd + bspwm
super + alt + r
	pkill -USR1 -x sxhkd; bspc wm -r

# Salir de bspwm
super + alt + q
	bspc quit

# Ir a escritorio / mover ventana a escritorio
super + {_,shift + }{1-9,0}
	bspc {desktop -f,node -d} '^{1-9,10}'

# Mover foco / mover ventana (intercambia)
super + {_,shift + }{Left,Down,Up,Right}
	bspc node -{f,s} {west,south,north,east}

# ── Redimensionar con teclado ──
# Super + Alt + → / ← : más ancha / más estrecha
# Super + Alt + ↑ / ↓ : más alta / más baja
# (si un lado toca el borde de la pantalla, usa el lado contrario)
super + alt + Right
	bspc node -z right 40 0 || bspc node -z left -40 0

super + alt + Left
	bspc node -z right -40 0 || bspc node -z left 40 0

super + alt + Up
	bspc node -z top 0 -40 || bspc node -z bottom 0 40

super + alt + Down
	bspc node -z top 0 40 || bspc node -z bottom 0 -40

# ── Modos de ventana ──
# Fullscreen real (tapa la barra)
super + f
	bspc node -t ~fullscreen

# Monóculo (alterna layout tiled/monocle, respeta la barra)
super + m
	bspc desktop -l next

# Flotante
super + s
	bspc node -t floating

# Tiled
super + t
	bspc node -t tiled

# Captura de pantalla
Print
	flameshot gui

# Menú power
super + alt + p
	~/.config/polybar/scripts/powermenu.sh

# Volumen (teclas multimedia)
XF86Audio{RaiseVolume,LowerVolume,Mute}
	pactl {set-sink-volume @DEFAULT_SINK@ +5%,set-sink-volume @DEFAULT_SINK@ -5%,set-sink-mute @DEFAULT_SINK@ toggle}
NEONGRID_EOF
put ".config/polybar/config.ini" 644 <<'NEONGRID_EOF'
;  ███ NEON//GRID · polybar ███
[colors]
bg        = #e60a0e0a
bg-alt    = #0d1a12
fg        = #39ff14
accent    = #00ff9c
dim       = #1f7a4d
alert     = #ffb000
dark-alert= #0f5132

[bar/neon]
width = 100%
height = 28
offset-y = 0
background = ${colors.bg}
foreground = ${colors.fg}
line-size = 2
border-bottom-size = 1
border-bottom-color = ${colors.accent}
padding-left = 1
padding-right = 1
module-margin = 1
separator = "|"
separator-foreground = ${colors.dim}
font-0 = JetBrainsMono Nerd Font:style=Bold:size=10;3
font-1 = JetBrainsMono Nerd Font:size=13;3
modules-left = launcher bspwm xwindow
modules-center = brand
fixed-center = false
modules-right = vpnip target cpu memory temperature load network pulseaudio date tray powermenu
wm-restack = bspwm
enable-ipc = true
cursor-click = pointer

[module/launcher]
type = custom/text
format = "󰣇 "
format-foreground = ${colors.accent}
format-font = 2
click-left = rofi -show drun

[module/brand]
type = custom/text
format = "%{F#00ff9c}%{F-} ManelFernandezBaeza"
format-foreground = ${colors.fg}
click-left = xdg-open https://github.com/ManelFernandezBaeza &

[module/bspwm]
type = internal/bspwm
pin-workspaces = true
label-focused = %name%
label-focused-foreground = #0a0e0a
label-focused-background = ${colors.accent}
label-focused-padding = 1
label-occupied = %name%
label-occupied-foreground = ${colors.fg}
label-occupied-underline = ${colors.dim}
label-occupied-padding = 1
label-urgent = %name%
label-urgent-foreground = #0a0e0a
label-urgent-background = ${colors.alert}
label-urgent-padding = 1
label-empty = %name%
label-empty-foreground = ${colors.dim}
label-empty-padding = 1

[module/xwindow]
type = internal/xwindow
label = "%{F#00ff9c}󰖯 %{F#1f7a4d}WIN%{F-} %title%"
label-foreground = ${colors.accent}
; ancho fijo (72 = ~45 visibles + 27 de códigos de color), alineado a la izquierda: el nombre central no se mueve
label-minlen = 72
label-maxlen = 72
label-alignment = left
label-ellipsis = true
label-empty = "%{F#00ff9c}󰖯 %{F#1f7a4d}WIN%{F-} ~"
label-empty-foreground = ${colors.dim}
label-empty-minlen = 72
label-empty-alignment = left
[module/date]
type = internal/date
interval = 1
date = %a %d %b
time = %H:%M:%S
label = "%{F#00ff9c}󰥔%{F-} %date%  %time%"
label-foreground = ${colors.accent}

[module/vpnip]
type = custom/script
exec = ~/.config/polybar/scripts/vpnip.sh
interval = 5
format-foreground = ${colors.accent}
format-underline = ${colors.accent}

[module/target]
type = custom/script
exec = ~/.config/polybar/scripts/target.sh
interval = 2
format-foreground = ${colors.fg}
format-underline = ${colors.fg}
click-left = ~/.config/polybar/scripts/target.sh copy

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "%{F#00ff9c}󰻠 %{F#1f7a4d}CPU%{F-} "
label = %percentage:2%%
warn-percentage = 85
format-warn-prefix = "%{F#00ff9c}󰻠 %{F#1f7a4d}CPU%{F-} "
label-warn = %percentage:2%%
label-warn-foreground = ${colors.alert}

[module/memory]
type = internal/memory
interval = 3
format-prefix = "%{F#00ff9c}󰍛 %{F#1f7a4d}RAM%{F-} "
label = %percentage_used:2%%
warn-percentage = 90
format-warn-prefix = "%{F#00ff9c}󰍛 %{F#1f7a4d}RAM%{F-} "
label-warn = %percentage_used:2%%
label-warn-foreground = ${colors.alert}

[module/temperature]
type = custom/script
exec = ~/.config/polybar/scripts/temp.sh
interval = 5
format-prefix = "%{F#00ff9c}󰔏 %{F#1f7a4d}TEMP%{F-} "

[module/load]
type = custom/script
exec = cut -d' ' -f1-3 /proc/loadavg
interval = 5
format-prefix = "%{F#00ff9c}󰊚 %{F#1f7a4d}LOAD%{F-} "

[module/network]
type = internal/network
interface-type = wired
interval = 2
format-connected = <label-connected>
label-connected = "%{F#00ff9c}󰛳 %{F#1f7a4d}NET%{F-} %{F#00ff9c}󰁅%{F-}%downspeed:8% %{F#00ff9c}󰁝%{F-}%upspeed:8%"
label-connected-foreground = ${colors.fg}
format-disconnected = <label-disconnected>
label-disconnected = "󰈂 %{F#1f7a4d}NET%{F-} offline"
label-disconnected-foreground = ${colors.dim}

[module/pulseaudio]
type = internal/pulseaudio
use-ui-max = false
format-volume = <ramp-volume> <label-volume>
format-volume-prefix = ""
label-volume = "%{F#1f7a4d}VOL%{F-} %percentage%%"
ramp-volume-0 = 󰕿
ramp-volume-1 = 󰖀
ramp-volume-2 = 󰕾
ramp-volume-foreground = ${colors.accent}
label-muted = "󰝟 VOL mute"
label-muted-foreground = ${colors.dim}
click-right = pavucontrol

[module/powermenu]
type = custom/text
format = "⏻"
format-foreground = ${colors.alert}
format-font = 2
click-left = ~/.config/polybar/scripts/powermenu.sh

[module/tray]
type = internal/tray
tray-background = ${colors.bg}
tray-spacing = 6px
tray-size = 60%

[settings]
screenchange-reload = true
pseudo-transparency = false
NEONGRID_EOF
put ".config/polybar/launch.sh" 755 <<'NEONGRID_EOF'
#!/usr/bin/env bash
# Mata instancias previas y relanza polybar
polybar-msg cmd quit >/dev/null 2>&1
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done
for m in $(polybar --list-monitors 2>/dev/null | cut -d: -f1); do
  MONITOR=$m polybar --reload neon >/tmp/polybar-$m.log 2>&1 &
done
pgrep -u "$UID" -x polybar >/dev/null || polybar --reload neon >/tmp/polybar.log 2>&1 &
disown -a
NEONGRID_EOF
put ".config/polybar/scripts/vpnip.sh" 755 <<'NEONGRID_EOF'
#!/usr/bin/env bash
# IP de tun0 (VPN) o, en su defecto, de la interfaz principal
ip4() { ip -4 -o addr show dev "$1" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1; }
vpn=$(ip4 tun0)
if [ -n "$vpn" ]; then
  echo "󰌾 %{F#1f7a4d}VPN%{F-} $vpn"
else
  iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
  lan=$(ip4 "$iface")
  echo "󰈀 %{F#1f7a4d}LAN%{F-} ${lan:-sin red}"
fi
NEONGRID_EOF
put ".config/polybar/scripts/target.sh" 755 <<'NEONGRID_EOF'
#!/usr/bin/env bash
# Muestra la IP objetivo guardada en ~/.config/polybar/target
f="$HOME/.config/polybar/target"
t=$(head -1 "$f" 2>/dev/null | tr -d '[:space:]')
if [ "$1" = copy ] && [ -n "$t" ]; then printf %s "$t" | xclip -sel clip; exit; fi
if [ -n "$t" ]; then echo "󰓾 %{F#1f7a4d}TARGET%{F-} $t"; else echo "󰓾 %{F#1f7a4d}TARGET%{F-} none"; fi
NEONGRID_EOF
put ".config/polybar/scripts/temp.sh" 755 <<'NEONGRID_EOF'
#!/usr/bin/env bash
# Temperatura de CPU (hwmon / thermal_zone); N/A en VMs sin sensores
for f in /sys/class/hwmon/hwmon*/temp1_input /sys/class/thermal/thermal_zone*/temp; do
  [ -r "$f" ] && { echo "$(( $(cat "$f") / 1000 ))°C"; exit; }
done
echo "N/A"
NEONGRID_EOF
put ".config/polybar/scripts/powermenu.sh" 755 <<'NEONGRID_EOF'
#!/usr/bin/env bash
# Menú power con rofi
ops="󰌾  bloquear\n󰍃  salir de bspwm\n󰜉  reiniciar\n󰐥  apagar"
sel=$(printf "$ops" | rofi -dmenu -i -p "power" -theme-str 'window {width: 300px;} listview {lines: 4;}')
case "$sel" in
  *bloquear*) loginctl lock-session ;;
  *salir*)    bspc quit ;;
  *reiniciar*) systemctl reboot ;;
  *apagar*)   systemctl poweroff ;;
esac
NEONGRID_EOF
put ".config/picom/picom.conf" 644 <<'NEONGRID_EOF'
# ── picom · NEON//GRID (con aceleración 3D: OpenGL >= 3.3 por hardware) ──
# bspwmrc usa picom-lite.conf automáticamente si no hay OpenGL >= 3.3 por hardware.
backend = "glx";
vsync = true;
use-damage = false;   # repintado completo: evita zonas sin dibujar en VMware

# Sombras: glow verde discreto
shadow = true;
shadow-radius = 16;
shadow-opacity = 0.45;
shadow-offset-x = -14;
shadow-offset-y = -14;
shadow-color = "#00ff9c";

# Fading rápido (las ventanas nuevas aparecen sin retraso perceptible)
fading = true;
fade-in-step = 0.1;
fade-out-step = 0.1;
fade-delta = 5;

# Esquinas
corner-radius = 6;

# Blur detrás de ventanas translúcidas
blur-method = "dual_kawase";
blur-strength = 4;
blur-background = true;
blur-background-frame = true;

rules = (
  # Foco: las ventanas sin foco se oscurecen; la activa queda a plena intensidad
  { match = "!focused && window_type = 'normal'"; dim = 0.35; },
  { match = "window_type = 'dock' || window_type = 'desktop'"; shadow = false; blur-background = false; corner-radius = 0; },
  { match = "window_type = 'tooltip' || window_type = 'popup_menu' || window_type = 'dropdown_menu' || window_type = 'notification'"; shadow = false; opacity = 0.95; },
  { match = "class_g = 'flameshot' || class_g = 'Polybar'"; shadow = false; blur-background = false; },
  { match = "fullscreen"; corner-radius = 0; },
);
NEONGRID_EOF
put ".config/picom/picom-lite.conf" 644 <<'NEONGRID_EOF'
# ── picom-lite · NEON//GRID (sin aceleración 3D: render por CPU) ──
# Lo usa bspwmrc automáticamente cuando no hay OpenGL >= 3.3 por hardware.
backend = "xrender";
vsync = true;
use-damage = false;   # repintado completo: evita zonas sin dibujar en VMs

shadow = true;
shadow-radius = 8;
shadow-opacity = 0.45;
shadow-offset-x = -8;
shadow-offset-y = -8;
shadow-color = "#00ff9c";

fading = true;
fade-in-step = 0.1;
fade-out-step = 0.1;
fade-delta = 5;

corner-radius = 6;

rules = (
  # Foco: las ventanas sin foco se oscurecen; la activa queda a plena intensidad
  { match = "!focused && window_type = 'normal'"; dim = 0.35; },
  { match = "window_type = 'dock' || window_type = 'desktop'"; shadow = false; corner-radius = 0; },
  { match = "window_type = 'tooltip' || window_type = 'popup_menu' || window_type = 'dropdown_menu' || window_type = 'notification'"; shadow = false; opacity = 0.95; },
  { match = "class_g = 'flameshot' || class_g = 'Polybar'"; shadow = false; },
  { match = "fullscreen"; corner-radius = 0; },
);
NEONGRID_EOF
put ".config/rofi/config.rasi" 644 <<'NEONGRID_EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    drun-display-format: "{name}";
    display-drun: "󰣇 apps";
    display-run: " run";
    display-window: "󰖯 win";
    terminal: "kitty --single-instance";
}
@theme "neon-grid"
NEONGRID_EOF
put ".config/rofi/themes/neon-grid.rasi" 644 <<'NEONGRID_EOF'
/* NEON//GRID · tema rofi propio (cyberpunk verde) */
* {
    bg:       #0a0e0ae6;
    bg-alt:   #0f1a12;
    fg:       #39ff14;
    accent:   #00ff9c;
    dim:      #1f7a4d;
    alert:    #ffb000;
    background-color: transparent;
    text-color: @fg;
    font: "JetBrainsMono Nerd Font Bold 11";
}
window {
    width: 640px;
    background-color: @bg;
    border: 2px;
    border-color: @accent;
    border-radius: 6px;
    padding: 0;
}
mainbox { padding: 14px; spacing: 10px; children: [ inputbar, message, listview, mode-switcher ]; }
inputbar {
    children: [ prompt, textbox-prompt-sep, entry ];
    background-color: @bg-alt;
    border: 0 0 2px 0;
    border-color: @dim;
    padding: 8px 10px;
}
prompt { text-color: @accent; }
textbox-prompt-sep { expand: false; str: " ▸ "; text-color: @dim; }
entry { placeholder: "buscar..."; placeholder-color: @dim; cursor: text; }
message { border: 1px; border-color: @dim; padding: 6px; }
listview { lines: 8; columns: 1; spacing: 3px; scrollbar: true; fixed-height: true; }
scrollbar { handle-color: @accent; handle-width: 3px; background-color: @bg-alt; }
element { padding: 6px 10px; border-radius: 3px; spacing: 10px; }
element normal.normal, element alternate.normal { text-color: @fg; }
element normal.active, element alternate.active { text-color: @accent; }
element normal.urgent, element alternate.urgent { text-color: @alert; }
element selected.normal, element selected.active {
    background-color: @accent;
    text-color: #0a0e0a;
}
element selected.urgent { background-color: @alert; text-color: #0a0e0a; }
element-icon { size: 1.2em; }
element-text { text-color: inherit; highlight: bold underline; }
mode-switcher { spacing: 6px; }
button { padding: 4px; text-color: @dim; border: 0 0 2px 0; border-color: @dim; }
button selected { text-color: @accent; border-color: @accent; }
NEONGRID_EOF
put ".config/rofi/themes/neon-grid-terminal.rasi" 644 <<'NEONGRID_EOF'
/* NEON//GRID-TERMINAL · variante compacta, fondo opaco, estilo consola */
@import "neon-grid"
* { bg: #0d0d0dff; font: "JetBrainsMono Nerd Font 10"; }
window { width: 520px; border: 1px; border-radius: 0; location: north; y-offset: 40px; }
inputbar { border: 0; }
prompt { str: ">_"; }
element selected.normal, element selected.active { background-color: transparent; text-color: @accent; border: 0 0 0 3px; border-color: @fg; }
NEONGRID_EOF
put ".config/kitty/kitty.conf" 644 <<'NEONGRID_EOF'
# ── kitty · NEON//GRID ──
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
font_size        11.0
window_padding_width 8
background_opacity 0.90
confirm_os_window_close 0
enable_audio_bell no
cursor_shape     block
cursor_blink_interval 0.6
scrollback_lines 10000
tab_bar_style    powerline
url_style        curly

foreground            #b8ffdf
background            #0a0e0a
selection_foreground  #0a0e0a
selection_background  #00ff9c
cursor                #00ff9c
cursor_text_color     #0a0e0a
url_color             #39ff14
active_border_color   #00ff9c
inactive_border_color #1f7a4d
active_tab_foreground   #0a0e0a
active_tab_background   #00ff9c
inactive_tab_foreground #1f7a4d
inactive_tab_background #0d0d0d

# Paleta ANSI (verdes + ámbar para alertas)
color0  #0d0d0d
color8  #1f7a4d
color1  #ff5f5f
color9  #ff8c69
color2  #00ff9c
color10 #39ff14
color3  #ffb000
color11 #ffd166
color4  #1fb58f
color12 #5cffc8
color5  #7dff7a
color13 #b6ff9e
color6  #00d9a3
color14 #8affd6
color7  #a8e6c8
color15 #e8fff3
NEONGRID_EOF
put ".config/dunst/dunstrc" 644 <<'NEONGRID_EOF'
[global]
    font = JetBrainsMono Nerd Font 10
    width = 340
    offset = (14, 42)
    origin = top-right
    frame_width = 2
    frame_color = "#00ff9c"
    separator_color = frame
    corner_radius = 4
    padding = 10
    horizontal_padding = 12
    format = "<b>%s</b>\n%b"
[urgency_low]
    background = "#0a0e0a"
    foreground = "#1f7a4d"
    frame_color = "#1f7a4d"
    timeout = 4
[urgency_normal]
    background = "#0a0e0a"
    foreground = "#39ff14"
    timeout = 6
[urgency_critical]
    background = "#0a0e0a"
    foreground = "#ffb000"
    frame_color = "#ffb000"
    timeout = 0
NEONGRID_EOF
put ".config/wallpapers/src/neon-grid.py" 755 <<'NEONGRID_EOF'
#!/usr/bin/env python3
"""Genera el wallpaper NEON//GRID (procedural, original) usando ImageMagick."""
import random, subprocess, os, sys
W, H = 2560, 1440
HY = int(H * 0.58)            # horizonte
VX = W // 2                   # punto de fuga
random.seed(int(sys.argv[1]) if len(sys.argv) > 1 else 1337)
out = os.path.expanduser("~/.config/wallpapers/neon-grid.png")
tmp = os.path.dirname(os.path.abspath(__file__))

grid = ["stroke-antialias 1", "fill none"]
sun = []
# Líneas de fuga
for i in range(-40, 41):
    x = VX + i * 110
    a = max(0.15, 0.9 - abs(i) * 0.03)
    grid += [f"stroke rgba(0,255,156,{a:.2f})", "stroke-width 2", f"line {VX},{HY} {x},{H}"]
# Líneas horizontales (espaciado cuadrático = perspectiva)
for k in range(1, 26):
    y = HY + int((k / 25) ** 2.2 * (H - HY))
    a = 0.15 + 0.75 * (k / 25)
    grid += [f"stroke rgba(57,255,20,{a:.2f})", "stroke-width 2", f"line 0,{y} {W},{y}"]
# Línea de horizonte
grid += ["stroke #b8ffdf", "stroke-width 3", f"line 0,{HY} {W},{HY}"]
# Anillo / "sol" segmentado sobre el horizonte
R = 300; cy = HY - 120
sun += ["stroke #00ff9c", "stroke-width 4", f"circle {VX},{cy} {VX+R},{cy}"]
sun += ["stroke rgba(0,255,156,0.5)", "stroke-width 2", f"circle {VX},{cy} {VX+R+30},{cy}"]
for j in range(9):
    y = cy - R + 40 + j * 28 + j * j * 2
    if y >= HY: break
    import math
    dx = int(math.sqrt(max(R*R - (y-cy)**2, 0)))
    sun += ["stroke rgba(0,255,156,0.7)", f"stroke-width {2 + j//3}", f"line {VX-dx},{y} {VX+dx},{y}"]
grid = ["stroke-antialias 1", "fill none"] + sun + ["stroke none", "fill #070a07", f"rectangle 0,{HY} {W},{H}", "fill none"] + grid[2:]
# Brackets HUD en esquinas
for (x, y, sx, sy) in [(80,80,1,1),(W-80,80,-1,1),(80,H-80,1,-1),(W-80,H-80,-1,-1)]:
    grid += ["stroke #00ff9c", "stroke-width 3", f"polyline {x+sx*120},{y} {x},{y} {x},{y+sy*120}"]

# Columnas de "datos" en verde apagado (cielo)
data = ["font-size 18", "fill rgba(31,122,77,0.55)"]
for _ in range(70):
    x = random.randint(40, W - 40); y = random.randint(40, HY - 240)
    s = "".join(random.choice("0123456789ABCDEF") for _ in range(random.randint(4, 10)))
    for n, ch in enumerate(s):
        data.append(f"text {x},{y + n*20} '{ch}'")
data += ["font-size 26", "fill #00ff9c", f"text 110,{H-110} 'NEON//GRID'",
         "font-size 16", "fill #1f7a4d", f"text 110,{H-82} 'kali://bspwm  ::  sys.online  ::  trace.active'",
         f"text {W-470},130 'LAT 00.0000  LON 00.0000  //  NODE-0x9C'"]

font = subprocess.run(["fc-match", "-f", "%{file}", "JetBrainsMono Nerd Font:style=Bold"], capture_output=True, text=True).stdout
m = "magick" if subprocess.run(["which", "magick"], capture_output=True).returncode == 0 else "convert"
cmd = [m,
  # Fondo: gradiente radial verde muy oscuro
  "-size", f"{W}x{H}", "radial-gradient:#0f2a1a-#0a0e0a", "-gravity", "north", "-extent", f"{W}x{H}", "+gravity",
  # Capa glow
  "(", "-size", f"{W}x{H}", "xc:none", "-draw", " ".join(grid), "-blur", "0x14", ")", "-compose", "screen", "-composite",
  # Capa nítida
  "(", "-size", f"{W}x{H}", "xc:none", "-draw", " ".join(grid), ")", "-compose", "over", "-composite",
  # Datos
  "(", "-size", f"{W}x{H}", "xc:none", "-font", font, "-draw", " ".join(data), ")", "-compose", "over", "-composite",
  # Scanlines
  "(", "-size", "1x3", "xc:none", "-fill", "rgba(0,0,0,0.35)", "-draw", "point 0,2", "-write", "mpr:sl", "+delete",
       "-size", f"{W}x{H}", "tile:mpr:sl", ")", "-compose", "over", "-composite",
  # Viñeta
  "(", "-size", f"{W}x{H}", "radial-gradient:white-black", "-level", "0%,65%", "-negate",
       "-background", "black", "-alpha", "copy", "-channel", "A", "-evaluate", "multiply", "0.75", "+channel", "-fill", "black", "-colorize", "100", ")",
  "-compose", "over", "-composite",
  out]
subprocess.run(cmd, check=True)
print(out)
NEONGRID_EOF
put ".config/neon-grid/functions.sh" 644 <<'NEONGRID_EOF'
# ── NEON//GRID · funciones de pentesting (bash + zsh) ──
_NG_TARGET="$HOME/.config/polybar/target"

settarget() {
  [ -z "$1" ] && { echo "uso: settarget <IP>"; return 1; }
  printf '%s\n' "$1" > "$_NG_TARGET"
  "$HOME/.config/polybar/launch.sh" >/dev/null 2>&1
  echo "[+] target -> $1"
}

cleartarget() {
  : > "$_NG_TARGET"
  "$HOME/.config/polybar/launch.sh" >/dev/null 2>&1
  echo "[+] target borrado"
}

gettarget() {
  local t; t=$(head -1 "$_NG_TARGET" 2>/dev/null | tr -d '[:space:]')
  [ -z "$t" ] && { echo "[-] no hay target"; return 1; }
  echo "$t"
  printf '%s' "$t" | xclip -sel clip 2>/dev/null && echo "[+] copiado al portapapeles"
}

mkt() {
  mkdir -p nmap content exploits scripts && echo "[+] creadas: nmap content exploits scripts"
}

extractPorts() {
  [ -r "$1" ] || { echo "uso: extractPorts <salida_nmap>"; return 1; }
  local ip ports
  # Admite formato grepeable (-oG) y normal (-oN)
  ports=$( { grep -oE '[0-9]{1,5}/open' "$1"; grep -oE '^[0-9]{1,5}/(tcp|udp)[[:space:]]+open' "$1"; } \
           | cut -d/ -f1 | sort -un | paste -sd, -)
  ip=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$1" | grep -v '^0\.' | head -1)
  [ -z "$ports" ] && { echo "[-] no se encontraron puertos abiertos"; return 1; }
  echo "[*] IP:     ${ip:-?}"
  echo "[*] Puertos: $ports"
  printf '%s' "$ports" | xclip -sel clip 2>/dev/null && echo "[+] puertos copiados al portapapeles"
}

# Alias QoL
alias cat='bat --paging=never --style=plain'
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias tree='eza --tree --icons'
alias vim='nvim'
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
NEONGRID_EOF
put ".config/neon-grid/doc/guia-entorno.md" 644 <<'NEONGRID_EOF'
---
title: Guía del entorno NEON//GRID
lang: es
---

# NEON//GRID · Guía del entorno bspwm

Escritorio tiling **bspwm** con tema cyberpunk verde propio para Kali Linux.
Paleta: fondo `#0a0e0a` · neón `#00ff9c` · acento `#39ff14` · secundario `#1f7a4d` · alerta `#ffb000`.
Fuente: **JetBrainsMono Nerd Font**.

## 1. Entrar en la sesión bspwm

- **Desde LightDM (recomendado):** cierra sesión. En la pantalla de login, el selector de sesión
  (icono arriba a la derecha) ya tiene **bspwm** como sesión por defecto del usuario `kali`.
  XFCE sigue disponible en el mismo menú.
- **Desde una TTY (sin gestor gráfico):** `Ctrl+Alt+F3`, inicia sesión y ejecuta `startx`
  (usa `~/.xinitrc`, que hace `exec bspwm`).
- Al arrancar, `bspwmrc` detecta la GPU y lanza sxhkd, picom, dunst, nm-applet, el wallpaper,
  polybar y un **kitty oculto precargado**. Todo comprueba si ya está en marcha, así que recargar
  no duplica procesos.

> **Modificador:** todas las combinaciones usan **Super** (tecla Windows).

## 2. Atajos de teclado (sxhkd)

### Básicos

| Atajo | Acción |
|---|---|
| `Super + Return` | Abrir terminal (kitty, instancia única precargada: abre al instante) |
| `Super + d` | Lanzador de aplicaciones (rofi drun) |
| `Super + Shift + d` | Lista de ventanas abiertas (rofi window) |
| `Super + w` | Cerrar la ventana enfocada |
| `Super + Alt + r` | Recargar bspwm + sxhkd |
| `Super + Alt + q` | Salir de bspwm |
| `Super + Alt + p` | Menú power (bloquear / salir / reiniciar / apagar) |
| `Print` | Captura de pantalla con `flameshot gui` |
| `XF86Audio±/Mute` | Subir / bajar / silenciar volumen |

### Escritorios y foco

| Atajo | Acción |
|---|---|
| `Super + 1…9, 0` | Ir al escritorio 1…10 |
| `Super + Shift + 1…9, 0` | Mover la ventana al escritorio 1…10 |
| `Super + ←/↓/↑/→` | Mover el foco en esa dirección |
| `Super + Shift + ←/↓/↑/→` | Mover (intercambiar) la ventana en esa dirección |

### Redimensionar con teclado

| Atajo | Acción |
|---|---|
| `Super + Alt + →` | Ventana más ancha |
| `Super + Alt + ←` | Ventana más estrecha |
| `Super + Alt + ↑` | Ventana más alta |
| `Super + Alt + ↓` | Ventana más baja |

Cada pulsación son 40 px (mantén pulsado para repetir). Si un lado toca el borde de la pantalla,
crece o encoge por el lado contrario. En mosaico se mueve la división con la ventana vecina,
así que solo cambia en la dirección donde haya otra ventana; en flotante funcionan las cuatro flechas.

### Modos de ventana

| Atajo | Modo | Detalle |
|---|---|---|
| `Super + f` | **Fullscreen real** | `bspc node -t ~fullscreen`: tapa la polybar. Pulsa otra vez para volver. |
| `Super + m` | **Monóculo** | `bspc desktop -l next`: la ventana ocupa todo el área útil **sin** tapar la barra. Repite para volver a tiled. |
| `Super + s` | **Flotante** | `bspc node -t floating` |
| `Super + t` | **Tiled** | `bspc node -t tiled`: devuelve una ventana flotante al mosaico |
| `Super + clic izq. + arrastrar` | Mover | Mueve una ventana flotante; en mosaico la **intercambia** con la ventana donde la sueltes |
| `Super + clic der. + arrastrar` | Redimensionar | Redimensiona desde la esquina más cercana |
| `Super + rueda (clic) + arrastrar` | Redimensionar | Redimensiona desde el lado más cercano |

## 3. Rofi y el selector de temas

- `Super + d` abre el lanzador. Escribe para filtrar, `Enter` para lanzar y `Shift+←/→`
  (o un clic en la pestaña inferior) para cambiar entre **apps**, **run** y **win**.
- Desde terminal: `rofi -show drun`, `rofi -show run` o `rofi -show window`.
- **Cambiar de tema al vuelo:** ejecuta `rofi-theme-selector`. Muévete con las flechas para
  previsualizar y pulsa `Alt+a` para aplicar y guardar (escribe `@theme` en `~/.config/rofi/config.rasi`).
- Temas propios incluidos (además de los del sistema):
  - **neon-grid** (predeterminado): ventana centrada, translúcida, selección rellena en neón.
  - **neon-grid-terminal**: variante compacta y opaca anclada arriba, estilo consola.
- Para volver al tema por defecto: pon `@theme "neon-grid"` en la última línea de `config.rasi`.

## 4. Recargar componentes

| Componente | Cómo |
|---|---|
| bspwm + sxhkd | `Super + Alt + r` |
| Solo sxhkd | `pkill -USR1 -x sxhkd` |
| Polybar | `~/.config/polybar/launch.sh` (mata instancias y relanza) |
| Picom | `pkill picom` y `Super + Alt + r` (bspwmrc lo relanza con la config adecuada a tu GPU) |
| Dunst | `killall dunst; dunst &` |
| kitty | `Ctrl+Shift+F5` dentro de kitty |
| tmux | `prefix + r` (prefijo: `Ctrl+a`) |
| zsh | `source ~/.zshrc` |

## 5. Rendimiento y GPU (máquinas virtuales)

`bspwmrc` comprueba la GPU con `glxinfo` en cada inicio de sesión y elige automáticamente:

| OpenGL disponible | picom | kitty |
|---|---|---|
| ≥ 3.3 por hardware (3D activado y compatibilidad de hardware reciente) | `picom.conf`: glx + blur + sombras completas | GPU |
| Solo software (llvmpipe, VM sin 3D) | `picom-lite.conf`: xrender, sin blur | software |
| Hardware < 3.3 (VMware 3D con compatibilidad antigua) | `picom-lite.conf` | software forzado (`LIBGL_ALWAYS_SOFTWARE=1`) |

> **VMware:** para tener blur y la GPU real, apaga la VM, activa *Configuración → Pantalla → Acelerar gráficos 3D* y sube *VM → Administrar → Cambiar compatibilidad de hardware* a la versión más reciente. Comprueba con `glxinfo -B | grep -E "renderer|core profile"`.

Ajustes visuales: las ventanas sin foco se oscurecen (`dim = 0.35` en `rules` de picom; súbelo o bájalo a tu gusto). El cambio de foco no anima la opacidad, así que no parpadea.

## 6. Polybar

Cada elemento lleva icono y etiqueta fija (`CPU`, `RAM`, `TARGET`…), ordenados por grupos:

- **Izquierda (navegación):** lanzador · escritorios · `WIN` ventana activa (ancho fijo, recorta con `...`).
- **Centro:** icono de GitHub + **ManelFernandezBaeza** (clic = abre el perfil). Queda centrado en el hueco libre y no se mueve al cambiar de ventana.
- **Derecha:** `LAN`/`VPN` · `TARGET` │ `CPU` · `RAM` · `TEMP` · `LOAD` · `NET` │ `VOL` · fecha/hora · bandeja · power.

- **vpnip** (cada 5 s): IP de `tun0` con icono de candado si la VPN está levantada; si no, la IP de la interfaz de la ruta por defecto.
- **target** (cada 2 s): lee `~/.config/polybar/target`. Clic izquierdo = copiar la IP. Muestra `no target` si está vacío.
- **volumen**: clic derecho abre `pavucontrol`, rueda para subir/bajar, clic para silenciar.
- **temperatura**: muestra `N/A` en máquinas virtuales sin sensores.

## 7. Comandos propios (zsh y bash)

Definidos en `~/.config/neon-grid/functions.sh`, que cargan `~/.zshrc` y `~/.bashrc`.

| Comando | Qué hace |
|---|---|
| `settarget <IP>` | Guarda la IP en `~/.config/polybar/target` y recarga polybar |
| `cleartarget` | Vacía el fichero target y recarga polybar |
| `gettarget` | Imprime la IP objetivo y la copia al portapapeles (xclip) |
| `mkt` | Crea en el directorio actual: `nmap/ content/ exploits/ scripts/` |
| `extractPorts <fichero>` | Extrae los puertos abiertos de una salida de nmap (`-oG` o `-oN`), muestra IP y puertos y copia la lista `22,80,…` al portapapeles |

Flujo típico:

```
settarget 10.10.11.42
mkt && cd nmap
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn $(gettarget) -oG allPorts
extractPorts allPorts
nmap -sCV -p$(xclip -o -sel clip) $(gettarget) -oN targeted
```

Alias: `ls`/`ll`/`tree` → **eza** con iconos · `cat` → **bat** sin paginar · `vim` → **nvim**.

## 8. Wallpaper

El wallpaper **neon-grid.png** es original y está generado de forma procedural con ImageMagick:
suelo en perspectiva, horizonte, anillo segmentado, columnas de datos, glow, scanlines y viñeta.

- Regenerar (otra semilla = otras columnas de datos): `python3 ~/.config/wallpapers/src/neon-grid.py 42`
- **Cambiar de wallpaper:** `feh --bg-fill /ruta/imagen.png`. feh guarda el comando en `~/.fehbg`
  y bspwm lo reaplica en cada arranque.
- Volver al original: `feh --bg-fill ~/.config/wallpapers/neon-grid.png`

## 9. Rutas de todos los ficheros de configuración

| Fichero | Función |
|---|---|
| `~/.config/bspwm/bspwmrc` | bspwm: gaps, bordes, ratón, reglas, autostart |
| `~/.config/sxhkd/sxhkdrc` | Atajos de teclado |
| `~/.config/polybar/config.ini` | Barra y módulos |
| `~/.config/polybar/launch.sh` | Lanzador de polybar |
| `~/.config/polybar/scripts/vpnip.sh` | Módulo IP VPN/LAN |
| `~/.config/polybar/scripts/target.sh` | Módulo target |
| `~/.config/polybar/scripts/temp.sh` | Módulo temperatura |
| `~/.config/polybar/scripts/powermenu.sh` | Menú power (rofi) |
| `~/.config/polybar/target` | IP objetivo actual |
| `~/.config/picom/picom.conf` | Compositor con GPU: sombras, blur, fading, esquinas, dim |
| `~/.config/picom/picom-lite.conf` | Compositor sin GPU (xrender) |
| `~/.config/rofi/config.rasi` | Config de rofi y tema activo |
| `~/.config/rofi/themes/neon-grid*.rasi` | Temas propios (enlazados en `~/.local/share/rofi/themes`) |
| `~/.config/kitty/kitty.conf` | Terminal y paleta ANSI verde |
| `~/.config/dunst/dunstrc` | Notificaciones |
| `~/.config/wallpapers/neon-grid.png` | Wallpaper |
| `~/.config/wallpapers/src/neon-grid.py` | Generador del wallpaper |
| `~/.fehbg` | Último wallpaper aplicado |
| `~/.config/neon-grid/functions.sh` | Funciones y alias de pentesting |
| `~/.zshrc` / `~/.bashrc` | Shells (backups: `*.bak-pre-neongrid`) |
| `~/.p10k.zsh` | Prompt powerlevel10k verde |
| `~/.powerlevel10k/` | Tema powerlevel10k |
| `~/.tmux.conf` | tmux con tema verde (prefijo `Ctrl+a`) |
| `~/.xinitrc` | Arranque con `startx` |
| `~/.dmrc`, `/var/lib/AccountsService/users/kali` | Sesión por defecto = bspwm |
| `~/.local/share/fonts/JetBrainsMonoNF/` | JetBrainsMono Nerd Font |
| `~/.config/neon-grid/doc/` | Fuente de esta guía (Markdown + CSS) |

## 10. Herramientas instaladas

| Categoría | Paquetes |
|---|---|
| Escritorio | bspwm, sxhkd, polybar, picom, rofi, feh, kitty, dunst, lxappearance, network-manager-gnome (nm-applet), pavucontrol |
| Base X / utilidades | xorg, xinit, xclip, xdotool, jq, curl, imagemagick, mesa-utils (`glxinfo`) |
| Fuentes | fonts-jetbrains-mono, JetBrainsMono Nerd Font |
| Terminal / QoL | zsh + powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, tmux, btop, ripgrep (`rg`), fzf, bat, eza, neovim (`nvim`) |
| Pentesting / red | nmap, net-tools, seclists (`/usr/share/seclists`), flameshot |
| Documentación | pandoc + weasyprint (generan este PDF) |

### tmux (prefijo `Ctrl+a`)

`prefix |` divide en vertical · `prefix -` divide en horizontal · `prefix r` recarga · ratón activado.
La barra de estado muestra también el target actual.

### Regenerar esta guía

```
cd ~/.config/neon-grid/doc
pandoc guia-entorno.md -s --css guia.css --pdf-engine=weasyprint -o ~/guia-entorno.pdf
```

## 11. Replicar el entorno en otra Kali

El script `install-neon-grid.sh` lleva dentro todas las configuraciones de esta guía.
En una Kali recién instalada, como **usuario normal** (no root) y con conexión a Internet:

```
chmod +x install-neon-grid.sh
./install-neon-grid.sh
```

Opciones: `--no-pdf` (no genera esta guía), `--no-session` (no pone bspwm como sesión por defecto),
`--skip-packages` (no usa apt). Es idempotente: se puede relanzar sin duplicar nada.
Antes de sobrescribir, guarda tus configs previas en `~/.neon-grid-backup-<fecha>/`.
Al terminar, cierra sesión y entra en **bspwm**.
NEONGRID_EOF
put ".config/neon-grid/doc/guia.css" 644 <<'NEONGRID_EOF'
@page { size: A4; margin: 16mm 14mm; background: #0a0e0a;
  @bottom-right { content: "NEON//GRID · " counter(page); color: #1f7a4d; font: 8pt "JetBrainsMono Nerd Font"; } }
body { font-family: "JetBrainsMono Nerd Font", monospace; font-size: 8.6pt; color: #c8f5dc; background: #0a0e0a; line-height: 1.45; }
h1 { color: #00ff9c; font-size: 20pt; border-bottom: 2px solid #00ff9c; padding-bottom: 4px; margin-top: 0; }
h2 { color: #39ff14; font-size: 12.5pt; border-left: 4px solid #00ff9c; padding-left: 8px; margin-top: 18px; page-break-after: avoid; }
h3 { color: #00ff9c; font-size: 10pt; margin-bottom: 4px; page-break-after: avoid; }
a { color: #39ff14; }
code { color: #39ff14; background: #0f1a12; padding: 0 3px; border-radius: 2px; }
pre { background: #0f1a12; border: 1px solid #1f7a4d; border-left: 3px solid #00ff9c; padding: 6px 8px; white-space: pre-wrap; page-break-inside: avoid; }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 6px 0 10px; page-break-inside: avoid; }
th { background: #00ff9c; color: #0a0e0a; text-align: left; padding: 4px 6px; }
td { border-bottom: 1px solid #1f3a2a; padding: 3px 6px; vertical-align: top; }
tr:nth-child(even) td { background: #0d140f; }
blockquote { border-left: 3px solid #ffb000; color: #ffd166; margin: 8px 0; padding: 2px 10px; background: #14120a; }
strong { color: #00ff9c; }
header#title-block-header { display: none; }
NEONGRID_EOF
put ".p10k.zsh" 644 <<'NEONGRID_EOF'
# ── powerlevel10k · NEON//GRID (config propia, verde) ──
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'
() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs newline prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs vpn_ip time)
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{#1f7a4d}┌─'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{#1f7a4d}└─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=''

  # Estilo "lean" sin fondos: solo color de texto
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#00ff9c'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='#ffb000'
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#39ff14'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#1f7a4d'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#b8ffdf'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_VCS_FOREGROUND='#00d9a3'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#ffb000'

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#00ff9c'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#ffb000'

  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#ffb000'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#1f7a4d'
  typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND='#00ff9c'
  typeset -g POWERLEVEL9K_VPN_IP_INTERFACE='tun[0-9]+'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#1f7a4d'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  (( ! $+functions[p10k] )) || p10k reload
}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
NEONGRID_EOF
put ".tmux.conf" 644 <<'NEONGRID_EOF'
# ── tmux · NEON//GRID ──
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-kitty:RGB"
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g history-limit 50000
set -g escape-time 10
set -g renumber-windows on
unbind C-b
set -g prefix C-a
bind C-a send-prefix
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind r source-file ~/.tmux.conf \; display "tmux recargado"
setw -g mode-keys vi

# Colores
set -g status-position bottom
set -g status-style "bg=#0a0e0a,fg=#39ff14"
set -g status-left-length 40
set -g status-left "#[bg=#00ff9c,fg=#0a0e0a,bold] 󰆍 #S #[bg=#0a0e0a,fg=#1f7a4d] :: "
set -g status-right "#[fg=#1f7a4d]#(cat ~/.config/polybar/target 2>/dev/null | head -1 | sed 's/^/󰓾 /') :: #[fg=#00ff9c]%H:%M #[bg=#00ff9c,fg=#0a0e0a,bold] #H "
set -g status-right-length 80
setw -g window-status-format "#[fg=#1f7a4d] #I:#W "
setw -g window-status-current-format "#[fg=#00ff9c,bold,underscore] #I:#W "
set -g pane-border-style "fg=#1f7a4d"
set -g pane-active-border-style "fg=#00ff9c"
set -g message-style "bg=#0a0e0a,fg=#00ff9c"
set -g mode-style "bg=#00ff9c,fg=#0a0e0a"
setw -g clock-mode-colour "#00ff9c"
NEONGRID_EOF
put ".xinitrc" 755 <<'NEONGRID_EOF'
#!/bin/sh
# startx -> bspwm (NEON//GRID)
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
xsetroot -cursor_name left_ptr
exec bspwm
NEONGRID_EOF
put ".fehbg" 755 <<'NEONGRID_EOF'
#!/bin/sh
feh --no-fehbg --bg-fill "$HOME/.config/wallpapers/neon-grid.png"
NEONGRID_EOF
info "configs escritas"
[ -d "$BACKUP" ] && info "configs anteriores guardadas en $BACKUP"

# Fichero de target vacío (sin pisar uno existente)
[ -e "$HOME/.config/polybar/target" ] || : > "$HOME/.config/polybar/target"
# rofi-theme-selector busca en ~/.local/share/rofi/themes
mkdir -p "$HOME/.local/share/rofi"
if [ ! -L "$HOME/.local/share/rofi/themes" ]; then
  [ -d "$HOME/.local/share/rofi/themes" ] && cp -n "$HOME"/.local/share/rofi/themes/*.rasi "$HOME/.config/rofi/themes/" 2>/dev/null || true
  rm -rf "$HOME/.local/share/rofi/themes"
  ln -s "$HOME/.config/rofi/themes" "$HOME/.local/share/rofi/themes"
fi

# ── 5. Shells ───────────────────────────────────────────────────────
step "zsh / bash"
[ -f "$HOME/.zshrc" ]  || cp /etc/skel/.zshrc "$HOME/.zshrc" 2>/dev/null || touch "$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] || cp /etc/skel/.bashrc "$HOME/.bashrc" 2>/dev/null || touch "$HOME/.bashrc"
if ! grep -q "neon-grid/functions.sh" "$HOME/.zshrc"; then
  cp -n "$HOME/.zshrc" "$HOME/.zshrc.bak-pre-neongrid"
  { cat <<'ZHEAD'
# NEON//GRID: instant prompt de powerlevel10k (debe ir al principio)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZHEAD
    cat "$HOME/.zshrc"
    cat <<'ZTAIL'

# ── NEON//GRID ──
[ -f ~/.config/neon-grid/functions.sh ] && source ~/.config/neon-grid/functions.sh
source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
ZTAIL
  } > "$HOME/.zshrc.neongrid.tmp" && mv "$HOME/.zshrc.neongrid.tmp" "$HOME/.zshrc"
  info "~/.zshrc integrado (backup: ~/.zshrc.bak-pre-neongrid)"
else info "~/.zshrc ya integrado"; fi
if ! grep -q "neon-grid/functions.sh" "$HOME/.bashrc"; then
  cp -n "$HOME/.bashrc" "$HOME/.bashrc.bak-pre-neongrid"
  cat >> "$HOME/.bashrc" <<'BTAIL'

# NEON//GRID
[ -f ~/.config/neon-grid/functions.sh ] && . ~/.config/neon-grid/functions.sh
PS1='\[\e[38;2;31;122;77m\]┌─[\[\e[38;2;0;255;156m\]\u@\h\[\e[38;2;31;122;77m\]]─[\[\e[38;2;57;255;20m\]\w\[\e[38;2;31;122;77m\]]\n└─\[\e[38;2;0;255;156m\]❯\[\e[0m\] '
BTAIL
  info "~/.bashrc integrado (backup: ~/.bashrc.bak-pre-neongrid)"
else info "~/.bashrc ya integrado"; fi
rm -f "$HOME"/.cache/p10k-instant-prompt-*.zsh* 2>/dev/null || true
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER" && info "zsh como shell por defecto"
fi

# ── 6. Wallpaper ────────────────────────────────────────────────────
step "Wallpaper procedural"
if [ -f "$HOME/.config/wallpapers/neon-grid.png" ]; then info "ya generado"
else python3 "$HOME/.config/wallpapers/src/neon-grid.py" >/dev/null && info "generado: ~/.config/wallpapers/neon-grid.png"; fi

# ── 7. Sesión ───────────────────────────────────────────────────────
if [ "$DO_SESSION" = 1 ]; then
  step "Sesión por defecto: bspwm"
  printf '[Desktop]\nSession=bspwm\n' > "$HOME/.dmrc"
  AS="/var/lib/AccountsService/users/$USER"
  if sudo test -f "$AS"; then
    if sudo grep -q '^XSession=' "$AS"; then sudo sed -i 's/^XSession=.*/XSession=bspwm/' "$AS"
    else sudo sed -i '/^\[User\]/a XSession=bspwm' "$AS"; fi
  else
    sudo mkdir -p /var/lib/AccountsService/users
    printf '[User]\nXSession=bspwm\nSystemAccount=false\n' | sudo tee "$AS" >/dev/null
  fi
  info "LightDM arrancará bspwm (XFCE sigue disponible en el selector)"
fi

# ── 8. Guía PDF ─────────────────────────────────────────────────────
if [ "$DO_PDF" = 1 ]; then
  step "Guía PDF"
  if command -v pandoc >/dev/null && command -v weasyprint >/dev/null; then
    ( cd "$HOME/.config/neon-grid/doc" && pandoc guia-entorno.md -s --css guia.css --pdf-engine=weasyprint -o "$HOME/guia-entorno.pdf" 2>/dev/null ) \
      && info "~/guia-entorno.pdf" || warn "no se pudo generar el PDF"
  else warn "faltan pandoc/weasyprint; PDF omitido"; fi
fi

# ── Recargar si ya estamos dentro de bspwm ──────────────────────────
if [ -n "${DISPLAY:-}" ] && pgrep -x bspwm >/dev/null; then
  step "Recargando bspwm"
  pkill -x sxhkd || true; pkill -x picom || true; sleep 0.5
  bspc wm -r || true
fi

printf '\n%s════════ NEON//GRID instalado ════════%s\n' "$G" "$R"
cat <<EOF
  ${D}1.${R} Cierra sesión y entra en ${G}bspwm${R} (o 'startx' desde una TTY).
  ${D}2.${R} Super+Return = terminal · Super+d = rofi · Super+Alt+r = recargar
  ${D}3.${R} Comandos: settarget / cleartarget / gettarget / mkt / extractPorts
  ${D}4.${R} Guía: ~/guia-entorno.pdf
  ${D}VM:${R} activa la aceleración 3D (y compatibilidad de hardware reciente) para blur.
EOF
