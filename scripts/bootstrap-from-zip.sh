#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 /path/to/parallel-computing-lab.zip /destination/directory"
    exit 2
fi

ZIP_PATH="$1"
DEST_DIR="$2"

if [[ ! -f "$ZIP_PATH" ]]; then
    echo "Error: zip file not found: $ZIP_PATH"
    exit 1
fi

mkdir -p "$DEST_DIR"
unzip -o "$ZIP_PATH" -d "$DEST_DIR"

# The archive contains the top-level parallel-computing-lab/ directory.
PROJECT_DIR="$DEST_DIR/parallel-computing-lab"
if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: expected project directory was not found after extraction."
    exit 1
fi

chmod +x "$PROJECT_DIR/run.sh" "$PROJECT_DIR/scripts/"*.sh
echo "Extracted to: $PROJECT_DIR"
echo "Next:"
echo "  cd \"$PROJECT_DIR\""
echo "  ./scripts/setup.sh"
