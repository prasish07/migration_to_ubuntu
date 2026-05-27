---
name: architecture-engine-store-screen
description: Three-layer architecture pattern for complex React Native apps — pure engine, thin store, dumb screens. Proven in the Coup game project.
metadata:
  type: user
---

## The Pattern

```
src/app/*.tsx           ← Screens: thin wrappers, NO logic
      ↕  useGameStore(selector)
src/store/*.ts          ← Store: thin wiring, calls engine, no business rules
      ↕  pure function calls
src/engine/*.ts         ← Engine: pure functions, NO React imports, fully testable
```

## Engine Layer Rules
- Zero React imports — EVER. If tsc passes with `isolatedModules`, the engine is truly pure.
- Every function pure: same input → same output, no side effects
- Never mutate state: `return { ...state, field: newValue }`
- All types in `types.ts` — never redefine types locally in other engine files
- Shared lookup constants (e.g. action→character mapping) belong in `types.ts`, not duplicated across files
- Every export has a Jest test

## Store Layer Rules (Zustand)
- Explicit TypeScript interface for the store
- Actions are thin: validate → call engine function → call `set()`
- Private helpers for orchestration (turn advance, AI chain) are fine if unexported
- No business logic — no coin math, no rule enforcement
- Always use selectors in components: `useStore(s => s.field)`, never `const { field } = useStore()`

## Screen Layer Rules
- No business logic in screens
- No direct engine calls — only store actions
- Params via `useLocalSearchParams<{ param: string }>()`, JSON.stringify for small objects
- Never pass large objects through navigation

## Testing Strategy
- Engine: pure functions → trivially unit-testable with `makeState()` factories
- Store: test with `useStore.getState()` and `useStore.setState()` directly, no rendering needed
- Component: skip until E2E, or use RNTL for critical interactions
- Always include "should not mutate original state" test for every engine function

## Multi-Step State Machine (learned from block→challenge→reveal flow)
When a sequence chains multiple engine calls (e.g. block fails → blocker loses card → original action resolves):
- Implement the chain in the STORE action, not in the engine
- Capture `prevState` before the first engine call to detect context for subsequent branches
- Engine primitives stay simple; the store owns sequence orchestration

## W2 Pattern (detecting context after loseInfluence)
```ts
revealCard: (cardIndex) => set((store) => {
  const prevState = store.gameState;  // capture BEFORE engine call
  let next = loseInfluence(prevState, cardIndex);
  // loseInfluence clears pending — use prevState to recover context
  const blockerExposed =
    prevState.pending !== null &&
    prevState.pendingBlock !== null &&
    prevState.loserId === prevState.pendingBlock.blockerId;
  if (blockerExposed && next.phase === 'action') {
    next = resolveAction({ ...next, pending: prevState.pending });
  }
  // ... advance turn
})
```
