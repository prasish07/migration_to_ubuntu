---
name: rn-expo-stack
description: React Native / Expo stack preferences, bootstrap steps, EAS build workflow, and common gotchas learned from the Coup game project
metadata:
  type: user
---

## Stack
- **Framework:** Expo managed workflow (NOT bare React Native)
- **SDK:** 56 (latest as of May 2026)
- **Language:** TypeScript strict mode
- **Routing:** Expo Router, file-based, screens in `src/app/` (not `app/` at root)
- **State:** Zustand ^5 (no Provider, always use selectors)
- **Animation:** React Native Reanimated 4 (included in SDK 56 template)
- **Testing:** Jest + jest-expo preset
- **Builds:** EAS (Expo Application Services)

## Bootstrap Order
1. Scaffold in `/tmp/` (Expo CLI refuses non-empty dirs), then rsync to project
2. Move screens to `src/app/`, add `@/*` path alias in tsconfig
3. Add `"types": ["jest"]` to tsconfig compilerOptions
4. Remove `import '@/global.css'` from `src/constants/theme.ts` (template TS bug)
5. Fix `/explore` route in `src/components/app-tabs.web.tsx` → change to `/`
6. Install: `zustand`, `jest`, `jest-expo`, `@types/jest`
7. Do NOT install `expo-av` until the final polish phase (causes `LazyKType` crash)
8. Run `npx eas login` → `npx eas build:configure` → `eas.json` gets created

## EAS Build Workflow
- `npx eas build --profile development --platform android` → APK (~15 min build)
- Install APK on phone, then `npx expo start --dev-client` on computer
- Expo Go on Play Store does NOT support SDK 56+ — must use EAS dev build
- Native modules are baked into the APK at build time — JS changes are live, native changes need rebuild

## Common Gotchas
- `expo-av` → `LazyKType` NoClassDefFoundError on launch: remove it until Phase 5
- Template `app-tabs.web.tsx` references `/explore` (non-existent route) → TS error
- Template `theme.ts` has `import '@/global.css'` → TS error, remove it
- `describe`/`it`/`expect` TS errors in test files → add `"types": ["jest"]` to tsconfig
- EAS build tied to commit — changing package.json after build doesn't update native modules

## Reference
Full blueprint at: `/home/prasish/Documents/Development/learning/coup/wisdom/mobile-app-blueprint.md`
