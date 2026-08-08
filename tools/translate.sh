#!/usr/bin/env bash
# Build the English research corpus (corpus-en/) from resources/*.pdf.
# - English books are extracted and copied as-is.
# - Non-English books are split into pages (pdftotext form feeds), translated in
#   batches of 6 pages via agy (primary) with grok as fallback lane.
# - Resumable: a batch whose output exists and passes the size check is skipped.
# - Both CLIs sometimes exit 0 having written nothing (known failure mode), so
#   every output is size-checked; a failed batch is deleted so a rerun retries it.
# The English corpus is a research index ONLY — quotes are always taken from the
# original (see CONTEXT.md).
set -u
cd "$(dirname "$0")/.."
mkdir -p corpus-orig corpus-en tools/log

BATCH=6
MODEL="gemini-3.6-flash-medium"
LOG="tools/log/translate.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

trim_chatter() { # $1=file — drop CLI narration before the first [PAGE marker
  local f="$1" t="$1.trim"
  grep -q '\[PAGE' "$f" || return 0
  awk '!f{i=index($0,"[PAGE"); if(!i) next; $0=substr($0,i); f=1} {print}' \
    "$f" > "$t" && mv "$t" "$f"
}

grok_active_book() { # book translate_grok.sh is on right now ('' if idle)
  pgrep -f 'tools/translate_grok\.sh' >/dev/null 2>&1 || { echo ""; return; }
  grep -o '[a-z][a-z] ([A-Za-z]*): [0-9]* pages' tools/log/translate_grok.log 2>/dev/null \
    | tail -1 | cut -d' ' -f1
}

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
in|English|in-ncert-themes-world-history11.pdf
uk|English|uk-2013-lowe-modernworldhistory.pdf
us|English|us-2022-openstax-worldhistory2.pdf
"

PROMPT_HEAD='Translate these %s history textbook pages to English. Requirements: faithful and literal; preserve paragraph breaks; keep euphemisms, agentless constructions and official phrasing EXACTLY as worded (do not smooth, do not editorialize); this is source material for wording analysis. Reproduce the [PAGE n] markers exactly where they appear. Mark illegible fragments as [OCR?]. Output the translation only.'

translate_batch() { # $1=promptfile $2=outfile $3=minbytes
  local pf="$1" out="$2" min="$3"
  timeout 900 agy --dangerously-skip-permissions --print-timeout 14m \
    --model "$MODEL" -p "$(cat "$pf")" > "$out" 2>>"$LOG.err" || true
  trim_chatter "$out"
  [ "$(wc -c < "$out")" -ge "$min" ] && return 0
  log "  agy thin/empty, retrying via grok"
  timeout 900 grok --always-approve --max-turns 3 \
    -p "$(cat "$pf")" > "$out" 2>>"$LOG.err" || true
  trim_chatter "$out"
  [ "$(wc -c < "$out")" -ge "$min" ] && return 0
  rm -f "$out"
  return 1
}

echo "$BOOKS" | while IFS='|' read -r id lang pdf; do
  [ -z "$id" ] && continue
  if [ "$id" = "$(grok_active_book)" ]; then
    log "$id: translate_grok.sh is on this book right now — skipped (grok lane will finish and assemble it)"
    continue
  fi
  src="resources/$pdf"
  orig="corpus-orig/$id.txt"
  [ -s "$orig" ] || pdftotext -layout "$src" "$orig" 2>/dev/null
  if [ "$lang" = "English" ]; then
    [ -s "corpus-en/$id.txt" ] || cp "$orig" "corpus-en/$id.txt"
    log "$id: English, copied ($(wc -c < "corpus-en/$id.txt") bytes)"
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
  log "$id ($lang): $npages pages, batches of $BATCH"

  i=1
  fails=0
  while [ "$i" -le "$npages" ]; do
    end=$((i + BATCH - 1)); [ "$end" -gt "$npages" ] && end=$npages
    bout=$(printf '%s/b%04d.txt' "$bdir" "$i")
    tmp="tools/log/$id-batch.tmp"
    : > "$tmp"
    for p in $(seq "$i" "$end"); do
      printf '\n[PAGE %d]\n' "$p" >> "$tmp"
      cat "$(printf '%s/p%04d.txt' "$pdir" "$p")" >> "$tmp"
    done
    osz=$(wc -c < "$tmp")
    # Scaled floor: a fixed 400-byte minimum false-failed RU 229-234 (art-plate
    # pages whose source batch was itself only 478 bytes).
    min=$((osz / 4)); [ "$min" -lt 120 ] && min=120
    if [ "$osz" -ge 2000 ] && [ "$min" -lt 400 ]; then min=400; fi
    [ -f "$bout" ] && trim_chatter "$bout"
    if [ -s "$bout" ] && [ "$(wc -c < "$bout")" -ge "$min" ]; then
      i=$((end + 1)); continue
    fi
    if [ "$osz" -lt 200 ]; then         # image-only / blank pages
      printf '[PAGE %d-%d: no extractable text]\n' "$i" "$end" > "$bout"
      i=$((end + 1)); continue
    fi
    pf="tools/log/$id-prompt.tmp"
    { printf "$PROMPT_HEAD\n\n---\n" "$lang"; cat "$tmp"; } > "$pf"
    if translate_batch "$pf" "$bout" "$min"; then
      log "  $id pages $i-$end ok ($(wc -c < "$bout") bytes)"
    else
      log "  $id pages $i-$end FAILED (both lanes)"
      fails=$((fails + 1))
    fi
    i=$((end + 1))
  done

  if [ "$fails" -eq 0 ]; then
    cat "$bdir"/b*.txt > "corpus-en/$id.txt"
    log "$id: assembled corpus-en/$id.txt ($(wc -c < "corpus-en/$id.txt") bytes)"
  else
    log "$id: $fails failed batch(es) — rerun tools/translate.sh to retry; not assembled"
  fi
done
log "DONE"
