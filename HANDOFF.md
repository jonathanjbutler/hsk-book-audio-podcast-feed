# HSK Book Audio Podcast Feed — Handoff

## Overview

This repo hosts two self-generated podcast feeds of HSK Standard Course content, sourced from YouTube:

1. **HSK Book Audio** — Full textbook audio with chapter markers
2. **HSK Vocabulary** — Vocabulary words with example sentences (HSK levels 1-9)

Episodes are downloaded as M4A with chapters embedded, stored in GitHub Releases, and served via podcast RSS feeds on GitHub Pages.

## Architecture

```
hsk-book-audio-podcast-feed/
├── scripts/
│   ├── add-episode.sh           # Download audio, parse chapters, embed in M4A, create metadata
│   ├── generate-feed.sh         # Rebuild hsk-book-audio-feed-v2.xml from episodes/*/metadata.json
│   ├── publish-release.sh       # Upload audio to GitHub Release, update feed, commit+push
│   ├── add-vocab-episode.sh     # Add vocabulary episode (similar to add-episode.sh)
│   ├── generate-vocab-feed.sh   # Rebuild hsk-vocab-feed.xml from vocab-episodes/*/metadata.json
│   └── publish-vocab-release.sh # Upload vocab audio to GitHub Release, update feed, commit+push
├── episodes/                    # HSK Book Audio episodes
│   ├── hsk-1/
│   ├── hsk-2/
│   ├── hsk-3/
│   ├── hsk-4-shang/
│   └── hsk-4-xia/
├── vocab-episodes/              # HSK Vocabulary episodes
│   ├── vocab-hsk-1/
│   ├── vocab-hsk-2/
│   ├── ...
│   └── vocab-hsk-7-9h/
├── audio/                       # Local staging for book audio (gitignored)
├── audio-vocab/                 # Local staging for vocab audio (gitignored)
├── artwork/
│   ├── cover.png                # 1400x1400 cover art for HSK Book Audio
│   └── cover-vocab.png          # 1400x1400 cover art for HSK Vocabulary
├── channel.json                 # Metadata for HSK Book Audio feed
├── channel-vocab.json           # Metadata for HSK Vocabulary feed
├── hsk-book-audio-feed-v2.xml   # RSS feed for HSK Book Audio (served by GitHub Pages)
├── hsk-vocab-feed.xml           # RSS feed for HSK Vocabulary (served by GitHub Pages)
└── .gitignore
```

## Key URLs

| Resource | URL |
|---|---|
| Repo | https://github.com/jonathanjbutler/hsk-book-audio-podcast-feed |
| Book Audio Feed (subscribe) | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-book-audio-feed-v2.xml |
| Vocabulary Feed (subscribe) | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-vocab-feed.xml |
| Book Audio Cover art | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/artwork/cover.png |
| Vocabulary Cover art | https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/artwork/cover-vocab.png |
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

## Vocabulary Episodes

| # | Slug | Title | YouTube Source |
|---|---|---|---|
| 1 | vocab-hsk-1 | HSK 1 Vocabulary | https://www.youtube.com/watch?v=vROYT4eD-GI |
| 2 | vocab-hsk-2 | HSK 2 Vocabulary | https://www.youtube.com/watch?v=UYV1k6swyKU |
| 3 | vocab-hsk-3 | HSK 3 Vocabulary | https://www.youtube.com/watch?v=ElvY6pceOkc |
| 4 | vocab-hsk-4 | HSK 4 Vocabulary | https://www.youtube.com/watch?v=BD4WZUwaFcg |
| 5 | vocab-hsk-5a | HSK 5 Vocabulary Part 1 | https://www.youtube.com/watch?v=xy_8SRmI568 |
| 6 | vocab-hsk-5b | HSK 5 Vocabulary Part 2 | https://www.youtube.com/watch?v=8SLTqxo_Pbs |
| 7 | vocab-hsk-6a | HSK 6 Vocabulary Part 1 | https://www.youtube.com/watch?v=QtVAcDYzU9w |
| 8 | vocab-hsk-6b | HSK 6 Vocabulary Part 2 | https://www.youtube.com/watch?v=xOneK0tsdRU |
| 9 | vocab-hsk-6c | HSK 6 Vocabulary Part 3 | https://www.youtube.com/watch?v=wZWTUwUKcFk |
| 10 | vocab-hsk-6d | HSK 6 Vocabulary Part 4 | https://www.youtube.com/watch?v=Qf08YoJRx5o |
| 11 | vocab-hsk-7-9a | HSK 7-9 Vocabulary Part 1 | https://www.youtube.com/watch?v=_d1pnq4PorI |
| 12 | vocab-hsk-7-9b | HSK 7-9 Vocabulary Part 2 | https://www.youtube.com/watch?v=F1NYDV3Is24 |
| 13 | vocab-hsk-7-9c | HSK 7-9 Vocabulary Part 3 | https://www.youtube.com/watch?v=1wWKhA0KVNI |
| 14 | vocab-hsk-7-9d | HSK 7-9 Vocabulary Part 4 | https://www.youtube.com/watch?v=XXkYzpYWZ7g |
| 15 | vocab-hsk-7-9e | HSK 7-9 Vocabulary Part 5 | https://www.youtube.com/watch?v=Hk8XKuXxuU4 |
| 16 | vocab-hsk-7-9f | HSK 7-9 Vocabulary Part 6 | https://www.youtube.com/watch?v=O-Z2vntfWsg |
| 17 | vocab-hsk-7-9g | HSK 7-9 Vocabulary Part 7 | https://www.youtube.com/watch?v=m898bwEZ22s |
| 18 | vocab-hsk-7-9h | HSK 7-9 Vocabulary Part 8 | https://www.youtube.com/watch?v=5M8IUEOjVhs |

Vocabulary episodes are in **season 1** with sequential episode numbers. Pub dates are in the past (August 2025) to avoid Overcast ordering issues.

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
- Regenerate `hsk-book-audio-feed-v2.xml`

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
- Regenerate `hsk-book-audio-feed-v2.xml`
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
- **Overcast does not handle future pub_dates correctly** — episodes with future dates may appear in wrong order. Always use past dates for pub_date.

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

**HSK Book Audio** (full textbook audio):
```
https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-book-audio-feed-v2.xml
```

**HSK Vocabulary** (vocabulary with example sentences):
```
https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-vocab-feed.xml
```

Chapters will appear natively in Overcast's chapter navigation.

## Repo Local Path

```
~/projects/hsk-book-audio-podcast-feed
```
