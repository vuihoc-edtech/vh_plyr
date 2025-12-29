#!/bin/bash
# Sync web files to mobile assets before build
# Run this before `flutter build` if symlink doesn't work

SOURCE_DIR="$(dirname "$0")/web"
TARGET_DIR="$(dirname "$0")/mobile/assets/player"

echo "Syncing web files to mobile assets..."

# Remove existing directory/symlink and create fresh copy
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp "$SOURCE_DIR"/*.html "$TARGET_DIR/"
cp "$SOURCE_DIR"/*.js "$TARGET_DIR/"
cp "$SOURCE_DIR"/*.css "$TARGET_DIR/"

echo "Done! Files synced:"
ls -la "$TARGET_DIR"
