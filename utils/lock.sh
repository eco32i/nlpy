#!/bin/bash

IMAGE=/tmp/i3lock.png
SCREENSHOT="scrot $IMAGE"

BLURTYPE="12x18"

$SCREENSHOT
convert $IMAGE -blur $BLURTYPE $IMAGE
i3lock -i $IMAGE
rm $IMAGE
