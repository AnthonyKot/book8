#!/usr/bin/env bash
# Confirm space ranges with a second, blind boundary pass.
# Runs the boundary agent again (independently worded prompt, forbidden from
# reading the first pass), then compares dedicated-page sets per book and the
# char impact of any disagreement. Verdict per book:
#   CONFIRMED  — identical pages, or char delta < 0.10 percentage points
#   CHECK      — larger disagreement; both ranges kept for a human eye
# Output: notes/space/<topic>.confirm.md (+ .ranges2 kept as artifact)
# usage: ./tools/topic_space_confirm.sh <topic-id>
set -u
cd "$(dirname "$0")/.."
TOPIC="${1:?usage: topic_space_confirm.sh <topic-id>}"
R1="notes/space/$TOPIC.ranges"; R2="notes/space/$TOPIC.ranges2"
[ -s "$R1" ] || { echo "no first-pass ranges $R1"; exit 1; }
LOG="tools/log/topic_space.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }
IDS=$(awk -F'|' '{print $1}' "$R1" | sort -u | tr '\n' ' ')

if [ ! -s "$R2" ]; then
  pf="tools/log/space-$TOPIC-confirm-prompt.tmp"
  cat > "$pf" <<EOF
You are an independent measurement agent for book8, in this directory. IMPORTANT: do NOT read any files under notes/space/ — your judgment must be blind. Task: for the topic covered by the dossier notes/$TOPIC.md, decide for each book id in: $IDS — which EXTRACT pages of corpus-en/<id>.txt are DEDICATED to that topic (the topic is the passage's subject, not merely present). Use the dossier's page hints and read the surrounding corpus pages to set the boundaries yourself. Passing mentions (topic appears inside a passage about something else) are counted, not measured. Write notes/space/$TOPIC.ranges2 with EXACTLY this line format and nothing else in the file:
id|dedicated|START-END
id|mentions|N
Books with no coverage: only "id|mentions|0". No character estimates. Print a 2-line summary when done.
EOF
  log "$TOPIC: confirm pass via agy over: $IDS"
  timeout 900 agy --dangerously-skip-permissions --print-timeout 14m \
    --model gemini-3.6-flash-high -p "$(cat "$pf")" > "tools/log/space-$TOPIC-confirm-agent.txt" 2>>"$LOG.err" || true
  [ -s "$R2" ] || { log "$TOPIC: confirm agent produced nothing — FAILED"; exit 1; }
fi

chars_for() { # $1=id $2=rangesfile — sum chars of dedicated pages
  local id="$1" rf="$2" tot=0 s e p f
  while IFS='|' read -r rid rtype rval; do
    [ "$rid" = "$id" ] && [ "$rtype" = "dedicated" ] || continue
    s=${rval%-*}; e=${rval#*-}
    for p in $(seq "$s" "$e"); do
      f=$(printf 'corpus-orig/pages-%s/p%04d.txt' "$id" "$p")
      [ -f "$f" ] && tot=$((tot + $(wc -c < "$f")))
    done
  done < "$rf"
  echo "$tot"
}
pages_for() { # expand dedicated pages to a sorted list
  local id="$1" rf="$2"
  awk -F'|' -v id="$id" '$1==id && $2=="dedicated" {split($3,a,"-"); for(i=a[1];i<=a[2];i++) print i}' "$rf" | sort -n | tr '\n' ','
}

out="notes/space/$TOPIC.confirm.md"
{
  echo "# Space-range confirmation — $TOPIC ($(date +%Y-%m-%d))"
  echo ""
  echo "| Book | Pass 1 pages | Pass 2 pages | Δ chars | Δ pp of book | Verdict |"
  echo "|---|---|---|---|---|---|"
  for id in $IDS; do
    total=$(wc -c < "corpus-orig/$id.txt")
    c1=$(chars_for "$id" "$R1"); c2=$(chars_for "$id" "$R2")
    p1=$(pages_for "$id" "$R1"); p2=$(pages_for "$id" "$R2")
    d=$((c1 - c2)); [ "$d" -lt 0 ] && d=$((-d))
    dpp=$(awk -v d="$d" -v t="$total" 'BEGIN{printf "%.3f", 100*d/t}')
    if [ "$p1" = "$p2" ]; then v="CONFIRMED (identical)"
    elif awk -v x="$dpp" 'BEGIN{exit !(x<0.10)}'; then v="CONFIRMED (Δ<0.10pp)"
    else v="CHECK"; fi
    echo "| $id | ${p1:-—} | ${p2:-—} | $d | ${dpp}pp | $v |"
  done
} > "$out"
log "$TOPIC: confirmation written to $out"
cat "$out"