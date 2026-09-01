#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AUDIO_DIR="$REPO_DIR/audio"
EPISODES_DIR="$REPO_DIR/episodes"

# --- Argument parsing ---
SLUG="${1:-}"

if [ -z "$SLUG" ]; then
  echo "Usage: bash scripts/publish-release.sh <episode-slug>"
  echo ""
  echo "Available episodes:"
  for dir in "$EPISODES_DIR"/*/; do
    if [ -f "$dir/metadata.json" ]; then
      ep_slug=$(jq -r '.slug' "$dir/metadata.json")
      ep_title=$(jq -r '.title' "$dir/metadata.json")
      echo "  $ep_slug - $ep_title"
    fi
  done
  exit 1
fi

# --- Load episode metadata ---
EPISODE_DIR="$EPISODES_DIR/$SLUG"
METADATA_FILE="$EPISODE_DIR/metadata.json"

if [ ! -f "$METADATA_FILE" ]; then
  echo "Error: Episode metadata not found: $METADATA_FILE"
  exit 1
fi

TITLE=$(jq -r '.title' "$METADATA_FILE")
DESCRIPTION=$(jq -r '.description' "$METADATA_FILE")
AUDIO_FILE_NAME=$(jq -r '.audio_file' "$METADATA_FILE")
AUDIO_FILE="$AUDIO_DIR/$AUDIO_FILE_NAME"
AUDIO_SIZE=$(jq -r '.audio_size_bytes' "$METADATA_FILE")
YOUTUBE_URL=$(jq -r '.youtube_url // ""' "$METADATA_FILE")

echo "Episode: $TITLE"
echo "Audio: $AUDIO_FILE"

if [ ! -f "$AUDIO_FILE" ]; then
  echo "Error: Audio file not found: $AUDIO_FILE"
  echo "Run add-episode.sh first to download and prepare the audio."
  exit 1
fi

# --- Build release notes ---
RELEASE_NOTES="$DESCRIPTION"
if [ -n "$YOUTUBE_URL" ] && [ "$YOUTUBE_URL" != "null" ]; then
  RELEASE_NOTES+="\n\nSource: $YOUTUBE_URL"
fi

# --- Check if release already exists ---
echo ""
echo "Checking for existing release..."
if gh release view "$SLUG" --repo jonathanjbutler/hsk-book-audio-podcast-feed &>/dev/null; then
  echo "Release '$SLUG' already exists."
  read -p "Update release assets? (y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  
  echo "Uploading updated audio..."
  gh release upload "$SLUG" "$AUDIO_FILE" \
    --repo jonathanjbutler/hsk-book-audio-podcast-feed \
    --clobber
else
  echo "Creating new release..."
  echo -e "$RELEASE_NOTES" | gh release create "$SLUG" "$AUDIO_FILE" \
    --repo jonathanjbutler/hsk-book-audio-podcast-feed \
    --title "$TITLE" \
    --notes-file -
fi

# --- Get the release asset URL ---
echo ""
echo "Getting release URL..."
RELEASE_URL="https://github.com/jonathanjbutler/hsk-book-audio-podcast-feed/releases/download/${SLUG}/${AUDIO_FILE_NAME}"
echo "Audio URL: $RELEASE_URL"

# --- Update metadata with actual audio URL ---
echo "Updating metadata.json with audio URL..."
jq --arg url "$RELEASE_URL" '.audio_url = $url' "$METADATA_FILE" > "$METADATA_FILE.tmp"
mv "$METADATA_FILE.tmp" "$METADATA_FILE"

# --- Regenerate feed ---
echo "Regenerating hsk-book-audio-feed-v2.xml..."
bash "$SCRIPT_DIR/generate-feed.sh"

# --- Git commit and push ---
echo ""
echo "Committing and pushing..."
cd "$REPO_DIR"
git add -A
git commit -m "Add episode: $TITLE

- Audio uploaded to GitHub Release: $SLUG
- Feed updated with episode metadata
- Chapters embedded in M4A file"
git push origin main

# --- Summary ---
echo ""
echo "=========================================="
echo "Episode published!"
echo "=========================================="
echo "Release: https://github.com/jonathanjbutler/hsk-book-audio-podcast-feed/releases/tag/$SLUG"
echo "Feed: https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-book-audio-feed-v2.xml"
echo ""
echo "Subscribe in Overcast:"
echo "  https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-book-audio-feed-v2.xml"
echo "=========================================="
