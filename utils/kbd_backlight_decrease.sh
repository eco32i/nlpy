#!/bin/bash

val=$(cat /sys/class/leds/asus::kbd_backlight/brightness)
if [ 0 -lt $val  ]
then
    val=$(($val - 1))
    echo $val | tee /sys/class/leds/asus::kbd_backlight/brightness
fi
