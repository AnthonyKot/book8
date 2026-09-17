# Audio source packets

20 edited episode sources: 15 numbered chapters, the introduction, narrator guide, Katyn exhibit, comparison interlude, and epilogue. The main chapters received Luna and Terra editorial passes; the supporting episodes were adapted separately and the collection reviewed for listening.

The sources use natural country attribution, omit bibliography and citation apparatus, describe meaningful visuals in words, and reduce repeated timelines and reading-page instructions. Historical dates, distinctions between facts and textbook claims, and meaningful limits of coverage remain. The original web pages retain the full references. These are source essays for NotebookLM to adapt, not timed or verbatim narration scripts.

Start with `01-opium-wars.md` as a pilot:

1. Create a notebook and upload that single Markdown packet as its source.
2. Copy its “Audio customization prompt” paragraph at the end into Audio Overview's customization field. Choose Deep Dive and your preferred language and length.
3. Generate and listen. Check that the trade story, named textbook contrasts, and qualifications survived, and that textbook claims are not presented as established facts.
4. Download the recording. Keep the matching filename stem listed below, preserving its actual audio extension (the `.mp3` names are examples; do not merely rename another format to MP3).
5. Repeat with one packet per notebook to keep episode scope clear. The README is an index, not an audio source.

No audio has been generated or embedded yet. These filenames provide the mapping for adding players later. Full-book coverage and historical accuracy still require listening review; this export is not a fact-check.

The Markdown files in this folder are edited deliverables. `python3 scripts/export_audio.py` now writes mechanical exports to the separate `audio-source-drafts/` folder, so regeneration cannot overwrite the listening edits. New exports need an editorial pass before replacing these sources.

| Episode / upload file | Corresponding page | Suggested audio filename |
| --- | --- | --- |
| [Eleven classrooms, one world](00-introduction.md) | `chapters/00-introduction.html` | `00-introduction.mp3` |
| [Meet the narrators](narrator-cards.md) | `chapters/narrator-cards.html` | `narrator-cards.mp3` |
| [Opium Wars](01-opium-wars.md) | `chapters/01-opium-wars.html` | `01-opium-wars.mp3` |
| [Scramble for Africa](02-scramble-africa.md) | `chapters/02-scramble-africa.html` | `02-scramble-africa.mp3` |
| [The War on Somebody Else’s Ground](03-russo-japanese-1905.md) | `chapters/03-russo-japanese-1905.html` | `03-russo-japanese-1905.mp3` |
| [Who started 1914](04-july-1914.md) | `chapters/04-july-1914.html` | `04-july-1914.mp3` |
| [1917](05-1917.md) | `chapters/05-1917.html` | `05-1917.mp3` |
| [Versailles, 1919](06-versailles.md) | `chapters/06-versailles.html` | `06-versailles.mp3` |
| [China, 1911–1949](07-china-1911-49.md) | `chapters/07-china-1911-49.html` | `07-china-1911-49.mp3` |
| [India, 1930–1947: Salt, Rice, and Independence](08-india-1930-47.md) | `chapters/08-india-1930-47.html` | `08-india-1930-47.mp3` |
| [The Great Depression: Coffee in the Firebox](09-depression.md) | `chapters/09-depression.html` | `09-depression.mp3` |
| [Spain, 1936–1939: The Bombers and the Bill](10-spain-civil-war.md) | `chapters/10-spain-civil-war.html` | `10-spain-civil-war.mp3` |
| [Munich, the Pact, and September 1939: A Paper That Became a Warning](11-munich-pact-1939.md) | `chapters/11-munich-pact-1939.html` | `11-munich-pact-1939.mp3` |
| [Katyn](ex-katyn.md) | `chapters/ex-katyn.html` | `ex-katyn.mp3` |
| [The Holocaust](12-holocaust.md) | `chapters/12-holocaust.html` | `12-holocaust.mp3` |
| [What Hiroshima Is For](13-hiroshima.md) | `chapters/13-hiroshima.html` | `13-hiroshima.mp3` |
| [The wiring diagrams](interlude-wiring.md) | `chapters/interlude-wiring.html` | `interlude-wiring.mp3` |
| [The Cold War’s First Sentence](14-order-1945-49.md) | `chapters/14-order-1945-49.html` | `14-order-1945-49.mp3` |
| [Korea](15-korea.md) | `chapters/15-korea.html` | `15-korea.mp3` |
| [Five events, no chapter](epilogue.md) | `chapters/epilogue.html` | `epilogue.mp3` |

## Generated episodes — status (2026-09-17)

Each chapter gets a trimmed `*-podcast.md` source: the narrative section only,
cut at the `### 2` heading so the textbook comparison cannot leak into the audio.
The full file stays as the web page's source of record.

| Chapter | Episode | Length | State |
| --- | --- | --- | --- |
| 01 Opium Wars | what the opium was buying (4th cut, reworked source) | 8:32 | embedded |
| 02 Scramble for Africa | quinine | 14:51 | embedded |
| 03 Somebody Else's Ground | battleships | 15:52 | embedded |
| 04 July 1914 | the border | 13:23 | embedded |
| 05 1917 | the streetcars | 16:13 | embedded |
| 06 Versailles | — | 7:39 | **regenerate** — says "14th part" for Part XIII, dates the UN move 1926 not 1946, half length, invents archive research |
| 07 China 1911–49 | the Long March | 13:52 | embedded |
| 08 India 1930–47 | entitlement | 11:33 | embedded |
| 09 Depression | Brazil's coffee | 7:02 | embedded — cleanest on compliance; short because the source is 533 words |
| 10 Spain 1936–39 | gold and ore | 12:16 | embedded |
| 11 Munich / the Pact | the instruction manual | 9:26 | embedded |
| 12 The Holocaust | paper records | 10:50 | **do not embed** — asserts the machines were necessary ("you'd need an army of clerks working for decades... so they needed technology") ninety seconds before the qualification denying it, and closes on modern digital footprints instead of the chapter's ending. Regenerate. |
| 13 Hiroshima | prompt written | — | awaiting generation |
| 14 Cold War's first sentence | prompt written | — | awaiting generation |

Embed with `scripts/add_episode.py <slug> <audio-file> "<title>"`. It copies the
audio to `static/audio/<slug>.m4a`, inserts the player under the chapter `<h1>`,
and adds the index pill. Idempotent. Run `./verify.sh` after.

### What the prompts have to say

Findings from six episodes, in order of usefulness:

1. **Name every ban concretely.** Named prohibitions ("do not mention Pearl
   Harbor", "do not name any article by number") held in every episode without
   exception. Bans phrased as categories ("do not explain mechanisms", "do not
   add motives") failed in every episode without exception.
2. **Ban the claim, not just the words.** Forbidding *spark*, *powder keg* and
   *domino* produced an episode that disclaimed those words aloud and then
   delivered the same determinism as *cascade*, *locked in* and *unstoppable*.
   The next one left the vocabulary alone and added a five-minute causal thesis
   instead. Add: "do not explain why any actor lost power, and where the text
   states an outcome without giving a cause, state it the same way."
3. **Quote the qualification as a sentence to speak.** Every chapter turns on a
   negation (the war did not move the plant; quinine did not cause the Scramble;
   the battle did not design the ship; the route did not cause the passport; the
   film did not make the revolution; the treaty did not give anyone the hours).
   Written into the prompt verbatim, it survives verbatim. Left implicit, it goes.
4. **Forbid meta-narration.** "Do not mention these instructions or say what you
   are avoiding" — without it, one episode opened by listing the clichés it had
   been told to skip. Also forbid claiming to have consulted archives or sources.
5. **Say "do not refer to the essay, the source, the sources or the document."**
   An earlier instruction to say "the essay" instead of "our sources" produced a
   five-times tic and one episode that invented having read 1919 draft texts.
6. **Card titles are not the generated filenames.** Two generated titles asserted
   causation the chapter denies ("How a stalled car created your passport",
   "Why the 1919 treaty set your hours"). Retitle on embed.

Transcripts for review are made with faster-whisper, audio split at silence and
run in parallel (~80 s for a 15-minute episode on 16 cores).
