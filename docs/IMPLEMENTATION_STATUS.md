# LifePilot Implementation Status

**Branch:** `cursor/daily-life-mvp-4d5a`  
**Base:** `origin/develop` + merged `cursor/sync-main-develop-4d5a` (architecture fixes)  
**Last updated:** 2026-07-15  
**Environment:** Cloud agent (Linux). `swift` / Xcode not available locally — verification via GitHub Actions (macOS).

---

## Audit summary (2026-07-15)

### What is actually implemented

| Area | Reality |
|---|---|
| SwiftUI app shell | Splash, Onboarding, Home, Timeline, Settings tabs; Memory/Insights are “coming soon” |
| Design system | Real tokens + components (largest code surface) |
| Ghost Brain | `GhostBrainServing` + **mock** provider; `GhostBrainService` throws `unavailable` |
| Timeline | Protocol + mock provider (architecture fix already on this branch) |
| Persistence | **None** — no SwiftData, no store |
| EventKit / Reminders / Notifications | **None** |
| Agents | Folder empty; docs invent agents that do not exist |
| Services | Empty marker module |
| Approvals | Not implemented |
| Web demos | `Website/public/` + `demo/index.html` (hackathon) — mock UX |

Approx. **90 Swift files**, ~3.4k non-empty lines. CI (Build/Lint/Test) green on develop historically.

### Scope violations found (must remove)

- `Core/Models/FinanceTransaction.swift`, `Mocks/MockFinance.swift`
- `AgentKind.finance` / `.shopping` / `.health`, `DaySignal.Kind.finance` / `.health`
- Finance signals in mocks, demos, README, ARCHITECTURE, ROADMAP, DECISIONS, SECURITY
- HealthKit claimed as near-term; not in MVP
- Auto-email / “move money” language in docs

### Branch / PR context (do not duplicate)

Open PRs (demo/deploy, unmerged due to solo-maintainer review gap #7): #16, #20, #22, #23.  
This branch already includes sync+architecture content from #23’s tip.

### Tooling blockers

- No local `swift` / Xcode → cannot claim simulator/UI results from this environment.
- Cannot merge to `main`/`develop` (branch protection). Feature branch + PR only.
- Cannot enable GitHub Pages / merge deploy PRs without owner approval.

---

## Checkbox plan (execution order)

### Stage 1 — Audit, rules, status
- [x] Full code/docs/git audit
- [x] `docs/IMPLEMENTATION_STATUS.md` (this file)
- [x] `.cursor/rules/` for corrected scope
- [ ] Conventional commit after slice

### Stage 2 — Scope correction (finance/commerce/health-MVP out)
- [ ] Delete finance model + mock + tests
- [ ] Strip finance/shopping/health from enums, signals, mocks, demos
- [ ] Rewrite README / vision / architecture / roadmap / security language
- [ ] Finance-removal regression scan test
- [ ] Verify package still builds on CI

### Stage 3 — Domain contracts + offline persistence
- [ ] Expand Core models: Task (subtasks/tags/recurrence), Event/Shift, Timeline, Evidence, Recommendation/Approval, Preference/Memory, Permission state
- [ ] Store / Clock / ID / Executor protocols
- [ ] In-memory + SwiftData-ready persistence for LifePilot-owned state
- [ ] App launch / onboarding persistence
- [ ] Unit + migration-shaped tests

### Stage 4 — Tasks / reminders / notifications
- [ ] Task CRUD + lists (Inbox/Today/Upcoming/Completed)
- [ ] Recurrence + notification identity models
- [ ] Notification scheduler protocol + fake for tests
- [ ] Quick capture entry points

### Stage 5 — Events, schedules, conflict rules, Timeline
- [ ] Personal/work event models + local creation
- [ ] Deterministic overlap / buffer / overload rules
- [ ] Unified Timeline from stores (not only mocks)

### Stage 6 — Today / Morning Briefing / Upcoming
- [ ] Replace Home mock-driven briefing with store-backed briefing
- [ ] Freshness / partial / offline states

### Stage 7 — Recommendations + approval-gated execution
- [ ] ActionProposal / Approval / AuditEvent models
- [ ] Revalidation + idempotent executor boundary
- [ ] Security policy allow/deny tests
- [ ] Approvals UI

### Stage 8 — Memory, insights, search, settings, privacy
- [ ] User-controlled preferences/routines/people/places
- [ ] Evidence-based insights (time-use only; no finance/medical judgments)
- [ ] Offline search
- [ ] Export / delete LifePilot-owned data

### Stage 9 — System adapters (graceful degradation)
- [ ] EventKit Calendar + Reminders adapters (fakes + real #if)
- [ ] WeatherKit / MapKit optional adapters
- [ ] Background refresh hooks
- [ ] CloudKit optional additive sync

### Stage 10 — Optional AI boundary
- [ ] Protocol for enhancement; deterministic planning remains primary
- [ ] No secrets in client; disabled by default

### Stage 11 — App Intents + widgets
- [ ] After core flows pass

### Stage 12 — Accessibility, security, docs, CI stabilization
- [ ] Docs match reality; screenshots only from running app
- [ ] Green macOS Actions for final commit

---

## Verification log

| When | What ran | Result |
|---|---|---|
| 2026-07-15 | Local `swift` / `xcodebuild` | **Unavailable** on agent host |
| (pending) | `swift build` / `swift test` via GHA | — |

---

## Dependencies / decisions locked

1. **No finance/banking/commerce** — permanent.
2. **No HealthKit / medical MVP** — deferred only.
3. **No Apple Mail ingestion / automatic sending** — follow-ups may be manual/share-sheet only.
4. **Offline-first** without account; AI optional and never holds execution credentials.
5. **Composition:** `App → AppShell → Features → Core protocols` ← `Services` / adapters; GhostBrain → Core only.
