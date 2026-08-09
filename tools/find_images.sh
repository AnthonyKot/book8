#!/usr/bin/env bash
# Wikimedia Commons image candidates per chapter — evidence, not decoration.
# Queries are hand-curated per chapter; API results filtered to free licenses;
# output notes/images/candidates-NN.md for the human pick (editorial gate).
set -u
cd "$(dirname "$0")/.."
q() { # $1=outfile $2=query
  curl -s --max-time 30 "https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$2")&gsrnamespace=6&gsrlimit=4&prop=imageinfo&iiprop=url|extmetadata&format=json" | \
  python3 -c "
import json,sys
try: d=json.load(sys.stdin)
except: sys.exit()
for p in d.get('query',{}).get('pages',{}).values():
    ii=p.get('imageinfo',[{}])[0]; em=ii.get('extmetadata',{})
    lic=em.get('LicenseShortName',{}).get('value','?')
    if not any(x in lic for x in ('Public domain','CC0','CC BY')): continue
    artist=em.get('Artist',{}).get('value','')[:60].replace('|','/')
    import re; artist=re.sub('<[^>]+>','',artist)
    print(f\"| {p['title'].replace('File:','')[:65]} | {lic} | {artist} | {ii.get('url','')} |\")" >> "$1"
}
