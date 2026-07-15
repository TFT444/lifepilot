# Architecture

This document describes LifePilot's system architecture: how the codebase is organized, how layers depend on one another, how the AI agent system is structured, and how the design scales as the product grows.

## Table of Contents

- [System Overview](#system-overview)
- [Folder Structure](#folder-structure)
- [Layered Architecture](#layered-architecture)
- [Dependency Rules](#dependency-rules)
- [AI Agent Architecture](#ai-agent-architecture)
- [Future Scalability](#future-scalability)

## System Overview

LifePilot is structured as a layered system: signal collection at the edges, reasoning at the core, and execution gated behind explicit human approval. This is a direct expression of the product's core loop — **Observe → Understand → Predict → Prepare → Explain → Approve → Execute → Learn** — described in the [README](../README.md#core-philosophy).

```mermaid
flowchart TD
    U[User]
    GB[Ghost Brain\nCore Reasoning Engine]
    AG[Capabilities\nCalendar · Tasks · Travel · Weather · Memory]
    APPS[Connected Sources\nCalendar · Reminders · Maps · Weather]
    REC[Recommendations\nRanked, Explained]
    APP[Approval\nUser Reviews & Confirms]
    EX[Execution\nAction Performed]

    U --> GB
    GB --> AG
    AG --> APPS
    APPS --> AG
    AG --> GB
    GB --> REC
    REC --> APP
    APP -->|approved| EX
    APP -->|rejected| GB
    EX --> U
```

Three properties fall directly out of this diagram:

1. **The Ghost Brain is the only component that reasons across domains.** Agents reason within their domain and report structured findings upward; only the Ghost Brain fuses them into one model of "today."
2. **No path reaches Execution without passing through Approval.** This is enforced in code, not just in the UI — see [Dependency Rules](#dependency-rules).
3. **Connected Apps are adapters, not sources of truth for meaning.** LifePilot never forks the user's data model; it reads from and writes back to the systems of record.

## Folder Structure

```
lifepilot/
├── App/                      # Thin Xcode wrapper: @main entry + asset catalog
├── AppShell/                 # Composition root (DI) and root navigation
├── Core/                     # Shared domain models and protocols
├── GhostBrain/               # Reasoning seam: GhostBrainServing, models, mock provider
├── Agents/                   # Future domain adapters (Calendar, Travel, ...); empty in current MVP
├── DesignSystem/             # Shared UI components, typography, tokens, theming
├── Features/                 # User-facing feature modules (Morning Briefing, Timeline, ...)
├── Services/                 # Cross-cutting infrastructure: networking, persistence, auth
├── Mocks/                    # Mock data providers for development and tests
├── Resources/                # Assets, localization, configuration
├── Assets/                   # Brand assets (logo, marks) — source of truth for derived icons
├── Tests/                    # Unit and integration tests, mirroring the module structure above
├── Examples/                 # Minimal, runnable examples of agent and service usage
├── Scripts/                  # Developer tooling: setup, codegen, release scripts
├── packages/                 # Local Swift Packages extracted from Core as it grows
├── Website/public/           # Interactive web demo (GitHub Pages + Vercel)
├── docs/                     # Architecture, product, and engineering documentation
└── .github/                  # Issue templates, PR template, CI/CD workflows
```

Each first-class module (`Core`, `GhostBrain`, `Agents`, `DesignSystem`, `Features`, `Services`, `AppShell`) is expected to be internally organized by feature, not by file type — e.g. `Agents/CalendarAgent/CalendarAgent.swift`, `Agents/CalendarAgent/CalendarSignal.swift`, rather than a flat `Models/`, `Views/`, `Controllers/` split at the top level.

The root `Package.swift` builds seven SPM library targets (`LifePilotCore`, `LifePilotGhostBrain`, `LifePilotDesignSystem`, `LifePilotFeatures`, `LifePilotServices`, `LifePilotMocks`, `LifePilotAppShell`) plus matching test targets. The thin `App/LifePilot.xcodeproj` wraps `LifePilotAppShell` for simulator/device runs. `packages/` remains reserved for domain logic *extracted* from `Core` once it outgrows a single target, per [ADR-005](DECISIONS.md#adr-005-protocol-first-module-boundaries).

## Layered Architecture

LifePilot follows a strict layering model. Each layer may depend only on the layers below it.

```mermaid
flowchart TB
    subgraph L4["Presentation Layer"]
        F[Features]
        DS[DesignSystem]
    end
    subgraph L3["Domain Layer"]
        C[Core / Ghost Brain]
        AG[Agents]
    end
    subgraph L2["Service Layer"]
        S[Services]
    end
    subgraph L1["Platform Layer"]
        INT["Integrations — CloudKit, WeatherKit, MapKit, Supabase, OpenAI"]
    end

    F --> C
    F --> DS
    C --> AG
    AG --> S
    S --> INT
```

| Layer | Responsibility | May depend on |
|---|---|---|
| **Presentation** (`Features`, `DesignSystem`) | Renders UI, handles user interaction, presents Ghost Brain output. | Domain layer only. Never talks to Services or Integrations directly. |
| **Domain** (`Core`, `Agents`) | Reasoning, prediction, and domain modeling. Framework-agnostic. | Service layer, via protocols. |
| **Service** (`Services`) | Cross-cutting infrastructure: networking, persistence, auth, logging. | Platform layer. |
| **Platform** (`Integrations`) | Thin adapters around external SDKs and APIs. | Nothing above it. |

## Dependency Rules

1. **Dependencies point downward only.** `Features` may import `Core`; `Core` must never import `Features`. Circular dependencies between modules are a build failure, not a style preference.
2. **The Domain layer is UI-framework-agnostic.** `Core` and `Agents` contain no `import SwiftUI`. This keeps the reasoning engine testable in isolation and portable to a future non-Apple surface if the product ever requires it.
3. **Agents communicate only through the Ghost Brain.** `Agents/CalendarAgent` never directly calls `Agents/EmailAgent`. Cross-agent context flows through `Core`, so the reasoning graph stays inspectable and testable as a whole.
4. **Execution is gated by construction.** The type that represents an "approved action" is only constructible from a successful Approval flow — see [Core Philosophy](../README.md#core-philosophy) and the Security Agent's role in [AI Agent Architecture](#ai-agent-architecture). There is no code path that produces a side effect without passing through that type.
5. **Integrations are swappable.** `Services` depends on protocols, not concrete SDK types, so `OpenAI`, `Supabase`, or `CloudKit` can be replaced or mocked without touching `Core` or `Agents`.

## AI Agent Architecture

Each agent is a self-contained unit that reasons within one domain and reports structured, typed findings to the Ghost Brain. This mirrors the [AI Agent System](../README.md#ai-agent-system) described in the README, with the following structural contract:

```mermaid
classDiagram
    class Agent {
        <<protocol>>
        +observe() SignalList
        +predict(context) PredictionList
    }
    class GhostBrain {
        +fuse(predictions) DayModel
        +rank(recommendations) RankedRecommendations
    }
    class SecurityAgent {
        +audit(action) RiskAssessment
    }
    class ApprovalGate {
        +request(action) ApprovedAction
    }

    Agent <|-- CalendarCapability
    Agent <|-- TaskCapability
    Agent <|-- TravelCapability
    Agent <|-- WeatherCapability
    Agent <|-- MemoryCapability
    Agent <|-- ReminderCapability

    GhostBrain --> Agent : fuses output of
    GhostBrain --> SecurityAgent : requests audit
    SecurityAgent --> ApprovalGate : gates
    ApprovalGate --> GhostBrain : returns ApprovedAction
```

Capabilities implement a common observation/prediction contract. Finance, shopping, and health agents are deliberately **not** part of the MVP surface.

See the [README capability table](../README.md#capability-surface-daily-life-mvp) for what ships now.

## Future Scalability

The layering above is designed to absorb three kinds of future growth without rearchitecting:

- **New capabilities.** Home and Social adapters can be added behind Core protocols — no changes to `Features` or `DesignSystem` required.
- **New surfaces.** Because `Core` is UI-framework-agnostic, a future web dashboard or other client can reuse the same planning engine.
- **New integrations.** Because `Services` depends on protocols rather than concrete SDKs, swapping or adding a data source touches one adapter, not the planning core.

As the codebase grows past what a single `Core` module can comfortably hold, domain logic will be extracted into local Swift Packages under `packages/`, each with its own tests and versioned independently — without changing the dependency rules above.
