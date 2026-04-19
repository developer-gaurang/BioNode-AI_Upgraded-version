#!/bin/bash

echo "🚀 Starting BioNode AI Vercel Build (Optimized Binary Mode)..."

# 1. Download the pre-compiled Flutter SDK to avoid Git timeout limits
echo "⬇️ Downloading Flutter SDK Tarball..."
curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz | tar xJ

# 2. Add Flutter precisely to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Resolve dependencies
echo "📦 Injecting dependencies..."
flutter config --no-analytics
flutter pub get

# 4. Build the Web version
echo "🔨 Compiling Flutter Web Application..."
flutter build web --release

echo "✅ Build Complete! Outward directory is build/web"
