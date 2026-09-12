# HSK Book Audio Podcast Feed

Two podcast feeds for HSK Standard Course content, designed for Chinese language learners:

1. **HSK Book Audio** — Full textbook audio with chapter markers
2. **HSK Vocabulary** — Vocabulary words with example sentences (HSK levels 1-9)

## Subscribe

### HSK Book Audio (Full Textbook Audio)

Add this feed URL to your podcast app (Overcast, Apple Podcasts, Pocket Casts, etc.):

```
https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-book-audio-feed-v2.xml
```

### HSK Vocabulary (Vocabulary with Example Sentences)

```
https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/hsk-vocab-feed.xml
```

## Episodes

### HSK Book Audio

| Episode | Title | Duration |
|---------|-------|----------|
| S1E1 | HSK 1 - Full Book Audio | 1:25:42 |
| S1E2 | HSK 2 - Full Book Audio | 0:52:06 |
| S1E3 | HSK 3 - Full Book Audio | 1:49:31 |
| S1E4 | HSK 4 上 - Full Book Audio | 1:06:02 |
| S1E5 | HSK 4 下 - Full Book Audio | 1:11:46 |

### HSK Vocabulary

| Episode | Title |
|---------|-------|
| S1E1 | HSK 1 Vocabulary |
| S1E2 | HSK 2 Vocabulary |
| S1E3 | HSK 3 Vocabulary |
| S1E4 | HSK 4 Vocabulary |
| S1E5-E6 | HSK 5 Vocabulary Parts 1-2 |
| S1E7-E10 | HSK 6 Vocabulary Parts 1-4 |
| S1E11-E18 | HSK 7-9 Vocabulary Parts 1-8 |

## Adding a New Episode

### HSK Book Audio

```bash
# Download audio and create episode metadata
bash scripts/add-episode.sh <youtube-url>

# Or pipe in chapter timestamps
echo "00:13 01. Chapter Title
06:35 02. Another Chapter" | bash scripts/add-episode.sh <youtube-url> -

# Publish to GitHub Releases and update feed
bash scripts/publish-release.sh <episode-slug>
```

### HSK Vocabulary

```bash
# Download audio and create episode metadata
bash scripts/add-vocab-episode.sh <youtube-url>

# Or pipe in chapter timestamps
echo "00:13 01. Word Definition
06:35 02. Another Word" | bash scripts/add-vocab-episode.sh <youtube-url> -

# Publish to GitHub Releases and update feed
bash scripts/publish-vocab-release.sh <episode-slug>
```

## How It Works

1. **Audio source**: YouTube videos downloaded as M4A via yt-dlp (best quality)
2. **Chapters**: Embedded in the M4A file + Podcasting 2.0 JSON format
3. **Hosting**: Audio in GitHub Releases, feed served via GitHub Pages
4. **Feed**: RSS 2.0 with iTunes and Podcasting 2.0 namespaces

## Feed Features

- iTunes-compatible metadata
- Podcasting 2.0 chapter markers (supported by Overcast, Pocket Casts, etc.)
- Chapter timestamps in episode descriptions
- Cover art

## License

Audio content is sourced from publicly available YouTube videos for personal educational use.
