#!/usr/bin/env bash
set -e

BUILD_PATH="./app/build/linux/x64/release/bundle"
INSTALL_NAME="cambric-app"

if [ ! -d "" ]; then
    echo "Linux build not found. Run: flutter build linux"
    exit 1
fi

INSTALL_DIR="C:\Users\m/.local/share/"
BIN_DIR="C:\Users\m/.local/bin"
DESKTOP_DIR="C:\Users\m/.local/share/applications"

mkdir -p "" "" ""

cp -r ""/. ""/

MAIN_BINARY="/cambric_app"

if [ ! -f "" ]; then
    echo "Expected Flutter executable was not found: "
    exit 1
fi

cat > "/" <<EOF
#!/usr/bin/env bash
exec "" "\$@"
EOF

chmod +x "/"

cat > "/.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Cambric App
Exec=/
Terminal=false
Categories=Utility;
EOF

chmod +x "/.desktop"

echo "Installed to "
echo "Desktop launcher created."
