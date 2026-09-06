#!/bin/bash
# Build paper/paper.pdf from paper/paper.md with pandoc (pypandoc_binary) and headless Chromium.
set -e
cd "$(dirname "$0")"
python3 - <<'PY'
import pypandoc, pathlib
css = """
body{font-family:Georgia,serif;font-size:11pt;line-height:1.35;max-width:17cm;margin:1.5cm auto;color:#111}
h1{font-size:15pt;margin-top:1.4em} h1.title{font-size:20pt;margin-top:0} p.author,p.date{margin:0}
div.abstract{margin:1em 1.5em;font-size:10pt} div.abstract p.abstract-title{font-weight:bold;text-align:center}
table{border-collapse:collapse;font-size:9.5pt;margin:0.6em 0} th,td{border:1px solid #999;padding:2px 6px;text-align:left}
code{font-family:Menlo,monospace;font-size:9.5pt} pre{background:#f4f4f4;padding:6px;font-size:9pt}
blockquote{border-left:3px solid #999;margin-left:0;padding-left:10px;color:#333}
"""
pathlib.Path("_paper.css").write_text(css)
pypandoc.convert_file("paper.md", "html", outputfile="_paper.html",
    extra_args=["--standalone", "--mathml", "--css=_paper.css"])
PY
CHROME=$(ls -d /opt/pw-browsers/chromium_headless_shell-*/chrome-linux/headless_shell | tail -1)
$CHROME --no-sandbox --disable-gpu --headless --print-to-pdf=paper.pdf --no-pdf-header-footer "file://$PWD/_paper.html" 2>/dev/null
rm -f _paper.html _paper.css
ls -la paper.pdf
