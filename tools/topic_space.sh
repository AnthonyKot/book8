#!/usr/bin/env bash
# Topic space measurement — quantifies the "space" coding category.
# Two stages, per the design rule "LLM for boundaries, script for arithmetic":
#   1. An agent reads the topic dossier + corpus and emits machine-readable
#      page ranges: notes/space/<topic>.ranges  (lines: id|dedicated|p1-p2
#      or id|mentions|N). Ranges = contiguous passages DEDICATED to the topic;
#      passing mentions counted separately, never measured as space.
#   2. This script computes chars mechanically from corpus-orig page files
#      (same ranges always yield the same numbers) and appends a "## Space"
#      table to notes/<topic>.md: pages · chars(orig) · % of book · mentions.
# usage: ./tools/topic_space.sh <topic-id> <book-id>...
set -u
cd "$(dirname "$0")/.."
mkdir -p notes/space tools/log
TOPIC="${1:?usage: topic_space.sh <topic-id> <book-id>...}"; shift
IDS="$*"
[ -s "notes/$TOPIC.md" ] || { echo "no dossier notes/$TOPIC.md"; exit 1; }
LOG="tools/log/topic_space.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

# Ensure per-page splits exist for every book (English books were never split)
for id in $IDS; do
  pdir="corpus-orig/pages-$id"
  if [ ! -d "$pdir" ]; then
    mkdir -p "$pdir"
    awk -v dir="$pdir" 'BEGIN{RS="\f"} {f=sprintf("%s/p%04d.txt",dir,NR); print > f; close(f)}' "corpus-orig/$id.txt"
    log "$id: page split created ($(ls "$pdir" | wc -l) pages)"
  fi
done

RANGES="notes/space/$TOPIC.ranges"
if [ ! -s "$RANGES" ]; then
  pf="tools/log/space-$TOPIC-prompt.tmp"
  cat > "$pf" <<EOF
You are a boundary-finding agent for book8, working in this directory. Read notes/$TOPIC.md (the topic dossier — it lists pages per book) and, for each book id in: $IDS — use the dossier's page lists plus corpus-en/<id>.txt around those pages to decide which EXTRACT pages are DEDICATED to the topic (the topic is the passage's subject) versus passing mentions (the topic appears inside a passage about something else). Write the file notes/space/$TOPIC.ranges with one line per finding, EXACTLY this format, nothing else in the file:
id|dedicated|START-END        (contiguous extract-page range dedicated to the topic; repeat per range)
id|mentions|N                 (count of passing mentions outside dedicated ranges; one line per book, N may be 0)
Books with zero coverage get only an "id|mentions|0" line. Do not measure or estimate characters — ranges only. When done print a 3-line summary.
EOF
  log "$TOPIC: finding boundaries via agy over: $IDS"
  timeout 900 agy --dangerously-skip-permissions --print-timeout 14m \
    --model gemini-3.6-flash-high -p "$(cat "$pf")" > "tools/log/space-$TOPIC-agent.txt" 2>>"$LOG.err" || true
  [ -s "$RANGES" ] || { log "$TOPIC: agent produced no ranges file — FAILED"; exit 1; }
fi

# Stage 2: mechanical arithmetic
out="tools/log/space-$TOPIC-table.tmp"
{
  echo ""
  echo "## Space (computed $(date +%Y-%m-%d) by tools/topic_space.sh — chars from corpus-orig page files; ranges: notes/space/$TOPIC.ranges)"
  echo ""
  echo "| Book | Dedicated pages | Chars (orig) | % of book | Passing mentions |"
  echo "|---|---|---|---|---|"
  for id in $IDS; do
    total=$(wc -c < "corpus-orig/$id.txt")
    ded=0; pages=""
    while IFS='|' read -r rid rtype rval; do
      [ "$rid" = "$id" ] || continue
      if [ "$rtype" = "dedicated" ]; then
        s=${rval%-*}; e=${rval#*-}
        for p in $(seq "$s" "$e"); do
          f=$(printf 'corpus-orig/pages-%s/p%04d.txt' "$id" "$p")
          [ -f "$f" ] && ded=$((ded + $(wc -c < "$f")))
        done
        pages="$pages $rval"
      fi
    done < "$RANGES"
    men=$(awk -F'|' -v id="$id" '$1==id && $2=="mentions" {print $3; exit}' "$RANGES")
    pct=$(awk -v d="$ded" -v t="$total" 'BEGIN{printf "%.2f", 100*d/t}')
    echo "| $id | ${pages:-—} | $ded | ${pct}% | ${men:-?} |"
  done
} > "$out"
# Replace any previous Space section, then append the fresh one
awk '/^## Space \(computed/{skip=1} /^## /&&!/^## Space \(computed/{skip=0} !skip' "notes/$TOPIC.md" > "notes/$TOPIC.md.tmp" \
  && mv "notes/$TOPIC.md.tmp" "notes/$TOPIC.md"
cat "$out" >> "notes/$TOPIC.md"
log "$TOPIC: space table appended to notes/$TOPIC.md"
grep -A15 "^## Space" "notes/$TOPIC.md" | head -18