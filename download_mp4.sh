#!/usr/bin/env bash
# Download an .mp4 file from a given URL.
# Usage: ./download_mp4.sh <url> [output_filename]

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <url> [output_filename]"
    exit 1
fi

URL="$1"

# Determine output filename
if [[ $# -ge 2 ]]; then
    OUTPUT="$2"
else
    # Extract filename from URL, fallback to video.mp4
    OUTPUT=$(basename "${URL%%\?*}")  # strip query params first
    if [[ ! "$OUTPUT" =~ \.mp4$ ]]; then
        OUTPUT="video.mp4"
    fi
fi

echo "Downloading: $URL"
echo "Saving to:   $OUTPUT"

# Prefer curl, fall back to wget
if command -v curl &>/dev/null; then
    curl -L --progress-bar -o "$OUTPUT" "$URL"
elif command -v wget &>/dev/null; then
    wget --show-progress -O "$OUTPUT" "$URL"
else
    echo "Error: neither curl nor wget found. Install one and try again."
    exit 1
fi

echo "Done! Saved to $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
