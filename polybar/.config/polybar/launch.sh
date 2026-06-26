#!/usr/bin/env bash

pkill polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --reload laptop &
polybar --reload monitor &
