---
name: claude-code-project-setup
description: How prasish07 sets up Claude Code projects — CLAUDE.md structure, hooks, agents, wisdom/ folder, phase-based development
metadata:
  type: user
---

## Setup Order
1. Create CLAUDE.md with commands, stack, architecture, critical rules, phase workflow, session start imports
2. `.claude/settings.json` — permissions allowlist, prettier PostToolUse hook, auto-commit Stop hook
3. `.claude/hooks/auto-commit-push.sh` — commits all changes + pushes on every session end
4. `.claude/rules/` — path-scoped rules (engine.md for src/engine/**, testing.md for *.test.ts)
5. `.claude/agents/phase-reviewer.md` — code quality agent, spawned after every phase
6. `examples/` — code pattern files excluded from TS build
7. `wisdom/` — progress.md, project-map.md, mistakes.md, good-practices.md, domain-best-practices.md

## CLAUDE.md Must-Haves
- Commands section (start, test, typecheck, lint)
- Architecture section (which folder does what)
- Critical Rules (invariants that must never be violated)
- Phase Completion Workflow (commit → reviewer agent → fix fails → update progress.md)
- Session Start section: `@wisdom/progress.md` and other wisdom files (loads them every session)

## Hooks
- **PostToolUse (Edit|Write):** auto-format .ts/.tsx with prettier
- **Stop:** run auto-commit-push.sh (commits all changes, pushes to GitHub)

## Phase-Reviewer Agent
- Tools: Bash, Read, Edit, Write
- Runs: tsc, jest, per-file checklists, anti-pattern scan, wisdom updates, progress.md update
- Verdict: PASS / PASS WITH WARNINGS / FAIL
- Mandatory after every phase from Phase 2 onwards — never skip

## Phase-Based Development (for complex apps)
| Phase | What | Review |
|---|---|---|
| 0 | Claude Code setup | Skip |
| 1 | Framework bootstrap | Skip |
| 2 | Business logic / engine | Full review |
| 3 | State management | Full review |
| 4 | UI / screens | Full review |
| 5 | Polish | Full review |

## wisdom/ Folder Purpose
- `progress.md` — READ FIRST each session (phase status, decisions, gotchas)
- `project-map.md` — every file, what it does, when to touch it
- `mistakes.md` — anti-patterns actually hit (updated by reviewer)
- `good-practices.md` — patterns that worked (updated by reviewer)
- domain-specific best-practices — researched from web (not just training data)

## Key Preference
Always set up the Claude Code infrastructure (Phase 0) BEFORE writing any app code.
Research best practices from the web for the specific tech stack being used.
