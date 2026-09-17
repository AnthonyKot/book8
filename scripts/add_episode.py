#!/usr/bin/env python3
"""Embed a companion audio episode into a chapter page.

Usage: add_episode.py <chapter-slug> <audio-file> "<episode title>"
Copies the audio into static/audio/<slug>.m4a, inserts a player under the
chapter's <h1>, and adds an "audio" pill to that chapter's index entry.
Idempotent: re-running replaces the audio and leaves the markup alone.
"""
import os, re, shutil, subprocess, sys

def duration(path):
    out = subprocess.run(
        [sys.executable, "-c",
         "import av,sys; c=av.open(sys.argv[1]); print(c.duration/1000000)", path],
        capture_output=True, text=True)
    s = float(out.stdout.strip())
    return int(s // 60), int(round(s % 60))

def main():
    slug, src, title = sys.argv[1], sys.argv[2], sys.argv[3]
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)
    dest = f"static/audio/{slug}.m4a"
    os.makedirs("static/audio", exist_ok=True)
    shutil.copyfile(src, dest)
    m, s = duration(dest)
    mb = os.path.getsize(dest) / 1e6

    page = f"chapters/{slug}.html"
    html = open(page, encoding="utf-8").read()
    if 'class="episode"' in html:
        print(f"  player already present in {page}; audio refreshed only")
    else:
        block = f'''
  <div class="episode">
    <p class="episode-label">Companion episode</p>
    <p class="episode-title">{title}</p>
    <audio controls preload="none" aria-label="Companion audio episode for this chapter" src="../{dest}">
      Your browser cannot play this audio. <a href="../{dest}">Download the episode</a> instead.
    </audio>
    <p class="episode-meta">{m}&nbsp;min&nbsp;{s}&nbsp;s · An AI-generated two-host conversation built from this chapter and checked against it. The voices are synthetic; the chapter below is the source of record. · <a href="../{dest}" download>Download</a></p>
  </div>
'''
        html = re.sub(r"(<h1>.*?</h1>\n)", lambda mo: mo.group(1) + block, html, count=1, flags=re.S)
        open(page, "w", encoding="utf-8").write(html)
        print(f"  player inserted in {page}")

    idx = open("index.html", encoding="utf-8").read()
    line = next((l for l in idx.splitlines() if f"chapters/{slug}.html" in l), None)
    if line and "has-audio" not in line:
        idx = idx.replace(line, line.replace("</strong></a>",
              '</strong></a> <span class="has-audio">audio</span>', 1), 1)
        open("index.html", "w", encoding="utf-8").write(idx)
        print("  index pill added")
    elif line:
        print("  index pill already present")
    print(f"  {slug}: {m}m{s:02d}s, {mb:.1f} MB")

main()
