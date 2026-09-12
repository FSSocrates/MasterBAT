#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  catppuccin-lo — Catppuccin theme switcher for LibreOffice
#  Self-contained: downloads only what's needed, no clone.
#  Usage: catppuccin-lo [flavor] [accent]
# ─────────────────────────────────────────────────────────────

set -euo pipefail

BASE="https://raw.githubusercontent.com/catppuccin/libreoffice/main"
CONFIG_DIR=$(ls -d "${XDG_CONFIG_HOME:-$HOME/.config}"/libreoffice/*/user/config 2>/dev/null | head -1)

# ── Colors ──────────────────────────────────────────────────
R=$'\e[0m'  B=$'\e[1m'
C_LATTE=$'\e[38;2;166;124;113m'
C_FRAPPE=$'\e[38;2;166;110;131m'
C_MACCHIATO=$'\e[38;2;178;114;142m'
C_MOCHA=$'\e[38;2;190;105;135m'
C_RED=$'\e[38;2;242;135;145m'

flavors=("latte" "frappe" "macchiato" "mocha")
accents=("rosewater" "flamingo" "red" "maroon" "mauve" "blue" \
         "sapphire" "sky" "teal" "green" "yellow" "peach")

banner() {
  echo
  echo -e "  ${C_MOCHA}░░${R}  ${B}Catppuccin · LibreOffice${R}  ${C_MOCHA}░░${R}"
  echo
}

pick_flavor() {
  if [[ -n "${1:-}" ]]; then flavor="$1"; return; fi
  echo -e "  ${B}Flavor:${R}"
  for i in "${!flavors[@]}"; do
    local f="${flavors[$i]}" c
    case "$f" in
      latte)     c=$C_LATTE ;;
      frappe)    c=$C_FRAPPE ;;
      macchiato) c=$C_MACCHIATO ;;
      mocha)     c=$C_MOCHA ;;
    esac
    echo -e "    $((i+1)). ${c}${B}${f}${R}"
  done
  read -rp "  Choose [1-4]: " n
  flavor="${flavors[$((n-1))]}"
}

pick_accent() {
  if [[ -n "${1:-}" ]]; then accent="$1"; return; fi
  echo -e "  ${B}Accent:${R}"
  for i in "${!accents[@]}"; do
    echo -e "    $((i+1)). ${accents[$i]}"
  done
  read -rp "  Choose [1-12]: " n
  accent="${accents[$((n-1))]}"
}

apply() {
  local tmp; tmp="$(mktemp -d)"
  local soc_url="$BASE/themes/$flavor/$accent/catppuccin-$flavor-$accent.soc"
  local script_url="$BASE/scripts/install_theme.sh"

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
