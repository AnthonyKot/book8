#!/usr/bin/env bash
# Grok-only fill-in for the English research corpus.
# - Skips batches that already pass the size check (agy successes stay).
# - Translates only missing / thin / failed batches via `grok`.
# - Safe to run while translate.sh is running: the book the main run is
#   currently on is detected from its log and skipped (both scripts write the
#   same batch files, so that one book must not be shared).
# - CLI narration ("Checking the workspace...") is stripped from outputs:
#   anything before the first [PAGE marker is chatter, since every source
#   batch begins with one. Applied to fresh grok output AND to existing
#   batches on re-check, so a final no-arg pass scrubs agy-era chatter too.
# - Resumable. Re-assembles corpus-en/$id.txt when a book has zero gaps.
# Optional: pass book ids as args, e.g.  ./translate_grok.sh ru ua
# Default: all non-English books in BOOKS order.
set -u
cd "$(dirname "$0")/.."
mkdir -p corpus-orig corpus-en tools/log

BATCH=6
LOG="tools/log/translate_grok.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

# id|lang|pdf
BOOKS="
ru|Russian|ru-2023-chubaryan-worldhistory10.pdf
ua|Ukrainian|ua-2019-hisem-martyniuk-history11.pdf
by|Russian|by-2021-koshelev-worldhistory11.pdf
kz|Russian|kz-2015-history11.pdf
cn|Chinese|cn-2019-zhongwai-gangyao-shang.pdf
it|Italian|it-2004-sabbatucci-vidotto-mondocontemporaneo.pdf
de|German|de-2012-bpb-ns-krieg-holocaust.pdf
sd|Arabic|sd-2009-history3-secondary.pdf
"

PROMPT_HEAD='Translate these %s history textbook pages to English. Requirements: faithful and literal; preserve paragraph breaks; keep euphemisms, agentless constructions and official phrasing EXACTLY as worded (do not smooth, do not editorialize); this is source material for wording analysis. Reproduce the [PAGE n] markers exactly where they appear. Mark illegible fragments as [OCR?]. Output the translation only.'

is_good_batch() { # $1=file $2=minbytes
  local f="$1" min="$2"
  [ -s "$f" ] || return 1
  # intentional blank-page placeholder from either script
  if grep -q 'no extractable text' "$f" 2>/dev/null; then
    return 0
  fi
  [ "$(wc -c < "$f")" -ge "$min" ]
}

trim_chatter() { # $1=file — drop CLI narration before the first [PAGE marker
  local f="$1" t="$1.trim"
  grep -q '\[PAGE' "$f" || return 0
  awk '!f{i=index($0,"[PAGE"); if(!i) next; $0=substr($0,i); f=1} {print}' \
    "$f" > "$t" && mv "$t" "$f"
}

active_book() { # book the main translate.sh run is on right now ('' if idle)
  pgrep -f 'bash .*tools/translate\.sh' >/dev/null 2>&1 || { echo ""; return; }
  grep -o '[a-z][a-z] ([A-Za-z]*): [0-9]* pages' tools/log/translate.log 2>/dev/null \
    | tail -1 | cut -d' ' -f1
}

translate_batch_grok() { # $1=promptfile $2=outfile $3=minbytes
  local pf="$1" out="$2" min="$3"
  # Two attempts: max-turns 3 then a slightly longer retry
  timeout 900 grok --always-approve --max-turns 3 \
    -p "$(cat "$pf")" > "$out" 2>>"$LOG.err" || true
  trim_chatter "$out"
  if [ "$(wc -c < "$out" 2>/dev/null || echo 0)" -ge "$min" ]; then
    return 0
  fi
  log "  grok thin/empty, second attempt"
  timeout 900 grok --always-approve --max-turns 5 \
    -p "$(cat "$pf")" > "$out" 2>>"$LOG.err" || true
  trim_chatter "$out"
  if [ "$(wc -c < "$out" 2>/dev/null || echo 0)" -ge "$min" ]; then
    return 0
  fi
  rm -f "$out"
  return 1
}

FILTERED=()
if [ "$#" -gt 0 ]; then
  for a in "$@"; do FILTERED+=("$a"); done
fi
want() {
  local id="$1"
  if [ "${#FILTERED[@]}" -eq 0 ]; then return 0; fi
  local x
  for x in "${FILTERED[@]}"; do
    [ "$x" = "$id" ] && return 0
  done
  return 1
}

log "=== translate_grok.sh start (filter: ${FILTERED[*]:-all}) ==="

echo "$BOOKS" | while IFS='|' read -r id lang pdf; do
  [ -z "$id" ] && continue
  want "$id" || continue
  if [ "$id" = "$(active_book)" ]; then
    log "$id: main translate.sh is on this book right now — skipped, retry later"
    continue
  fi

  src="resources/$pdf"
  orig="corpus-orig/$id.txt"
  if [ ! -s "$orig" ]; then
    if [ ! -f "$src" ]; then
      log "$id: missing $src — skip"
      continue
    fi
    pdftotext -layout "$src" "$orig" 2>/dev/null || true
  fi
  if [ ! -s "$orig" ]; then
    log "$id: no extractable text — skip"
    continue
  fi

  pdir="corpus-orig/pages-$id"
  if [ ! -d "$pdir" ]; then
    mkdir -p "$pdir"
    awk -v dir="$pdir" 'BEGIN{RS="\f"} {f=sprintf("%s/p%04d.txt",dir,NR); print > f; close(f)}' "$orig"
  fi
  npages=$(ls "$pdir" | wc -l)
  bdir="corpus-en/batches-$id"
  mkdir -p "$bdir"
  log "$id ($lang): $npages pages — grok fill of missing/thin batches"

  i=1
  fails=0
  filled=0
  skipped=0
  while [ "$i" -le "$npages" ]; do
    end=$((i + BATCH - 1)); [ "$end" -gt "$npages" ] && end=$npages
    bout=$(printf '%s/b%04d.txt' "$bdir" "$i")
    tmp="tools/log/grok-$id-batch.tmp"
    : > "$tmp"
    for p in $(seq "$i" "$end"); do
      printf '\n[PAGE %d]\n' "$p" >> "$tmp"
      cat "$(printf '%s/p%04d.txt' "$pdir" "$p")" >> "$tmp"
    done
    osz=$(wc -c < "$tmp")
    # nearly empty source → placeholder, no API
    if [ "$osz" -lt 200 ]; then
      if ! grep -q 'no extractable text' "$bout" 2>/dev/null; then
        printf '[PAGE %d-%d: no extractable text]\n' "$i" "$end" > "$bout"
      fi
      skipped=$((skipped + 1))
      i=$((end + 1))
      continue
    fi
    # Floor scales with source size: end-of-book batches are tiny and a
    # fixed 400-byte floor false-failed RU 229–234 (agy+grok) earlier.
    min=$((osz / 4))
    [ "$min" -lt 120 ] && min=120
    # keep a modest absolute floor only for large batches
    if [ "$osz" -ge 2000 ] && [ "$min" -lt 400 ]; then min=400; fi
    [ -f "$bout" ] && trim_chatter "$bout"
    if is_good_batch "$bout" "$min"; then
      skipped=$((skipped + 1))
      i=$((end + 1))
      continue
    fi
    # Drop a thin partial so we rewrite cleanly
    rm -f "$bout"
    pf="tools/log/grok-$id-prompt.tmp"
    { printf "$PROMPT_HEAD\n\n---\n" "$lang"; cat "$tmp"; } > "$pf"
    if translate_batch_grok "$pf" "$bout" "$min"; then
      log "  $id pages $i-$end ok via grok ($(wc -c < "$bout") bytes)"
      filled=$((filled + 1))
    else
      log "  $id pages $i-$end FAILED (grok)"
      fails=$((fails + 1))
    fi
    i=$((end + 1))
  done

  log "$id: filled=$filled skipped_ok=$skipped fails=$fails"
  if [ "$fails" -eq 0 ]; then
    cat "$bdir"/b*.txt > "corpus-en/$id.txt"
    nbytes=$(wc -c < "corpus-en/$id.txt")
    log "$id: assembled corpus-en/$id.txt ($nbytes bytes)"
  else
    log "$id: $fails gap(s) remain — rerun tools/translate_grok.sh $id"
  fi
done

log "DONE"
