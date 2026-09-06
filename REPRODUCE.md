# Reproduce

All runs are CPU-only (float32), no GPU.

```bash
# theory
git clone https://github.com/Kairose-master/recognition-paths && cd recognition-paths && git checkout a21e675
lake build                                   # Lean 4 v4.24.0, no Mathlib

# tables, controls, models, analysis
git clone https://github.com/Kairose-master/proof-path-invariance && cd proof-path-invariance && git checkout aa9b90c
python3 rq2/build_table.py                    # rq2/table/rq2_prompts.jsonl (check rq2/table/LOCK)
python3 rq2/run_constructed.py --out-dir experiments/rq2/results --symbolic
python3 rq2/train_rq2.py --kind iter --rounds 4 --out experiments/rq2/iter_r4.pt     # ~1 h, 1 thread
python3 rq2/train_rq2.py --kind iter --rounds 2 --out experiments/rq2/iter_r2.pt
python3 rq2/train_rq2.py --kind set --out experiments/rq2/set7.pt
python3 rq2/run_constructed.py --out-dir experiments/rq2/results --model experiments/rq2/iter_r4.pt --rounds 1 2 3 4 6
python3 rq2/run_constructed.py --out-dir experiments/rq2/results --model experiments/rq2/iter_r2.pt --rounds 1 2 3 4 6
python3 rq2/run_constructed.py --out-dir experiments/rq2/results --model experiments/rq2/set7.pt
for m in "EleutherAI/pythia-70m step143000 pythia70m" "Qwen/Qwen2.5-0.5B-Instruct main qwen05b" "Qwen/Qwen2.5-1.5B-Instruct main qwen15b"; do
  set -- $m; python3 scripts/run_hf_hankel.py --prompts rq2/table/rq2_prompts.jsonl --out experiments/rq2/results/$3.jsonl --run-id $3 --model-id $1 --revision $2 --expected-rows 4000
done
python3 rq2/analyze.py --results experiments/rq2/results --primary iter_r4_k2 iter_r4_k4 --primary iter_r2_k2 iter_r2_k4 --primary qwen05b qwen15b --out experiments/rq2/analysis.json

# composition law
python3 rq2/build_presat.py                   # rq2/table/rq2b_presat.jsonl (check rq2/table/LOCK_rq2b)
python3 rq2/run_presat.py --symbolic --out experiments/rq2/results_b/symbolic.json
python3 rq2/run_presat.py --model experiments/rq2/iter_r4.pt --out experiments/rq2/results_b/iter_r4.json
python3 rq2/run_presat.py --model experiments/rq2/iter_r2.pt --out experiments/rq2/results_b/iter_r2.json
```

Trained weights are also on Hugging Face
(`jinu0633/recognition-paths-recognizers`, folder `rq2/`) with the exact
training logs; the evaluation scripts accept them after conversion from
safetensors (see each model card).
