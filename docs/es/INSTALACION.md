# Instalación

🇬🇧 [English](../en/INSTALLATION.md) | 🇪🇸 **Español** · [← Volver al README](../../README.es.md)

## Antes de empezar

- **Kali Linux** (rolling) con un escritorio que ya funcione. En otros sistemas Debian/apt el script muestra un aviso y lo intenta igualmente.
- Un **usuario normal con permisos de sudo**. Se niega a ejecutarse como root a propósito: las configuraciones tienen que acabar en tu propio `$HOME`.
- **Conexión a Internet** para `apt`, la descarga de JetBrainsMono Nerd Font (releases de GitHub) y el `git clone` de powerlevel10k.
- **LightDM** si quieres que bspwm quede como sesión por defecto automáticamente (Kali lo usa por defecto).
- En una VM, activa la **aceleración 3D** para tener blur y sombras completas (consulta [Solución de problemas](SOLUCION-PROBLEMAS.md#no-hay-blur-o-la-vm-va-lenta)).

> [!WARNING]
> El script **cambia tu shell de inicio a zsh** (`chsh`), **sobrescribe `~/.dmrc`** y sustituye `~/.local/share/rofi/themes` por un enlace simbólico (solo se copian los `.rasi` que ya hubiera en esa carpeta). Revisa la sección [Qué hace exactamente el script](../../README.es.md#-qué-hace-exactamente-el-script) si tienes un entorno personalizado.

## Instalar

```bash
git clone https://github.com/ManelFernandezBaeza/neon-grid.git
cd neon-grid
chmod +x install-neon-grid.sh
./install-neon-grid.sh
```

El script pide la contraseña de sudo una vez y mantiene la sesión de sudo activa en segundo plano hasta que termina.

### Opciones

| Opción | Efecto |
|---|---|
| `--no-pdf` | No genera `~/guia-entorno.pdf` |
| `--no-session` | No pone bspwm como sesión por defecto en LightDM (no toca `~/.dmrc` ni AccountsService) |
| `--skip-packages` | No instala nada con `apt` (útil al relanzarlo) |
| `-h`, `--help` | Muestra la cabecera de ayuda y sale |

Cualquier otro argumento detiene el script con `Opción desconocida`.

### Volver a ejecutarlo

El instalador es **idempotente**:

- Los paquetes, la Nerd Font, powerlevel10k y el wallpaper se omiten si ya están.
- Las configuraciones solo se reemplazan si su contenido cambia; antes se copia la versión anterior en `~/.neon-grid-backup-<AAAAMMDD-HHMMSS>/`.
- `~/.zshrc` y `~/.bashrc` solo se modifican una vez (busca `neon-grid/functions.sh`).
- Nunca sobrescribe un `~/.config/polybar/target` existente.

Si lo lanzas desde dentro de bspwm, al final reinicia sxhkd y picom y recarga bspwm.

## Primer inicio

1. Cierra sesión.
2. En la pantalla de LightDM, abre el selector de sesión (icono arriba a la derecha): **bspwm** ya es tu sesión por defecto. XFCE sigue en la lista.
3. Inicia sesión.

Sin gestor gráfico: ve a una TTY con <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F3</kbd>, inicia sesión y ejecuta `startx` (`~/.xinitrc` hace `exec bspwm`).

En cada inicio de sesión `bspwmrc` comprueba la GPU y arranca **sxhkd**, **picom** (config completa o ligera), **dunst**, **nm-applet**, el wallpaper, **polybar** y un **kitty** oculto precargado. Todo comprueba si ya está en marcha, así que recargar no duplica procesos.

Siguiente paso: aprende los [atajos de teclado](ATAJOS.md).

## Desinstalación / volver al escritorio anterior

No hay desinstalador automático. Deshaz los cambios a mano:

1. **Sesión por defecto**: elige XFCE (o tu escritorio anterior) en el selector de sesión de LightDM. Para dejarlo fijo, edita `~/.dmrc` y `/var/lib/AccountsService/users/$USER` (`XSession=`) con el nombre de tu sesión anterior.
2. **Configuraciones**: recupera lo que necesites de `~/.neon-grid-backup-<fecha>/`. Solo contiene los archivos que ya existían y eran distintos antes de instalar.
3. **Shells**:

   ```bash
   mv ~/.zshrc.bak-pre-neongrid ~/.zshrc
   mv ~/.bashrc.bak-pre-neongrid ~/.bashrc
   ```

4. **Shell de inicio** (si quieres volver a bash):

   ```bash
   chsh -s /bin/bash
   ```

5. **Borrar los archivos de NEON//GRID** (opcional):

   ```bash
   rm -rf ~/.config/{bspwm,sxhkd,polybar,picom,rofi,kitty,dunst,wallpapers,neon-grid}
   rm -rf ~/.powerlevel10k ~/.p10k.zsh ~/.local/share/fonts/JetBrainsMonoNF
   rm -f ~/.local/share/rofi/themes ~/.fehbg ~/.xinitrc ~/guia-entorno.pdf
   fc-cache -f
   ```

   > [!CAUTION]
   > Revisa `~/.tmux.conf` y `~/.xinitrc` antes de borrarlos si tenías tus propias versiones; en ese caso, recupéralas de la carpeta de backup.

6. **Paquetes** (opcional): el script no registra qué paquetes eran nuevos, así que desinstala solo los que tengas claro que no necesitas con `sudo apt remove <paquete>`. El enlace `/usr/local/bin/bat` se quita con `sudo rm /usr/local/bin/bat`.
