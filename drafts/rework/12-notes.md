# Chapter 12 rework notes

## What moved where

- The former “The paperwork” thread now opens the chapter as “The list and the archive.” It joins Ringelblum and Oyneg Shabes to the Speer office card index, the Wannsee total, the 1933 and 1939 censuses, punch-card tabulation and the modern census-form landing.
- Both documentary figures and their captions remain on the chapter page.
- The complete ladder, every cell, quotation and translation, the full “The widening circle” tell, “Credit where due,” “Where this stops being true,” and the receipts list with its badges moved verbatim to `chapters/12-receipts.html`. Only their heading numbers changed.
- The ladder and grammar analysis became the prose finding “What reaches the classroom.” Credit and limits are combined into one short paragraph. The chronology became a seven-line list under “The dates, briefly.”

## What was cut

- The question box and the report-like country-by-country walk through the ladder were removed from the chapter page.
- Repetition between the old lede, the paperwork thread and the closing transition was cut.
- The extended death-factory discussion, the Babi Yar comparison, detailed genre cautions, search stems, page references and source disputes now live only on the receipts page.
- The eight-line chronology was compressed to seven lines, and the transition into the Hiroshima chapter was dropped so the receipts link leads directly to the refrain.

## The two quotes kept

1. RU · Чубарьян 2023: «После взятия Киева в районе Бабьего Яра было расстреляно около 70 тыс. евреев…» / “After the taking of Kyiv, in the area of Babi Yar about 70 thousand Jews were shot…”
2. DE · bpb Nr. 316, 2012: „Deutsche Soldaten beteiligten sich an den Mordtaten gegen die Zivilbevölkerung, sicherten die Erschießungsstätten ab, brannten ganze Dörfer nieder…“ / “German soldiers took part in the killings of the civilian population, secured the shooting sites, burned whole villages down…”

Both original-language lines, translations and displayed citations match the former chapter text character for character; country and edition labels sit immediately above them.

## Word count

- Before: **6,312 visible words** on the chapter page.
- After: **1,462 visible words** on the chapter page.
- The opening essay is 726 words, the classroom twist is 428 words, and credit and limits together are 114 words.
- Method: `pandoc -f html -t plain … | wc -w`, including visible text inside `<main>`; Pandoc omits the figure captions in this layout, consistently before and after.

## Facts deliberately not added

- I was tempted to say that specific punch-card codes identified Jews, that tabulators directed deportation traffic at railway hubs, or that Auschwitz registration numbers were Hollerith numbers. The old limits section says those stronger claims are disputed, so none was added.
- I did not add present-day census schedules, legal-response rules or country examples beyond the chapter’s supported general point that a census form makes a household countable.
