#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Purrfection.sh — Catppuccin theme switcher for LibreOffice
#  Self-contained: downloads only what's needed, no clone.
#  Usage: Purrfection.sh [flavor] [accent]
# ─────────────────────────────────────────────────────────────

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/catppuccin/libreoffice/main"
CONFIG_DIR=$(ls -d "${XDG_CONFIG_HOME:-$HOME}"/.config/libreoffice/*/user/config 2>/dev/null | head -1)

# ── Colors ──────────────────────────────────────────────────
R=$'\e[0m'  B=$'\e[1m'
C_RED=$'\e[38;2;242;135;145m'

# Flavor base colors (R G B)
declare -A BASE=(
  [latte]="239 241 245"
  [frappe]="48 52 70"
  [macchiato]="36 39 58"
  [mocha]="30 30 46"
)

# Accent colors per flavor (R G B)
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
accents=("rosewater" "flamingo" "red" "maroon" "mauve" "blue" \
         "sapphire" "sky" "teal" "green" "yellow" "peach")

# ── Helper: print colored circle ────────────────────────────
dot() {
  local rgb=($3)
  printf '\e[38;2;%s;%s;%sm●\e[0m' "${rgb[0]}" "${rgb[1]}" "${rgb[2]}"
}

# ── Banner ──────────────────────────────────────────────────
banner() {
  echo
  echo -e "  ${B}░░ Catppuccin · LibreOffice ░░${R}"
  echo
}

# ── Pick flavor ─────────────────────────────────────────────
pick_flavor() {
  if [[ -n "${1:-}" ]]; then flavor="$1"; return; fi
  echo -e "  ${B}Flavor:${R}"
  for i in "${!flavors[@]}"; do
    local f="${flavors[$i]}"
    local rgb=(${BASE[$f]})
    printf '   %2d. ' "$((i+1))"
    dot "" "" "$rgb"
    printf ' %s\n' "$f"
  done
  read -rp "  Choose [1-4]: " n
  flavor="${flavors[$((n-1))]}"
}

# ── Pick accent ─────────────────────────────────────────────
pick_accent() {
  if [[ -n "${1:-}" ]]; then accent="$1"; return; fi
  echo -e "  ${B}Accent:${R}"
  for i in "${!accents[@]}"; do
    local a="${accents[$i]}"
    local rgb=(${ACCENT[$flavor:$a]})
    printf '   %2d. ' "$((i+1))"
    dot "" "" "$rgb"
    printf ' %s\n' "$a"
  done
  read -rp "  Choose [1-12]: " n
  accent="${accents[$((n-1))]}"
}

# ── Apply ───────────────────────────────────────────────────
apply() {
  local tmp; tmp="$(mktemp -d)"
  local soc_url="$BASE_URL/themes/$flavor/$accent/catppuccin-$flavor-$accent.soc"
  local script_url="$BASE_URL/scripts/install_theme.sh"

  echo -e "  ${B}↓${R} Downloading ${flavor}/${accent}…"

  curl -sfL "$soc_url" -o "$tmp/palette.soc"
  curl -sfL "$script_url" -o "$tmp/install.sh"
  chmod +x "$tmp/install.sh"

  if [[ ! -f "$tmp/palette.soc" || ! -f "$tmp/install.sh" ]]; then
    echo -e "  ${C_RED}✗${R} Download failed." >&2
    rm -rf "$tmp"; exit 1
  fi

  cp "$tmp/palette.soc" "$CONFIG_DIR"
  bash "$tmp/install.sh" "$flavor" "$accent"

  rm -rf "$tmp"
}

# ── Main ────────────────────────────────────────────────────
banner
pick_flavor "${1:-}"
pick_accent "${2:-}"
echo
apply
echo -e "  ${B}✓${R} ${flavor} / ${accent} applied.\n"   
