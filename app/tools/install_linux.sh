#!/usr/bin/env bash
# Linux installation helper for Cambric app projects.
# Run from the repository root after building the Linux application.
set -e

BUILD_PATH="./app/build/linux/x64/release/bundle"
INSTALL_NAME="cambric-app"
DISPLAY_NAME="Cambric App"

if [ ! -d "$BUILD_PATH" ]; then
    echo "Linux build not found at $BUILD_PATH"
    echo "Run: cd app && flutter build linux --release"
    exit 1
fi

INSTALL_DIR="$HOME/.local/share/$INSTALL_NAME"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$DESKTOP_DIR"

# Copy bundle
cp -r "$BUILD_PATH/." "$INSTALL_DIR/"

# Detect the main executable (Flutter Linux produces 'cambric_app' by default)
MAIN_BINARY="$INSTALL_DIR/cambric_app"

if [ ! -f "$MAIN_BINARY" ]; then
    echo "Expected Flutter executable was not found: $MAIN_BINARY"
    echo "Check the binary name in $INSTALL_DIR and update MAIN_BINARY in this script."
    exit 1
fi

# Create wrapper script in ~/.local/bin
WRAPPER="$BIN_DIR/$INSTALL_NAME"
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
exec "$MAIN_BINARY" "\$@"
EOF
chmod +x "$WRAPPER"

# Create .desktop launcher
DESKTOP_FILE="$DESKTOP_DIR/$INSTALL_NAME.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$DISPLAY_NAME
Exec=$MAIN_BINARY
Terminal=false
Categories=Utility;
EOF
chmod +x "$DESKTOP_FILE"

echo "Installed to: $INSTALL_DIR"
echo "Wrapper script: $WRAPPER"
echo "Desktop launcher: $DESKTOP_FILE"
