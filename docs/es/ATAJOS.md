# Atajos de teclado y comandos

🇬🇧 [English](../en/SHORTCUTS.md) | 🇪🇸 **Español** · [← Volver al README](../../README.es.md)

Basado en la guía original ([`guia-entorno.pdf`](../guia-entorno.pdf)). Los atajos están definidos en `~/.config/sxhkd/sxhkdrc`.

> [!NOTE]
> **Modificador:** todas las combinaciones usan <kbd>Super</kbd> (tecla Windows).

## Básicos

| Atajo | Acción |
|---|---|
| <kbd>Super</kbd> + <kbd>Return</kbd> | Abrir terminal (kitty, instancia única precargada: abre al instante) |
| <kbd>Super</kbd> + <kbd>d</kbd> | Lanzador de aplicaciones (rofi drun) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>d</kbd> | Lista de ventanas abiertas (rofi window) |
| <kbd>Super</kbd> + <kbd>w</kbd> | Cerrar la ventana enfocada |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> | Recargar bspwm + sxhkd |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>q</kbd> | Salir de bspwm |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>p</kbd> | Menú power (bloquear / salir / reiniciar / apagar) |
| <kbd>Print</kbd> | Captura de pantalla con `flameshot gui` |
| `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` | Subir / bajar / silenciar volumen |

## Escritorios y foco

| Atajo | Acción |
|---|---|
| <kbd>Super</kbd> + <kbd>1…9, 0</kbd> | Ir al escritorio 1…10 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1…9, 0</kbd> | Mover la ventana al escritorio 1…10 |
| <kbd>Super</kbd> + <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd> | Mover el foco en esa dirección |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd> | Mover (intercambiar) la ventana en esa dirección |

## Redimensionar con teclado

| Atajo | Acción |
|---|---|
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd> | Ventana más ancha |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>←</kbd> | Ventana más estrecha |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↑</kbd> | Ventana más alta |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↓</kbd> | Ventana más baja |

Cada pulsación son 40 px (mantén pulsado para repetir). Si un lado toca el borde de la pantalla, crece o encoge por el lado contrario. En mosaico se mueve la división con la ventana vecina, así que solo cambia en la dirección donde haya otra ventana; en flotante funcionan las cuatro flechas.

## Modos de ventana y ratón

| Atajo | Modo | Detalle |
|---|---|---|
| <kbd>Super</kbd> + <kbd>f</kbd> | **Fullscreen real** | `bspc node -t ~fullscreen`: tapa la polybar. Pulsa otra vez para volver. |
| <kbd>Super</kbd> + <kbd>m</kbd> | **Monóculo** | `bspc desktop -l next`: la ventana ocupa todo el área útil **sin** tapar la barra. Repite para volver a tiled. |
| <kbd>Super</kbd> + <kbd>s</kbd> | **Flotante** | `bspc node -t floating` |
| <kbd>Super</kbd> + <kbd>t</kbd> | **Tiled** | `bspc node -t tiled`: devuelve una ventana flotante al mosaico |
| <kbd>Super</kbd> + clic izq. + arrastrar | Mover | Mueve una ventana flotante; en mosaico la **intercambia** con la ventana donde la sueltes |
| <kbd>Super</kbd> + clic der. + arrastrar | Redimensionar | Redimensiona desde la esquina más cercana |
| <kbd>Super</kbd> + rueda (clic) + arrastrar | Redimensionar | Redimensiona desde el lado más cercano |

## Rofi y el selector de temas

- <kbd>Super</kbd> + <kbd>d</kbd> abre el lanzador. Escribe para filtrar, <kbd>Enter</kbd> para lanzar y <kbd>Shift</kbd> + <kbd>←</kbd>/<kbd>→</kbd> (o un clic en la pestaña inferior) para cambiar entre **apps**, **run** y **win**.
- Desde terminal: `rofi -show drun`, `rofi -show run` o `rofi -show window`.
- **Cambiar de tema al vuelo:** ejecuta `rofi-theme-selector`. Muévete con las flechas para previsualizar y pulsa <kbd>Alt</kbd> + <kbd>a</kbd> para aplicar y guardar (escribe `@theme` en `~/.config/rofi/config.rasi`).
- Temas propios incluidos (además de los del sistema):
  - **neon-grid** (predeterminado): ventana centrada, translúcida, selección rellena en neón.
  - **neon-grid-terminal**: variante compacta y opaca anclada arriba, estilo consola.
- Para volver al tema por defecto: pon `@theme "neon-grid"` en la última línea de `config.rasi`.

## Recargar componentes

| Componente | Cómo |
|---|---|
| bspwm + sxhkd | <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> |
| Solo sxhkd | `pkill -USR1 -x sxhkd` |
| Polybar | `~/.config/polybar/launch.sh` (mata instancias y relanza) |
| Picom | `pkill picom` y <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd> (bspwmrc lo relanza con la config adecuada a tu GPU) |
| Dunst | `killall dunst; dunst &` |
| kitty | <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F5</kbd> dentro de kitty |
| tmux | `prefix + r` (prefijo: <kbd>Ctrl</kbd> + <kbd>a</kbd>) |
| zsh | `source ~/.zshrc` |

## tmux (prefijo <kbd>Ctrl</kbd> + <kbd>a</kbd>)

| Teclas | Acción |
|---|---|
| `prefix` + <kbd>\|</kbd> | Divide en vertical |
| `prefix` + <kbd>-</kbd> | Divide en horizontal |
| `prefix` + <kbd>r</kbd> | Recarga `~/.tmux.conf` |

Ratón activado. La barra de estado muestra también el target actual.

## Interacción con la polybar

| Módulo | Interacción |
|---|---|
| Lanzador (icono izquierdo) | Clic izquierdo abre `rofi -show drun` |
| Nombre central | Clic izquierdo abre el perfil de GitHub del autor |
| `TARGET` | Clic izquierdo copia la IP objetivo al portapapeles |
| `VOL` | Clic derecho abre `pavucontrol`; rueda para subir/bajar; clic para silenciar |
| Icono de apagado | Clic izquierdo abre el menú power |

## Comandos propios (zsh y bash)

Definidos en `~/.config/neon-grid/functions.sh`, que cargan `~/.zshrc` y `~/.bashrc`.

| Comando | Qué hace |
|---|---|
| `settarget <IP>` | Guarda la IP en `~/.config/polybar/target` y recarga polybar |
| `cleartarget` | Vacía el fichero target y recarga polybar |
| `gettarget` | Imprime la IP objetivo y la copia al portapapeles (xclip) |
| `mkt` | Crea en el directorio actual: `nmap/ content/ exploits/ scripts/` |
| `extractPorts <fichero>` | Extrae los puertos abiertos de una salida de nmap (`-oG` o `-oN`), muestra IP y puertos y copia la lista `22,80,…` al portapapeles |

Flujo típico (IP de ejemplo de un laboratorio):

```bash
settarget 10.10.11.42
mkt && cd nmap
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn $(gettarget) -oG allPorts
extractPorts allPorts
nmap -sCV -p$(xclip -o -sel clip) $(gettarget) -oN targeted
```

Alias: `ls` / `ll` / `tree` → **eza** con iconos · `cat` → **bat** sin paginar · `vim` → **nvim**.

## Wallpaper

- Regenerar (otra semilla = otras columnas de datos): `python3 ~/.config/wallpapers/src/neon-grid.py 42`
- Cambiar de wallpaper: `feh --bg-fill /ruta/imagen.png`. feh guarda el comando en `~/.fehbg` y bspwm lo reaplica en cada arranque.
- Volver al original: `feh --bg-fill ~/.config/wallpapers/neon-grid.png`
