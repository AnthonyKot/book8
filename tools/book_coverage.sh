#!/usr/bin/env bash
# Inverse coverage: what a book spends itself on that the spine never asks about.
# An agent maps the book's own structure (units/chapters with extract-page ranges);
# the script computes each unit's char share mechanically and marks which units the
# spine's measured ranges already claim. Output: notes/space/coverage-<id>.md,
# units sorted by share, UNCLAIMED blocks highlighted — the book's dark matter.
# usage: ./tools/book_coverage.sh <book-id>
set -u
cd "$(dirname "$0")/.."
ID="${1:?usage: book_coverage.sh <book-id>}"
LOG="tools/log/coverage.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }
R="notes/space/coverage-$ID.ranges"

if [ ! -s "$R" ]; then
  pf="tools/log/coverage-$ID-prompt.tmp"
  cat > "$pf" <<EOF
You are a structure-mapping agent for book8, in this directory. Task: map the internal structure of corpus-en/$ID.txt (a school/university history textbook, machine-translated; [PAGE n] markers give extract pages). Find its table of contents and/or section headings and produce a COMPLETE partition of the book into its own teaching units (chapters/sections as the book divides itself, typically 15-60 units), covering every page from 1 to the last. Write notes/space/coverage-$ID.ranges with EXACTLY this line format, nothing else in the file:
START-END|short unit label (the book's own topic, in English, max 8 words)
Ranges must not overlap and should cover the whole book including front/back matter (label those "front matter" / "index etc"). No estimates of size — ranges only. Print a 2-line summary when done.
EOF
  log "$ID: structure mapping via grok"
  timeout 1200 grok --always-approve --max-turns 30 -p "$(cat "$pf")" > "tools/log/coverage-$ID-agent.txt" 2>>"$LOG.err" || true
  [ -s "$R" ] || { log "$ID: agent produced no ranges — FAILED"; exit 1; }
fi

python3 - "$ID" <<'EOF'
import sys, os, re, glob
ID = sys.argv[1]
pdir = f"corpus-orig/pages-{ID}"
total = os.path.getsize(f"corpus-orig/{ID}.txt")
def chars(s, e):
    t = 0
    for p in range(s, e+1):
        f = f"{pdir}/p{p:04d}.txt"
        if os.path.exists(f): t += os.path.getsize(f)
    return t
# spine-claimed pages for this book
claimed = {}
for rf in glob.glob("notes/space/*.ranges"):
    if "coverage-" in rf: continue
    topic = os.path.basename(rf).replace(".ranges","").replace("2","")
    for line in open(rf):
        parts = line.strip().split("|")
        if len(parts) == 3 and parts[0] == ID and parts[1] == "dedicated":
            s, e = parts[2].split("-");
            for p in range(int(s), int(e)+1): claimed[p] = topic
units = []
for line in open(f"notes/space/coverage-{ID}.ranges"):
    line = line.strip()
    if not line or "|" not in line: continue
    rng, label = line.split("|", 1)
    try: s, e = [int(x) for x in rng.split("-")]
    except: continue
    c = chars(s, e)
    cl = sorted(set(claimed[p] for p in range(s, e+1) if p in claimed))
    units.append((c, s, e, label.strip(), ", ".join(cl) if cl else "UNCLAIMED"))
units.sort(reverse=True)
out = [f"# Coverage map — {ID} (book's own units vs spine claims)\n",
       f"Total extraction: {total} chars. Units sorted by share; UNCLAIMED = the spine never measured here.\n",
       "| Share | Pages | Book's own unit | Spine claim |", "|---|---|---|---|"]
unclaimed_total = 0
for c, s, e, label, cl in units:
    pct = 100*c/total
    if cl == "UNCLAIMED": unclaimed_total += pct
    out.append(f"| {pct:.1f}% | {s}-{e} | {label} | {cl} |")
out.append(f"\n**Unclaimed share: {unclaimed_total:.1f}%** of the book is territory the spine never measured.")
open(f"notes/space/coverage-{ID}.md","w").write("\n".join(out)+"\n")
print(f"{ID}: {len(units)} units, {unclaimed_total:.1f}% unclaimed")
EOF
log "$ID: coverage map written to notes/space/coverage-$ID.md"