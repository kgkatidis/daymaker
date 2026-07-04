#!/bin/bash
# DayMaker macOS Build Script
# © 2026 Konstantinos Gkatidis. All rights reserved.

set -e

echo ""
echo "☀️  DayMaker macOS Builder"
echo "══════════════════════════"
echo ""

echo "📦 Installing dependencies..."
pip install -q customtkinter pyinstaller pillow

echo "🔨 Building DayMaker.app..."
pyinstaller \
  --windowed \
  --name "DayMaker" \
  --onedir \
  --clean \
  --noconfirm \
  --hidden-import customtkinter \
  --hidden-import PIL \
  --collect-all customtkinter \
  daymaker.py

echo ""
echo "✅ Done! DayMaker.app is in dist/"
echo ""

if [ -d "dist/DayMaker.app" ]; then
  echo "📂 Opening dist/ folder..."
  open dist/
fi
