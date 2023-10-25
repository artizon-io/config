#!/usr/bin/env bash

# Wallpaper
swww init &
swww img ~/Desktop/Desktop-background/sand-wave.jpg &

# Network manager applet
nm-applet --indicator &

# Waybar
# waybar &

# Notifications
dunst &

# wl-clipboard + cliphist (a clipboard manager for wayland)
# https://github.com/sentriz/cliphist
wl-paste --watch cliphist store &

# Day/night gamma adjustments
# https://www.mankier.com/1/wlsunset
wlsunset -S "06:30" -s "18:30" -T 6500 -t 4600 &

# Key remap
# sudo xremap ~/.config/xremap/config.yml &