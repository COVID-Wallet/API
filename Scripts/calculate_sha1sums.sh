#!/bin/sh

echo "➜ Image Resource SHA1Sums:"
shasum ../Resources/Templates/*.pass/*.png

echo ""
echo "➜ Translations SHA1Sums:"

shasum ../Resources/Templates/*.pass/*/*
