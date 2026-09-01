#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CHANNEL_FILE="$REPO_DIR/channel.json"
FEED_FILE="$REPO_DIR/hsk-book-audio-feed-v2.xml"

if [ ! -f "$CHANNEL_FILE" ]; then
  echo "Error: channel.json not found at $CHANNEL_FILE"
  exit 1
fi

# Read channel metadata
TITLE=$(jq -r '.title' "$CHANNEL_FILE")
DESCRIPTION=$(jq -r '.description' "$CHANNEL_FILE")
AUTHOR=$(jq -r '.author' "$CHANNEL_FILE")
LANGUAGE=$(jq -r '.language' "$CHANNEL_FILE")
IMAGE=$(jq -r '.image' "$CHANNEL_FILE")
LINK=$(jq -r '.link' "$CHANNEL_FILE")
FEED_URL=$(jq -r '.feed_url' "$CHANNEL_FILE")
EXPLICIT=$(jq -r '.explicit' "$CHANNEL_FILE")

# Build image URL (relative to GitHub Pages)
IMAGE_URL="${LINK}${IMAGE}"

# Start building feed
cat > "$FEED_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
     xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
     xmlns:podcast="https://podcastindex.org/namespace/1.0"
     xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>${TITLE}</title>
    <description>${DESCRIPTION}</description>
    <link>${LINK}</link>
    <language>${LANGUAGE}</language>
    <itunes:author>${AUTHOR}</itunes:author>
    <itunes:summary>${DESCRIPTION}</itunes:summary>
    <itunes:image href="${IMAGE_URL}"/>
    <itunes:category text="${CATEGORY:-Education}">
      <itunes:category text="${SUBCATEGORY:-Language Learning}"/>
    </itunes:category>
    <itunes:explicit>${EXPLICIT}</itunes:explicit>
    <itunes:owner>
      <itunes:name>${AUTHOR}</itunes:name>
    </itunes:owner>
    <podcast:locked>no</podcast:locked>
    <atom:link href="${FEED_URL}" rel="self" xmlns:atom="http://www.w3.org/2005/Atom"/>
EOF

# Read category from channel.json if present
CATEGORY=$(jq -r '.category // "Education"' "$CHANNEL_FILE")
SUBCATEGORY=$(jq -r '.subcategory // "Language Learning"' "$CHANNEL_FILE")

# Find all episode metadata files and sort by episode_number
EPISODE_FILES=()
while IFS= read -r -d '' file; do
  EPISODE_FILES+=("$file")
done < <(find "$REPO_DIR/episodes" -name "metadata.json" -print0 2>/dev/null)

# Sort episodes by episode_number
SORTED_EPISODES=()
for file in "${EPISODE_FILES[@]}"; do
  ep_num=$(jq -r '.episode_number // 999' "$file")
  SORTED_EPISODES+=("${ep_num}:${file}")
done

# Sort numerically
IFS=$'\n' SORTED_EPISODES=($(sort -n -t: -k1 <<<"${SORTED_EPISODES[*]}"))
unset IFS

# Generate episode items
for entry in "${SORTED_EPISODES[@]}"; do
  file="${entry#*:}"
  
  SLUG=$(jq -r '.slug' "$file")
  EP_TITLE=$(jq -r '.title' "$file")
  EP_DESCRIPTION=$(jq -r '.description' "$file")
  YOUTUBE_URL=$(jq -r '.youtube_url // ""' "$file")
  DURATION=$(jq -r '.duration_seconds' "$file")
  AUDIO_URL=$(jq -r '.audio_url // ""' "$file")
  AUDIO_SIZE=$(jq -r '.audio_size_bytes // 0' "$file")
  AUDIO_TYPE=$(jq -r '.audio_type // "audio/mp4"' "$file")
  PUB_DATE=$(jq -r '.pub_date' "$file")
  EP_NUM=$(jq -r '.episode_number // ""' "$file")
  SEASON_NUM=$(jq -r '.season_number // ""' "$file")
  GUID=$(jq -r '.guid // empty' "$file")
  if [ -z "$GUID" ]; then
    GUID="$SLUG"
  fi
  
  # Format duration as HH:MM:SS
  hours=$((DURATION / 3600))
  minutes=$(( (DURATION % 3600) / 60 ))
  seconds=$((DURATION % 60))
  DURATION_FORMATTED=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
  
  # Build chapters URL (served via GitHub Pages)
  CHAPTERS_URL="${LINK}episodes/${SLUG}/chapters.json"
  
  # Check if chapters.json exists
  CHAPTERS_FILE="$REPO_DIR/episodes/${SLUG}/chapters.json"
  HAS_CHAPTERS="false"
  if [ -f "$CHAPTERS_FILE" ]; then
    HAS_CHAPTERS="true"
  fi
  
  # Escape XML special characters in description
  EP_DESCRIPTION_ESCAPED=$(echo "$EP_DESCRIPTION" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  
  # Use audio URL as-is if set, otherwise use placeholder
  if [ -z "$AUDIO_URL" ]; then
    AUDIO_URL="https://github.com/jonathanjbutler/hsk-book-audio-podcast-feed/releases/download/${SLUG}/${SLUG}-chapters.m4a"
  fi
  
  cat >> "$FEED_FILE" << EOF
    <item>
      <title>${EP_TITLE}</title>
      <description>${EP_DESCRIPTION_ESCAPED}</description>
      <enclosure url="${AUDIO_URL}" length="${AUDIO_SIZE}" type="${AUDIO_TYPE}"/>
      <guid isPermaLink="false">${GUID}</guid>
      <pubDate>${PUB_DATE}</pubDate>
      <itunes:title>${EP_TITLE}</itunes:title>
      <itunes:summary>${EP_DESCRIPTION_ESCAPED}</itunes:summary>
      <itunes:duration>${DURATION_FORMATTED}</itunes:duration>
      <itunes:explicit>false</itunes:explicit>
EOF

  if [ -n "$EP_NUM" ] && [ "$EP_NUM" != "null" ]; then
    echo "      <itunes:episode>${EP_NUM}</itunes:episode>" >> "$FEED_FILE"
  fi
  
  if [ -n "$SEASON_NUM" ] && [ "$SEASON_NUM" != "null" ]; then
    echo "      <itunes:season>${SEASON_NUM}</itunes:season>" >> "$FEED_FILE"
  fi
  
  if [ "$HAS_CHAPTERS" = "true" ]; then
    cat >> "$FEED_FILE" << EOF
      <podcast:chapters url="${CHAPTERS_URL}" type="application/json+chapters"/>
EOF
  fi
  
  if [ -n "$YOUTUBE_URL" ] && [ "$YOUTUBE_URL" != "null" ]; then
    echo "      <!-- Source: ${YOUTUBE_URL} -->" >> "$FEED_FILE"
  fi
  
  cat >> "$FEED_FILE" << EOF
    </item>
EOF
done

# Close feed
cat >> "$FEED_FILE" << EOF
  </channel>
</rss>
EOF

echo "Feed generated: $FEED_FILE"
echo "Episodes: ${#SORTED_EPISODES[@]}"
