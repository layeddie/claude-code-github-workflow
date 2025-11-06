# Architecture Documentation

**Comprehensive technical documentation of the GitHub Workflow Blueprint system architecture, design decisions, and implementation details**

---

## Table of Contents

1. [System Architecture Overview](#system-architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Design Principles](#design-principles)
4. [Component Interactions](#component-interactions)
5. [Data Flow](#data-flow)
6. [Design Decisions](#design-decisions)
7. [Security Model](#security-model)
8. [Scalability Considerations](#scalability-considerations)
9. [Performance Optimization](#performance-optimization)
10. [Technical Constraints](#technical-constraints)
11. [Future Enhancements](#future-enhancements)

---

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER INTERFACE LAYER                         │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Slash Commands  │  │ Setup Wizard    │  │ Documentation   │ │
│  │ (8 commands)    │  │ (Interactive)   │  │ (8 guides)      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    AUTOMATION LAYER                              │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Agents          │  │ Composite       │  │ Validators      │ │
│  │ (4 specialized) │  │ Actions (5)     │  │ & Helpers       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      WORKFLOW LAYER                              │
│                                                                   │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐           │
│  │Bootstrap│  │PR Checks│  │Plan→    │  │Status   │           │
│  │         │  │         │  │Issues   │  │Sync     │ ...       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘           │
│                   (8 Core Workflows)                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    INTEGRATION LAYER                             │
│                                                                   │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐           │
│  │ GitHub  │  │ GitHub  │  │ Claude  │  │ External│           │
│  │ REST API│  │ GraphQL │  │ Code    │  │ Tools   │           │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     FOUNDATION LAYER                             │
│                                                                   │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐           │
│  │   Git   │  │ GitHub  │  │ Project │  │ Issue   │           │
│  │         │  │ Actions │  │ Board   │  │ Tracking│           │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### User Interface Layer
- **Purpose**: Provide intuitive interfaces for developers
- **Components**:
  - 8 slash commands for common operations
  - Interactive setup wizard
  - Comprehensive documentation
- **Key Features**: Beginner-friendly, self-documenting, safe defaults

#### Automation Layer
- **Purpose**: Orchestrate complex multi-step operations
- **Components**:
  - 4 specialized agents (Claude Code subagents)
  - 5 composite actions (reusable GitHub Actions)
  - Validation and helper functions
- **Key Features**: DRY principles, error recovery, idempotency

#### Workflow Layer
- **Purpose**: Automate development lifecycle events
- **Components**: 8 core GitHub Actions workflows
- **Key Features**: Event-driven, parallel execution, quality gates

#### Integration Layer
- **Purpose**: Connect to external services and APIs
- **Components**:
  - GitHub REST API (issues, PRs, labels)
  - GitHub GraphQL API (Projects v2)
  - Claude Code Action (AI-powered automation)
  - External webhooks (Slack, Jira, etc.)
- **Key Features**: Rate limiting, circuit breakers, retry logic

#### Foundation Layer
- **Purpose**: Provide core platform capabilities
- **Components**: Git, GitHub Actions, Project boards, Issue tracking
- **Key Features**: Reliable, scalable, well-documented

---

## Technology Stack

### Core Technologies

| Component | Technology | Version | Rationale |
|-----------|-----------|---------|-----------|
| **CI/CD** | GitHub Actions | Latest | Native integration, free for public repos |
| **Package Manager** | pnpm | 9.x | Fast, efficient, workspace support |
| **Runtime** | Node.js | 20 LTS | Stable, long-term support, modern features |
| **Project Management** | GitHub Projects v2 | Latest | GraphQL API, flexible, native GitHub |
| **AI Automation** | Claude Code Action | v1 GA | Official Anthropic integration, stable API |
| **Version Control** | Git | 2.40+ | Industry standard, ubiquitous |

### Supporting Technologies

| Purpose | Technology | Usage |
|---------|-----------|-------|
| **JSON Validation** | jq | Parse and validate plan JSON |
| **Path Filtering** | dorny/paths-filter@v3 | Smart workflow triggers |
| **Semantic PR** | amannn/action-semantic-pull-request@v5 | Conventional commit validation |
| **Script Execution** | actions/github-script@v7 | JavaScript in workflows |
| **Caching** | actions/cache@v4 | Speed up builds |

### Why These Choices?

**GitHub Actions over Jenkins/CircleCI**:
- ✅ Native GitHub integration
- ✅ Free for public repositories
- ✅ No infrastructure management
- ✅ Excellent marketplace ecosystem
- ❌ Vendor lock-in (mitigated by standard YAML)

**pnpm over npm/yarn**:
- ✅ 2-3x faster installs
- ✅ Efficient disk space usage (content-addressable storage)
- ✅ Strict dependency resolution (no phantom dependencies)
- ✅ Built-in workspace support
- ❌ Slightly less ecosystem maturity than npm

**Projects v2 over Classic Projects**:
- ✅ GraphQL API (powerful queries)
- ✅ Custom fields and views
- ✅ Automation capabilities
- ✅ Future-proof (GitHub's recommended approach)
- ❌ More complex API than Classic Projects

**Claude Code Action v1 GA over Beta**:
- ✅ Stable, production-ready API
- ✅ Simplified configuration
- ✅ Auto mode detection
- ✅ Official support from Anthropic
- ❌ Fewer cutting-edge features than beta

---

## Design Principles

### 1. Simplicity First

**Principle**: Prefer simple, obvious solutions over clever ones.

**Examples**:
- Max 10 tasks per plan (simple limit, easy to understand)
- Conventional commit format (industry standard)
- Linear git history (squash merges only)

**Rationale**: Lower cognitive load for users, easier debugging, fewer edge cases.

---

### 2. Safety by Default

**Principle**: Fail safe, not fail fast. Prevent destructive operations.

**Examples**:
- Fork PRs are read-only (can't modify repository)
- Rate limit checks before mutations (prevent API exhaustion)
- Branch protection enforced (no force push, no deletion)
- Kill switch mechanism (emergency stop)

**Rationale**: Protects users from mistakes, prevents cascading failures.

---

### 3. Progressive Disclosure

**Principle**: Show simple options first, advanced options on demand.

**Examples**:
- Quick Start: 3 steps, <5 minutes
- Complete Setup: Comprehensive, all options
- Branching: Simple (default) → Standard → Complex

**Rationale**: Lowers barrier to entry, doesn't overwhelm beginners.

---

### 4. DRY (Don't Repeat Yourself)

**Principle**: Extract common patterns into reusable components.

**Examples**:
- `reusable-pr-checks.yml` (called by multiple workflows)
- Composite actions (5 reusable actions)
- Shared validation logic

**Rationale**: Easier maintenance, consistent behavior, fewer bugs.

---

### 5. Idempotency

**Principle**: Operations should be safe to retry.

**Examples**:
- Bootstrap workflow checks if labels exist before creating
- Issue creation skips duplicates (checks by title)
- Branch creation skips if branch exists

**Rationale**: Transient failures shouldn't cause permanent issues.

---

### 6. Fail-Fast Validation

**Principle**: Validate inputs early, fail with clear messages.

**Examples**:
- Plan JSON validated before processing (schema, task count)
- PR title validated immediately (conventional format)
- Branch name validated before quality checks

**Rationale**: Fast feedback, clear error messages, saves compute time.

---

### 7. Observable Operations

**Principle**: Every operation should be visible and debuggable.

**Examples**:
- GitHub Actions summary (markdown reports)
- PR comments (validation failures, helpful guidance)
- Detailed logs (emoji indicators, structured output)

**Rationale**: Easier debugging, better user experience, builds trust.

---

## Component Interactions

### Workflow ↔ Composite Actions

```
┌──────────────────────┐
│   pr-into-dev.yml    │
│                      │
│  1. Fork check   ────┼────→ .github/actions/fork-safety
│  2. Rate limit   ────┼────→ .github/actions/rate-limit-check
│  3. Quality     ────┼────→ .github/workflows/reusable-pr-checks.yml
│                      │         │
└──────────────────────┘         │
                                 ├────→ .github/actions/setup-node-pnpm
                                 └────→ .github/actions/quality-gates
```

**Flow**:
1. PR event triggers `pr-into-dev.yml`
2. Workflow calls composite actions for reusable logic
3. Composite actions perform atomic operations
4. Results aggregate back to workflow
5. Workflow generates summary report

**Benefits**:
- **Reusability**: Same logic across multiple workflows
- **Maintainability**: Update once, applies everywhere
- **Testability**: Actions can be tested independently
- **Performance**: Parallel execution where possible

---

### Slash Commands ↔ Workflows

```
User runs: /blueprint-init
     ↓
Claude Code executes command
     ↓
Command prompts user (interactive)
     ↓
Command calls: gh workflow run bootstrap.yml
     ↓
Workflow executes in GitHub Actions
     ↓
Results displayed to user
```

**Integration Points**:
1. **Command → Workflow**: Commands trigger workflows via `gh workflow run`
2. **Workflow → Status**: Workflows post results to PR/issue comments
3. **Command → Validation**: Commands validate before triggering workflows

**Design Decision**: Commands are thin wrappers around workflows, not duplicating logic.

---

### Agents ↔ GitHub API

```
User runs: /plan-to-issues plan.json
     ↓
plan-converter agent (Claude Code)
     ↓
Agent validates plan structure
     ↓
Agent calls: gh workflow run claude-plan-to-issues.yml
     ↓
Workflow processes via GitHub REST API:
  - Create milestone (if specified)
  - Create issues (max 10)
  - Apply labels
  - Link dependencies
     ↓
Workflow syncs to Project Board via GraphQL
     ↓
Agent displays summary to user
```

**API Usage**:
- **REST API**: CRUD operations (issues, PRs, labels, milestones)
- **GraphQL API**: Project board operations (queries, mutations)
- **Mixed Approach**: Use REST for simple ops, GraphQL for complex queries

**Rate Limit Strategy**:
- Check remaining calls before operations (circuit breaker)
- Batch operations where possible
- Add delays between mutations (500ms)
- Use conditional requests (ETags) to save quota

---

### Project Board ↔ Issues

```
Issue Created (#123)
     ↓
Labels: claude-code + status:ready
     ↓
create-branch-on-issue.yml triggers
     ↓
GraphQL Mutation:
  - Add issue to project
  - Set Status: "Ready"
     ↓
Developer works on branch
     ↓
PR Created → dev
     ↓
pr-status-sync.yml updates:
  - Issue Status: "In Review"
  - Project Board: "In Review"
     ↓
PR Merged
     ↓
pr-status-sync.yml updates:
  - Issue Status: "To Deploy"
  - Project Board: "To Deploy"
     ↓
Release to main
     ↓
release-status-sync.yml closes:
  - Issue closed
  - Project Board: "Done"
```

**Bidirectional Sync**:
- Issues → Project Board (automatic via workflows)
- Project Board → Issues (manual via `/sync-status` command)

**Status Mapping**:
```
Issue Labels          Project Board Status
─────────────────     ────────────────────
status:ready      →   Ready
status:in-progress →  In Progress
status:in-review   →  In Review
status:to-deploy   →  To Deploy
[closed]           →  Done
```

---

## Data Flow

### Complete Lifecycle: Plan → Production

```
1. PLANNING PHASE
   ┌─────────────────────┐
   │ Claude Code Plan    │
   │ (JSON, max 10 tasks)│
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ /plan-to-issues     │
   │ (command)           │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ claude-plan-to-     │
   │ issues.yml          │
   │ (workflow)          │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ GitHub Issues       │
   │ (10 issues created) │
   │ Labels: claude-code │
   │         status:ready│
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ Project Board       │
   │ Status: Ready       │
   └─────────────────────┘

2. DEVELOPMENT PHASE
   ┌─────────────────────┐
   │ Issue #123 labeled  │
   │ claude-code +       │
   │ status:ready        │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ create-branch-on-   │
   │ issue.yml           │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ Branch created:     │
   │ feature/issue-123-  │
   │ description         │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ Developer commits   │
   │ to feature branch   │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ /commit-smart       │
   │ (quality checks)    │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ /create-pr          │
   │ PR → dev            │
   └─────────────────────┘

3. REVIEW PHASE
   ┌─────────────────────┐
   │ PR opened to dev    │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ pr-into-dev.yml     │
   │ - Validate branch   │
   │ - Validate title    │
   │ - Check linked issue│
   │ - Run quality gates │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ reusable-pr-checks  │
   │ - Lint              │
   │ - Typecheck         │
   │ - Unit tests        │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ pr-status-sync.yml  │
   │ Issue: In Review    │
   │ Board: In Review    │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ /review-pr          │
   │ (optional)          │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ PR approved & merged│
   └─────────────────────┘

4. DEPLOYMENT PHASE
   ┌─────────────────────┐
   │ PR merged to dev    │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ pr-status-sync.yml  │
   │ Issue: To Deploy    │
   │ Board: To Deploy    │
   │ Branch deleted      │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ /release            │
   │ PR: dev → main      │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ dev-to-main.yml     │
   │ - Build prod        │
   │ - Smoke tests       │
   │ - Security scan     │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ PR merged to main   │
   └──────────┬──────────┘
              ↓
   ┌─────────────────────┐
   │ release-status-     │
   │ sync.yml            │
   │ - Close issues      │
   │ - Board: Done       │
   │ - Create release    │
   └─────────────────────┘

5. PRODUCTION
   ┌─────────────────────┐
   │ GitHub Release      │
   │ v1.2.3              │
   │ - Changelog         │
   │ - Artifacts         │
   └─────────────────────┘
```

### Status Propagation Flow

```
Issue Label Change
     ↓
GitHub Webhook
     ↓
Workflow Triggered (pr-status-sync.yml)
     ↓
┌─────────────────────────────────────┐
│ Determine New Status                │
│ - PR opened → "In Review"           │
│ - PR draft → "In Progress"          │
│ - PR merged → "To Deploy"           │
│ - PR closed (not merged) → reset   │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Update Issue Labels                 │
│ - Remove old status label           │
│ - Add new status label              │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Update Project Board (GraphQL)      │
│ - Query project ID                  │
│ - Query status field ID             │
│ - Mutate status value               │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Post Comment (if applicable)        │
│ "Status updated to: In Review"      │
└─────────────────────────────────────┘
```

**Debouncing**: 10-second delay between status updates prevents infinite loops.

---

## Design Decisions

### 1. Why Max 10 Tasks per Plan?

**Decision**: Hard limit of 10 tasks per Claude Code plan.

**Rationale**:

**Technical**:
- GitHub API rate limits (5,000 requests/hour)
- Creating 10 issues ≈ 30-40 API calls
- Leaves buffer for other operations
- Workflow execution time <30 seconds

**User Experience**:
- Encourages focused, manageable sprints
- Prevents overwhelming issue list
- Forces better planning granularity
- Easier to track progress

**Performance**:
- Fast workflow execution
- No pagination needed
- Predictable resource usage

**Alternative Considered**: No limit
- ❌ Risk of API rate limit exhaustion
- ❌ Slow workflow execution (timeouts)
- ❌ Poor user experience (too many issues)

**Customization**: Users can change limit in workflow (see CUSTOMIZATION.md)

---

### 2. Why GraphQL for Projects v2?

**Decision**: Use GitHub GraphQL API for project board operations.

**Rationale**:

**Projects v2 Requirement**:
- GitHub Projects v2 **only** supports GraphQL
- No REST API available
- Future-proof (GitHub's recommended approach)

**GraphQL Advantages**:
- **Precise queries**: Fetch exactly what you need
- **Single request**: Get project + status + issues in one call
- **Strongly typed**: Better error messages
- **Flexible**: Easy to add fields without breaking changes

**GraphQL Challenges**:
- **Complexity**: More verbose than REST
- **Learning curve**: Requires GraphQL knowledge
- **Debugging**: Harder to debug than REST

**Mixed Approach**:
- Use REST for simple CRUD (issues, PRs, labels)
- Use GraphQL only for Projects v2 (no choice)
- Provides best of both worlds

**Example GraphQL Query**:
```graphql
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    issue(number: $number) {
      id
      projectItems(first: 10) {
        nodes {
          project {
            id
            title
          }
        }
      }
    }
  }
}
```

---

### 3. Why Three Branching Strategies?

**Decision**: Support Simple, Standard, and Complex branching strategies.

**Rationale**:

**Flexibility**:
- **Simple** (feature → main): Solo developers, startups
- **Standard** (feature → dev → main): Small-medium teams (recommended)
- **Complex** (feature → dev → staging → main): Enterprises

**User Personas**:

**Solo Developer** (Simple):
- Wants fast iteration
- No formal review process
- Low risk tolerance acceptable

**Small Team** (Standard):
- Needs code review
- Wants staging before production
- Balance of speed and safety

**Enterprise** (Complex):
- Multiple environments (dev, staging, prod)
- Strict approval processes
- Maximum safety required

**Implementation Cost**:
- Minimal: Just branch filters in workflows
- Same workflows work for all strategies
- No code duplication

**Alternative Considered**: Force Standard strategy
- ❌ Too rigid for solo developers
- ❌ Not enough for enterprises
- ❌ One-size-fits-all doesn't work

---

### 4. Why pnpm over npm?

**Decision**: Default to pnpm for package management.

**Rationale**:

**Performance**:
- 2-3x faster installs than npm
- Content-addressable storage (global cache)
- Hard links save disk space

**Reliability**:
- Strict dependency resolution
- No phantom dependencies
- Deterministic installs

**Modern Features**:
- Built-in workspace support
- Better monorepo handling
- Faster CI/CD builds

**Adoption**:
- Used by major projects (Vue.js, Prisma, etc.)
- Growing ecosystem
- Active development

**Backwards Compatibility**:
- Works with npm packages
- Standard package.json
- Easy migration from npm

**Trade-offs**:
- Slightly less ecosystem maturity
- Some tools don't support pnpm (rare)
- Learning curve for npm users (minimal)

**Override**: Users can switch to npm/yarn (see CUSTOMIZATION.md)

---

### 5. Why Node.js 20 LTS?

**Decision**: Default to Node.js 20 (LTS).

**Rationale**:

**Long-Term Support**:
- Supported until April 2026
- Stable, production-ready
- Security updates guaranteed

**Modern Features**:
- Native test runner
- Improved performance
- ESM support stable
- Better TypeScript support

**Ecosystem Compatibility**:
- All major tools support Node 20+
- Sufficient for most projects
- Good balance of new and stable

**Trade-offs**:
- Not cutting-edge (Node 22+ has newer features)
- Some legacy projects need older versions

**Override**: Users can specify different version (see CUSTOMIZATION.md)

```yaml
uses: ./.github/actions/setup-node-pnpm
with:
  node-version: '22'  # Use Node 22 instead
```

---

### 6. Why Rate Limiting with Circuit Breakers?

**Decision**: Check API rate limits before operations, fail-fast if too low.

**Rationale**:

**Problem**: GitHub API rate limits
- 5,000 requests/hour (authenticated)
- 1,000 requests/hour (unauthenticated)
- Shared across all workflows

**Without Rate Limiting**:
- Workflows fail mid-execution
- Partial state (some issues created, some not)
- Poor error messages
- Difficult recovery

**With Circuit Breakers**:
- Check remaining quota before starting
- Fail-fast with clear message if too low
- Prevents partial operations
- Suggests retry time

**Thresholds**:
- `claude-plan-to-issues.yml`: 100 minimum (creates up to 10 issues)
- `pr-into-dev.yml`: 50 minimum (validation + comments)
- Other workflows: 50 minimum

**Implementation**:
```yaml
- name: Check rate limit
  uses: ./.github/actions/rate-limit-check
  with:
    minimum-remaining: 100
```

**Benefits**:
- Prevents cascading failures
- Clear error messages
- Predictable behavior
- Easy to customize

---

### 7. Why Squash-Only Merges?

**Decision**: Enforce squash merges (no merge commits, no rebase).

**Rationale**:

**Linear History**:
- Clean, readable git log
- Easy to revert entire features
- Bisect works reliably

**Simplified Commits**:
- One commit per PR
- Commit message = PR title
- Easy to generate changelog

**Review Efficiency**:
- Review PR as whole, not individual commits
- No need to fix commit history
- Faster review cycle

**Trade-offs**:
- Lose individual commit history within PR
- Can't cherry-pick individual commits
- Some developers prefer preserving work-in-progress commits

**Alternatives Considered**:
- **Merge commits**: ❌ Messy history, hard to read
- **Rebase**: ❌ Can rewrite history, risky
- **Squash**: ✅ Best balance

**Override**: Change branch protection settings if needed

---

### 8. Why Fork Safety (Read-Only for Forks)?

**Decision**: Fork PRs run checks but skip write operations.

**Rationale**:

**Security Risk**:
- Forks can modify workflows
- Malicious actors could steal secrets
- Could spam issues/comments
- Could DOS GitHub API

**GitHub Security Model**:
- Fork PRs get read-only `GITHUB_TOKEN`
- Can't write to base repository
- Can't access organization secrets

**Our Implementation**:
- Detect fork PRs automatically
- Run quality checks (safe)
- Skip mutations (write operations)
- Log warning message

**Example**:
```yaml
- name: Check if PR is from fork
  id: fork-safety
  uses: ./.github/actions/fork-safety

- name: Update project board
  if: steps.fork-safety.outputs.is-fork != 'true'
  run: |
    # Only runs for non-fork PRs
```

**User Experience**:
- Fork contributors still get quality feedback
- Base repository stays secure
- Clear messaging about limitations

---

## Security Model

### Secret Handling

**Secrets Required**:
1. `ANTHROPIC_API_KEY` - Claude Code integration
2. `PROJECT_URL` - GitHub Projects v2 board
3. `GITHUB_TOKEN` - Auto-provided by GitHub Actions

**Storage**:
- GitHub repository secrets (encrypted at rest)
- Scoped to repository only
- Not accessible to forks
- Masked in logs

**Best Practices**:
```yaml
# ✅ Good: Secret only in workflow
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

# ❌ Bad: Secret in code
env:
  API_KEY: "sk-ant-..."  # Never hardcode!

# ✅ Good: Validate secret format
- name: Validate API key
  run: |
    if [[ ! "${{ secrets.ANTHROPIC_API_KEY }}" =~ ^sk-ant- ]]; then
      echo "Invalid API key format"
      exit 1
    fi
```

**Rotation**:
- Rotate ANTHROPIC_API_KEY every 90 days
- Use GitHub API tokens with minimum permissions
- Audit secret usage regularly

---

### Permission Model (Least Privilege)

**Workflow Permissions**:

```yaml
# Default: Read-only
permissions:
  contents: read

# Add permissions as needed
permissions:
  contents: read        # Read repository content
  pull-requests: write  # Create PR comments
  issues: write         # Create/update issues
  statuses: write       # Update commit statuses
```

**Progressive Permissions**:
- Start with minimal permissions
- Add only what's needed
- Document why each permission is required

**Examples**:

**bootstrap.yml** (setup):
```yaml
permissions:
  contents: write   # Create labels, configure repo
  issues: write     # Create milestone
```

**pr-into-dev.yml** (validation):
```yaml
permissions:
  contents: read        # Read code
  pull-requests: write  # Post comments
  issues: read          # Validate linked issues
```

**release-status-sync.yml** (deployment):
```yaml
permissions:
  contents: write   # Create GitHub release
  issues: write     # Close issues
  pull-requests: read  # Read merged PRs
```

---

### Fork Safety Implementation

**Detection**:
```yaml
- name: Check if PR is from fork
  id: fork-check
  run: |
    IS_FORK=${{ github.event.pull_request.head.repo.fork }}
    echo "is-fork=$IS_FORK" >> $GITHUB_OUTPUT
```

**Conditional Execution**:
```yaml
- name: Update project board
  if: steps.fork-check.outputs.is-fork != 'true'
  run: |
    # Safe to run write operations
```

**User Communication**:
```yaml
- name: Log fork status
  run: |
    if [[ "$IS_FORK" == "true" ]]; then
      echo "⚠️  Fork PR detected - write operations disabled"
    fi
```

---

### Rate Limiting Strategy

**Circuit Breaker Pattern**:

```yaml
- name: Check API rate limit
  id: rate-limit
  uses: ./.github/actions/rate-limit-check
  with:
    minimum-remaining: 100

- name: Fail if rate limit too low
  if: steps.rate-limit.outputs.can-proceed != 'true'
  run: |
    echo "❌ Rate limit too low: ${{ steps.rate-limit.outputs.remaining }}"
    echo "Resets at: ${{ steps.rate-limit.outputs.reset-time }}"
    exit 1
```

**Exponential Backoff**:
```yaml
- name: Retry with backoff
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_wait_seconds: 30
    command: gh api /repos/$REPO/issues
```

**Batching**:
```javascript
// Create issues in batches of 3 with delays
for (let i = 0; i < issues.length; i += 3) {
  const batch = issues.slice(i, i + 3);
  await Promise.all(batch.map(createIssue));
  await sleep(1000); // 1 second between batches
}
```

---

### Idempotency Guarantees

**Principle**: Operations should be safe to retry without side effects.

**Implementation Examples**:

**Label Creation** (bootstrap.yml):
```bash
# Check if label exists before creating
if ! gh label list | grep -q "claude-code"; then
  gh label create "claude-code" --color "0e8a16"
else
  echo "Label already exists, skipping"
fi
```

**Issue Creation** (claude-plan-to-issues.yml):
```javascript
// Check for existing issue with same title
const existing = await github.rest.issues.listForRepo({
  state: 'all'
}).then(({data}) => data.find(i => i.title === task.title));

if (existing) {
  console.log(`Issue already exists: #${existing.number}`);
  continue; // Skip creation
}
```

**Branch Creation** (create-branch-on-issue.yml):
```bash
# Check if branch exists
if git rev-parse --verify "feature/issue-$NUMBER" 2>/dev/null; then
  echo "Branch already exists"
  exit 0
fi

# Create branch
git checkout -b "feature/issue-$NUMBER"
```

---

## Scalability Considerations

### API Rate Limits

**GitHub API Limits**:
- **REST API**: 5,000 requests/hour (authenticated)
- **GraphQL API**: 5,000 points/hour (costs vary by query)
- **Search API**: 30 requests/minute

**Mitigation Strategies**:

**1. Caching**:
```yaml
- name: Cache API responses
  uses: actions/cache@v4
  with:
    path: ~/.gh-cache
    key: api-cache-${{ hashFiles('**/queries.json') }}
```

**2. Conditional Requests (ETags)**:
```bash
# Use ETags to avoid fetching unchanged data
ETAG=$(gh api /repos/$REPO/issues --include | grep -i etag)
gh api /repos/$REPO/issues --header "If-None-Match: $ETAG"
# Returns 304 Not Modified if unchanged (doesn't count against rate limit)
```

**3. Batching**:
```javascript
// GraphQL allows multiple queries in one request
query {
  issue1: repository(...) { issue(number: 1) { ... } }
  issue2: repository(...) { issue(number: 2) { ... } }
  issue3: repository(...) { issue(number: 3) { ... } }
}
```

**4. Pagination**:
```javascript
// Use pagination for large result sets
const allIssues = await github.paginate(
  github.rest.issues.listForRepo,
  { owner, repo, per_page: 100 }
);
```

---

### Concurrent Workflow Execution

**Challenge**: Multiple workflows can run simultaneously.

**Concurrency Control**:

```yaml
# Cancel in-progress runs for same PR
concurrency:
  group: pr-checks-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

**Benefits**:
- Saves compute resources
- Faster feedback (newest code only)
- Prevents race conditions

**Grouping Strategies**:

**By PR**:
```yaml
group: pr-${{ github.event.pull_request.number }}
```

**By Branch**:
```yaml
group: branch-${{ github.ref }}
```

**By Workflow**:
```yaml
group: ${{ github.workflow }}-${{ github.ref }}
```

---

### Caching Strategy

**What to Cache**:
- ✅ node_modules (pnpm cache)
- ✅ Build artifacts (.next, dist)
- ✅ Test coverage reports
- ❌ API responses (stale quickly)
- ❌ Secrets (security risk)

**Implementation**:

**pnpm Cache**:
```yaml
- name: Cache pnpm store
  uses: actions/cache@v4
  with:
    path: ~/.pnpm-store
    key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}
    restore-keys: |
      ${{ runner.os }}-pnpm-
```

**Build Cache**:
```yaml
- name: Cache Next.js build
  uses: actions/cache@v4
  with:
    path: .next/cache
    key: ${{ runner.os }}-nextjs-${{ hashFiles('**/pnpm-lock.yaml') }}
```

**Cache Hit Rate**:
- Target: 80%+ hit rate
- Monitor via workflow logs
- Invalidate cache when dependencies change

---

### Performance Optimization

**Workflow Execution Time**:

**Target**:
- PR validation: <2 minutes
- Plan-to-issues: <30 seconds
- Status sync: <5 seconds

**Optimizations**:

**1. Parallel Jobs**:
```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
  test:
    runs-on: ubuntu-latest
  build:
    runs-on: ubuntu-latest
# All run in parallel
```

**2. Matrix Strategy**:
```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
# Tests run in parallel across versions
```

**3. Path Filtering**:
```yaml
- uses: dorny/paths-filter@v3
  id: changes
  with:
    filters: |
      frontend:
        - 'src/**'

- name: Frontend tests
  if: steps.changes.outputs.frontend == 'true'
  run: npm run test:frontend
# Only run frontend tests if frontend code changed
```

**4. Fail-Fast**:
```yaml
strategy:
  fail-fast: true
# Stop all jobs if one fails (for validation)
```

---

## Technical Constraints

### GitHub Actions Limitations

**Workflow Limits**:
- Max 35 days retention for logs/artifacts
- Max 20 concurrent jobs (free tier)
- Max 6 hours per workflow run
- Max 1000 API requests per workflow run

**Runner Limits**:
- 7GB RAM (ubuntu-latest)
- 14GB disk space
- 2 CPU cores

**Workarounds**:

**Long Workflows**:
- Split into multiple workflows
- Use self-hosted runners (if needed)

**Storage**:
- Upload artifacts to external storage (S3, etc.)
- Clean up old artifacts regularly

**Concurrency**:
- Use workflow queues
- Implement retry logic

---

### GitHub Projects v2 Constraints

**GraphQL Only**:
- No REST API available
- Must use GraphQL for all operations
- More complex queries

**Rate Limiting**:
- GraphQL queries cost "points"
- Complex queries cost more
- 5,000 points/hour limit

**Field Types**:
- Limited to predefined types (text, number, date, single-select, iteration)
- Can't create custom field types
- Single-select fields limited to 50 options

**Workarounds**:

**Complex Queries**:
- Cache query results
- Use fragments to reuse query parts
- Batch multiple queries

**Custom Fields**:
- Use text fields with JSON
- Create multiple single-select fields
- Document field formats

---

### Claude Code Action v1 GA

**Capabilities**:
- Execute slash commands
- Run agents
- Access repository context
- Call GitHub APIs

**Limitations**:
- Max 5-minute execution time per command
- No direct file system access (uses Read/Write tools)
- Rate-limited by GitHub Actions

**Best Practices**:
- Keep commands focused and fast
- Use workflow dispatch for long operations
- Validate inputs before processing
- Provide clear error messages

---

## Future Enhancements

### Planned Improvements

**1. Visual Workflow Designer**
- Web UI for creating/editing workflows
- Drag-and-drop interface
- Preview generated YAML
- Template library

**2. Advanced Analytics**
- Workflow success rates
- Average PR time to merge
- Issue cycle time
- Developer productivity metrics

**3. Multi-Repository Support**
- Shared workflows across repos
- Organization-level configuration
- Centralized monitoring

**4. Enhanced AI Integration**
- Auto-generate PR descriptions
- Suggest code reviewers
- Predict PR merge time
- Auto-fix linting issues

**5. Mobile App Integration**
- Push notifications for PR reviews
- Quick approve/reject PRs
- View workflow status
- Emergency controls

---

### Potential Optimizations

**1. Workflow Deduplication**
- Detect duplicate workflows
- Suggest consolidation
- Reduce execution time

**2. Smart Caching**
- ML-based cache invalidation
- Predictive cache warming
- Multi-level caching

**3. Advanced Concurrency**
- Dynamic concurrency limits
- Priority queues
- Resource pooling

**4. Cost Optimization**
- Analyze GitHub Actions usage
- Suggest cheaper alternatives
- Optimize runner selection

---

### Experimental Features

**1. Feature Flags Integration**
- LaunchDarkly/ConfigCat support
- Gradual rollouts
- A/B testing

**2. Automated Dependency Updates**
- Beyond Dependabot
- Security-first updates
- Auto-merge safe updates
- Rollback on failures

**3. Deployment Previews**
- Auto-deploy to preview environments
- Visual regression testing
- Performance benchmarking

**4. Code Coverage Tracking**
- Historical coverage trends
- Coverage gates
- Uncovered code highlights

---

## Summary

### Architecture Strengths

✅ **Modular**: Clear separation of concerns
✅ **Scalable**: Handles growth in users and workflows
✅ **Secure**: Multiple layers of protection
✅ **Performant**: Optimized for speed
✅ **Maintainable**: DRY principles, well-documented
✅ **Flexible**: Supports multiple workflows and strategies
✅ **Observable**: Clear logging and error messages

### Key Takeaways

1. **Simplicity Over Cleverness**: Easy to understand = easy to maintain
2. **Safety First**: Multiple layers prevent destructive operations
3. **Progressive Disclosure**: Simple defaults, advanced options available
4. **Idempotency**: Safe to retry operations
5. **Observable**: Clear feedback at every step
6. **Flexible**: Supports solo developers to enterprises
7. **Future-Proof**: Built on stable, well-supported technologies

---

**This architecture is designed to scale from solo developers to enterprise teams while maintaining simplicity, security, and performance.**

---

**Last Updated**: 2025-11-06
**Version**: 1.0.0
