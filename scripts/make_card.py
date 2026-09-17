#!/usr/bin/env python3
"""Render the 1200x630 social-preview card (static/img/card.png) in the site's dark palette."""
from PIL import Image, ImageDraw, ImageFont
W, H = 1200, 630
BG, INK, SOFT, ACCENT = "#161512", "#ece8e1", "#a8a298", "#d4785c"
im = Image.new("RGB", (W, H), BG); d = ImageDraw.Draw(im)
serif = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf", 118)
sans  = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 40)
small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 26)
d.rectangle([0, 0, 14, H], fill=ACCENT)                       # brick accent bar, like the episode card
d.text((90, 150), "Still Working", font=serif, fill=INK)
d.text((94, 300), "Seven short histories.", font=sans, fill=ACCENT)
d.text((94, 356), "Each starts with something ordinary and follows it back to where it was made.", font=small, fill=SOFT)
d.line([(94, 500), (W-90, 500)], fill="#322f2a", width=2)
d.text((94, 530), "anthonykot.github.io/still-working", font=small, fill=SOFT)
im.save("static/img/card.png", optimize=True); print("card.png", im.size)
