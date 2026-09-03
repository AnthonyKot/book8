# Rework brief — chapter {{NN}} ({{FILE}}): from a comparison report to a little-known-history essay

You are rewriting one chapter of Book 8 (four countries' school history textbooks compared) so that a
normal reader finds it interesting. The author's reading of the current chapters: the comparison
sections read like a report, and the one part people enjoy is the closing "thread" section, the
little-known causal story behind the event. Invert the chapter around that part. Work only on
`chapters/{{FILE}}` and a new page `chapters/{{NN}}-receipts.html`. Do not touch any other file. Do not
run git.

Read first: `CONTEXT.md`, `TEMPLATE.md`, `AGENT.md`, then the chapter itself, then one neighbour
chapter for the shared markup (site-nav, chapter-nav, figure and receipts classes, `static/style.css`).

## The new shape (target 1,300–1,700 words on the chapter page)

1. **Open with the thread.** The chapter's little-known story (the section currently called "The
   thread", or its equivalent: "The crossing", "The picture", "Why the 1880s", whichever section tells
   the causal story the textbooks cut) becomes the essay proper, first on the page, about 700–900
   words. Keep its figures and captions. Tighten, do not pad. No textbooks yet, except where the
   story cannot be told without one line from one of them.
2. **Then the twist**, 350–500 words, under a heading of your choosing: what the classrooms tell a
   fifteen-year-old about this, told as a finding, not a table. At most two quoted textbook lines,
   verbatim from the current chapter, with country and edition. What each country leaves out is the
   punchline. The ladder and the grammar analysis are summarised in prose here, not reproduced.
3. **One short paragraph** of credit and limits together (from "Credit where due" and "Where this
   stops being true"), 80–150 words.
4. **The dry facts** become a short list of five to eight lines under its own numbered heading (for
   example "The dates, briefly"), or are dropped if the essay already carries the dates. Never an
   unheaded list floating between sections.
5. **Close** in this order: the link "The full comparison and receipts for this chapter" →
   `{{NN}}-receipts.html`, then the book's refrain line (`<p class="coda">`), then the chapter-nav.

## The receipts page (`chapters/{{NN}}-receipts.html`)

Same shell, site-nav and style as the chapter. Title: the chapter title plus " — the comparison and
receipts". Content, moved verbatim from the current chapter: the ladder (every cell, every quote, every
translation), the tell, credit where due, where this stops being true, and the receipts list with its
badges. Nothing on this page may be paraphrased; it is the evidence, reorganised only by headings. Link
back to the chapter at the top and bottom. Keep the chapter-nav out of it.

## Rules, non-negotiable

- **Never false.** You may not add any fact, date, number, name or quotation that is not already in
  the current chapter, its receipts, or the corpus extracts under `corpus-en/` and `resources/`. If a
  sentence would be better with a fact you do not have, leave it out. This includes facts you are sure
  of: in the first batch a run added two true passport-abolition dates from memory and they had to be
  removed. Every date and number on the new page must be findable in the old page.
- **Quotes verbatim.** Any textbook quotation kept on the chapter page must match the current
  chapter character for character, including the translation and attribution.
- Preserve the chapter's kicker, title, site-nav, chapter-nav (prev/next links unchanged), figures with
  their credits, and the closing refrain. Keep the HTML valid and the existing class names.
- Voice: plain, concrete, no outrage, wonder rather than sneer (AGENT.md). Short paragraphs.
- When done, run `./verify.sh` from the repo root and fix anything it reports for your two files.
- Write `drafts/rework/{{NN}}-notes.md`: what moved where, what was cut, the two quotes kept, the word
  count before and after, and any place where you were tempted to add a fact and did not.

Final reply ≤120 words: word counts before and after, the section order, and the two quotes kept.
