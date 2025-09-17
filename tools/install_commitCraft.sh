#!/bin/bash

GITHUB_REPO="Cerebellum-ITM/CommitCraftReborn" # Your GitHub repository (e.g., "pascualchavez/CommitCraft_v2")
# RELEASE_TAG="v0.2.3"                           # The release tag whose source code you want to download (e.g., "v0.1.0")
BINARY_NAME="commitcraft"      # The name of your binary once installed
INSTALL_DIR="$HOME/.local/bin" # Installation directory. Ensure it's in your PATH.

# --- 1. Detect OS and Architecture ---
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
x86_64)
    ARCH="amd64"
    ;;
arm64 | aarch64)
    ARCH="arm64"
    ;;
armv*)
    ARCH="arm"
    ;;
*)
    echo "Error: Architecture '$ARCH' not handled by this script."
    exit 1
    ;;
esac

LATEST_RELEASE_INFO=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")
RELEASE_TAG=$(echo "$LATEST_RELEASE_INFO" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

# --- 2. Construct the binary file name for download ---
DOWNLOAD_FILE_NAME="commitcraft"
case "$OS" in
darwin) # macOS
    if [ "$ARCH" == "amd64" ]; then
        DOWNLOAD_FILE_NAME="${BINARY_NAME}_darwin_amd64"
    elif [ "$ARCH" == "arm64" ]; then
        DOWNLOAD_FILE_NAME="${BINARY_NAME}_darwin_arm64"
    fi
    ;;
linux) # Linux
    if [ "$ARCH" == "amd64" ]; then
        DOWNLOAD_FILE_NAME="${BINARY_NAME}_linux_amd64"
    elif [ "$ARCH" == "arm64" ]; then
        DOWNLOAD_FILE_NAME="${BINARY_NAME}_linux_arm64"
    elif [ "$ARCH" == "arm" ]; then
        DOWNLOAD_FILE_NAME="${BINARY_NAME}_linux_arm32" # Assuming GOARM=7 in the build
    fi
    ;;
windows) # Windows (cross-compiled for .exe)
    if [ "$ARCH" == "amd64" ]; then
        DOWNLOAD_FILE_NAME="${BINARY_NAME}_windows_amd64.exe"
    fi
    ;;
*)
    echo "Error: Operating system '$OS' not handled by this script."
    exit 1
    ;;
esac

if [ -z "$DOWNLOAD_FILE_NAME" ]; then
    echo "Error: No suitable binary name could be constructed for OS='$OS' and ARCH='$ARCH'."
    exit 1
fi

DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/${DOWNLOAD_FILE_NAME}"
echo $DOWNLOAD_URL

# --- 3. Download the binary ---
TEMP_DIR=$(mktemp -d)
TEMP_BINARY_PATH="${TEMP_DIR}/${DOWNLOAD_FILE_NAME}"

# Try curl first, then wget
if command -v curl &>/dev/null; then
    curl -L -o "$TEMP_BINARY_PATH" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
    wget -O "$TEMP_BINARY_PATH" "$DOWNLOAD_URL"
else
    echo "Error: Neither 'curl' nor 'wget' are installed. Please install one to proceed."
    rm -rf "$TEMP_DIR"
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to download the binary from ${DOWNLOAD_URL}."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# --- 4. Make it executable ---
chmod +x "$TEMP_BINARY_PATH"

# --- 5. Move to the correct location ---
mkdir -p "$INSTALL_DIR" # Ensure the installation directory exists

# Use sudo if installing to a system-wide directory
if [[ "$INSTALL_DIR" == "/usr/local/bin" || "$INSTALL_DIR" == "/usr/bin" ]]; then
    sudo mv -f "$TEMP_BINARY_PATH" "$INSTALL_DIR/$BINARY_NAME"
else
    mv -f "$TEMP_BINARY_PATH" "$INSTALL_DIR/$BINARY_NAME"
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to move binary to ${INSTALL_DIR}."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# --- Clean up temporary files ---
rm -rf "$TEMP_DIR"
