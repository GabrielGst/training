# Projects Index

This directory will contain standalone capstone and real-world projects built during training.

Projects here are promoted from track capstones once they are polished enough to stand alone as portfolio pieces.

---

## Promotion criteria

A track capstone is promoted to `projects/` when:
- It has a complete, self-contained README (setup → run → test)
- It has a written case study (`CASE_STUDY.md`)
- It is deployed (live URL or reproducible demo script)
- CI passes (lint + tests green)
- It has been reviewed by at least one other person (peer review or mentor review)

---

## Project index

| Project | Source track | Status | Live URL |
|---------|-------------|--------|----------|
| ML Model Serving API | ai-engineer/06-capstone | ⏳ Pending | — |
| Full-Stack Task App | software-engineer/05-capstone | ⏳ Pending | — |
| Data Platform | data-engineer/05-capstone | ⏳ Pending | — |
| Multi-Agent Research Assistant | ai-agents/06-capstone | ⏳ Pending | — |
| Remote GPU Training CLI | gpu-monitoring/03 extension | ⏳ Pending | — |
| Hybrid Quantum VQE | hpc-quantum/02 extension | ⏳ Pending | — |

---

## Adding a project

```bash
# 1. Copy from the track
cp -r tracks/ai-engineer/06-capstone-ml-api projects/ml-model-api

# 2. Polish README and add CASE_STUDY.md
# 3. Verify CI passes
# 4. Update the index table above
# 5. Commit with:
git commit -m "track(ai-engineer): promote capstone to projects/ as ml-model-api"
```
