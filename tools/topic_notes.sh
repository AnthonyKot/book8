#!/usr/bin/env bash
# Topic dossier builder — the research cache between corpus and chapters.
# For one topic, an agent searches corpus-en/ (and corpus-orig/ for negative
# claims) across the given books and writes notes/<topic>.md: per-book pages,
# verbatim MT quotes with [PAGE n], vocabulary/agency/numbers, omission checks
# with the search stems recorded. Extracts and pointers ONLY — the dossier is a
# map, never a citation source (CONTEXT.md: quotes come from the original page).
# usage: ./tools/topic_notes.sh <topic-id> <book-id>...
#        ./tools/topic_notes.sh korea-1950 ua by kz ru
set -u
cd "$(dirname "$0")/.."
mkdir -p notes tools/log

MODEL="gemini-3.6-flash-high"
LOG="tools/log/topic_notes.log"
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

TOPIC="${1:?usage: topic_notes.sh <topic-id> <book-id>...}"
shift
[ "$#" -ge 2 ] || { echo "need at least 2 book ids"; exit 1; }
IDS="$*"

# topic-id|title|English search terms (agent derives original-language stems)
TOPICS="
korea-1950|Korean War, 1950-1953|Korean War; Korea; 38th parallel; Inchon; armistice; DPRK; North Korea; South Korea; Pyongyang; Seoul; MacArthur
sept-1939|September 1939: the invasion of Poland|Poland; September 1939; Gleiwitz; Molotov-Ribbentrop; secret protocol; non-aggression pact; liberation campaign; Western Ukraine; Western Belarus; Curzon Line
occupation-east|German occupation in the East, 1939-1945|occupation; occupied territories; General Government; Einsatzgruppen; Babi Yar; war of annihilation; Barbarossa; new order; forced labor; Ostland; Reichskommissariat; partisans
holocaust|Holocaust and the murder of the Jews|Holocaust; Auschwitz; Treblinka; Wannsee; extermination; Final Solution; Jews; ghetto; genocide; gas chambers; six million; Night of Broken Glass; Kristallnacht
katyn|Katyn, 1940|Katyn; Polish officers; NKVD; Smolensk; prisoners of war shot; Polish POWs
hiroshima|Hiroshima and Nagasaki, 1945|Hiroshima; Nagasaki; atomic bomb; nuclear; surrender of Japan
munich-1938|Munich Agreement, 1938|Munich; Sudetenland; appeasement; Chamberlain; Czechoslovakia
opium-wars|Opium Wars, 1839-1860|Opium War; Nanjing; unequal treaty; Canton; Hong Kong; Lin Zexu
1917|Russian Revolution, 1917|February Revolution; October Revolution; Bolshevik; Provisional Government; Lenin; dual power
scramble-africa|The Scramble for Africa, 1880s-1914|Scramble for Africa; Berlin Conference; partition of Africa; colonies; Congo; Omdurman; Mahdi; Fashoda; imperialism
russo-japanese-1905|Russo-Japanese War, 1904-1905|Russo-Japanese War; Port Arthur; Tsushima; Mukden; Portsmouth 1905; first defeat of a European power
july-1914|Who started 1914|July Crisis; Sarajevo; Franz Ferdinand; ultimatum; Serbia; mobilization; war guilt; Schlieffen
versailles|Versailles, 1919|Versailles; Paris Peace Conference; reparations; war guilt clause; Fourteen Points; League of Nations; May Fourth; Shandong
china-1911-49|China 1911-1949|Xinhai; 1911 Revolution; Sun Yat-sen; May Fourth; Long March; Chiang Kai-shek; Mao; civil war; 1949
india-1930-47|India 1930-1947|Amritsar; Jallianwala; civil disobedience; Salt March; Gandhi; Quit India; partition 1947; independence
depression|The Great Depression|Great Depression; 1929; Wall Street crash; unemployment; New Deal; Roosevelt; world economic crisis
spain-civil-war|Spanish Civil War, 1936-1939|Spanish Civil War; Franco; Republic; Guernica; International Brigades; non-intervention; Condor Legion
order-1945-49|The 1945-1949 order|Yalta; Potsdam; United Nations founding; Marshall Plan; Truman Doctrine; Berlin blockade; NATO 1949; iron curtain
hungary-1956|Hungary, 1956|Hungarian uprising; Hungary 1956; Budapest; Imre Nagy; Soviet intervention; Warsaw Pact; counter-revolution
afghanistan-1979|Afghanistan, 1979-1989|Afghanistan; Soviet invasion; mujahideen; Kabul; limited contingent; 1979; withdrawal 1989
kal-007|KAL 007, 1983|Korean airliner; KAL 007; Boeing; shot down; Sakhalin; 1983; passenger plane
tiananmen-1989|Tiananmen, 1989|Tiananmen; 1989; Beijing; students; martial law; demonstrations; protests
crimea-2014|Crimea, 2014|Crimea; annexation; 2014; referendum; Donbas; hybrid; little green men
"
line=$(echo "$TOPICS" | grep "^$TOPIC|") || { echo "unknown topic '$TOPIC' — add it to TOPICS in $0"; exit 1; }
TITLE=$(echo "$line" | cut -d'|' -f2)
TERMS=$(echo "$line" | cut -d'|' -f3)

# Book identities the agent needs for the scope-vs-omission call (edition + years).
book_desc() {
  case "$1" in
    by) echo "Belarus — Кошелев и др., «Всемирная история», 11 кл., 2021, state monopoly; covers ~1800-2020; orig Russian" ;;
    ru) echo "Russia — Чубарьян, «Всеобщая история. Новейшая история 1914-1945», 10 кл., 2023, unified state course; covers 1914-1945 ONLY; orig Russian" ;;
    kz) echo "Kazakhstan — «История Казахстана», 11 кл., 2015, ministry-approved NATIONAL history (thematic, ~18th c.-2010s); orig Russian, noisy OCR (intra-word spaces — use short stems)" ;;
    ua) echo "Ukraine — Гісем/Мартинюк, «Всесвітня історія», 11 кл., 2019, ministry-approved; covers 1945-2018; orig Ukrainian" ;;
    cn) echo "China — «中外历史纲要 上», state-compiled, 2019; Chinese history antiquity-2017; orig Chinese" ;;
    in) echo "India — NCERT «Themes in World History», Class XI, post-2022; ~3000 BCE-2000; English original" ;;
    sd) echo "Sudan — MoE «التاريخ», 3rd secondary, 2009; covers 1821-1948; orig Arabic" ;;
    de) echo "Germany — bpb Nr. 316 «NS: Krieg und Holocaust», 2012, federal civic agency; covers 1939-1945+reckoning; orig German" ;;
    it) echo "Italy — Sabbatucci/Vidotto, «Il mondo contemporaneo», Laterza 2004, university manual, free market; 1848-2004; orig Italian. NOTE: corpus-en/it.txt may be a PARTIAL translation (see its first line for the translated page range) — corpus-orig/it.txt is complete, so verify any absence there before claiming 0 mentions" ;;
    uk) echo "UK — Lowe, «Mastering Modern World History», 5th ed. 2013, market standard; ~1900-2013; English original" ;;
    us) echo "USA — OpenStax «World History Vol. 2», 2022, free market/CC; 1400-2022; English original" ;;
    *)  echo "UNKNOWN BOOK" ;;
  esac
}

for id in $IDS; do
  [ -s "corpus-en/$id.txt" ] || { echo "corpus-en/$id.txt missing or empty — translate it first"; exit 1; }
done

pf="tools/log/topic-$TOPIC-prompt.tmp"
{
  cat <<EOF
You are building a research dossier for a comparative study of national school history textbooks. You are in a directory with the corpus files. Work ONLY from the files; do not use outside knowledge of what these books "should" say.

TOPIC: $TITLE
BOOKS (id — identity, approval mechanism, years covered):
EOF
  for id in $IDS; do
    echo "- $id — $(book_desc "$id")"
  done
  cat <<'EOF'

FILES per book id B:
- corpus-en/B.txt — machine-translated English text of the book. [PAGE n] markers give the original PDF page of everything after them.
- corpus-orig/B.txt — the original-language extraction, same pagination.

FOR EACH BOOK, in the order listed:
1. Search corpus-en/B.txt for the topic (grep, case-insensitive). Suggested English terms (also try your own variants):
EOF
  echo "   $TERMS"
  cat <<'EOF'
2. ALSO search corpus-orig/B.txt using original-language stems you derive for that language (e.g. Корей- for Russian, Корей- for Ukrainian, 朝鲜/朝鮮 for Chinese, prefix stems for noisy OCR). Machine translation can mangle proper nouns, so a claim of absence is only valid if the ORIGINAL file was searched too. Record every stem you tried.
3. If the topic IS covered: read the surrounding pages in corpus-en/B.txt and record:
   - Pages: the [PAGE n] numbers where it appears
   - Label(s): the exact name/vocabulary the book uses for the event (quote the phrase)
   - Agency: who is said to act or start it; note agentless/passive constructions verbatim
   - Numbers: casualties, dates, quantities given (or "none given")
   - People: individuals named (or "none")
   - Quotes: 2-6 SHORT verbatim quotes from corpus-en, each prefixed with its [PAGE n]. Copy exactly, do not smooth.
4. If NOT found, distinguish honestly:
   - "OUT OF SCOPE — book covers YYYY-YYYY" when the topic falls outside the book's year range or its genre (e.g. a national-history book vs a world event)
   - "0 MENTIONS (in scope)" when the book plausibly should cover it but does not
   Either way list all stems tried in both files.

AFTER all books are done, grade coverage against the corpus baseline: count how many in-scope books in THIS dossier cover the topic. School curricula cannot fit all of modern history, so the finding is always the correlation, and it works in BOTH directions:
- majority of in-scope books cover it, this one skips it entirely → append "— avoidance signal (X/Y in-scope books cover it)"
- most in-scope books skip it too → append "— low salience in corpus (X/Y cover it)", a curriculum norm, not national avoidance
- only a small minority cover it (rare presence) → append to each COVERING book "— signature topic (only X/Y in-scope books cover it)" and note in the diff summary what work the topic seems to do for those narrators — a topic most curricula cut, but these books made room for

Cover EXACTLY the books listed above — do not add or skip books, even if other corpus files exist in the directory.

THEN write a diff summary: at most 6 lines, only differences the quotes above actually support.

OUTPUT ONLY the markdown file content, exactly this structure, nothing before or after it:

# <topic title> — topic dossier
> MT extracts — map, not source. Verify every quote against the original page before it goes into a chapter.
> Generated by tools/topic_notes.sh · books: <ids>

## Diff summary
<max 6 lines>

## <id> — <one-line book identity with edition year>
- Status: covered | 0 mentions (in scope) | out of scope (covers YYYY-YYYY)
- Pages: ...
- Label(s): ...
- Agency: ...
- Numbers: ...
- People: ...
- Quotes:
  - [PAGE n] "..."
- Stems searched: en: ...; orig: ...

(one such section per book, in the order listed)
EOF
} > "$pf"

out="notes/$TOPIC.md"
log "topic $TOPIC ($TITLE) over: $IDS — grok primary"
# grok primary (cheaper, matched agy quality on the korea-1950 pilot); agy fallback
timeout 1200 grok --always-approve --max-turns 25 \
  -p "$(cat "$pf")" > "$out" 2>>"$LOG.err" || true
if [ "$(wc -c < "$out" 2>/dev/null || echo 0)" -lt 1500 ]; then
  log "  grok thin/empty ($(wc -c < "$out" 2>/dev/null || echo 0) bytes), retry via agy $MODEL"
  timeout 1200 agy --dangerously-skip-permissions --print-timeout 19m \
    --model "$MODEL" -p "$(cat "$pf")" > "$out" 2>>"$LOG.err" || true
fi
if [ "$(wc -c < "$out" 2>/dev/null || echo 0)" -lt 1500 ]; then
  rm -f "$out"
  log "  FAILED: $TOPIC"
  exit 1
fi
# Keep from the LAST occurrence of the dossier header: models sometimes emit
# leading narration, a truncated first draft, or a full duplicate echo — in
# every observed case the final copy is the complete one.
off=$(grep -abo '# .* — topic dossier' "$out" | tail -1 | cut -d: -f1)
if [ -n "$off" ]; then
  tail -c +$((off + 1)) "$out" > "$out.tmp" && mv "$out.tmp" "$out"
fi
log "  ok: $out ($(wc -c < "$out") bytes)"
