#!/usr/bin/env sh
set -e

APP_NAME=nodup
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
WRAPPER="$BIN_DIR/$APP_NAME"

echo "▶ Creating pipenv environment..."
pipenv install .

echo "▶ Ensuring $BIN_DIR exists..."
mkdir -p "$BIN_DIR"

echo "▶ Generating wrapper script..."

sed \
  -e "s|{{APP_NAME}}|$APP_NAME|g" \
  -e "s|{{PROJECT_DIR}}|$PROJECT_DIR|g" \
  "$PROJECT_DIR/wrapper.tmpl" > "$WRAPPER"

chmod +x "$WRAPPER"

echo "✅ Installed $APP_NAME"
echo "➡ Run: $APP_NAME --help"
echo "➡ Ensure ~/.local/bin is in your PATH"
