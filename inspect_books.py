import re, os

books = ["ru", "ua", "by", "cn", "de", "it", "sd", "in", "uk", "us"]

# Define key terms for India 1930-1947
keywords = [
    r"\bGandhi\b", r"\bGandhism\b", r"\bAmritsar\b", r"\bJallianwala\b",
    r"\bSalt March\b", r"\bQuit India\b", r"\bcivil disobedience\b",
    r"\bNehru\b", r"\bJinnah\b", r"\bIndian National Congress\b",
    r"\bMuslim League\b", r"\bRowlatt\b", r"\bpartition\b", r"\bsatyagraha\b",
    r"\bIndia\b", r"\bIndian\b", r"\bPakistan\b", r"\bMountbatten\b"
]
kw_regex = re.compile("|".join(keywords), re.IGNORECASE)

def get_page_dict(b):
    en_path = f"corpus-en/{b}.txt"
    with open(en_path, "r", encoding="utf-8", errors="ignore") as f:
        text = f.read()
    
    pages = {}
    if "[PAGE 1]" in text or "[PAGE 2]" in text:
        parts = re.split(r"\[PAGE\s+(\d+)\]", text)
        # parts[0] is header/before first marker
        for i in range(1, len(parts), 2):
            pnum = int(parts[i])
            pcontent = parts[i+1]
            pages[pnum] = pcontent
    else:
        parts = text.split("\f")
        for idx, pcontent in enumerate(parts, 1):
            pages[idx] = pcontent
    return pages

for b in books:
    pages = get_page_dict(b)
    hits = {}
    for pnum, content in sorted(pages.items()):
        matches = kw_regex.findall(content)
        if matches:
            hits[pnum] = set(m.lower() for m in matches)
    print(f"=== BOOK {b} (total pages: {len(pages)}) ===")
    print(f"Pages with keywords ({len(hits)} pages): {sorted(hits.keys())}")
    for pnum in sorted(hits.keys()):
        print(f"  Page {pnum}: {sorted(list(hits[pnum]))}")

