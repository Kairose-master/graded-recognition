# graded-recognition

**Budgets as grades: which equal-meaning inputs a budgeted reasoner distinguishes.**

A recognizer that reads a Horn theory with a fixed computation budget
`k` (rounds of forward chaining) does not identify logically identical
inputs; this repository asks *which* of them it separates, and answers
with a graded monad. The closure operator of Horn logic factors into
stages `T_k` with `T_0 = id`, `T_j ∘ T_k = T_{j+k}`, and limit the
closure; budget-`k` behavioural identity is the kernel of `T_k`, and a
trace is separated from a redundant extension at budget `k` exactly when
the extension moves some derivation across the budget. The prediction
was preregistered and held on 200 fresh cases for a learned iterative
reasoner (interaction 0.885, 95 % CI [0.84, 0.93]); the composition law
was then tested as a second, independent prediction and **failed** for
the same model at tight budgets while holding for a model trained under
a smaller budget; the one-round sandwich law that the failure suggested
was preregistered and held on a third set of 200 fresh cases without
exception. Open-weight LLMs at 0.5–1.5B do not read the table at the
decision level; a language model with a thinking budget is the oracle
once it thinks and, without thinking, is helped by a shortening clause
(+0.155) and hurt by a depth-preserving redundant clause (−0.070), both
effects preregistered on a fresh seed and both removed by the budget.

This is the paper repository. Code, tables and models live where they
were made and are cited by commit and hash:

| artifact | where | version |
|---|---|---|
| Theory (Lean 4, core only): `RecognitionPaths/Graded.lean` | [recognition-paths](https://github.com/Kairose-master/recognition-paths) | `a21e675`; concept DOI 10.5281/zenodo.22495808 |
| Tables, runners, analysis: `rq2/` | [proof-path-invariance](https://github.com/Kairose-master/proof-path-invariance) | `aa9b90c`; concept DOI 10.5281/zenodo.22495706 |
| RQ2 table | `rq2/table/rq2_prompts.jsonl` | sha256 `39a82a17f9aae4027586339c58942a0114439bf0f978cf12724e754479676510` |
| RQ2b table | `rq2/table/rq2b_presat.jsonl` | sha256 `5e42376dd5e01a7f4f6b04856a74a4596f8378ea6579786acce489928456a910` |
| Models: `rq2/iter_r4`, `rq2/iter_r2`, `rq2/set7` | [jinu0633/recognition-paths-recognizers](https://huggingface.co/jinu0633/recognition-paths-recognizers) | folder `rq2/` |

## Contents

- `paper/paper.md` — the manuscript source (Markdown); `paper/build.sh` renders an HTML-based PDF.
- `arxiv/` — the arXiv submission: `paper.tex` (preamble and bibliography), `paper_body.tex` (generated from the Markdown), `paper.pdf`, `build.sh`.
- `docs/PREREGISTRATION_RQ2.md`, `docs/RESULTS_RQ2.md` — the depth-vs-budget prediction (held).
- `docs/PREREGISTRATION_RQ2B.md`, `docs/RESULTS_RQ2B.md` — the composition law (failed for the primary model).
- `docs/PREREGISTRATION_RQ2C.md`, `docs/RESULTS_RQ2C.md` — the one-round sandwich law on a fresh seed (held on every case).
- `docs/PREREGISTRATION_RQ2D.md`, `docs/RESULTS_RQ2D.md` — a language model with a thinking budget (unsigned test failed; oracle with thinking).
- `docs/PREREGISTRATION_RQ2E.md`, `docs/RESULTS_RQ2E.md` — the signed effects on a fresh seed (held: shortening helps, redundancy hurts, thinking removes both).
- `REPRODUCE.md` — the exact commands.

The preregistrations here are verbatim copies of the files committed in
`proof-path-invariance` before the corresponding runs; the commit history
there is the timestamp.

## Relation to the other repositories

The framework paper (recognition paths, the Recognition Factorization
Theorem, and the Hankel-table instrument) is `proof-path-invariance/docs/DRAFT.md`.
The domain-independent audit tool is [recognition-audit](https://github.com/Kairose-master/recognition-audit).
This repository depends on both and adds one object (the graded closure),
two preregistered predictions, and their outcomes.

## License

MIT (code and text of this repository). Cited artifacts carry their own licenses (MIT).
