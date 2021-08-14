#!/bin/sh

echo "➜ Image Resource SHA1Sums:"
shasum ../Resources/*.pass/*.png

echo ""
echo "➜ Translations SHA1Sums:"

shasum ../Resources/*.pass/*/*
