# HSK Book Audio Podcast Feed — Handoff

## Overview

This repo hosts a self-generated podcast feed of HSK Standard Course textbook audio, sourced from YouTube. Episodes are downloaded as M4A with chapters embedded, stored in GitHub Releases, and served via a podcast RSS feed on GitHub Pages.

## Architecture

```
hsk-book-audio-podcast-feed/
├── scripts/
│   ├── add-episode.sh       # Download audio, parse chapters, embed in M4A, create metadata
│   ├── generate-feed.sh     # Rebuild feed.xml from all episodes/*/metadata.json
│   └── publish-release.sh   # Upload audio to GitHub Release, update feed, commit+push
├── episodes/
│   ├── hsk-1/               # One folder per episode
│   │   ├── metadata.json    # Episode metadata (slug, title, episode_number, pub_date, etc.)
│   │   └── chapters.json    # Podcasting 2.0 chapter markers
│   ├── hsk-2/
│   ├── hsk-3/
│   ├── hsk-4-shang/
│   └── hsk-4-xia/
├── audio/                   # Local staging (gitignored, audio lives in GitHub Releases)
├── artwork/
│   └── cover.png            # 1400x1400 podcast cover art
├── channel.json             # Podcast-level metadata (title, author, description, etc.)
├── feed.xml                 # Generated RSS feed (served by GitHub Pages)
└── .gitignore
```

## Key URLs

| Resource | URL |
|---|---|
| Repo | https://github.com/jonathanjbutler/hsk-book-audio-podcast-feed |
| Feed (subscribe in Overcast) | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/feed.xml |
| Cover art | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/artwork/cover.png |
| Chapter JSON example | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/episodes/hsk-1/chapters.json |

## Current Episodes

| # | Slug | Title | Season | YouTube Source |
|---|---|---|---|---|
| 1 | hsk-1 | HSK 1 Full Book Audio | 1 | https://www.youtube.com/watch?v=p_MsNhe7s0A |
| 2 | hsk-2 | HSK 2 Full Book Audio | 1 | https://www.youtube.com/watch?v=3nW_BFZZT_I |
| 3 | hsk-3 | HSK 3 Full Book Audio | 1 | https://www.youtube.com/watch?v=LprYHlO4urs |
| 4 | hsk-4-shang | HSK 4 上 Full Book Audio | 1 | https://www.youtube.com/watch?v=fpMa1m3tm4A |
| 5 | hsk-4-xia | HSK 4 下 Full Book Audio | 1 | https://www.youtube.com/watch?v=xU6nXfatALY |

All episodes are in **season 1** with sequential episode numbers. Pub dates are staggered by 1 hour each so episode 1 appears first (newest date).

## How to Add a New Episode

### 1. Run add-episode.sh

Pipe chapter timestamps into the script (format: `MM:SS Title` or `HH:MM:SS Title`):

```bash
cd ~/projects/hsk-book-audio-podcast-feed

echo "00:10 LESSON 1
5:29 LESSON 2
13:42 LESSON 3" | bash scripts/add-episode.sh "https://www.youtube.com/watch?v=VIDEO_ID" -
```

The script will:
- Download best M4A audio via yt-dlp (format 140, 129kbps/44kHz)
- Parse chapter timestamps
- Embed chapters into the M4A file via ffmpeg
- Create `episodes/<slug>/metadata.json` and `chapters.json`
- Regenerate `feed.xml`

### 2. Rename slug if needed

The slug is auto-generated from the video title. Rename it to something cleaner:

```bash
OLD_SLUG="auto-generated-slug"
NEW_SLUG="hsk-5"  # or whatever makes sense

mv "episodes/$OLD_SLUG" "episodes/$NEW_SLUG"
mv "audio/$OLD_SLUG.m4a" "audio/$NEW_SLUG.m4a"
mv "audio/${OLD_SLUG}-chapters.m4a" "audio/${NEW_SLUG}-chapters.m4a"

# Update metadata
jq --arg slug "$NEW_SLUG" --arg file "${NEW_SLUG}-chapters.m4a" \
  '.slug = $slug | .audio_file = $file' \
  "episodes/$NEW_SLUG/metadata.json" > tmp.json && \
mv tmp.json "episodes/$NEW_SLUG/metadata.json"
```

### 3. Set episode number and season

```bash
# Set this episode's number and season
jq '.episode_number = 6 | .season_number = 1 | .pub_date = "Wed, 02 Sep 2026 00:00:00 +0000"' \
  episodes/hsk-5/metadata.json > tmp.json && mv tmp.json episodes/hsk-5/metadata.json

# Regenerate feed
bash scripts/generate-feed.sh
```

**Important**: Episode ordering depends on `pub_date` (newest first). Each new episode should have an earlier pub_date than the previous one, OR update all episodes to have sequential dates.

### 4. Publish

```bash
bash scripts/publish-release.sh hsk-5
```

This will:
- Create a GitHub Release with the M4A as an asset
- Update `metadata.json` with the real audio URL
- Regenerate `feed.xml`
- Commit and push to GitHub

## Technical Details

### Audio Format
- **Format**: M4A (AAC), format 140 from YouTube
- **Quality**: 129kbps, 44kHz — best available M4A
- **Chapters**: Embedded in M4A via ffmpeg + Podcasting 2.0 JSON

### Feed Format
- RSS 2.0 with `xmlns:itunes` and `xmlns:podcast` namespaces
- `<podcast:chapters>` points to chapters.json served via GitHub Pages
- `<enclosure>` points to GitHub Release asset URL

### Dependencies
- **yt-dlp**: Download YouTube audio (installed at `/opt/homebrew/bin/yt-dlp`)
- **ffmpeg**: Embed chapters into M4A (installed at `/opt/homebrew/bin/ffmpeg`)
- **jq**: JSON parsing (installed at `/opt/homebrew/bin/jq`)
- **gh**: GitHub CLI for releases (installed, authenticated as `jonathanjbutler`)

### Known Issues / Notes
- The `add-episode.sh` script uses `10#` prefix for bash arithmetic to avoid octal parsing errors with leading zeros (e.g., "09")
- GitHub Pages can take 10-20 seconds to deploy after a push
- Use cache-busting query param when checking feed: `?$(date +%s)`
- Cover art was generated with Python Pillow (installed via `pip3 install --break-system-packages Pillow`)

## TODO — Videos to Add

- [ ] https://www.youtube.com/watch?v=_HPB7RKr5sg
- [ ] https://www.youtube.com/watch?v=5W8Y6QMrNyE
- [ ] https://www.youtube.com/watch?v=M3IK6v_kNbQ
- [ ] https://www.youtube.com/watch?v=Se1gZMmb38k

For each video:
1. Find chapter timestamps (in video description or comments)
2. Run `add-episode.sh` with the URL and timestamps
3. Rename slug to match HSK level (e.g., `hsk-5`, `hsk-6`)
4. Set correct episode number
5. Publish with `publish-release.sh`

## Podcast App Setup

**Overcast**: Add feed URL `https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/feed.xml`

Chapters will appear natively in Overcast's chapter navigation.

## Repo Local Path

```
~/projects/hsk-book-audio-podcast-feed
```
