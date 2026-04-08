# TODO / v0.1.1 plan

This file tracks the next small but meaningful improvement batch for the `weibo` skill.

## v0.1.1 goals

### 1. Pin install source more explicitly
Current install uses the GitHub repo directly.

Planned improvements:
- pin to a known tag or commit in a more visible way
- document the validated upstream version / commit in README or script comments
- reduce ambiguity around future upstream drift

### 2. Tighten install / check ergonomics
Planned improvements:
- improve log wording so failures are easier to spot
- make smoke-test outputs easier to inspect when debugging
- consider optional cleanup of temporary test artifacts

### 3. Improve README for external readers
Planned improvements:
- add a short “how this fits into OpenClaw skills” section
- add a compact quick-start block near the top
- optionally add a tiny architecture diagram or flow summary

### 4. Decide whether `references/` should exist yet
Right now the skill is small enough that `SKILL.md` does not need extra references.

Planned decision:
- either remove `references/` until genuinely needed
- or add real reference material there once longer docs appear

### 5. Add one lightweight maintenance pass
Planned improvements:
- re-check schema naming against upstream MCP server
- verify examples still match real tool signatures
- confirm fresh install still works after any README/script changes

## Non-goals for v0.1.1

These are intentionally out of scope for the next small release:

- adding write/post capabilities
- turning this into a full Weibo automation client
- adding a large framework or overengineering the repo
- stuffing README or SKILL.md with long debug transcripts

## Release standard for v0.1.1

Before cutting `v0.1.1`, verify:

1. clean install works
2. `bash scripts/check.sh` passes
3. `mcporter list weibo --schema` works
4. smoke test succeeds
5. README and SKILL.md still reflect actual behavior
