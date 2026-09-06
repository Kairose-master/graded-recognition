#!/bin/bash
# paper/paper.md -> arxiv/paper_body.tex (pandoc) -> arxiv/paper.pdf (latexmk)
set -e
cd "$(dirname "$0")"
python3 - <<'PY'
import re, pypandoc, pathlib
src = pathlib.Path("../paper/paper.md").read_text()
m = re.match(r"---\n(.*?)\n---\n(.*)", src, re.S)
meta, body = m.group(1), m.group(2)
abstract = re.search(r"abstract: \|\n((?:  .*\n?)+)", meta).group(1)
abstract = "\n".join(l[2:] for l in abstract.splitlines())
keys = ["rp2026","ppi2026","smirnov2008","fujii2016","chen2024premise","zhou2026lgmt","gu2026crtbench",
        "essebbani2026robustness","egressy2025setllm","he2025order","saparov2023prontoqa","merrill2024cot",
        "barcelo2020gnn","katsumata2014parametric","dowling1984horn","nerode1958","angluin1987learning"]
def cite(mo):
    nums = [int(x) for x in mo.group(1).split(",")]
    return "\\cite{" + ",".join(keys[n-1] for n in nums) + "}"
body = re.sub(r"\[(\d+(?:,\d+)*)\]", cite, body)
opts = ["--wrap=none", "--columns=400"]
abs_tex = pypandoc.convert_text(abstract, "latex", format="md", extra_args=opts)
body_tex = pypandoc.convert_text(body, "latex", format="md", extra_args=opts)
pathlib.Path("paper_body.tex").write_text("\\begin{abstract}\n" + abs_tex + "\\end{abstract}\n\n" + body_tex)
PY
latexmk -g -pdf -interaction=nonstopmode -halt-on-error paper.tex > build.log 2>&1 || { grep -n "^!" -A3 build.log | head -40; exit 1; }
latexmk -c > /dev/null 2>&1
ls -la paper.pdf
