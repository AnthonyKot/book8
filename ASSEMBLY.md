# ASSEMBLY — from fifteen drafts to one book

The problem, measured (2026-08-09): the limits-closer formula appears in 11 chapters,
"N of 11" punchlines 12 times, editor-instruction leakage ("Say the causation exactly")
in 3, and every chapter carries identical section furniture with no tissue between
chapters. Diagnosis: what reads as "AI analysis" is not the method — it is verbatim
sentence reuse plus the absence of the connective layer CONTEXT.md designed but nobody
built. The fix is one part construction (A), one part editing (B), one part carpentry (C).

Principle: KEEP the fixed refrains — kicker · ladder · "Credit where due" · the coda —
they are the book's rubrics, its identity across essays. KILL verbatim sentence reuse
between chapters. VARY the punchline shapes. BUILD the tissue.

## Phase A — the connective layer (construct; can start now, in parallel)

A1. **Introduction essay** (~2 pages): the method told as a story, not a spec — the
    first Korea grep, five books disagreeing about who crossed a parallel, the decision
    to read eleven textbooks against each other. Establishes the narrator's stance
    (see decision D2). Ends by teaching the reader the rubrics once, so chapters
    don't have to ("Dry scaffolding… the ruler" explained here, then trimmed there).
A2. **Meet the narrators** — the Axis 2 card deck (pending from reader's grok chat;
    reassign to Opus if it doesn't land). Placed after the introduction. Cards carry
    each book's space-allocation fingerprint from the measured tables.
A3. **Part openers I–V** — half-page handoff essays per CONTEXT.md: each narrates the
    causal bridge (why Versailles follows 1914, why the Depression walks into Spain
    "wearing a uniform") and hands off in the voice of the braid, not a summary.
    These are where inheritance lives, freeing chapter ledes to stay pure image.
A4. **Interlude: "The wiring diagrams"** — extract the diagram list now inside ch. 11
    into a standalone set piece between Parts IV and V: the same nodes drawn per
    narrator, arrows only. One SVG per narrator, four to six diagrams.
A5. **Epilogue** — the open question: the late-century exhibits (Hungary 56, Afghanistan,
    KAL 007, Tiananmen, Crimea 14) compressed to one ladder each, closing with the
    book-level transformation of the refrain: after fifteen chapters of "now look up
    what your textbook calls it," the epilogue's last line turns it on the reader's
    present. Uses the RU-aid rows and UA/KZ material that never got a chapter.
A6. **Contents page** = real table of contents with the braid SVG; index.html becomes
    the book's front door (title, tagline, cards link, parts, epilogue).

## Phase B — the harmonization pass (edit; after ch. 12/14 threads land)

B1. **Dedupe the formulas.** One editorial read 1→15 in order. Each chapter keeps AT
    MOST one "N of 11" punchline in prose (the thread's count); other counts move to
    receipts badges. The limits closer gets rewritten per chapter in local vocabulary
    (ch. 2 already has the right template: "including the one that runs fifty-five
    pages"). Remove editor-voice leakage ("Say … exactly" phrasing) — precision stays,
    stage directions go.
B2. **Vary the variable furniture.** Fixed rubrics stay fixed. But "The boring facts"
    intro line, the ladder preamble, and the tell's opening move must not repeat
    sentence-for-sentence across chapters — each gets chapter-specific wording.
B3. **Length and register variation.** Not every chapter deserves equal weight and the
    book should show it: Katyn exhibit stays half-length inside ch. 11; ch. 12 keeps
    its sober register visibly distinct; one or two chapters (3, 10) can afford the
    longer essayistic tells. Sameness of length is itself a tell.
B4. **Space data integration.** Each ladder gets its measured space line (from
    notes/space tables, double-pass-confirmed): "dedicated space: BY 0.00% · UA 0.93%…"
    — one line, not a table, converting adjectives to numbers as a recurring signature.
B5. **Finish the stragglers to the same standard**: ch. 1 retrofit (tea thread beat +
    space line + align limits to the matured voice), ch. 6 thread (bread queue — from
    reader's grok or reassigned), ch. 12 + ch. 14 threads (pitch picks pending),
    Katyn exhibit merged into ch. 11 at its socket.

## Phase C — carpentry (last)

C1. Promote drafts/NN-*.opus.html → chapters/NN-slug.html; retire the workbench from
    the public flow (keep as /drafts.html for provenance).
C2. Fix the nav chain (every prev/next resolves; part openers in the chain) and extend
    verify.sh mechanically: nav-chain check, coda-refrain check, one-space-line-per-
    chapter check. Still light, still no reference machinery.
C3. Typography/polish pass: ladder tables on mobile, pull-quote rhythm, the braid SVG,
    print stylesheet. Title metadata unified per D1.
C4. Final anti-leak audit + full-corpus quote re-grep (script exists piecemeal; run it
    once end-to-end and archive the log as the book's evidentiary record).

## Decisions needed from the reader (blocking B/C, not A)

D1. **Title.** Site header says "Same War, Different Classroom"; CONTEXT.md still says
    "Same event. Different classrooms." Chapters' <title> tags are split between them.
    Pick one; the loser becomes the tagline's first line.
D2. **Narrator stance.** The chapters currently have an implicit editorial narrator.
    Options: stay impersonal (essays with no "I"), or allow a restrained first-person
    plural in the intro/part openers only ("we ran the search; here is what came back").
    Recommendation: the second — the connective layer needs a voice, the chapters don't.
D3. Ch. 12 and ch. 14 thread picks (pitch files on the workbench).

## Sequencing

Now: A1, A3, A5 drafts (Opus, one brief each, my audit); A4 SVG sketch; B5 items as
their inputs arrive. After D3: B1–B4 as one editorial pass (editor, not writers).
Then C. Rough calendar: A in a day, B in a sitting once inputs land, C in an evening.
