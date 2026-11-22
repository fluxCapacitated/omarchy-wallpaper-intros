# Wallpaper Intros

Create short intro clips for Omarchy wallpapers, and play them when you change the wallpaper, then settle on the still.

Omarchy already plays matching intros on login and when you switch themes. This plugin fills the gap for ordinary wallpaper changes, such as Super+Ctrl+Space or `omarchy theme bg next`. It also ships `omarchy-intro-make`, which builds those clips locally with ffmpeg.

## How it works

Omarchy resolves an intro from a still wallpaper by looking for a video with the same file stem:

```
~/.config/omarchy/themes/<theme>/backgrounds/<name>.webp
~/.config/omarchy/themes/<theme>/backgrounds/intros/<name>.mp4
```

Supported video extensions are `mp4`, `m4v`, `mov`, `webm`, `mkv`, and `avi`. Playback uses [OWE](https://github.com/omacom/owe) (`owe` / `owed`). If Hyprland animations are off, or intros are disabled with `omarchy theme bg intro disable`, the wallpaper still changes and no clip is played.

The official plugin format is a Quickshell QML module. Third-party plugins cannot intercept `omarchy-theme-bg-set`, so this plugin also ships a user-level PATH wrapper. After install, `~/.local/bin/omarchy-theme-bg-set` shadows the stock command, pre-warms the OWE renderer, sets the wallpaper with the stock script, then plays the intro. If the renderer is not ready in time (common on power-saver profiles), playback is retried once. Failures are logged to `~/.cache/bg-intro.log`; the still wallpaper is left in place.

The wrapper also looks in your theme overlay when the stock resolver only sees the copied files under `~/.local/state/omarchy/current/theme/`. That means a newly added overlay clip can play before you re-apply the theme.

## Dependencies

- Omarchy, with `omarchy-theme-bg-set` and `omarchy-theme-bg-boot-intro`
- `owe` / `owed` 0.2.12 or later (`owe warm` and `owe intro --start first-frame`)
- `hyprctl` and `jq` (used to honor the animations-off setting)
- `ffmpeg` and `ffprobe`, required only to *create* intro clips with `omarchy-intro-make`. Playback does not need them.

## Installation

1. Add the plugin from its public GitHub repository:

   ```bash
   omarchy plugin add https://github.com/fluxCapacitated/omarchy-wallpaper-intros
   ```

   If you are installing from a local copy instead:

   ```bash
   mkdir -p ~/.config/omarchy/plugins/io.github.fluxcapacitated.wallpaper-intros
   cp -a /path/to/this/folder/. ~/.config/omarchy/plugins/io.github.fluxcapacitated.wallpaper-intros/
   omarchy plugin validate ~/.config/omarchy/plugins/io.github.fluxcapacitated.wallpaper-intros
   omarchy plugin enable io.github.fluxcapacitated.wallpaper-intros
   ```

2. Install the wallpaper-change wrapper and link the generator. This only touches `~/.local/bin`. It will not overwrite a different file already at either path, and it will not change your themes, clips, or `shell.json`.

   ```bash
   ~/.config/omarchy/plugins/io.github.fluxcapacitated.wallpaper-intros/scripts/install.sh
   ```

   The wrapper is copied to `~/.local/bin/omarchy-theme-bg-set`. The generator is linked to `~/.local/bin/omarchy-intro-make` only if that path is free.

3. Confirm `~/.local/bin` is on your PATH (Omarchy sessions include it by default) and that `command -v omarchy-theme-bg-set` points at the wrapper.

## Removal

```bash
~/.config/omarchy/plugins/io.github.fluxcapacitated.wallpaper-intros/scripts/uninstall.sh
omarchy plugin remove io.github.fluxcapacitated.wallpaper-intros
```

Uninstall removes only this plugin's wrapper and generator link, and only if those files still belong to the plugin. Your intro clips and themes are left alone. After that, wallpaper changes use the stock command again (no intro on wallpaper change). Login and theme-switch intros from Omarchy itself keep working.

## Create intro clips

`omarchy-intro-make` builds a roughly 4 second mp4 from the wallpaper still, using ffmpeg only. It does not call any cloud or AI service. Every style keeps the wallpaper's true aspect ratio (no stretching), settles onto the still before the end, and finishes on a frame that matches the wallpaper.

```bash
omarchy-intro-make /path/to/5-omakub.webp
omarchy-intro-make /path/to/5-omakub.webp --style zoom-out --theme tokyo-night
omarchy-intro-make --all-missing --theme tokyo-night
```

Styles:

- `fade` — fade in from black, then hold the wallpaper (default)
- `zoom-out` — slow Ken Burns zoom-out that settles on the still
- `blur-sharp` — a blurred still that sharpens into the wallpaper
- `bloom` — a soft color-bloom reveal into the wallpaper

By default the clip is written to:

```
~/.config/omarchy/themes/<theme>/backgrounds/intros/<stem>.mp4
```

The theme is `--theme` if you pass it, otherwise it is inferred from the wallpaper path, otherwise the current theme. An existing clip is never overwritten unless you pass `--force`.

If that theme is the one currently active, the clip is also copied to `~/.local/state/omarchy/current/theme/backgrounds/intros/<stem>.mp4`, which is where stock login and theme-switch playback looks. Pass `--output`, `--output-dir`, or `--no-state-copy` to skip that copy.

`--all-missing` builds a clip for every still in the theme that does not already have one. It skips the default Omarchy logo (`omarchy.webp`, `.png`, or `.jpg`). `--dry-run` prints the planned paths without writing files.

For tests or a custom destination:

```bash
omarchy-intro-make ./wallpaper.webp --style fade --output /tmp/intro-fade.mp4
```

The long edge is capped at 2560 pixels by default, which matches the usual size of Omarchy intro clips, and the original aspect ratio is kept. Pass `--native` to encode at the wallpaper's full pixel size, or `--max-dimension N` to choose another cap. If a side is odd, one pixel is cropped so the video can use yuv420p.

## Add your own intro clips by hand

You can also author a clip yourself, as long as you follow the same rules:

1. Start from the real wallpaper file. Keep its true aspect ratio; do not stretch or crop to a different shape.
2. Name the clip after the wallpaper stem and put it in an `intros` folder next to that wallpaper:

   ```
   ~/.config/omarchy/themes/<theme>/backgrounds/intros/<wallpaper-stem>.mp4
   ```

   User wallpapers in `~/.config/omarchy/backgrounds/<theme>/` can keep their clip at `~/.config/omarchy/backgrounds/<theme>/intros/<stem>.mp4`.

3. Keep the clip short, about 4 to 7 seconds. The first seconds can animate; settle onto the exact wallpaper frame early. The last frame must match the still, at the same aspect ratio and colors.
4. If the theme is already active, either re-apply it so Omarchy copies the overlay into `~/.local/state/omarchy/current/theme/backgrounds/intros/`, or rely on this plugin's overlay fallback and change the wallpaper once.

This repository does not ship wallpaper clips. Some themes already include stock intros under `/usr/share/omarchy/themes/<theme>/backgrounds/intros/`. User overlays in `~/.config/omarchy/themes/` are merged over the stock theme the next time that theme is applied.

## Toggle and troubleshooting

- Toggle: `omarchy theme bg intro toggle`
- Playback log: `~/.cache/bg-intro.log`
- "Intro start failed" or a log line of `failed, still wallpaper only` usually means the OWE renderer was not ready. The wrapper pre-warms it and retries once. On a power-saver profile this can still occasionally miss; changing the wallpaper again is enough.
- If no intro plays and the log is empty, check that the wrapper is first on PATH and that the clip stem matches the wallpaper file.
- If `omarchy-intro-make` fails, confirm `ffmpeg` and `ffprobe` are installed.

## License

MIT. See [LICENSE](LICENSE).
