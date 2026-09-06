# arXiv submission source

`paper_body.tex` is generated from `../paper/paper.md` by `build.sh` (pandoc via
`pypandoc_binary`; numbered citations `[n]` become `\cite{}` keys in the order of
the bibliography in `paper.tex`). Build with

```bash
./build.sh            # or: latexmk -pdf -interaction=nonstopmode -halt-on-error paper.tex
```

Upload `paper.tex` and `paper_body.tex` together. Category: cs.LO (cross-list
cs.AI, cs.LG). The DOI-linked repositories contain the formalization, code,
frozen tables, raw runs and checkpoints.
