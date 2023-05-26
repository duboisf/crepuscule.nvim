# 🌅 Crepuscule.nvim 🌄

> _Crépuscule is french for twilight_

Neovim plugin to change the background color according to the time of day.

This plugin was an excuse to learn Neovim plugin development.

The main motivation for this plugin was that I sometimes use my Chromebook to code and I wanted to have this feature there too. I couldn't find a way from the linux container to determine if dark mode was enabled (it switches on automatically).

## Features

- 🌃 Changes the background between light and dark according to the time of day.
- 🗺️ Uses the ipapi.co API to get the geo coordinates. For now the coordinates are cached permanently!
- ⚡ Uses cache that's persisted to the filesystem for fast bootup

## How it works

1. Geo coordinates are obtained using the ipapi.co API.
2. The sunrise and sunset times are calculated based on the obtained coordinates.
3. The background color is changed according to the time of day.
4. A timer is scheduled to update the background so that the background switches automatically while nvim is open.

The code to calculate the sunrise/sunset was copied from an obscure [forum post](https://forum.logicmachine.net/printthread.php?tid=14). I have no idea if it's correct or not, but it seems to give times that are pretty close to the actual sunset and sunrise times!

For now the geo coordinates are cached permanently as to be nice with the ipapi.co API.

## Aren't there better ways to do this?

Aren't there always? 😅
