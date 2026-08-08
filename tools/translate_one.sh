#!/usr/bin/env bash
# Translate ONE book into the English research corpus, without touching the
# BOOKS lists of the (possibly running) translate.sh / translate_grok.sh.
# Same mechanics: page split, batches of 6, agy primary + grok fallback,
# chatter trim, scaled size floor, resumable, assemble on zero fails.
# usage: ./tools/translate_one.sh <id> <lang> <pdf-path>
#        ./tools/translate_one.sh ru-aid Russian "/mnt/c/Users/CoderA/Downloads/1702480509_....pdf"
set -u
cd "$(dirname "$0")/.."
mkdir -p corpus-orig corpus-en tools/log

ID="${1:?usage: translate_one.sh <id> <lang> <pdf-path>}"
LANG_NAME="${2:?need language name}"
SRC="${3:?need pdf path}"
[ -f "$SRC" ] || { echo "no such file: $SRC"; exit 1; }

BATCH=6
MODEL="gemini-3.6-flash-medium"
LOG="tools/log/translate_one.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

trim_chatter() { # $1=file — drop CLI narration before the first [PAGE marker
  local f="$1" t="$1.trim"
  grep -q '\[PAGE' "$f" || return 0
  awk '!f{i=index($0,"[PAGE"); if(!i) next; $0=substr($0,i); f=1} {print}' \
    "$f" > "$t" && mv "$t" "$f"
}

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

orig="corpus-orig/$ID.txt"
[ -s "$orig" ] || pdftotext -layout "$SRC" "$orig" 2>/dev/null
[ -s "$orig" ] || { log "$ID: no extractable text"; exit 1; }

pdir="corpus-orig/pages-$ID"
if [ ! -d "$pdir" ]; then
  mkdir -p "$pdir"
  awk -v dir="$pdir" 'BEGIN{RS="\f"} {f=sprintf("%s/p%04d.txt",dir,NR); print > f; close(f)}' "$orig"
fi
npages=$(ls "$pdir" | wc -l)
bdir="corpus-en/batches-$ID"
mkdir -p "$bdir"
log "$ID ($LANG_NAME): $npages pages, batches of $BATCH"

i=1
fails=0
while [ "$i" -le "$npages" ]; do
  end=$((i + BATCH - 1)); [ "$end" -gt "$npages" ] && end=$npages
  bout=$(printf '%s/b%04d.txt' "$bdir" "$i")
  tmp="tools/log/$ID-batch.tmp"
  : > "$tmp"
  for p in $(seq "$i" "$end"); do
    printf '\n[PAGE %d]\n' "$p" >> "$tmp"
    cat "$(printf '%s/p%04d.txt' "$pdir" "$p")" >> "$tmp"
  done
  osz=$(wc -c < "$tmp")
  min=$((osz / 4)); [ "$min" -lt 120 ] && min=120
  if [ "$osz" -ge 2000 ] && [ "$min" -lt 400 ]; then min=400; fi
  [ -f "$bout" ] && trim_chatter "$bout"
  if [ -s "$bout" ] && [ "$(wc -c < "$bout")" -ge "$min" ]; then
    i=$((end + 1)); continue
  fi
  if [ "$osz" -lt 200 ]; then
    printf '[PAGE %d-%d: no extractable text]\n' "$i" "$end" > "$bout"
    i=$((end + 1)); continue
  fi
  pf="tools/log/$ID-prompt.tmp"
  { printf "$PROMPT_HEAD\n\n---\n" "$LANG_NAME"; cat "$tmp"; } > "$pf"
  if translate_batch "$pf" "$bout" "$min"; then
    log "  $ID pages $i-$end ok ($(wc -c < "$bout") bytes)"
  else
    log "  $ID pages $i-$end FAILED (both lanes)"
    fails=$((fails + 1))
  fi
  i=$((end + 1))
done

if [ "$fails" -eq 0 ]; then
  cat "$bdir"/b*.txt > "corpus-en/$ID.txt"
  log "$ID: assembled corpus-en/$ID.txt ($(wc -c < "corpus-en/$ID.txt") bytes)"
else
  log "$ID: $fails failed batch(es) — rerun to retry; not assembled"
fi
