# Book 8 — CONTEXT (authority document)

Comparative reading of school history textbooks: the same events, eleven national narrators.
Working tagline: **Same event. Different classrooms.** Third line open:
(a) "Watch what each textbook needs the student to believe." (b) "Every textbook tells the
truth — about the countries it doesn't love."

Precedence (from book6): this file → AGENT.md (audience, priority stack, cup-of-tea rule,
the missing-piece thread) → chapter contract → TEMPLATE.md → chapter prose.

## Thesis

Textbooks nationalize three things: **agency** (who acts), **omission** (what exists), and
**causality** (what caused what — visible only *between* chapters). Candor scales with the
narrating state's distance from the actor; state control of textbook approval determines
self-pole candor (ministry books soften their own state; market books interrogate it).
Convergence exists too — the colonial-era control row proves textbooks agree when nobody's
identity is at stake. Coding categories per passage: space · agency · vocabulary · causes ·
numbers · people. Omission verified by search is a data point, not a gap — but graded
against the corpus baseline: a zero is an **avoidance signal** only when most in-scope
narrators cover the topic (rule of thumb: 6+ of 11 cover it, 2–3 skip it entirely); an
omission shared by most books is curriculum norm, not national avoidance. The rule is
symmetric: a topic only 2–3 narrators cover is a **signature topic** — most curricula cut
it, these books made room, and what it does for them is the finding (KZ's 1937 Korean
deportation pages, CN's May Fourth). School books cannot fit all of modern history —
the finding is the correlation, in either direction, not the absence or presence itself.

## Corpus

11 sources, one per narrator position — see `CORPUS.md` (sizes, years, languages,
parseability, approval mechanism per country, genre caveats, supplementary sources in
Downloads). Editions are pinned; every quote carries its edition year. ~7 core columns
(BY RU UA CN IT UK US) + 4 special-purpose voices (DE = WWII self-incrimination pole;
SD = colonial resistance + 1948; IN = chapter-deletion meta-finding + Hiroshima/China rows;
KZ = NOT a world-history narrator (national-history genre, user decision 2026-08-08) —
kept only for signature topics: deportation memory (1937 Koreans, Polish deportees), Soviet
policy as lived in the republics. Never put KZ in a world-event ladder as a peer column.
Wishlist: the actual KZ «Всемирная история» 11 кл. would restore a proper KZ core column.

**English research corpus** (`corpus-en/`, built by `tools/translate.sh` via agy/grok):
discovery only, NEVER a citation source — machine translation smooths exactly the wording
this book studies. Discovery in English; evidence quoted from the original page,
hand-translated. `corpus-orig/` holds pdftotext extractions with page breaks.

## Spine (~14–16 chapters + open epilogue question)

| Part | Chapters |
|---|---|
| I Imperialism | 1 Opium Wars · 2 Scramble for Africa (SD lead) · 3 Russo-Japanese 1905 |
| II Great War | 4 Who started 1914 · 5 Versailles (incl. US entry; CN May-Fourth angle) |
| III Revolutions | 6 1917 · 7 China 1911→49 · 8 India 1930–47 (Amritsar 3-way: UK 0 · US "horrific" · IN self) |
| IV Deals & War | 9 Depression · 10 Spain · 11 Munich→Pact→Sept 1939 (Katyn exhibit) · 12 Holocaust (DE lead) · 13 Pacific & Hiroshima |
| V Cold War opens | 14 The 1945–49 order · 15 **Korea — finale** (the full ladder) |

Late-century exhibits (Hungary 56, Afghanistan 79, KAL 007, Tiananmen, Crimea 14) → possible
compressed epilogue; the UA and KZ books mostly live there. Decision open.

## Two axes

Axis 1 = episode chapters (rows: one event, N tellings). Axis 2 = book profiles (columns:
one narrator across all episodes), fixed template: identity/edition · approval mechanism ·
what it's good for · blind zone · signature move · fingerprint quote. Reading order:
"meet the narrators" cards → episodes → full profiles as synthesis. Credit precedes critique.

## Chapter form

Nine beats in `TEMPLATE.md` — a rhythm, not a form; chapters may merge or drop beats.
Key inherited devices: fixed narrator order every chapter; per-chapter Lead + absent-is-data
(book1); ladder table ordered agentless→agentive, empty cells meaningful (book1 entry-table);
lede states the situation not the lesson, question-box div, fixed credit-where-due beat,
"where this stops being true" limits section (book7); "Read the originals" closing receipts
with edition + page (book1) — human-readable, no verification machinery (user decision).

## Connections

Level 1 — causal braid: kicker carries `Inherits: X (ch. N) · Feeds: Y (ch. M)` (max two);
half-page part openers narrate handoffs; contents page carries one braid SVG.
Level 2 — the finding: narrators wire the same nodes with different edges (RU: Munich→war,
Pact as consequence; UK: appeasement+Pact→war; DE: German responsibility; CN: imperialist
system since Opium). Set piece: **"The wiring diagrams"** interlude — same chapter-nodes
drawn ~4×, once per major narrator, only arrows change.

## Voice (transposed from book6)

- **Quotes or nothing** — no claim about a textbook without the passage, original + translation.
- **Banned blame register**: *propaganda, brainwashing, regime* (as sneer), *sheep* — contempt
  teaches the reader to stop checking their own textbook, and the coda depends on them checking.
- **Banned guide register**: *just, simply, obviously, of course*.
- Funny by accuracy — the joke is the recognition; no memes.
- Provocations may open a chapter or part, never close one. Headline rule: no title claims
  more than its quotes support. Jargon defined once, never apologised for.
- Fixed coda every chapter: "Now look up what your textbook calls it."

## Checks (deliberately light — user decision, no per-reference verification)

`verify.sh`: internal links (gating) · chapter-count sync computed not typed · HTML nesting ·
**anti-leak (gating, non-negotiable): no PDF/corpus file ever tracked by git** — resources/,
corpus-orig/, corpus-en/ are copyrighted or derived; the repo publishes to GitHub Pages.

## Status log

- 2026-08-08: corpus assembled (11 PDFs), CORPUS.md + TEMPLATE.md written, design settled
  (spine, two axes, voice, connections, checks), translate pipeline built and launched.
  No chapters yet. First chapter planned: Korea (proof-of-format) or Opium Wars (book order).
- 2026-08-08 (later): English corpus built for ru ua by kz cn de + ru-aid (it/sd in flight,
  en books copied). `tools/topic_notes.sh` (dossier cache, grok primary — beat agy on the
  korea-1950 pilot) + `translate_one.sh` (add a book without touching running pipelines).
  First dossier: notes/korea-1950.md — new findings: BY pure-agentless pole, KZ Korea =
  1937 deportees not the war, CN full 抗美援朝 quote set. Omission rule: avoidance only
  vs corpus baseline. RU post-1945 gap known — wants Мединский/Чубарьян 11 кл. (2023).
- 2026-08-08 (evening): **Chapter 1 shipped** — `chapters/01-opium-wars.html` (+ index,
  about, static). Ladder UK→BY→IT→US→IN→CN; credit IN (triangle) + US (sequence); CN depth
  lead. Original-language pulls for CN/BY/IT; EN books from native text. Open ch.2 link is
  a stub until Scramble is written.

