#!/bin/bash

echo "🚀 Starting BioNode AI Vercel Build..."

# 1. Download the Flutter SDK
echo "⬇️ Downloading Flutter SDK (Stable Channel)..."
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add Flutter to PATH for this script execution
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable Web support in Flutter
echo "⚙️ Configuring Flutter Web..."
flutter config --enable-web

# 4. Resolve dependencies
echo "📦 Injecting dependencies..."
flutter pub get

# 5. Build the Web version
echo "🔨 Compiling Flutter Web Application..."
flutter build web --release --web-renderer canvaskit

echo "✅ Build Complete! Outward directory set to build/web"
