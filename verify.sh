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

# ---- 5. nav chain (reading order) ------------------------------------------
ORDER="00-introduction.html narrator-cards.html part-1.html 01-opium-wars.html 02-scramble-africa.html 03-russo-japanese-1905.html part-2.html 04-july-1914.html 05-1917.html 06-versailles.html part-3.html 07-china-1911-49.html 08-india-1930-47.html part-4.html 09-depression.html 10-spain-civil-war.html 11-munich-pact-1939.html 12-holocaust.html 13-hiroshima.html interlude-wiring.html part-5.html 14-order-1945-49.html 15-korea.html epilogue.html"
navfail=0; prev=""
for f in $ORDER; do
  if [ -n "$prev" ]; then
    grep -q "href=\"$f\"" "chapters/$prev" || { err "nav chain: chapters/$prev has no link to $f"; navfail=1; }
    grep -q "href=\"$prev\"" "chapters/$f" || { err "nav chain: chapters/$f has no link back to $prev"; navfail=1; }
  fi
  prev="$f"
done
[ "$navfail" -eq 0 ] && ok "nav chain (24 pages, both directions)"

# ---- 6. coda refrain --------------------------------------------------------
CODA="Now look up what your textbook calls it"
codafail=0
for f in chapters/0[1-9]*.html chapters/1[0-5]*.html chapters/ex-katyn.html chapters/epilogue.html; do
  [ -f "$f" ] || continue
  case "$f" in chapters/00-*) continue ;; esac
  n=$(grep -c "$CODA" "$f")
  [ "$n" -eq 1 ] || { err "coda: $f has $n occurrences (want 1)"; codafail=1; }
done
for f in chapters/part-[1-5].html chapters/narrator-cards.html chapters/interlude-wiring.html; do
  [ -f "$f" ] || continue
  n=$(grep -c "$CODA" "$f")
  [ "$n" -eq 0 ] || { err "coda: $f carries the chapter refrain (connective pages must not)"; codafail=1; }
done
[ "$codafail" -eq 0 ] && ok "coda refrain (chapters once each, connective pages none)"

# ---------------------------------------------------------------------------
echo
if [ "$fail" -gt 0 ]; then
  echo "verify: $fail FAILURE(S), $warn warning(s)"
  exit 1
fi
echo "verify: all checks passed, $warn warning(s)"
