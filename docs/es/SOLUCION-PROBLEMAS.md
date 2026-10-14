# Solución de problemas

🇬🇧 [English](../en/TROUBLESHOOTING.md) | 🇪🇸 **Español** · [← Volver al README](../../README.es.md)

## El script se para nada más empezar

| Mensaje | Causa y solución |
|---|---|
| `Ejecuta el script como tu usuario normal, no como root` | Lo has lanzado como root o con `sudo`. Ejecuta `./install-neon-grid.sh` como tu usuario normal. |
| `Se necesita apt-get.` | No es un sistema Debian/apt. NEON//GRID está pensado para Kali Linux. |
| `Se necesita sudo.` | Tu usuario no puede usar sudo o la contraseña era incorrecta. |
| `Opción desconocida: …` | Argumento no admitido. Opciones válidas: `--no-pdf`, `--no-session`, `--skip-packages`, `-h`. |
| `No parece Kali Linux…` | Solo es un aviso: el script continúa en otros sistemas Debian/apt. |

## No hay blur o la VM va lenta

`bspwmrc` comprueba la GPU con `glxinfo` en cada inicio de sesión y elige:

| OpenGL disponible | picom | kitty |
|---|---|---|
| ≥ 3.3 por hardware (3D activado y compatibilidad de hardware reciente) | `picom.conf`: glx + blur + sombras completas | GPU |
| Solo software (llvmpipe, VM sin 3D) | `picom-lite.conf`: xrender, sin blur | software |
| Hardware < 3.3 (VMware 3D con compatibilidad antigua) | `picom-lite.conf` | software forzado (`LIBGL_ALWAYS_SOFTWARE=1`) |

**VMware:** para tener blur y la GPU real, apaga la VM, activa *Configuración → Pantalla → Acelerar gráficos 3D* y sube *VM → Administrar → Cambiar compatibilidad de hardware* a la versión más reciente. Compruébalo con:

```bash
glxinfo -B | grep -E "renderer|core profile"
```

Las ventanas sin foco se oscurecen a propósito (`dim = 0.35` en `rules` de picom); súbelo o bájalo a tu gusto.

## picom no arranca

`picom.conf` y `picom-lite.conf` usan la sintaxis `rules = (...)`, que necesita **picom v12 o posterior**. Compruébalo con `picom --version`. En un sistema desactualizado, actualiza (`sudo apt update && sudo apt full-upgrade`).

## La polybar no aparece o sale incompleta

- Relánzala: `~/.config/polybar/launch.sh`.
- Revisa los logs: `/tmp/polybar-<monitor>.log` o `/tmp/polybar.log`.
- El módulo `tray` usa `internal/tray`, que requiere **polybar 3.7+** (`polybar --version`).
- `TEMP` muestra `N/A` en máquinas virtuales sin sensores de temperatura. Es lo esperado.
- `TARGET none` significa que no hay objetivo: usa `settarget <IP>`.

## Los iconos salen como cuadrados o no aparecen

La JetBrainsMono Nerd Font no está instalada o no está en la caché:

```bash
fc-list : family | grep -i "JetBrainsMono Nerd"
fc-cache -f
```

Si no aparece nada, vuelve a lanzar el instalador con Internet (descarga la fuente de las releases de nerd-fonts en GitHub).

## bspwm no aparece al iniciar sesión / sigue arrancando XFCE

- El archivo de sesión lo instala el paquete `bspwm`: comprueba que hay una entrada de bspwm en `/usr/share/xsessions/`.
- La sesión por defecto se escribe en `~/.dmrc` y en `/var/lib/AccountsService/users/$USER` (`XSession=bspwm`). Si usaste `--no-session`, elige bspwm a mano en el selector de sesión de LightDM.
- Con otro gestor de inicio (por ejemplo, GDM), elige la sesión en su propio menú.
- Sin gestor de inicio, usa `startx` desde una TTY.

## El atajo de la terminal no hace nada

- Comprueba que sxhkd está en marcha: `pgrep -x sxhkd`. Recarga con <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>r</kbd>.
- En una VM, asegúrate de que el anfitrión no está capturando la tecla <kbd>Super</kbd>.

## El prompt se ve mal o zsh no es la shell

- Cierra sesión y vuelve a entrar después de instalar: `chsh` solo se aplica en un inicio de sesión nuevo.
- Recarga: `source ~/.zshrc`.
- Tu configuración anterior está en `~/.zshrc.bak-pre-neongrid`.

## No se generó la guía PDF

El script muestra `faltan pandoc/weasyprint; PDF omitido` o `no se pudo generar el PDF`. Instala las herramientas y vuelve a generarla:

```bash
sudo apt install pandoc weasyprint
cd ~/.config/neon-grid/doc
pandoc guia-entorno.md -s --css guia.css --pdf-engine=weasyprint -o ~/guia-entorno.pdf
```

O sáltatela con `--no-pdf`. En este repositorio también hay una copia: [`docs/guia-entorno.pdf`](../guia-entorno.pdf).

## No se encuentra el comando `bat`

En Debian/Kali el binario se llama `batcat`. El instalador crea `/usr/local/bin/bat` apuntando a él; si falta:

```bash
sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
```
