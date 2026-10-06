#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
: "${CONNECTIQ_SDK:?Set CONNECTIQ_SDK to your Connect IQ SDK directory}"
mkdir -p dist/barrel
"$CONNECTIQ_SDK/bin/barrelbuild" --no-gen-styles -f monkey.jungle -o dist/barrel/ConnectIQComponents-0.1.0.barrel
cp dist/barrel/ConnectIQComponents-0.1.0.barrel dist/ConnectIQComponents-0.1.0.barrel
if [ -n "${CONNECTIQ_KEY:-}" ]; then
  for device in venu3 fenix7; do
    "$CONNECTIQ_SDK/bin/monkeyc" -f examples/showcase/monkey.jungle -d "$device" -y "$CONNECTIQ_KEY" -o "dist/showcase-$device.prg"
  done
fi
