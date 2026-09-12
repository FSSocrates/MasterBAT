# 🐱 Purrfection

A self-contained theme switcher for **Catppuccin** on **LibreOffice**.
No clone, no repo — just one script that downloads and applies the theme you pick.

## Requirements

- `bash`
- `curl`
- LibreOffice installed
- **Application theming enabled** in LibreOffice:
  *Tools → Options → LibreOffice → Appearance → ☑ Enable application theming*
  (do this once, then close all LibreOffice windows before running the script)

## Install

```bash
chmod +x Purrfection.sh
mv Purrfection.sh ~/bin/
```

> `~/bin` should be on your `$PATH`. If not, add `export PATH="$HOME/bin:$PATH"` to `~/.bashrc`.

## Usage

```bash
Purrfection.sh                # interactive menu
Purrfection.sh mocha mauve    # direct
Purrfection.sh latte blue     # another combo
```

### Flavors

| # | Flavor    |
|---|-----------|
| 1 | latte     |
| 2 | frappe    |
| 3 | macchiato |
| 4 | mocha     |

### Accents

`rosewater` · `flamingo` · `red` · `maroon` · `mauve` · `blue` · `sapphire` · `sky` · `teal` · `green` · `yellow` · `peach`

## How it works

1. Downloads the selected `.soc` palette + the upstream install script into a temp dir.
2. Copies the palette into your LibreOffice config.
3. Runs the install script to apply the UI theme.
4. Cleans up the temp dir.

No persistent state, no clone, no fixed path.

## Credits

Based on [catppuccin/libreoffice](https://github.com/catppuccin/libreoffice).   
