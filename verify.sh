#!/usr/bin/env bash
# Light checks only (CONTEXT.md, user decision — no per-reference verification):
#   1. anti-leak (GATING, non-negotiable): no corpus/PDF material ever tracked
#   2. internal links (gating; links to not-yet-written chapters warn only)
#   3. chapter count sync: index links vs chapters/*.html — computed, not typed
#   4. HTML tag nesting: open/close counts per structural tag
set -u
cd "$(dirname "$0")"
fail=0; warn=0
err() { echo "FAIL  $*"; fail=$((fail+1)); }
wrn() { echo "warn  $*"; warn=$((warn+1)); }
ok()  { echo "ok    $*"; }

# ---- 1. anti-leak ----------------------------------------------------------
for d in resources/ corpus-orig/ corpus-en/ notes/ tools/log/; do
  grep -qxF "$d" .gitignore || err "anti-leak: '$d' missing from .gitignore"
done
if [ -d .git ]; then
  leaked=$(git ls-files | grep -E '^(resources|corpus-orig|corpus-en|notes|tools/log)/|\.pdf$' || true)
  if [ -n "$leaked" ]; then
    err "anti-leak: corpus material is tracked by git:"
    echo "$leaked" | sed 's/^/        /'
  fi
fi
[ "$fail" -eq 0 ] && ok "anti-leak (.gitignore complete$( [ -d .git ] && echo ', no tracked corpus files' || echo ', git not initialized' ))"

# ---- 2. internal links -----------------------------------------------------
linkfail=0
for f in index.html about.html chapters/*.html; do
  [ -f "$f" ] || continue
  dir=$(dirname "$f")
  for ref in $(grep -oE '(href|src)="[^"]+"' "$f" | sed -E 's/^(href|src)="//; s/"$//'); do
    case "$ref" in
      http*|mailto:*|\#*) continue ;;
    esac
    target="$dir/${ref%%#*}"
    if [ ! -f "$target" ]; then
      if echo "$ref" | grep -qE '(^|/)[0-9]{2}-[^/]+\.html$'; then
        wrn "link: $f -> $ref (future chapter, not written yet)"
      else
        err "link: $f -> $ref (missing)"
        linkfail=1
      fi
    fi
  done
done
[ "$linkfail" -eq 0 ] && ok "internal links (stubs to future chapters are warnings)"

# ---- 3. chapter count sync -------------------------------------------------
nfiles=$(ls chapters/*.html 2>/dev/null | wc -l)
nlinks=$(grep -oE 'href="chapters/[^"]+\.html"' index.html | sort -u | wc -l)
if [ "$nfiles" -ne "$nlinks" ]; then
  err "count sync: $nfiles chapter file(s) but $nlinks chapter link(s) in index.html"
else
  ok "count sync ($nfiles chapters, $nlinks index links)"
fi

# ---- 4. HTML nesting (open/close counts) -----------------------------------
nestfail=0
for f in index.html about.html chapters/*.html; do
  [ -f "$f" ] || continue
  for tag in div section table thead tbody tr ul ol blockquote main nav header footer; do
    o=$(grep -oE "<$tag( [^>]*)?>" "$f" | wc -l)
    c=$(grep -oF "</$tag>" "$f" | wc -l)
    if [ "$o" -ne "$c" ]; then
      err "nesting: $f <$tag> open=$o close=$c"
      nestfail=1
    fi
  done
done
[ "$nestfail" -eq 0 ] && ok "HTML nesting"

# ---------------------------------------------------------------------------
echo
if [ "$fail" -gt 0 ]; then
  echo "verify: $fail FAILURE(S), $warn warning(s)"
  exit 1
fi
echo "verify: all checks passed, $warn warning(s)"
