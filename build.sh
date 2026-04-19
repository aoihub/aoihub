#!/bin/bash
# Configuration
RAW_FOLDER="raw"
INPUT_FILE="./$RAW_FOLDER/AoiHub_RAW.lua"
OUTPUT_DIR="./src"
FINAL_NAME="obfuscated.lua"
CLI_PATH="./Prometheus/cli.lua"
GITIGNORE=".gitignore"

echo "--- AoiHub Secure Build Tool ---"

# 1. Safety Check: .gitignore
if [ ! -f "$GITIGNORE" ]; then
    echo "ERROR: .gitignore file not found! Create one first to protect your source."
    exit 1
fi

if ! grep -q "^$RAW_FOLDER/" "$GITIGNORE"; then
    echo "--------------------------------------------------------"
    echo "CRITICAL SECURITY ERROR: '$RAW_FOLDER/' is not in .gitignore!"
    echo "To prevent leaking your source code, add it now:"
    echo "echo '$RAW_FOLDER/' >> .gitignore"
    echo "--------------------------------------------------------"
    exit 1
fi

# 2. Safety Check: Prometheus CLI
if [ ! -f "$CLI_PATH" ]; then
    echo "ERROR: Prometheus CLI not found at $CLI_PATH."
    exit 1
fi

# 3. Preset Selection
echo "Select Obfuscation Preset:"
echo "1) Medium (Best for GUI/Scanners)"
echo "2) Strong (Maximum Security)"
read -p "Enter choice [1-2]: " choice

case $choice in
    1) PRESET="Medium" ;;
    2) PRESET="Strong" ;;
    *) echo "Invalid choice, exiting."; exit 1 ;;
esac

# 4. Obfuscation Process
echo "Obfuscating $INPUT_FILE..."
lua "$CLI_PATH" --preset "$PRESET" "$INPUT_FILE"

TEMP_OUT="./$RAW_FOLDER/AoiHub_RAW.obfuscated.lua"

# 5. Move and Git Push
if [ -f "$TEMP_OUT" ]; then
    mkdir -p "$OUTPUT_DIR"
    mv "$TEMP_OUT" "$OUTPUT_DIR/$FINAL_NAME"
    
    echo "Pushing obfuscated build to Git..."
    git add "$OUTPUT_DIR/$FINAL_NAME"
    git commit -m "Build: AoiHub (Update)"
    git push
    
    echo "SUCCESS: Obfuscated script pushed to repository."
else
    echo "ERROR: Obfuscation failed. Check Prometheus output above."
    exit 1
fi
