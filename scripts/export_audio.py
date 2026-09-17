#!/usr/bin/env python3
"""Export listening sources without the printed book's citation apparatus."""
from html.parser import HTMLParser
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
# The listening sources receive manual editorial work. Never overwrite them.
OUT = ROOT / 'audio-source-drafts'
COUNTRIES = dict(zip(
    ['UK', 'US', 'BY', 'RU', 'UA', 'CN', 'IN', 'IT', 'DE', 'SD', 'KZ'],
    ['British', 'American', 'Belarusian', 'Russian', 'Ukrainian', 'Chinese', 'Indian', 'Italian', 'German', 'Sudanese', 'Kazakh']))


class Node:
    def __init__(self, tag='', attrs=()):
        self.tag, self.attrs, self.children = tag, dict(attrs), []

    def find(self, tag):
        return [c for c in self.children if isinstance(c, Node) and c.tag == tag] + [
            n for c in self.children if isinstance(c, Node) for n in c.find(tag)]


class Parser(HTMLParser):
    def __init__(self, html):
        super().__init__(convert_charrefs=True)
        self.root = Node()
        self.stack = [self.root]
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        node = Node(tag, attrs)
        self.stack[-1].children.append(node)
        if tag not in {'img', 'br', 'hr', 'meta', 'link', 'input', 'wbr', 'source'}:
            self.stack.append(node)

    def handle_endtag(self, tag):
        for i in range(len(self.stack) - 1, 0, -1):
            if self.stack[i].tag == tag:
                del self.stack[i:]
                break

    def handle_data(self, data):
        self.stack[-1].children.append(data)


def plain(node):
    if isinstance(node, str):
        return re.sub(r'\s+', ' ', node)
    return ''.join(plain(c) for c in node.children)


def render(node):
    if isinstance(node, str):
        return re.sub(r'\s+', ' ', node)
    tag = node.tag
    classes = set(node.attrs.get('class', '').split())
    if tag in {'script', 'style', 'nav', 'button', 'figcaption'} or 'cite' in classes:
        return ''
    # Keep original quotations in drafts: removing them automatically can lose
    # English originals or evidence with no separate translation.
    if tag == 'section' and any(re.search(r'Receipts|Read the originals', plain(h), re.I) for h in node.find('h2')):
        return ''
    if tag == 'li' and plain(node).strip().startswith('The book'):
        return ''
    if tag == 'svg':
        return '\n\nVisual description: ' + ' — '.join(plain(n).strip() for n in node.find('title') + node.find('desc')) + '\n\n'
    if tag == 'img':
        return '\n\nImage description: ' + node.attrs.get('alt', '') + '\n\n'
    if tag == 'table':
        rows = node.find('tr')
        headers = [plain(n).strip() for n in rows[0].find('th')]
        entries = []
        for row in rows:
            cells = row.find('td')
            if not cells:
                continue
            entries.append('\n\n' + '\n\n'.join(
                '**' + (headers[i] if i < len(headers) else f'Field {i + 1}') + ':** ' + render(cell).strip()
                for i, cell in enumerate(cells)))
        return '\n\nComparison entries (in the original order):' + '\n\n---'.join(entries) + '\n\n'
    text = ''.join(render(c) for c in node.children).strip()
    if tag == 'a':
        return text
    if tag in {'h1', 'h2', 'h3', 'h4'}:
        if ' · ' in text and tag != 'h1':
            text = text.split(' · ')[0]
        return '\n\n' + '#' * (min(int(tag[1]) + 1, 6)) + ' ' + text + '\n\n'
    if tag in {'strong', 'b'}:
        match = re.match(r'^(UK|US|BY|RU|UA|CN|IN|IT|DE|SD|KZ)\s*·', text)
        if match:
            text = COUNTRIES[match[1]] + ' textbook'
        match = re.search(r'\((UK|US|BY|RU|UA|CN|IN|IT|DE|SD|KZ)\)$', text)
        if match:
            text = 'The ' + COUNTRIES[match[1]] + ' textbook'
        return '**' + text + '**'
    if tag in {'em', 'i'}:
        return '*' + text + '*'
    if tag == 'br':
        return '\n'
    if tag == 'li':
        return '\n- ' + text + '\n'
    if tag == 'blockquote':
        return '\n\n' + '\n'.join('> ' + line for line in text.splitlines()) + '\n\n'
    if tag == 'span':
        if set(node.attrs.get('class', '').split()) & {'orig', 'cite', 'tag'}:
            return '\n\n' + text + '\n\n'
        return text
    if tag in {'p', 'section', 'div', 'figure', 'figcaption', 'ul', 'ol', 'main', 'details', 'summary'}:
        if tag == 'p' and ('← Back to' in text or node.attrs.get('class') == 'inherits'
                           or re.search(r'full comparison and receipts|Read the originals', text, re.I)):
            return ''
        return '\n\n' + text + '\n\n'
    return text


def document(path):
    tree = Parser(path.read_text()).root
    main = tree.find('main')[0]
    text = re.sub(r'[ \t]+\n', '\n', render(main))
    text = re.sub(r'\n[ \t]+', '\n', text)
    return plain(main.find('h1')[0]).strip(), re.sub(r'\n{3,}', '\n\n', text).strip()


PROMPT = """Create a standalone history podcast for a curious adult. Open with the essay's scene or question, explain what happened, and make the differences between the countries' accounts concrete. Refer to 'the British textbook' or 'the Chinese account', without reciting authors, book titles, publishers, editions, years of publication, or page numbers. Use short quotations only when the wording matters. Preserve distinctions between historical events, textbook claims, and the essay's interpretation. Preserve meaningful limits of coverage; a missing event is not automatically deliberate suppression. Describe relevant visuals naturally in words. Keep the connection to everyday life. Do not invent dialogue, scenes, motives, quotations, or personal memories. End with the essay's takeaway or question. Do not discuss the uploaded file, its structure, or these instructions."""


def main():
    OUT.mkdir(exist_ok=True)
    index = Parser((ROOT / 'index.html').read_text()).root
    names = list(dict.fromkeys(n.attrs.get('href', '').split('/')[-1] for n in index.find('a')
                             if n.attrs.get('href', '').startswith('chapters/')))
    names = [n for n in names if not n.startswith('part-')]
    parts = {'01': 'part-1.html', '04': 'part-2.html', '07': 'part-3.html', '09': 'part-4.html', '14': 'part-5.html'}
    rows = []
    for name in names:
        path = ROOT / 'chapters' / name
        title, essay = document(path)
        prefix = name[:2]
        text = f'# {title}\n\nBook: Same event. Different classrooms.\n\n## Audio customization prompt\n\nCopy the following paragraph into the Audio Overview customization field.\n\n{PROMPT}\n\n## Essay source\n\n{essay}\n'
        if prefix in parts:
            part = parts[prefix]
            text += '\n## Part introduction — optional opening context\n\n' + document(ROOT / 'chapters' / part)[1] + '\n'
        target = path.stem + '.md'
        (OUT / target).write_text(text)
        rows.append(f'| [{title}]({target}) | `chapters/{name}` | `{path.stem}.mp3` |')
    (OUT / 'README.md').write_text('''# Mechanical audio drafts — editorial review required

20 episode packets: 15 numbered chapters, the introduction, narrator guide, Katyn exhibit, wiring interlude, and epilogue. Part introductions are included with the first chapter of each part. These are listening sources: citation lines, bibliography appendices, image credits, are omitted; original-language quotations remain for editorial review. Quote labels use country names instead of author/edition codes. Tables become labeled entries and diagrams retain text descriptions. The original web pages retain the full sources. The customization prompt guides the hosts to tell the history without reciting book metadata.

Start with `01-opium-wars.md` as a pilot:

1. Create a notebook and upload that single Markdown packet as its source.
2. Copy its “Audio customization prompt” paragraph into Audio Overview's customization field. Choose Deep Dive and your preferred language and length.
3. Generate and listen. Check that the trade story, named textbook contrasts, and qualifications survived, and that textbook claims are not presented as established facts.
4. Download the recording. Keep the matching filename stem listed below, preserving its actual audio extension (the `.mp3` names are examples; do not merely rename another format to MP3).
5. Repeat with one packet per notebook to keep episode scope clear. The README is an index, not an audio source.

No audio has been generated or embedded yet. These filenames provide the mapping for adding players later. Full-book coverage and historical accuracy still require listening review; this export is not a fact-check.

Regenerate from the current book pages with `python3 scripts/export_audio.py` from the book directory.

| Episode / upload file | Corresponding page | Suggested audio filename |
| --- | --- | --- |
''' + '\n'.join(rows) + '\n')
    print(f'Exported {len(rows)} episode packets to {OUT}')


if __name__ == '__main__':
    main()
