# Purrfection

Interactive Catppuccin theme switcher for LibreOffice.

A self-contained script that lets you quickly apply any Catppuccin flavor + accent combination to LibreOffice.

> **Note:** This only installs the color palette and limited application colors.  
> Full UI theming (toolbars, icons, etc.) is **not** supported by the upstream Catppuccin LibreOffice port.

## Features

- Interactive menu with colored previews
- Non-interactive mode
- Current theme detection
- Automatic backup of `registrymodifications.xcu`
- Force-closes LibreOffice before applying changes
- Works with both regular and Flatpak installs

## Installation

```bash
mkdir -p ~/bin
curl -sfL https://raw.githubusercontent.com/FSSocrates/MasterBAT/main/Catppuccin/LibreOffice/Purrfection -o ~/bin/Purrfection
chmod +x ~/bin/Purrfection
```

## Usage

### Interactive mode
```bash
Purrfection
```

### Non-interactive mode
```bash
Purrfection mocha blue
# or
Purrfection --flavor mocha --accent sapphire
```

### Show current theme
```bash
Purrfection --current
# or
Purrfection -c
```

### Help
```bash
Purrfection --help
```

## Available Options

**Flavors:** `latte` · `frappe` · `macchiato` · `mocha`  

**Accents:** `rosewater` · `flamingo` · `red` · `maroon` · `mauve` · `blue` · `sapphire` · `sky` · `teal` · `green` · `yellow` · `peach`

## Limitations

- Only the color palette is reliably applied
- Full UI chrome and icon theming is not available upstream
- You still need to enable **Application theming** in  
  `Tools → Options → LibreOffice → Appearance`

## License

MIT
