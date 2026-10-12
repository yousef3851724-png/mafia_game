#!/usr/bin/env bash
set -e
IM=convert; command -v convert >/dev/null || IM=magick
$IM assets/logo/app_icon.png -resize 1024x1024 -alpha set \( -size 1024x1024 xc:none -fill white -draw "circle 512,512 512,0" \) -compose DstIn -composite assets/logo/app_icon_round.png
$IM assets/logo/app_icon_round.png -resize 660x660 -background none -gravity center -extent 1024x1024 assets/logo/app_icon_fg.png
$IM -size 1024x1024 xc:none assets/logo/app_icon_bg.png
dart run flutter_launcher_icons
