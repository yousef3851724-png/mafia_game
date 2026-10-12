#!/usr/bin/env bash
set -euo pipefail

# The canonical Mafia Radical app icon is stored in assets/images/.
# Generate adaptive launcher-icon resources under assets/logo/.
SOURCE_ICON="assets/images/app_icon.png"
OUTPUT_DIR="assets/logo"

if [[ ! -s "$SOURCE_ICON" ]]; then
  echo "::error::Canonical app icon not found: $SOURCE_ICON"
  echo "Check that the app icon exists in the repository before generating launcher icons."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

IM=convert
command -v convert >/dev/null 2>&1 || IM=magick
command -v "$IM" >/dev/null 2>&1 || {
  echo "::error::ImageMagick convert/magick command is unavailable"
  exit 1
}

# Use a temporary alpha mask instead of shell-escaped ImageMagick parentheses.
# This avoids Bash parsing failures in CI and keeps intermediate images out of assets/.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

"$IM" "$SOURCE_ICON" -resize 1024x1024 -alpha set "$TMP_DIR/app_icon_source.png"
"$IM" -size 1024x1024 xc:none -fill white -draw "circle 512,512 512,0" "$TMP_DIR/app_icon_mask.png"
"$IM" "$TMP_DIR/app_icon_source.png" "$TMP_DIR/app_icon_mask.png" -compose DstIn -composite "$OUTPUT_DIR/app_icon_round.png"
"$IM" "$OUTPUT_DIR/app_icon_round.png" -resize 660x660 -background none -gravity center -extent 1024x1024 "$OUTPUT_DIR/app_icon_fg.png"
"$IM" -size 1024x1024 xc:none "$OUTPUT_DIR/app_icon_bg.png"

dart run flutter_launcher_icons
