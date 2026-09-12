#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Purrfection.sh — Catppuccin theme switcher for LibreOffice
#  Self-contained interactive + non-interactive installer
# ─────────────────────────────────────────────────────────────

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/catppuccin/libreoffice/main"

# ── Colors ──────────────────────────────────────────────────
R=$'\e[0m'  B=$'\e[1m'
C_RED=$'\e[38;2;242;135;145m'
C_GREEN=$'\e[38;2;166;227;161m'
C_YELLOW=$'\e[38;2;249;226;175m'
C_BLUE=$'\e[38;2;137;180;250m'

declare -A BASE=(
  [latte]="239 241 245"
  [frappe]="48 52 70"
  [macchiato]="36 39 58"
  [mocha]="30 30 46"
)

declare -A ACCENT=(
  [latte:rosewater]="220 138 120"   [latte:flamingo]="221 120 120"
  [latte:red]="210 15 57"           [latte:maroon]="230 69 83"
  [latte:mauve]="136 57 239"        [latte:blue]="30 102 245"
  [latte:sapphire]="32 159 181"     [latte:sky]="4 165 229"
  [latte:teal]="23 146 153"         [latte:green]="64 160 43"
  [latte:yellow]="223 142 29"       [latte:peach]="254 100 11"

  [frappe:rosewater]="242 213 207"  [frappe:flamingo]="238 190 190"
  [frappe:red]="231 130 132"        [frappe:maroon]="234 153 156"
  [frappe:mauve]="202 158 230"      [frappe:blue]="140 170 238"
  [frappe:sapphire]="133 193 220"   [frappe:sky]="153 209 219"
  [frappe:teal]="129 200 190"       [frappe:green]="166 209 137"
  [frappe:yellow]="229 200 144"     [frappe:peach]="239 159 118"

  [macchiato:rosewater]="244 219 214" [macchiato:flamingo]="240 198 198"
  [macchiato:red]="237 135 150"       [macchiato:maroon]="238 153 160"
  [macchiato:mauve]="198 160 246"     [macchiato:blue]="138 173 244"
  [macchiato:sapphire]="125 196 228"  [macchiato:sky]="145 215 227"
  [macchiato:teal]="139 213 202"      [macchiato:green]="166 218 149"
  [macchiato:yellow]="238 212 159"    [macchiato:peach]="245 169 127"

  [mocha:rosewater]="245 224 220"    [mocha:flamingo]="242 205 205"
  [mocha:red]="243 139 168"          [mocha:maroon]="235 160 172"
  [mocha:mauve]="203 166 247"        [mocha:blue]="137 180 250"
  [mocha:sapphire]="116 199 236"     [mocha:sky]="137 220 235"
  [mocha:teal]="148 226 213"         [mocha:green]="166 227 161"
  [mocha:yellow]="249 226 175"       [mocha:peach]="250 179 135"
)

flavors=("latte" "frappe" "macchiato" "mocha")
accents=("rosewater" "flamingo" "red" "maroon" "mauve" "blue"
         "sapphire" "sky" "teal" "green" "yellow" "peach")

dot() {
  local rgb=($1)
  printf '\e[38;2;%s;%s;%sm●\e[0m' "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
}

banner() {
  echo
  echo -e "  ${B}░░ Catppuccin · LibreOffice ░░${R}"
  echo
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [FLAVOR ACCENT]

Interactive mode (default):
  $(basename "$0")

Non-interactive:
  $(basename "$0") mocha blue
  $(basename "$0") --flavor mocha --accent blue

Options:
  -c, --current     Show currently installed Catppuccin theme (if any)
  -h, --help        Show this help
  --flavor FLAVOR   Set flavor non-interactively
  --accent ACCENT   Set accent non-interactively

Flavors : ${flavors[*]}
Accents : ${accents[*]}
EOF
}

# ── Find registrymodifications.xcu ───────────────────────────
find_xcu() {
  local flatpak_glob="$HOME/.var/app/org.libreoffice.LibreOffice/config/libreoffice/*/user/registrymodifications.xcu"
  if compgen -G "$flatpak_glob" &>/dev/null; then
    realpath "$(compgen -G "$flatpak_glob" | head -n1)"
    return
  fi

  local regular="${XDG_CONFIG_HOME:-$HOME/.config}/libreoffice/*/user/registrymodifications.xcu"
  if compgen -G "$regular" &>/dev/null; then
    realpath "$(compgen -G "$regular" | head -n1)"
    return
  fi
  echo ""
}

# ── Detect current theme ────────────────────────────────────
detect_current() {
  local xcu
  xcu=$(find_xcu)

  if [[ -z "$xcu" ]]; then
    echo -e "  ${C_YELLOW}⚠${R}  registrymodifications.xcu not found."
    echo -e "     LibreOffice may not have been opened yet."
    return 1
  fi

  # Look for the most recent catppuccin-*.soc reference inside the xcu
  local current
  current=$(grep -oE 'catppuccin-[a-z]+-[a-z]+\.soc' "$xcu" 2>/dev/null | tail -1 || true)

  if [[ -z "$current" ]]; then
    # Fallback: check the config directory for any installed .soc
    local config_dir
    config_dir=$(ls -d "${XDG_CONFIG_HOME:-$HOME/.config}"/libreoffice/*/user/config 2>/dev/null | head -1)
    [[ -z "$config_dir" ]] && config_dir=$(ls -d "$HOME/.var/app/org.libreoffice.LibreOffice/config/libreoffice"/*/user/config 2>/dev/null | head -1)

    if [[ -n "$config_dir" ]]; then
      current=$(ls -1 "$config_dir"/catppuccin-*.soc 2>/dev/null | xargs -n1 basename 2>/dev/null | tail -1 || true)
    fi
  fi

  if [[ -n "$current" ]]; then
    # Extract flavor and accent from filename: catppuccin-mocha-blue.soc
    local name="${current%.soc}"
    local flavor="${name#catppuccin-}"
    flavor="${flavor%-*}"
    local accent="${name##*-}"

    echo -e "  ${B}Current theme:${R}"
    printf '    '
    dot "${BASE[$flavor]}"
    printf ' %s / ' "$flavor"
    dot "${ACCENT[$flavor:$accent]}"
    printf ' %s\n' "$accent"
    echo -e "    ${C_BLUE}→${R} $current"
  else
    echo -e "  ${C_YELLOW}No Catppuccin theme currently detected.${R}"
  fi
}

# ── Interactive pickers ─────────────────────────────────────
pick_flavor() {
  if [[ -n "${1:-}" ]]; then
    flavor="$1"
    return
  fi
  echo -e "  ${B}Flavor:${R}"
  for i in "${!flavors[@]}"; do
    local f="${flavors[$i]}"
    printf '   %2d. ' "$((i+1))"
    dot "${BASE[$f]}"
    printf ' %s\n' "$f"
  done
  read -rp "  Choose [1-4]: " n
  flavor="${flavors[$((n-1))]}"
}

pick_accent() {
  if [[ -n "${1:-}" ]]; then
    accent="$1"
    return
  fi
  echo -e "  ${B}Accent:${R}"
  for i in "${!accents[@]}"; do
    local a="${accents[$i]}"
    printf '   %2d. ' "$((i+1))"
    dot "${ACCENT[$flavor:$a]}"
    printf ' %s\n' "$a"
  done
  read -rp "  Choose [1-12]: " n
  accent="${accents[$((n-1))]}"
}

# ── Apply theme ─────────────────────────────────────────────
apply() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  local soc_url="$BASE_URL/themes/$flavor/$accent/catppuccin-$flavor-$accent.soc"
  local soc_file="$tmp/catppuccin-$flavor-$accent.soc"

  echo -e "  ${B}↓${R} Downloading ${flavor}/${accent}…"

  if ! curl -sfL "$soc_url" -o "$soc_file"; then
    echo -e "  ${C_RED}✗${R} Failed to download palette." >&2
    exit 1
  fi

  # 1. Install palette
  local config_dir
  config_dir=$(ls -d "${XDG_CONFIG_HOME:-$HOME/.config}"/libreoffice/*/user/config 2>/dev/null | head -1)
  [[ -z "$config_dir" ]] && config_dir=$(ls -d "$HOME/.var/app/org.libreoffice.LibreOffice/config/libreoffice"/*/user/config 2>/dev/null | head -1)

  if [[ -z "$config_dir" ]]; then
    echo -e "  ${C_RED}✗${R} Could not find LibreOffice config directory."
    echo -e "     Open LibreOffice once, then re-run." >&2
    exit 1
  fi

  # Clean old catppuccin palettes to avoid clutter
  rm -f "$config_dir"/catppuccin-*.soc 2>/dev/null || true
  cp "$soc_file" "$config_dir/"
  echo -e "  ${C_GREEN}✓${R} Palette installed → $config_dir"

  # 2. Apply application colors
  local xcu
  xcu=$(find_xcu)

  if [[ -z "$xcu" ]]; then
    echo -e "  ${C_RED}✗${R} registrymodifications.xcu not found."
    echo -e "     Open LibreOffice → Tools → Options → LibreOffice → Appearance"
    echo -e "     Enable “Application theming”, fully quit LibreOffice, then re-run." >&2
    exit 1
  fi

  if ! tail -n1 "$xcu" | grep -qE '^</oor:items>$'; then
    echo -e "  ${C_RED}✗${R} Unexpected format in registrymodifications.xcu — aborting." >&2
    exit 1
  fi

  # Backup
  local bak="${xcu}.$(date -u +%Y-%m-%dT%H:%M:%SZ).bak"
  cp "$xcu" "$bak"
  echo -e "  ${C_GREEN}✓${R} Backup created → $(basename "$bak")"

  # Remove any previous Catppuccin entries to avoid duplicates
  local cleaned
  cleaned=$(grep -v 'catppuccin-.*\.soc' "$xcu" || true)

  # Inject new theme just before the closing tag
  local new_settings
  new_settings="$(printf '%s\n' "$cleaned" | head -n -1)
$(cat "$soc_file")
$(printf '%s\n' "$cleaned" | tail -n1)"

  printf '%s\n' "$new_settings" > "$xcu"

  echo -e "  ${C_GREEN}✓${R} Application colors applied"
}

# ── Argument parsing ────────────────────────────────────────
flavor=""
accent=""
show_current=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -c|--current)
      show_current=true
      shift
      ;;
    --flavor)
      flavor="$2"
      shift 2
      ;;
    --accent)
      accent="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      # positional: flavor accent
      if [[ -z "$flavor" ]]; then
        flavor="$1"
      elif [[ -z "$accent" ]]; then
        accent="$1"
      else
        echo "Too many arguments" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

# ── Main ────────────────────────────────────────────────────
banner

if $show_current; then
  detect_current
  echo
  exit 0
fi

# Validate if non-interactive values were given
if [[ -n "$flavor" && -z "$accent" ]] || [[ -z "$flavor" && -n "$accent" ]]; then
  echo -e "  ${C_RED}✗${R} Both flavor and accent are required in non-interactive mode." >&2
  exit 1
fi

if [[ -n "$flavor" ]]; then
  # Non-interactive validation
  if [[ ! " ${flavors[*]} " =~ " ${flavor} " ]]; then
    echo -e "  ${C_RED}✗${R} Invalid flavor: $flavor" >&2
    exit 1
  fi
  if [[ ! " ${accents[*]} " =~ " ${accent} " ]]; then
    echo -e "  ${C_RED}✗${R} Invalid accent: $accent" >&2
    exit 1
  fi
else
  # Interactive
  pick_flavor
  pick_accent
fi

echo
apply
echo
echo -e "  ${B}✓ ${flavor} / ${accent} applied successfully.${R}"
echo -e "  Restart LibreOffice to see the full theme.\n"
