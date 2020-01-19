#!/bin/sh

set -e

echo "Resetting boot-args..."
nvram -d boot-args
