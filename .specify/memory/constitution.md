<!--
Sync Impact Report
==================
Version change: (new) → 1.0.0
Added sections: Core Principles (5), Technology Stack, Development Workflow, Governance
Modified principles: (none, initial creation)
Templates checked:
  ✅ .specify/templates/plan-template.md — Constitution Check section present; aligns with principles
  ✅ .specify/templates/spec-template.md — User stories + acceptance criteria pattern compatible
  ✅ .specify/templates/tasks-template.md — Phase/story structure compatible with architecture boundaries
Deferred TODOs:
  - RATIFICATION_DATE set to today (2026-08-12) as initial ratification
-->

# The Unsung Hero Constitution

## Core Principles

### I. Architecture Boundaries (NON-NEGOTIABLE)

The codebase MUST be separated into three layers with strict dependency rules:

- `src/game/` — game logic only; MUST NOT import Phaser or DOM APIs; all business logic lives here
- `src/scenes/` — Phaser 3 Scene rendering and input handling; MAY import from `src/game/`; MUST NOT
  contain business logic
- `src/ui/` — DOM overlay components (card selection UI, etc.); MAY import from `src/game/`; MUST be
  accessible to Playwright E2E tests as DOM elements

Cross-layer violations (e.g., Phaser imports in `src/game/`) MUST be rejected at review.
Rationale: Phaser canvas is opaque to test runners; separating logic from rendering enables fast unit
tests and E2E coverage without Phaser mocking.

### II. Test Coverage Gates (NON-NEGOTIABLE)

All code MUST pass the following gates before a push is accepted:

- **Unit/property tests** (Vitest + fast-check): lines ≥ 80%, functions ≥ 80%, branches ≥ 75%
  — measured over `src/game/**` only
- **Type safety**: `tsc --noEmit` MUST exit 0
- **E2E tests** (Playwright, headless): run in CI on every push to main; cover DOM overlay interactions

The pre-push hook enforces typecheck + coverage + `npm audit --audit-level=high` + license check.
Pre-commit enforces Biome lint/format + markdownlint (fast gates only).
No code MUST be pushed that breaks any of these gates.

### III. Game Balance Invariant

The simulation MUST be calibrated so that a player with no project management knowledge who plays
without strategic use of cards achieves a profit margin below 5% (near-miss or failure).
A skilled player who responds appropriately to events SHOULD achieve 15–25% profit.

All numerical parameters (dice formulae, event probabilities, card costs, EXP curves) MUST be
documented in `docs/03-詳細設計/` before implementation. Design rationale MUST be stored in the
Neo4j graph DB as ADR nodes—not in repository documents.

### IV. Design Knowledge in Graph DB

The Neo4j graph DB (`docker compose up -d`) is the authoritative source for design rationale, ADRs,
and entity relationships. Repository documents (`docs/`) MUST contain only:

- Numerical values, formulae, and coefficients
- Event and card lists
- Stage data
- Screen layout diagrams

Narrative rationale, ADRs, and "why" decisions MUST be stored only in Neo4j. When design decisions
are made in a session, they MUST be written to `docs/design-session/<date>-<topic>.md` (git-ignored)
and synced to Neo4j via `/sync-graphdb` before the session ends.

### V. Dependency Hygiene

- All production dependencies MUST have a license in the approved set:
  MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, 0BSD, Python-2.0, CC0-1.0, Unlicense
- `npm audit --audit-level=high` MUST exit 0 before every push
- Dependabot weekly updates MUST be reviewed promptly; security fixes MUST be applied within 7 days

## Technology Stack

| Category | Tool | Notes |
|---|---|---|
| Game engine | Phaser 3 | Canvas rendering |
| Language | TypeScript 5 | Strict mode |
| Build | Vite | Dev server + production bundler |
| Lint/Format | Biome | Replaces ESLint + Prettier |
| Unit/property tests | Vitest + fast-check | Node environment |
| E2E tests | Playwright | Headless; DOM overlay only |
| SCA | Dependabot + npm audit | Weekly + pre-push |
| SAST | CodeQL | Free for public repositories |
| License check | license-checker-rseidelsohn | Pre-push enforced |
| CI/CD | GitHub Actions | typecheck → lint → test → e2e → sca → sast |
| Hosting | AWS Amplify | Static delivery only |
| Implementation methodology | Spec-Driven Development + Spec Kit | specify CLI |

## Development Workflow

1. **Spec first**: Use `/speckit-specify` to define what and why before writing any code
2. **Plan**: Use `/speckit-plan` to lock in the technical approach
3. **Tasks**: Use `/speckit-tasks` to break the plan into trackable tasks
4. **Implement**: Use `/speckit-implement` to execute tasks
5. **Design sessions**: Write decisions to `docs/design-session/` then run `/sync-graphdb`

### Graph DB Sync Checkpoints (MANDATORY)

After each of the following Spec Kit steps, `/sync-graphdb` MUST be run to persist
decisions and rationale into Neo4j before moving to the next step:

- After `/speckit-constitution` — constitution principles become ADR nodes
- After `/speckit-specify` — feature scope and acceptance criteria become Spec nodes
- After `/speckit-clarify` — clarification answers update existing Spec nodes
- After `/speckit-plan` — technical decisions become ADR nodes with AFFECTS relationships
- After `/speckit-tasks` — task breakdown is recorded against the Spec node
- After `/speckit-checklist` — quality checklist findings update the Spec node
- After `/speckit-analyze` — consistency analysis findings update the Spec node
- After `/speckit-implement` — implementation results recorded against the Spec node

This is enforced automatically via `.specify/extensions.yml` mandatory after-hooks.
`/speckit-converge` does not require a sync (no new design decisions are made).

Commit messages MUST follow Conventional Commits in Japanese:
`<type>: <日本語の要約>` — types: feat, fix, docs, refactor, chore, test, style

## Governance

This constitution supersedes all other conventions in the repository. Amendments require:

1. A new design-session doc explaining the change rationale
2. A `/sync-graphdb` run to persist the ADR
3. A version bump commit following semantic versioning:
   - MAJOR: removal or redefinition of a non-negotiable principle
   - MINOR: new principle or section added
   - PATCH: wording clarification, non-semantic refinement
4. All templates under `.specify/templates/` MUST be reviewed for alignment

Compliance is verified at every PR review. Complexity deviations from principles MUST be justified
in the PR description and recorded as ADR nodes in Neo4j.

**Version**: 1.1.0 | **Ratified**: 2026-08-12 | **Last Amended**: 2026-08-12
