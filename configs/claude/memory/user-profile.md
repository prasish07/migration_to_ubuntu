---
name: user-profile
description: Who prasish07 is — role, preferences, working style, what to expect
metadata:
  type: user
---

## Profile
- Builds mobile apps (React Native / Expo) and web apps
- Comfortable with TypeScript, React, Node.js
- Prefers structured, phase-based development with documentation and quality gates
- Values infrastructure setup (Claude Code hooks, wisdom folders, agents) before writing app code
- Wants session continuity — progress docs must be detailed enough for a new session to resume exactly

## Working Style
- Asks for web research before accepting best-practice recommendations (don't rely on training data alone)
- Wants things documented so they persist across sessions and projects
- Prefers committing work incrementally with meaningful commit messages
- Uses EAS builds for Android testing (not Android Studio / emulator)
- Lets Claude make decisions and redirects if wrong, rather than micromanaging

## Preferences
- Auto-commit/push after every session (Stop hook)
- Prettier auto-format on every .ts/.tsx save (PostToolUse hook)
- Phase reviewer agent after every major phase
- wisdom/ folder auto-loaded every session via CLAUDE.md @imports
- No emojis unless explicitly asked
- Concise responses — no trailing summaries restating what was already visible in the diff

## Projects (known)
- `coup` — React Native Coup card game (Expo SDK 56, Zustand, Expo Router)
- `seatflow-frontend` — web frontend project
- `subscription` — subscription-related project
