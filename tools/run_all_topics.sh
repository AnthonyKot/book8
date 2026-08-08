#!/usr/bin/env bash
# Run topic_notes.sh for every defined topic over the full corpus, sequentially
# (one grok run at a time; the IT translation lane may also be running).
# Per-topic flock so a concurrent runner (another agent/session) can't clobber
# the same dossier — a held lock skips the topic instead of racing it.
# usage: ./tools/run_all_topics.sh            # all topics
#        ./tools/run_all_topics.sh 1917 holocaust   # subset
set -u
cd "$(dirname "$0")/.."
mkdir -p notes tools/log
LOG="tools/log/run_all_topics.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

# KZ excluded by default (national-history genre, user decision 2026-08-08) —
# include explicitly only for signature-topic hunts (deportations, republic policy).
ALL_BOOKS="ru ua by cn de it sd in uk us"
TOPICS_DEFAULT="opium-wars 1917 munich-1938 sept-1939 katyn occupation-east holocaust hiroshima korea-1950"
TOPICS="${*:-$TOPICS_DEFAULT}"

log "=== run: $TOPICS over: $ALL_BOOKS ==="
for t in $TOPICS; do
  if flock -n "notes/.$t.lock" ./tools/topic_notes.sh "$t" $ALL_BOOKS; then
    log "$t: done"
  else
    log "$t: FAILED or locked by another runner — skipped"
  fi
done
log "=== all topics done ==="
