# Book 8 — Corpus

Eleven official or market-leading school/university history textbooks, one per narrator position.
All files in `resources/`. Assembled 2026-08-08.

| # | Country | File | Book | Lang | Pages | MB | Years covered | Text extraction |
|---|---------|------|------|------|-------|----|---------------|-----------------|
| 1 | Belarus | `by-2021-koshelev-worldhistory11.pdf` | Кошелев и др., «Всемирная история. XIX — начало XXI в.», 11 кл., БГУ, MoE-approved | Russian | 265 | 10 | ~1800 – ~2020 | native text, clean |
| 2 | Russia | `ru-2023-chubaryan-worldhistory10.pdf` | Чубарьян, «Всеобщая история. Новейшая история 1914–1945», 10 кл., 2023 unified course | Russian | 241 | 8 | 1914 – 1945 | native text, clean |
| 3 | Kazakhstan | `kz-2015-history11.pdf` | «История Казахстана», 11 кл., Мектеп 2015, MoES-approved | Russian (KZ ru-medium schools) | 344 | 11 | ~18th c. – 2010s (thematic) | OCR, noisy (intra-word spaces) — grep works, quotes need cleanup |
| 4 | Ukraine | `ua-2019-hisem-martyniuk-history11.pdf` | Гісем/Мартинюк, «Всесвітня історія», 11 кл., 2019, МОН-approved | Ukrainian | 226 | 7 | 1945 – ~2018 | native text, clean |
| 5 | China | `cn-2019-zhongwai-gangyao-shang.pdf` | «中外历史纲要 上», state-compiled (统编), current | Chinese (simplified) | 217 | 20 | antiquity – ~2017 (Chinese history) | native text, clean |
| 6 | India | `in-ncert-themes-world-history11.pdf` | NCERT, «Themes in World History», Class XI, post-2022 rationalized ed. (8 chapter files merged) | English | 200 | 30 | ~3000 BCE – ~2000 | native text, clean |
| 7 | Sudan | `sd-2009-history3-secondary.pdf` | MoE, «التاريخ», 3rd secondary, rev. ed. 2009 (Bakht al-Ruda) | Arabic | 275 | 35 | 1821 – ~1948 | native-ish, RTL/ligature artifacts — greppable, quotes need care |
| 8 | Germany | `de-2012-bpb-ns-krieg-holocaust.pdf` | bpb, «Informationen zur politischen Bildung» Nr. 316: «Nationalsozialismus: Krieg und Holocaust», 2012 (federal agency) | German | 84 | 8 | 1939 – 1945 (+ postwar reckoning) | native text, clean |
| 9 | Italy | `it-2004-sabbatucci-vidotto-mondocontemporaneo.pdf` | Sabbatucci–Vidotto, «Il mondo contemporaneo. Dal 1848 a oggi», Laterza 2004 (university manual) | Italian | 749 | 4 | 1848 – ~2004 | native text, clean |
| 10 | UK | `uk-2013-lowe-modernworldhistory.pdf` | Norman Lowe, «Mastering Modern World History», 5th ed., Palgrave 2013 (GCSE/A-level market standard) | English | 999 | 13 | ~1900 – 2013 | native text, clean |
| 11 | USA | `us-2022-openstax-worldhistory2.pdf` | OpenStax, «World History, Volume 2: from 1400», Rice Univ. 2022, CC BY | English | 723 | 127 | 1400 – ~2022 | native text, clean |

## Notes

- **Approval mechanism** varies by design — it is a comparison axis: state monopoly (BY, RU, CN, SD), ministry approval list (UA, KZ, IN), federal-agency civic material (DE), free market (IT, UK, US).
- **KZ is not a world-history narrator** (user decision 2026-08-08): «История Казахстана» is the national-history course — comparing it to world-history books on world events is genre mismatch. Use it only for signature topics (1937 Korean deportation, Polish/German deportees, republic-level Soviet policy); never as a peer column in an event ladder. The proper KZ column would be the KZ «Всемирная история» textbook — wishlist.
- **Genre caveats**: DE is an agency booklet, not a school textbook (German commercial textbooks are paywalled; two Buchners Leseproben in Downloads document structure only). IT is the university manual by the authors of the school market leader. RU is the grade-10 volume (1914–1945); the grade-11 visual aid (poster companion, in Downloads) supplements post-1945 rows.
- **Editions are dated deliberately** — several sources are pre-2022 (UA 2019, KZ 2015, IT 2004, UK 2013); every quote must carry its edition year.
- **RU post-1945 gap**: the RU row is the grade-10 volume only. The grade-11 visual aid is translated as `corpus-en/ru-aid.txt` (bare-label event rows: Korean War, KAL 007 …) as a stopgap; the real fix is the companion textbook — Мединский/Чубарьян, «Всеобщая история. 1945 — начало XXI века», 11 кл., 2023 — add via `tools/translate_one.sh ru11 Russian <pdf>` when found.
- Supplementary sources kept in `C:\Users\CoderA\Downloads`: RU 2023 grade-11 visual aid, Полянський UA 2019 (variance control + 2014 chapter), Загладин RU 2014 (colonial control row), CN 2004 人民版 scan (time axis), Buchners Leseproben (DE structure), HK CityU 2018 essay volume (bibliography).
