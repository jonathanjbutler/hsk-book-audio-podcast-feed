# HSK Book Audio Podcast Feed

A podcast feed containing full audio from HSK Standard Course textbooks, designed for Chinese language learners.

## Subscribe

Add this feed URL to your podcast app (Overcast, Apple Podcasts, Pocket Casts, etc.):

```
https://jonathanjbutler.github.io/hsk-book-audio-podcast-feed/feed.xml
```

## Episodes

| Episode | Title | Duration |
|---------|-------|----------|
| S1E1 | HSK 4 上 - Full Book Audio | 1:06:02 |

## Adding a New Episode

```bash
# Download audio and create episode metadata
bash scripts/add-episode.sh <youtube-url>

# Or pipe in chapter timestamps
echo "00:13 01. Chapter Title
06:35 02. Another Chapter" | bash scripts/add-episode.sh <youtube-url> -

# Publish to GitHub Releases and update feed
bash scripts/publish-release.sh <episode-slug>
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
