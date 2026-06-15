# Doc Chores

Perform a documentation maintenance pass on the training repository: check consistency, find broken links, verify skill coverage, and sync progress.json with track READMEs.

## Steps

### 1. Consistency checks

```bash
# Missing module READMEs
for track in /home/ubuntu/Documents/Git/training/tracks/*/; do
  for mod in "$track"*/; do
    [ -d "$mod" ] && [ ! -f "${mod}README.md" ] && echo "MISSING README: $mod"
  done
done

# Modules in progress.json vs track directories
python3 -c "
import json, os
base = '/home/ubuntu/Documents/Git/training'
with open(f'{base}/dashboard/data/progress.json') as f:
    d = json.load(f)
for track in d['tracks']:
    if track['id'] in ['fde-ai', 'fde-quantum']:
        continue
    track_dir = f'{base}/tracks/{track[\"id\"]}'
    for mod in track['modules']:
        mod_dir = f'{track_dir}/{mod[\"id\"]}'
        if not os.path.isdir(mod_dir):
            print(f'DIR MISSING: {track[\"id\"]}/{mod[\"id\"]}')
"
```

### 2. Skill ID consistency

Verify that skill IDs (SK01–SK31 for AI, QSK01–QSK74 for quantum) referenced in `modules.md` and `bridge.md` are consistent with those defined in `skill-matrix.md`.

```bash
# Extract all SK/QSK references from modules.md
grep -oE 'SK[0-9]+|QSK[0-9]+' /home/ubuntu/Documents/Git/training/doc/roadmap/modules.md | sort -u

# Compare against skill-matrix.md
grep -oE 'SK[0-9]+|QSK[0-9]+' /home/ubuntu/Documents/Git/training/doc/research/skill-matrix.md | sort -u
```

Report any IDs in modules.md that are not in skill-matrix.md.

### 3. Project cross-reference

Verify every project referenced in bridge.md exists in the projects catalog:

```bash
grep -oE 'P[0-9]+|QP[0-9]+' /home/ubuntu/Documents/Git/training/doc/roadmap/bridge.md | sort -u
grep -oE '^## (P|QP)[0-9]+' /home/ubuntu/Documents/Git/training/doc/roadmap/projects/ai-projects.md
grep -oE '^## QP[0-9]+' /home/ubuntu/Documents/Git/training/doc/roadmap/projects/quantum-projects.md
```

### 4. Fix issues found

For each issue:
- **Missing module README:** Create a stub: `# Module: {name}\n\n**Status:** ⏳\n\n## Objective\n\nTODO\n\n## Deliverable\n\nTODO`
- **Broken skill ID reference:** Note in modules.md with `<!-- TODO: verify ID -->`
- **Missing project reference:** Alert and do not auto-fix — project definitions are source of truth

### 5. Summary report

Output at the end:
```
Doc Chores — {date}
Files reviewed: N
Missing module READMEs: N (created: N stubs)
Dir/progress.json mismatches: N (fixed: N)
Broken skill ID refs: N
Files modified: [list]
```

## Do NOT change
- CSV files under `doc/roadmap/resources/`
- Skill IDs or module IDs (stable DB keys)
- Roadmap hour estimates (tracked separately)
