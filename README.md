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

It gets the geo coordinates using the ipapi.co API (super nice API!) and then calculates the sunrise and suntset times.

The code to calculate the sunrise/sunset was copied from an obscure [forum post](https://forum.logicmachine.net/printthread.php?tid=14). I don't know if it's correct or not, but it seems to give times enough for me!

For now the geo coordinates are cached permanently as to be nice with the ipapi.co API.

The background color is changed according to the time of day.

A timer is scheduled to update the background so that the background switches automatically while nvim is open.

## Aren't there better ways to do this?

Aren't there always? 😅
