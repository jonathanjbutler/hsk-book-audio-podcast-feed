#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AUDIO_DIR="$REPO_DIR/audio"
EPISODES_DIR="$REPO_DIR/episodes"

# --- Argument parsing ---
YOUTUBE_URL="${1:-}"
CHAPTER_INPUT="${2:-}"  # optional: file path or "-" for stdin

if [ -z "$YOUTUBE_URL" ]; then
  echo "Usage: bash scripts/add-episode.sh <youtube-url> [chapter-file|-]"
  echo ""
  echo "Chapters can be provided as:"
  echo "  - A file path with one chapter per line: 'MM:SS Title'"
  echo "  - '-' to read from stdin"
  echo "  - Omitted to be prompted interactively"
  exit 1
fi

# --- Extract video metadata ---
echo "Fetching video metadata..."
VIDEO_JSON=$(yt-dlp --dump-json --no-download "$YOUTUBE_URL" 2>/dev/null)
VIDEO_TITLE=$(echo "$VIDEO_JSON" | jq -r '.title')
VIDEO_DURATION=$(echo "$VIDEO_JSON" | jq -r '.duration')
VIDEO_DESCRIPTION=$(echo "$VIDEO_JSON" | jq -r '.description // ""')
VIDEO_ID=$(echo "$VIDEO_JSON" | jq -r '.id')

echo "Title: $VIDEO_TITLE"
echo "Duration: ${VIDEO_DURATION}s"
echo "Video ID: $VIDEO_ID"

# --- Generate slug from title ---
# For HSK content, try to extract a meaningful slug
SLUG=$(echo "$VIDEO_TITLE" | \
  tr '[:upper:]' '[:lower:]' | \
  python3 -c "import sys,re; print(re.sub(r'[^a-z0-9]', '-', sys.stdin.read().strip()).strip('-'))" | \
  sed 's/--*/-/g' | \
  cut -c1-50)

# If slug is too generic, use video ID
if [ ${#SLUG} -lt 3 ]; then
  SLUG="episode-${VIDEO_ID}"
fi

echo "Slug: $SLUG"

# --- Create episode directory ---
EPISODE_DIR="$EPISODES_DIR/$SLUG"
mkdir -p "$EPISODE_DIR"

# --- Download audio ---
echo ""
echo "Downloading audio (best M4A quality)..."
AUDIO_FILE="$AUDIO_DIR/${SLUG}.m4a"
yt-dlp -f 140 \
  --no-post-overwrites \
  -o "$AUDIO_FILE" \
  "$YOUTUBE_URL" 2>&1 | tail -3

if [ ! -f "$AUDIO_FILE" ]; then
  echo "Error: Failed to download audio"
  exit 1
fi

AUDIO_SIZE=$(stat -f%z "$AUDIO_FILE" 2>/dev/null || stat -c%s "$AUDIO_FILE" 2>/dev/null)
echo "Downloaded: $AUDIO_FILE ($AUDIO_SIZE bytes)"

# --- Parse chapters ---
echo ""
echo "Parsing chapters..."

CHAPTERS_JSON_FILE="$EPISODE_DIR/chapters.json"
CHAPTERS_FFMETA_FILE="$EPISODE_DIR/chapters.ffmeta"

# Function to parse chapter lines into JSON
parse_chapters() {
  local input="$1"
  local chapters_json='{"version":"1.2.0","chapters":[]}'
  local prev_seconds=0
  
  while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue
    
    # Match timestamps: MM:SS or HH:MM:SS at start of line
    if [[ "$line" =~ ^([0-9]+):([0-9]+):([0-9]+)[[:space:]]+(.*) ]]; then
      hours=$((10#${BASH_REMATCH[1]}))
      minutes=$((10#${BASH_REMATCH[2]}))
      seconds=$((10#${BASH_REMATCH[3]}))
      title="${BASH_REMATCH[4]}"
      total_seconds=$((hours * 3600 + minutes * 60 + seconds))
    elif [[ "$line" =~ ^([0-9]+):([0-9]+)[[:space:]]+(.*) ]]; then
      minutes=$((10#${BASH_REMATCH[1]}))
      seconds=$((10#${BASH_REMATCH[2]}))
      title="${BASH_REMATCH[3]}"
      total_seconds=$((minutes * 60 + seconds))
    else
      continue
    fi
    
    # Trim whitespace from title
    title=$(echo "$title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    chapters_json=$(echo "$chapters_json" | jq \
      --argjson start "$total_seconds" \
      --arg title "$title" \
      '.chapters += [{"startTime": $start, "title": $title}]')
    
    prev_seconds=$total_seconds
  done <<< "$input"
  
  echo "$chapters_json"
}

# Function to generate ffmpeg metadata
generate_ffmeta() {
  local chapters_json="$1"
  local duration="$2"
  local ffmeta=";FFMETADATA1\n"
  
  local count=$(echo "$chapters_json" | jq '.chapters | length')
  
  for ((i=0; i<count; i++)); do
    start=$(echo "$chapters_json" | jq -r ".chapters[$i].startTime")
    title=$(echo "$chapters_json" | jq -r ".chapters[$i].title")
    
    # End time is either next chapter start or video duration
    if [ $((i+1)) -lt "$count" ]; then
      end=$(echo "$chapters_json" | jq -r ".chapters[$((i+1))].startTime")
    else
      end="$duration"
    fi
    
    # Convert to milliseconds for ffmpeg
    start_ms=$((start * 1000))
    end_ms=$((end * 1000))
    
    ffmeta+="[CHAPTER]\n"
    ffmeta+="TIMEBASE=1/1000\n"
    ffmeta+="START=${start_ms}\n"
    ffmeta+="END=${end_ms}\n"
    ffmeta+="title=${title}\n"
  done
  
  echo -e "$ffmeta"
}

# Get chapters from input
CHAPTER_LINES=""
if [ -n "$CHAPTER_INPUT" ] && [ "$CHAPTER_INPUT" = "-" ]; then
  echo "Reading chapters from stdin..."
  CHAPTER_LINES=$(cat)
elif [ -n "$CHAPTER_INPUT" ] && [ -f "$CHAPTER_INPUT" ]; then
  echo "Reading chapters from file: $CHAPTER_INPUT"
  CHAPTER_LINES=$(cat "$CHAPTER_INPUT")
else
  # Try to extract from video description
  echo "Checking video description for chapters..."
  DESC_CHAPTERS=$(echo "$VIDEO_DESCRIPTION" | grep -E '^[0-9]+:[0-9]+' || true)
  
  if [ -n "$DESC_CHAPTERS" ]; then
    echo "Found chapters in video description:"
    echo "$DESC_CHAPTERS"
    echo ""
    read -p "Use these chapters? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      CHAPTER_LINES="$DESC_CHAPTERS"
    fi
  fi
  
  if [ -z "$CHAPTER_LINES" ]; then
    echo "Enter chapter timestamps (one per line, format: MM:SS Title or HH:MM:SS Title)"
    echo "Press Ctrl+D when done:"
    CHAPTER_LINES=$(cat)
  fi
fi

if [ -z "$CHAPTER_LINES" ]; then
  echo "Warning: No chapters provided. Creating episode without chapters."
  CHAPTERS='{"version":"1.2.0","chapters":[]}'
else
  CHAPTERS=$(parse_chapters "$CHAPTER_LINES")
  CHAPTER_COUNT=$(echo "$CHAPTERS" | jq '.chapters | length')
  echo "Parsed $CHAPTER_COUNT chapters"
fi

# Save chapters.json
echo "$CHAPTERS" | jq '.' > "$CHAPTERS_JSON_FILE"
echo "Saved: $CHAPTERS_JSON_FILE"

# Generate and save ffmpeg metadata
FFMETA=$(generate_ffmeta "$CHAPTERS" "$VIDEO_DURATION")
echo -e "$FFMETA" > "$CHAPTERS_FFMETA_FILE"
echo "Saved: $CHAPTERS_FFMETA_FILE"

# --- Embed chapters into M4A ---
echo ""
echo "Embedding chapters into M4A..."
CHAPTERS_AUDIO_FILE="$AUDIO_DIR/${SLUG}-chapters.m4a"

ffmpeg -y \
  -i "$AUDIO_FILE" \
  -i "$CHAPTERS_FFMETA_FILE" \
  -map_metadata 1 \
  -codec copy \
  "$CHAPTERS_AUDIO_FILE" 2>/dev/null

if [ ! -f "$CHAPTERS_AUDIO_FILE" ]; then
  echo "Error: Failed to embed chapters"
  exit 1
fi

CHAPTERS_AUDIO_SIZE=$(stat -f%z "$CHAPTERS_AUDIO_FILE" 2>/dev/null || stat -c%s "$CHAPTERS_AUDIO_FILE" 2>/dev/null)
echo "Created: $CHAPTERS_AUDIO_FILE ($CHAPTERS_AUDIO_SIZE bytes)"

# --- Build description with timestamps ---
DESCRIPTION="$VIDEO_TITLE"
if [ -n "$CHAPTER_LINES" ]; then
  DESCRIPTION+="\n\nTimestamps:\n$CHAPTER_LINES"
fi
if [ -n "$YOUTUBE_URL" ]; then
  DESCRIPTION+="\n\nSource: $YOUTUBE_URL"
fi

# --- Determine episode/season numbers ---
# Try to extract from title (e.g., "HSK 4 上" -> season 4)
SEASON_NUM=""
if [[ "$SLUG" =~ hsk-([0-9]+) ]]; then
  SEASON_NUM="${BASH_REMATCH[1]}"
fi

# Count existing episodes for episode number
EXISTING_EPISODES=$(find "$EPISODES_DIR" -name "metadata.json" 2>/dev/null | wc -l | tr -d ' ')
EPISODE_NUM=$((EXISTING_EPISODES + 1))

# --- Create metadata.json ---
PUB_DATE=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")

cat > "$EPISODE_DIR/metadata.json" << EOF
{
  "slug": "$SLUG",
  "title": "$VIDEO_TITLE",
  "description": $(echo -e "$DESCRIPTION" | jq -Rs .),
  "youtube_url": "$YOUTUBE_URL",
  "youtube_id": "$VIDEO_ID",
  "duration_seconds": $VIDEO_DURATION,
  "audio_file": "${SLUG}-chapters.m4a",
  "audio_url": "",
  "audio_size_bytes": $CHAPTERS_AUDIO_SIZE,
  "audio_type": "audio/mp4",
  "pub_date": "$PUB_DATE",
  "episode_number": $EPISODE_NUM,
  "season_number": ${SEASON_NUM:-null}
}
EOF

echo ""
echo "Created: $EPISODE_DIR/metadata.json"

# --- Regenerate feed ---
echo ""
echo "Regenerating hsk-book-audio-feed.xml..."
bash "$SCRIPT_DIR/generate-feed.sh"

# --- Summary ---
echo ""
echo "=========================================="
echo "Episode created successfully!"
echo "=========================================="
echo "Slug: $SLUG"
echo "Audio: $CHAPTERS_AUDIO_FILE"
echo "Chapters: $CHAPTERS_JSON_FILE"
echo "Metadata: $EPISODE_DIR/metadata.json"
echo ""
echo "Next steps:"
echo "  1. Review the episode in episodes/$SLUG/"
echo "  2. Run: bash scripts/publish-release.sh $SLUG"
echo "=========================================="
