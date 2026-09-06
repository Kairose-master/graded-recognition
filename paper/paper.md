---
title: "Budgets as grades: which equal-meaning inputs a budgeted reasoner distinguishes"
author: "Jinu Jang"
date: "September 2026 (draft v0.1)"
abstract: |
  A recognizer that answers Horn entailment queries with a fixed computation budget does not treat logically identical inputs alike. We ask which of them it separates, and answer with a graded object. The closure operator of propositional Horn logic factors into stages $T_k$, the atoms derivable in $k$ parallel rounds, with $T_0=\mathrm{id}$, $T_j\circ T_k=T_{j+k}$, and limit the closure; we prove in Lean 4 (core only) that the limit is sound and complete, that budget-$k$ behavioural identity is blind to order and repetition at every grade, and that a trace is separated from a redundant extension at budget $k$ exactly when the extension moves some derivation across the budget. This yields a preregistered prediction: a derivable clause that shortens the target derivation changes a budgeted recognizer's decision at a low budget and not at a high one, while an equally redundant clause that preserves depth changes nothing. On 200 fresh cases the prediction held for a learned iterative reasoner (interaction $0.885$, 95\% CI $[0.84, 0.93]$), whose decisions coincided with the $k$-round symbolic reasoner at every budget. A second prediction, the composition law read on inputs ("a hint buys exactly its depth"), was then tested on the same weights and failed at tight budgets (agreement $0.90$ and $0.83$ against a $0.95$ criterion) while holding for a model trained under a smaller budget. Two language models (0.5B, 1.5B) did not read the table at the decision level; at the margin level their sensitivity to redundant clauses was dominated by lexical overlap with the query, with a small residual in the depth direction. The graded structure therefore describes what a budgeted reasoner distinguishes; whether it also obeys the structure's composition law is a property of training, not architecture, and was decided by testing the law rather than assuming it.
---

# 1. Question

Two inputs with the same meaning are, to a recognizer, two inputs. The
recognition-paths framework [1] makes this precise for Horn logic: a
recognizer $\rho$ induces a behavioural identity $\approx_\rho$ on premise
traces, logical identity $\equiv_L$ is theory equivalence, and $\rho$ factors
through $\equiv_L$ if and only if it identifies every pair of logically
identical traces (the Recognition Factorization Theorem). The empirical
part of that programme found that no recognizer examined, language models
to 1.5B and small constructed models alike, identifies logically identical
traces; in particular a trace and its extension by a *derivable* clause,
which changes no consequence, are distinguished by every one of them
[2].

That is a negative result about identification. This paper asks the
positive question it leaves open: *which* logically identical inputs does a
recognizer separate, and is there a mathematical object that predicts the
answer? The object we propose is the graded closure: forward chaining
stopped after $k$ rounds. Its grades are computation budgets, and it makes
two predictions that can be preregistered and tested, one about
identification and one about composition. The first held. The second
failed for the model it was primarily tested on. Both outcomes are the
content of the paper.

# 2. The graded closure

Fix a set of atoms and a Horn theory $\Gamma$ (a set of clauses
$a_1\wedge\dots\wedge a_m\to b_1\wedge\dots\wedge b_n$). For a set of atoms
$S$ let $\mathrm{step}_\Gamma(S)$ be $S$ together with the heads of all
clauses whose bodies lie in $S$, and let
$$T_0 S = S,\qquad T_{k+1}S=\mathrm{step}_\Gamma(T_kS).$$
The following are proved in `RecognitionPaths/Graded.lean` (Lean 4, no
Mathlib; names in parentheses):

1. $T_j(T_kS)=T_{j+k}S$ (`rounds_add`): the grades add.
2. $S\subseteq T_kS\subseteq T_{k+d}S$ (`rounds_extensive`,
   `rounds_le_add`); $T_k$ is monotone in $S$ and in $\Gamma$
   (`rounds_mono`, `rounds_mono_theory`).
3. Soundness: every atom in $T_kS$ holds in every model of $\Gamma$
   containing $S$ (`rounds_sound`). Completeness: $T_\infty S=\bigcup_kT_kS$
   is a model of $\Gamma$ (`limit_models`), hence semantic entailment is
   entailment at some finite grade (`entails_iff_exists_rounds`).

So $(T_k)_{k\in\mathbb N}$ is an $\mathbb N$-graded monad on the poset of
atom sets whose $\infty$-stage is the (idempotent) closure monad. Only the
limit is idempotent: $T_k\circ T_k=T_{2k}\neq T_k$.

**Graded entailment and identity.** Write $\Gamma\vdash_k(H\Rightarrow g)$
for $g\in T_kH$. Budget-$k$ identity of two traces $u,w$ is
$$u\approx_k w\iff \forall q,\ \Gamma(u)\vdash_k q\leftrightarrow\Gamma(w)\vdash_k q$$
(`GradedEquiv`). It is an equivalence relation, blind to permutation and
repetition at every grade (`gradedEquiv_of_perm`, `gradedEquiv_dup`), and
identity at every grade implies $\equiv_L$ (`logicalEquiv_of_gradedEquiv`).
The converse fails at any fixed grade, and the failure is characterised
exactly:

> **Theorem (`gradedEquiv_append_iff`).** For a trace $w$ and a clause $c$,
> $w\approx_k w{+}[c]$ if and only if every query answered within $k$
> rounds from $w{+}[c]$ is answered within $k$ rounds from $w$.
> Equivalently (`not_gradedEquiv_append_iff`), $w$ and $w{+}[c]$ are
> separated at budget $k$ iff some query's derivation is moved by $c$ from
> depth $>k$ to depth $\le k$.

For a derivable $c$ the separation is transient: for every query there is
a grade beyond which $w$ and $w{+}[c]$ agree
(`gradedEquiv_append_derivable_eventually`).

**The budgeted recognizer.** $\rho_k(w,q)=[\Gamma(w)\vdash_kq]$ is a
theory-factoring recognizer; its behavioural identity is $\approx_k$ in
every context (`roundsRecognizer_contextEquiv_iff`). The composition law
read on inputs (`entailsK_presaturate`) says
$$\rho_k(w,\ T_j\{a\}\Rightarrow g)=\rho_{j+k}(w,\ \{a\}\Rightarrow g):$$
pre-saturating the hypothesis by $j$ rounds and reading with budget $k$ is
reading with budget $j+k$. A hint buys exactly its depth.

The mathematics here is elementary. Its role is to name the object whose
equations become predictions; the paper's claims are about which
recognizers satisfy them.

# 3. Two predictions

**P1 (identification; RQ2).** Take a base theory $D$ with a target query of
depth $d\ge3$ from a single hypothesis atom. Let $F$ add a derivable clause
that shortens the target's depth by the least possible amount, and $C$ add
a derivable clause that preserves it; $D\equiv_LF\equiv_LC$. For a
recognizer with budget $k$ let $\mathrm{dis}_X(k)$ be the fraction of
cases whose target decision differs between $D$ and $X$, and
$\Delta(k)=\mathrm{dis}_F(k)-\mathrm{dis}_C(k)$. The theorem predicts
$\Delta(k)>0$ for $k$ below the base depth and $\Delta(k)=0$ above it.
The preregistered test is the interaction $I=\Delta(2)-\Delta(4)$ for a
learned reasoner trained at four rounds: P1 holds iff $I>0$ with a paired
case-bootstrap 95\% CI excluding 0 and $\Delta(2)\ge0.10$.

**P3 (composition; RQ2b).** For the same weights, with hypothesis sets
$H_j=T_j\{a\}$, the agreement rate between $\rho(H_j;k)$ and
$\rho(H_0;j{+}k)$ must have CI lower bound $\ge0.95$ on the four pairs
$(j,k)\in\{(1,2),(2,1),(2,2),(1,3)\}$ where the symbolic yes-rate changes
between budgets $k$ and $j+k$ (so that a constant answer cannot pass).

Both were committed with their exclusion rules, tie handling, sample-size
rationale, controls and failure sentences before any learned recognizer
was run (`docs/PREREGISTRATION_RQ2.md`, `docs/PREREGISTRATION_RQ2B.md`).

# 4. Instruments

**Table.** 7 atoms; 200 base theories of 5 random clauses with a target of
depth $\ge3$ from atom $a$ (depth 3: 177, depth 4: 23), generated from one
seed and taken in order after fixed exclusions; conditions $D$, $F$
(minimal shortening; never the direct clause), $F_1$ (the direct clause
$a\to\mathrm{goal}$, maximal shortening and maximal lexical overlap with
the query), $C$ (depth-preserving, overlap with $\{a,\mathrm{goal}\}$
matched to $F$ in 181/200 cases), and $L$ (one clause deleted so the
target becomes underivable: the logic-change control). Four queries per
case: the target $t$, a depth-1 atom $d_1$, a non-derivable atom $n$, and
the reversed query $r$. Logical identity of $D,F,F_1,C$ is certified by
closure equality on every single-atom hypothesis. The RQ2b table takes
the 200 $D$ theories with hypothesis sets $H_0,H_1,H_2$ for $t$ and $n$.

**Recognizers.** (i) The exact closure oracle and the $k$-round symbolic
reasoner, $k\in\{1,2,3,4,6\}$ (control validation: the theorem holds for
them by construction). (ii) A constant-NO recognizer and Pythia-70M
(non-reading controls). (iii) The iterative learned reasoner: atom states
updated along clauses by a message MLP and a GRU cell, max-aggregated per
head atom (so permutation- and repetition-invariant), read out from the
goal and hypothesis states; the number of rounds is the budget. 75k
parameters, trained 6000 steps on random 2–6-clause theories over 7 atoms
with the 1000 evaluation theories excluded up to atom relabelling, at 4
rounds (primary) and at 2 rounds (secondary). (iv) A 7-atom set
recognizer (max-pooled clause encoder; no budget knob). (v)
Qwen2.5-0.5B-Instruct and 1.5B-Instruct, raw prompt, one forward pass,
decision by the YES/NO logit comparison, on CPU.

Decisions are Boolean with ties to NO; the extended observation is the
real margin. All materials are frozen with SHA-256 locks and cited by
commit (see `REPRODUCE.md`).

# 5. Results

## 5.1 P1 holds, and the learned reasoner is the symbolic one

| budget $k$ | acc($D$, target) | $\mathrm{dis}_F$ | $\mathrm{dis}_{F_1}$ | $\mathrm{dis}_C$ | $\mathrm{dis}_L$ | $\Delta$ [95\% CI] |
|---:|---:|---:|---:|---:|---:|---|
| 1 | 0.00 | 0.01 | 1.00 | 0.00 | 0.00 | 0.01 [0.00, 0.01] |
| **2** | 0.00 | **0.89** | 1.00 | **0.00** | 0.00 | **0.89 [0.84, 0.93]** |
| 3 | 0.89 | 0.11 | 0.11 | 0.01 | 0.89 | 0.10 [0.06, 0.15] |
| **4** | 1.00 | **0.00** | 0.00 | **0.00** | 1.00 | **0.00 [0.00, 0.00]** |
| 6 | 1.00 | 0.00 | 0.00 | 0.00 | 1.00 | 0.00 [0.00, 0.00] |

Table 1: the 4-round learned reasoner on 200 cases.
$I=\Delta(2)-\Delta(4)=0.885$, 95\% CI $[0.84,0.93]$; P1 holds.

The learned reasoner's decision table coincides with the $k$-round
symbolic reasoner's at every budget: at $k=2$ the 177 depth-3 bases are
NO and their $F$ extensions (depth 2) YES, the 23 depth-4 bases NO on
both; at $k=4$ everything is YES and only $L$ is separated. Every
$D$–$F$ disagreement is $F$ correct and $D$ wrong. The direct clause $F_1$
separates at $k=1$ (it is read as a depth-1 derivation) and not at $k=4$,
so lexical overlap plays no role for this recognizer. The controls behave
as required: the oracle and the constant recognizer give $\Delta=0$,
Pythia-70M gives $\Delta=-0.02$ $[-0.04,0.01]$ with $\mathrm{dis}_L=0.04$
(it does not read).

A caveat stated in advance: in this architecture information flows one
hop per round, so a *correct* model must show this pattern. The empirical
content is that training produced this reader and not a shortcut
(in-distribution accuracy 0.996; no clause-count or lexical heuristic
survives at $k=2$), that the gap closes exactly at $k=4$, and that the
pattern is what the theorem says and nothing more.

**The 2-round model** (trained with a budget too small for its data,
validation accuracy 0.960) shows the same pattern, $I=0.665$
$[0.60,0.74]$, and closes the gap at $k=4$ although it never ran four
rounds in training. It differs in one informative way: at its own budget
it says YES on 16\% of the depth-3 bases it cannot derive and its decision
moves on 10\% of the depth-preserving extensions $C$. A model trained
under an insufficient budget acquires a shortcut component that a merely
redundant clause can trigger; depth accounts for 0.67 of its 0.77 $F$
effect.

**The set recognizer** (no budget) identifies almost every extension at
the decision level ($\mathrm{dis}_F=0.01$, $\mathrm{dis}_C=0.00$) and reads
the logic change ($\mathrm{dis}_L=0.94$). Its margins order the
conditions $F_1>F>C>0>L$ (mean shifts $+1.91$, $+0.65$, $+0.23$, $-9.3$
logits): a recognizer without rounds still orders redundant extensions by
depth shortening in its extended observation.

## 5.2 P3 fails for the primary model

| pair | symbolic | 4-round model (primary) | 2-round model |
|---|---:|---|---|
| $j{=}1,k{=}2$ | 1.000 | **0.897 [0.870, 0.925]** | 0.990 [0.980, 0.998] |
| $j{=}2,k{=}1$ | 1.000 | **0.830 [0.797, 0.863]** | 0.975 [0.960, 0.990] |
| $j{=}2,k{=}2$ | 1.000 | 0.995 [0.988, 1.000] | 0.998 [0.993, 1.000] |
| $j{=}1,k{=}3$ | 1.000 | 0.983 [0.970, 0.995] | 1.000 [1.000, 1.000] |

Table 2: agreement between $\rho(H_j;k)$ and $\rho(H_0;j{+}k)$ on 200
cases $\times$ 2 queries.

Two of the four primary pairs fall below the criterion; P3 fails. As
preregistered: *on 200 fresh Horn cases the learned reasoner did not
satisfy the composition law $T_k\circ T_j=T_{j+k}$ out of its training
format; the graded-monad description fits its budget behaviour but not
its hypothesis-set behaviour, and the law is a property of the symbolic
reasoner that the learned one does not inherit.*

The failure has one direction: in all 41 and 68 disagreements the model
answers NO from the pre-saturated hypotheses at the tight budget where
the law says YES. It reads multi-atom hypothesis sets correctly given
slack (accuracy 1.000 at $k=4$ with $H_1$ and $H_2$), agreement falls with
the size of the hint (at $j=2,k=1$: $|H_2|=3$: 0.73, 4: 0.63, 5: 0.55) and
is near-perfect on depth-4 cases (0.957), where a spare round exists. The
learned operator satisfies $T_k\circ T_j\subseteq T_{j+k}$ with strict
inclusion on 20–35\% of cases at the tight budgets: it loses part of a
round when the derivation starts from a set rather than an atom. The
2-round model, which had to propagate from whatever it was given within
two rounds, passes all four pairs; this was not preregistered for it and
is reported as an observation.

## 5.3 Language models: no decision-level reading; margins follow overlap

On this rendering (7 atoms, 5–6 clauses) Qwen2.5-0.5B answers YES on every
query of every condition and Qwen2.5-1.5B answers NO on every query, so
the decision-level test cannot be evaluated for either (the audit
protocol's Gate R). Their margins carry partial reading (comparative
accuracy $[m_t>m_n]$: 0.79 and 0.89). The mean margin shift on the target
relative to $D$, with paired-bootstrap CIs, is:

| recognizer | $F-C$ | $F_1-F$ | $L$ |
|---|---|---|---|
| Pythia-70M (non-reader) | 0.010 [0.005, 0.014] | 0.004 [−0.001, 0.009] | −0.080 |
| Qwen2.5-0.5B | 0.033 [0.026, 0.040] | 0.098 [0.091, 0.104] | −0.406 |
| Qwen2.5-1.5B | 0.048 [0.030, 0.067] | 0.285 [0.268, 0.302] | −0.207 |
| set recognizer | 0.417 [0.289, 0.540] | 1.264 [1.124, 1.407] | −9.32 |

Table 3: signed margin shifts (logits), 200 cases; exploratory.

The shortening clause moves the LLM margins more than the depth-preserving
clause, with CIs excluding 0, but by 0.03–0.05 logits: three to five times
the non-reader's surface residual (which exists because $F$ mentions the
hypothesis atom in 198/200 cases and $C$ in 131/200; on the 181
overlap-matched cases $F-C$ is 0.025 and 0.029) and an order of magnitude
below the direct clause's effect. For these language models, what makes
a redundant clause distinguishable is overwhelmingly its lexical overlap
with the query; the depth direction is a small residual.

# 6. What was learned

1. **The graded closure predicts identification.** For a budgeted
   reasoner, a redundant extension is distinguishable exactly when it
   moves a derivation across the budget; this held on fresh cases with
   the full predicted shape (large at $k=2$, zero at $k=4$, zero for
   depth-preserving clauses at every $k$).
2. **The same object's composition law is not inherited by training.**
   The 4-round model is exactly graded in what it separates but not
   exactly graded in how it composes hints with budget; a model trained
   under a tighter budget is. Architecture makes the law available;
   training decides whether it holds. This is the first equation of the
   candidate monad to be *refuted* for a constructed recognizer, and it
   was refuted by a preregistered test of the law.
3. **For the language models examined, depth is not the variable.** The
   quantity that predicts their (margin-level) sensitivity to redundant
   clauses is lexical overlap with the query. Whether a language model
   with a genuine budget knob (chain-of-thought length) obeys the
   composition law is the natural next test and is not attempted here.

# 7. Limits and non-claims

Two language models, both under 2B parameters, one rendering, single
forward pass; the decision-level LLM tests are not evaluable at this
scale and are reported as such, not as refutations. The constructed
models are small and the iterative reasoner's architecture makes P1's
pattern available to a correct model; the paper's claim is that training
produced that model and that the graded description has an equation the
model fails, not that the model "has" a monad. Nothing is claimed about
the algebraic structure of language models. The Lean development is
elementary; it fixes definitions and rules out ambiguity in what was
tested, and is not offered as new mathematics.

# References

- [1] J. Jang, *Recognition paths: logical and behavioural identity for
  Horn traces* (Lean 4). Zenodo, doi:10.5281/zenodo.22495808.
- [2] J. Jang, *Proof-path invariance: Hankel tables for recognizer
  identity* (data, code, results). Zenodo, doi:10.5281/zenodo.22495706;
  draft `docs/DRAFT.md`.
- Models: `jinu0633/recognition-paths-recognizers`, folder `rq2/`
  (Hugging Face).
- Related work on premise-order sensitivity, set-invariant encoders and
  graded monads is discussed in `proof-path-invariance/docs/RELATED_WORK.md`
  and `docs/NOVELTY.md`; the graded-monad notion follows Smirnov (2008)
  and Fujii, Katsumata and Melliès (2016).
