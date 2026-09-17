#!/usr/bin/env bash
# Stamp every page's stylesheet link with a hash of style.css so browsers refetch it
# when it changes (GitHub Pages caches for 10 min). Idempotent. Run before committing.
cd "$(dirname "$0")/.."
v=$(md5sum static/style.css | cut -c1-8)
sed -i -E "s|(href=\"(\.\./)?static/style\.css)(\?v=[0-9a-f]+)?\"|\1?v=$v\"|" index.html contents.html about.html space-matrix.html images.html drafts.html chapters/*.html 2>/dev/null
echo "style.css stamped v=$v"
