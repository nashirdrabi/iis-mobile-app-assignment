"""Pair normalized Figma exports with the latest Flutter captures.

Run from the project root after rendering figma_visual_review_test.dart.
Requires Pillow. References are normalized to 390 logical pixels; exported
status bars and outer canvas shadows are excluded from the comparison.
"""
from pathlib import Path
from html import escape
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1] / "design_review"
out = root / "comparisons"
out.mkdir(exist_ok=True)
titles = {
    "kintree_home": "KinTree · Home",
    "kintree_tree": "KinTree · Family Tree",
    "kintree_chat": "KinTree · Family Chat",
    "kintree_profile": "KinTree · Profile",
    "meditation_home": "Meditation · Home",
    "meditation_albums": "Meditation · My Albums",
    "meditation_playlists": "Meditation · Playlists",
    "meditation_profile": "Meditation · Profile",
    "meditation_settings": "Meditation · Settings & Practice",
}
options = []
for name, title in titles.items():
    reference = root / "reference" / f"{name}.png"
    rendered = root / "current" / f"{name}.png"
    if not reference.exists() or not rendered.exists():
        raise FileNotFoundError(f"Missing comparison image for {title}")
    left, right = Image.open(reference).convert("RGB"), Image.open(rendered).convert("RGB")
    width = max(left.width, right.width)
    canvas = Image.new("RGB", (width * 2 + 24, max(left.height, right.height) + 30), "#e6e6e6")
    canvas.paste(left, (8, 30))
    canvas.paste(right, (width + 16, 30))
    draw = ImageDraw.Draw(canvas)
    draw.text((8, 8), "Figma reference", fill="black")
    draw.text((width + 16, 8), "Flutter rendered output", fill="black")
    canvas.save(out / f"{name}.png")
    options.append(f'<option value="{name}">{escape(title)}</option>')
html = """<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>IIS · Figma comparison</title>
<style>
*{box-sizing:border-box}body{margin:0;background:#ecebf1;color:#1a1a2a;font:15px system-ui,sans-serif}
header{position:sticky;top:0;background:#fff;padding:16px 24px;box-shadow:0 2px 12px #0001;z-index:1}
h1{font-size:20px;margin:0 0 8px}p{margin:8px 0;color:#596274}select{font:inherit;padding:9px;border:1px solid #d7d2e6;border-radius:8px;max-width:100%}
main{max-width:850px;margin:20px auto;padding:0 12px}img{display:block;width:100%;height:auto}a{color:#4f46e5}
</style><header><h1>IIS Mobile Application · Design review</h1>
<p>Figma reference on the left. Rendered Flutter UI on the right. Select any of the nine screens.</p>
<select id="screen">OPTIONS</select> <a id="full" href="comparisons/kintree_home.png">Open full size</a>
</header><main><img id="comparison" src="comparisons/kintree_home.png" alt="Figma reference beside Flutter output"></main>
<script>document.getElementById('screen').addEventListener('change',e=>{const p='comparisons/'+e.target.value+'.png';document.getElementById('comparison').src=p;document.getElementById('full').href=p;window.scrollTo(0,0)})</script></html>"""
(root / "index.html").write_text(html.replace("OPTIONS", "".join(options)))
print(f"Created {len(titles)} screen comparisons and {root / 'index.html'}")
