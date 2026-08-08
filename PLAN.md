# PLAN — three-writer production run (2026-08-08)

The bake-off becomes production. Three writer models, three topics, one review
loop, finals merged per chapter. Rules of record: CONTEXT.md → AGENT.md →
TEMPLATE.md. Every draft passes the editor audit (quote grep vs corpus-en AND
corpus-orig, banned words, hallucinated-source check) BEFORE the human reads it.

## Steps

1. **Read all comparisons** (done — 9 full-corpus dossiers in notes/, all audited).
2. **Pick the 3 most promising chapter opportunities** (done — see assignments).
3. **One topic per writer**, most promising → strongest model:

| Writer | Topic | Output | Why this pairing |
|---|---|---|---|
| **Opus 5** | Korea, 1950–53 (ch. 15 finale) | drafts/15-korea.html + pitches | Most promising: the book's proof event, full 11-way ladder incl. 抗美援朝 originals, UK 5-page / US full-section depth, 3 thread pitches already staged |
| **grok** | Munich→Pact→Sept 1939 (ch. 11) | drafts/11-munich-pact-1939.html + pitches | Second: three dossiers merge (munich 19K + sept-1939 20K + katyn 9K), the wiring-diagrams chapter; grok's proven strengths = original-script stems, honest negatives |
| **agy** | Katyn exhibit (inside ch. 11) | drafts/ex-katyn.html | Smallest, most precise assignment: the «некоторые… расстреляны» exhibit, numbers question, zero-mention badges. Merges into ch. 11 at step 5 |
| (bonus) Opus 5 | Pacific & Hiroshima (ch. 13) | drafts/13-hiroshima.html | Already in flight before this plan; joins the same review flow |

   Thread beats are NEVER drafted cold: writers leave the placeholder and file
   pitches; the human picks per the guinea-pig gate (AGENT.md).
4. **Editor audit** (Fable): quote fidelity vs both corpora, banned words,
   source-title check, structure vs exemplars. Fix or bounce before human review.
5. **Reader switcher**: drafts.html — a workbench page listing every draft +
   shipped chapter so the human can flip through all articles in one place.
   Not linked from the public index; drafts/ stays out of verify.sh count-sync.
6. **Human review** → notes per article → rewrite/merge round:
   - agy's Katyn exhibit merges INTO grok's ch. 11 (placeholder marked in draft)
   - chosen thread pitches get written (by the writer that owns the chapter)
   - per-chapter notes applied; final files move drafts/ → chapters/, index
     updated, verify.sh green → shipped.
7. Done when ch. 11, 13, 15 (+ already-shipped 1, in-review 6) are in chapters/.

## Standing gates

- Guinea-pig gate: thread pitches → human reaction → write. No reaction, no thread.
- Errors are data: textbook mistakes (NCERT Comintern 1918, BY Singapore) stay
  verbatim, flagged in Limits.
- SD Arabic originals can't be grep-verified (ligatures) — printed-page eye check
  before any SD quote ships.
- KZ never a ladder column.

## Open decisions (human)

- Korea thread pick: (a) half-hour border · (b) war never ended · (c) Koryo-saram
  — plus whatever Opus pitches.
- Site title: "Same War, Different Classroom" vs "Same event. Different
  classrooms." (ch. 6 title tag currently disagrees with the site header).
- ch. 6 grok thread (bread queue / March 8) — in progress in user's grok chat.
