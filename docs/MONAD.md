# The monad question: what the data support, what they refute

The programme's rule: observation → equivalence → quotient → operations
and equations → algebraic theory → monad. This note records where each
recognizer studied stands on that path, with the Lean names that fix the
objects.

## 1. The monad behind logical identity

`Cl Γ` = the clauses derivable from Γ (`RecognitionPaths/Closure.lean`).
On the poset of theories it is extensive, monotone and idempotent
(`cl_extensive`, `cl_mono`, `cl_idem`): a monad on a poset is exactly a
closure operator. Its algebras are the closed theories, and logical
identity of traces is equality of closures (`logicalEquiv_iff_cl_eq`).
So the logical meaning space L of the framework paper is the set of
algebras of this monad. Which recognizers realise it, at the decision
level, on the tables? The ideal recognizer by definition; the constructed
reasoners at sufficient budget (k ≥ 4 on the RQ2 tables); and Gemini 3.1
Flash-Lite with a thinking budget of about 300 tokens, on two independent
tables of 200 cases, without exception. No open-weight model to 1.5B and
no zero-budget recognizer does.

## 2. The graded monad behind budgets

`rounds Γ k S` = T_k S (`Graded.lean`): T_0 = id, T_j ∘ T_k = T_{j+k},
extensive, nested, monotone; the limit is `Cl` restricted to single-atom
clauses (`mem_cl_iff_exists_rounds`). An ℕ-graded monad on the poset of
atom sets; only the limit is idempotent. Its kernel at grade k is
budget-k identity, and `gradedEquiv_append_iff` says exactly which
redundant extensions it separates. The learned 4-round reasoner's
identification behaviour coincides with this object on every budget
(RQ2, P1).

## 3. What training keeps of the graded monad: a lax graded reader

`LaxGraded Γ s`: monotone operators R_k with T_{k−s} ⊆ R_k ⊆ T_k. Slack 0
forces R = T (`eq_rounds_of_slack_zero`); R_0 = id for any slack
(`zero_eq_id`); composition inherits the sandwich with slack added
(`comp_sandwich`). Empirically, for the 4-round learned reader on fresh
cases:

| law | status | evidence |
|---|---|---|
| upper bound R_k ⊆ T_k | holds | RQ2b/c, RQ2g: 1.000 on every pair |
| lower bound T_{k−1} ⊆ R_k (slack 1) | holds, preregistered | RQ2c P4: 1.000 on every pair |
| exact multiplication R_j ∘ R_k = T_{j+k} (slack 0) | **fails** | RQ2b P3: 0.897, 0.830 at tight pairs (symbolic hints); RQ2g exact 0.818–1.000 (own outputs) |
| lax multiplication with slack 2 | holds, preregistered | RQ2g P9: 1.000 on all nine pairs |
| lax multiplication with slack 1 | holds on 8/9 pairs | RQ2g: 0.890 at (1,3), 1.000 elsewhere |
| monotonicity | holds, preregistered | RQ2g P10: 0.000 violations |
| unit R_0 = id | **fails** | RQ2g: 0.571 agreement (a constant answer) |

So the operations and equations observed on this recognizer are those of
an ℕ-graded family of monotone operators sitting inside the graded
closure monad, with a lax multiplication of slack ≤ 2 (usually 1) and no
unit. That is the algebraic object the data support for a trained
budgeted reasoner: a *lax graded monad without unit*, i.e. a lax graded
semigroup of operators bounded by the true monad. The 2-round model is
within 0.01 of the monad's multiplication and equally unitless.

## 4. The language models

At zero budget, Gemini 3.1 Flash-Lite is not described by any of the
above. Its decision changes have a sign structure (shortening +0.155,
depth-preserving redundant −0.070, two and three redundant −0.21, −0.28,
irrelevant underivable −0.22) that is not a quotient of the free monoid
of traces by a congruence, because concatenating with a derivable clause
and with an underivable one have different effects on the *same*
consequence set. It is closer to a valuation on theories with marginal
costs that depend on a clause's logical relation to the theory. No
monad is claimed for it; what is claimed is the sign and size of the
terms, twice preregistered. The open-weight models at 0.5–1.5B are
described by lexical overlap and by nothing algebraic here.

## 5. What would count as "finding the monad" for a language model

By the programme's own rule, a monad for a recognizer ρ is the monad
T_ρ = U_ρ F_ρ of the algebraic theory presented by the operations and
equations of B_ρ = Σ*/≈_ρ. For that, ≈_ρ must be a congruence observed
to be closed under a finite test family (`Identification.lean`) and the
equations must hold on fresh cases. For the budgeted reasoners this was
done, and the answer is §3. For the language models the first step,
closure of a finite family, has not been reached on any table (no family
tried is closed; the audit repository records the witnesses). Until it
is, "the monad of the language model" is not an object the data can
name, and this note does not name one.
