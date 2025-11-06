# Workflows Reference

**Complete reference for all GitHub Actions workflows in the Blueprint**

This guide documents all 8 core workflows that automate your development lifecycle from planning to deployment.

---

## Table of Contents

- [Overview](#overview)
- [Workflow Execution Order](#workflow-execution-order)
- [Quick Reference Table](#quick-reference-table)
- [Detailed Workflow Documentation](#detailed-workflow-documentation)
  - [1. bootstrap.yml](#1-bootstrapyml)
  - [2. reusable-pr-checks.yml](#2-reusable-pr-checksyml)
  - [3. pr-into-dev.yml](#3-pr-into-devyml)
  - [4. dev-to-main.yml](#4-dev-to-mainyml)
  - [5. claude-plan-to-issues.yml](#5-claude-plan-to-issuesyml)
  - [6. create-branch-on-issue.yml](#6-create-branch-on-issueyml)
  - [7. pr-status-sync.yml](#7-pr-status-syncyml)
  - [8. release-status-sync.yml](#8-release-status-syncyml)
- [Workflow Relationships](#workflow-relationships)
- [Best Practices](#best-practices)
- [Common Customizations](#common-customizations)
- [Troubleshooting](#troubleshooting)

---

## Overview

The GitHub Workflow Blueprint includes 8 specialized workflows that work together to automate your complete development lifecycle:

### Core Workflows

1. **bootstrap.yml** - One-time repository setup
2. **reusable-pr-checks.yml** - Reusable quality gates (DRY)
3. **pr-into-dev.yml** - Feature/fix PR validation
4. **dev-to-main.yml** - Release gates for production
5. **claude-plan-to-issues.yml** - Convert Claude plans to GitHub issues
6. **create-branch-on-issue.yml** - Auto-create branches from issues
7. **pr-status-sync.yml** - Sync PR lifecycle with issues
8. **release-status-sync.yml** - Close issues on production deployment

### Key Features

- ✅ **Automated Quality Gates** - Lint, type-check, and test before merge
- ✅ **Project Board Integration** - Bidirectional sync with GitHub Projects v2
- ✅ **Branch Management** - Auto-create and cleanup branches
- ✅ **Issue Tracking** - Automatic status updates throughout lifecycle
- ✅ **Fork Safety** - Read-only operations for fork PRs
- ✅ **Rate Limit Protection** - Circuit breakers prevent API exhaustion
- ✅ **Idempotent Operations** - Safe to run multiple times

---

## Workflow Execution Order

```
┌─────────────────────────────────────────────────────────────┐
│ SETUP PHASE                                                  │
└─────────────────────────────────────────────────────────────┘
    │
    └──> bootstrap.yml (manual, one-time)
         │
         └──> Creates labels, validates project board, sets up repo
              │
              │
┌─────────────────────────────────────────────────────────────┐
│ PLANNING PHASE                                               │
└─────────────────────────────────────────────────────────────┘
              │
              └──> claude-plan-to-issues.yml (manual)
                   │
                   └──> Creates max 10 issues with labels + milestone
                        │
                        │
┌─────────────────────────────────────────────────────────────┐
│ DEVELOPMENT PHASE                                            │
└─────────────────────────────────────────────────────────────┘
                        │
                        └──> create-branch-on-issue.yml (on label)
                             │
                             └──> Auto-creates feature/fix/hotfix branch
                                  └──> Updates project status: In Progress
                                       │
                                       └──> Developer commits to branch
                                            │
                                            └──> Creates PR to dev
                                                 │
┌─────────────────────────────────────────────────────────────┐
│ REVIEW PHASE                                                 │
└─────────────────────────────────────────────────────────────┘
                                                 │
                                                 └──> pr-into-dev.yml (on PR open)
                                                      ├──> Validates branch name
                                                      ├──> Validates PR title (conventional)
                                                      ├──> Validates linked issues
                                                      └──> Calls reusable-pr-checks.yml
                                                           ├──> Lint
                                                           ├──> Type check
                                                           ├──> Unit tests
                                                           └──> Integration tests (optional)
                                                      │
                                                      └──> pr-status-sync.yml (on PR events)
                                                           └──> Updates issues: In Review
                                                                │
                                                                └──> PR merged to dev
                                                                     ├──> Deletes source branch
                                                                     └──> Updates issues: To Deploy
                                                                          │
┌─────────────────────────────────────────────────────────────┐
│ RELEASE PHASE                                                │
└─────────────────────────────────────────────────────────────┘
                                                                          │
                                                                          └──> Create release PR (dev → main)
                                                                               │
                                                                               └──> dev-to-main.yml (on PR open)
                                                                                    ├──> Production build
                                                                                    ├──> Smoke tests
                                                                                    ├──> Security scan
                                                                                    └──> Deployment readiness
                                                                                    │
                                                                                    └──> PR merged to main
                                                                                         │
                                                                                         └──> release-status-sync.yml (on merge)
                                                                                              ├──> Closes all linked issues
                                                                                              ├──> Updates project: Done
                                                                                              ├──> Creates GitHub release
                                                                                              └──> Adds release comments
```

---

## Quick Reference Table

| Workflow | Trigger | Purpose | Duration |
|----------|---------|---------|----------|
| **bootstrap.yml** | Manual (`workflow_dispatch`) | One-time repository setup | ~30s |
| **reusable-pr-checks.yml** | Called by other workflows | DRY quality checks (lint, test, typecheck) | 1-2 min |
| **pr-into-dev.yml** | PR opened to `dev` | Validate feature/fix PRs | 1-3 min |
| **dev-to-main.yml** | PR opened to `main` | Release gates for production | 2-5 min |
| **claude-plan-to-issues.yml** | Manual (`workflow_dispatch`) | Convert Claude plans to issues | 10-30s |
| **create-branch-on-issue.yml** | Issue labeled | Auto-create feature branches | 5-10s |
| **pr-status-sync.yml** | PR events (open, close, draft) | Sync PR lifecycle with issues | 5-10s |
| **release-status-sync.yml** | PR merged to `main` | Close issues and update project | 10-20s |

---

## Detailed Workflow Documentation

### 1. bootstrap.yml

**One-time repository setup**

#### Purpose

Initializes your repository with all required labels, validates project board configuration, and verifies secrets are properly set.

#### When to Run

- **First time setup**: After cloning the blueprint
- **After major changes**: If you need to recreate labels
- **Troubleshooting**: To validate configuration

#### Trigger

```yaml
on:
  workflow_dispatch:
    inputs:
      create_milestone:
        description: 'Create initial milestone (optional)'
        required: false
        type: boolean
        default: false
      milestone_title:
        description: 'Milestone title (if creating)'
        required: false
        type: string
        default: 'Sprint 1'
      milestone_due_date:
        description: 'Milestone due date (YYYY-MM-DD, optional)'
        required: false
        type: string
```

**How to trigger**: Go to **Actions** → **Bootstrap Repository** → **Run workflow**

#### Permissions

```yaml
permissions:
  contents: read
  issues: write
  pull-requests: write
```

#### What It Does

1. **Validates Required Secrets**
   - `ANTHROPIC_API_KEY` - Claude Code API key
   - `PROJECT_URL` - GitHub Projects v2 board URL
   - `GITHUB_TOKEN` - Automatically provided

2. **Creates Required Labels** (23 total)
   - **Status**: `status:to-triage`, `status:ready`, `status:in-progress`, `status:in-review`, `status:to-deploy`
   - **Type**: `type:feature`, `type:fix`, `type:hotfix`, `type:docs`, `type:refactor`, `type:test`
   - **Platform**: `platform:web`, `platform:mobile`, `platform:fullstack`
   - **Priority**: `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
   - **Meta**: `claude-code`, `automerge`, `dependencies`

3. **Validates Project Board**
   - Extracts project ID from `PROJECT_URL`
   - Verifies `Status` field exists
   - Lists available status options
   - Checks GraphQL connectivity

4. **Creates Initial Milestone** (optional)
   - Only if `create_milestone` input is `true`
   - Uses provided `milestone_title` and `milestone_due_date`
   - Idempotent (skips if milestone already exists)

5. **Generates Summary Report**
   - Shows validation results
   - Lists created/skipped labels
   - Displays project board details
   - Provides next steps

#### Example Usage

**Basic setup (no milestone)**:
```bash
# Via GitHub Actions UI
Actions → Bootstrap Repository → Run workflow
```

**With milestone**:
```yaml
# Inputs in GitHub Actions UI
create_milestone: true
milestone_title: "Sprint 1 - MVP Features"
milestone_due_date: "2025-12-31"
```

**Via GitHub CLI**:
```bash
gh workflow run bootstrap.yml \
  -f create_milestone=true \
  -f milestone_title="Sprint 1" \
  -f milestone_due_date="2025-12-31"
```

#### Configuration

**Required Secrets** (in repository settings):
```
ANTHROPIC_API_KEY=sk-ant-...
PROJECT_URL=https://github.com/users/USERNAME/projects/1
# or
PROJECT_URL=https://github.com/orgs/ORGNAME/projects/1
```

**Setting secrets**:
```bash
# Via GitHub CLI
gh secret set ANTHROPIC_API_KEY
# Paste your API key when prompted

gh secret set PROJECT_URL
# Paste your project board URL when prompted
```

#### Troubleshooting

**Problem**: `❌ ANTHROPIC_API_KEY is not set`

**Solution**:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `ANTHROPIC_API_KEY`
4. Value: Your Claude API key (get from https://console.anthropic.com/)
5. Click **Add secret**

---

**Problem**: `❌ Invalid PROJECT_URL format`

**Solution**: PROJECT_URL must match one of these formats:
```
https://github.com/users/USERNAME/projects/NUMBER
https://github.com/orgs/ORGNAME/projects/NUMBER
```

To find your project URL:
1. Go to your GitHub project board
2. Copy the URL from your browser
3. Ensure it's the v2 project format (not classic projects)

---

**Problem**: `❌ 'Status' field not found in project board`

**Solution**:
1. Open your GitHub project board
2. Click **Settings** (⚙️) → **Fields**
3. Create a new **Single select** field named `Status`
4. Add these options (recommended):
   - To triage
   - Backlog
   - Ready
   - In Progress
   - In Review
   - To Deploy
   - Done
5. Save and re-run bootstrap

---

**Problem**: `Label already exists` warnings

**Solution**: This is **normal and safe**. The workflow is idempotent - it skips existing labels and only creates missing ones. No action needed.

---

#### Success Indicators

✅ All secrets validated
✅ 23 labels created (or already exist)
✅ Project board validated
✅ Status field found
✅ Milestone created (if requested)

#### Next Steps After Bootstrap

1. **Create your first issue** using the `plan-task` or `manual-task` template
2. **Label it** with `claude-code` + `status:ready` to trigger auto-branch creation
3. **Start working** on your feature branches
4. **Create PRs** to `dev` branch

---

### 2. reusable-pr-checks.yml

**Reusable quality gates workflow (DRY)**

#### Purpose

Provides a centralized, reusable workflow for running quality checks (lint, typecheck, tests) on pull requests. Used by other workflows to avoid code duplication.

#### Trigger

```yaml
on:
  workflow_call:
    inputs:
      mobile_check:
        description: 'Run mobile platform checks (iOS/Android)'
        type: boolean
        default: false
      integration_tests:
        description: 'Run integration tests'
        type: boolean
        default: false
      node_version:
        description: 'Node.js version to use'
        type: string
        default: '20'
      pnpm_version:
        description: 'pnpm version to use'
        type: string
        default: '9'
      working_directory:
        description: 'Working directory for checks'
        type: string
        default: '.'
```

**Not triggered directly** - called by other workflows like `pr-into-dev.yml`.

#### Permissions

```yaml
permissions:
  contents: read
  pull-requests: read
```

#### What It Does

1. **Path Filtering** (Smart Execution)
   - Detects which files changed in the PR
   - Only runs relevant checks based on paths
   - Skips checks if only docs changed
   - Separate detection for web, mobile, tests

2. **Quality Checks** (Parallel Execution)
   - **Lint**: ESLint + Prettier validation
   - **Type Check**: TypeScript compilation check
   - **Unit Tests**: Jest/Vitest with coverage
   - **Integration Tests**: Optional, enabled via input
   - **Mobile Checks**: Optional iOS/Android build validation

3. **Caching Strategy**
   - Caches `node_modules` based on lock file hash
   - Caches Gradle builds (Android)
   - Caches CocoaPods (iOS)
   - **90%+ speed improvement** on cache hits

4. **Artifacts on Failure**
   - Uploads lint reports, test results, coverage
   - 2-day retention for debugging
   - Only uploaded on failure to save storage

5. **Summary Report**
   - Shows pass/fail status for each check
   - Aggregates results in one place
   - Fails workflow if any check fails

#### Example Usage

**Called from another workflow**:
```yaml
jobs:
  quality-checks:
    uses: ./.github/workflows/reusable-pr-checks.yml
    with:
      mobile_check: false
      integration_tests: false
      node_version: '20'
      pnpm_version: '9'
```

**With mobile checks enabled**:
```yaml
jobs:
  quality-checks:
    uses: ./.github/workflows/reusable-pr-checks.yml
    with:
      mobile_check: true
      integration_tests: true
      node_version: '20'
      pnpm_version: '9'
```

#### Configuration

**Required package.json scripts**:
```json
{
  "scripts": {
    "lint": "eslint .",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:unit": "jest --testPathIgnorePatterns=integration",
    "test:integration": "jest --testPathPattern=integration",
    "format:check": "prettier --check ."
  }
}
```

**Optional scripts** (auto-detected):
```json
{
  "scripts": {
    "prettier:check": "prettier --check .",
    "typecheck": "tsc --noEmit",
    "ios:build": "react-native build-ios",
    "android:build": "cd android && ./gradlew assembleRelease"
  }
}
```

#### Path Filters

The workflow uses smart path filtering to skip unnecessary checks:

| Category | Paths | Checks Run |
|----------|-------|------------|
| **Web** | `src/`, `lib/`, `*.ts`, `*.tsx`, `package.json` | Lint, TypeCheck, Tests |
| **Mobile** | `mobile/`, `ios/`, `android/`, `*.swift`, `*.kt` | Mobile Build |
| **Tests** | `**/*.test.ts`, `**/*.spec.ts`, `__tests__/` | Tests Only |
| **Docs Only** | `**.md`, `docs/` | **All Skipped** |

#### Troubleshooting

**Problem**: `❌ ESLint not found`

**Solution**: Add ESLint to your project:
```bash
pnpm add -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

Create `.eslintrc.json`:
```json
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"]
}
```

---

**Problem**: `❌ Type check failed`

**Solution**: Fix TypeScript errors or adjust `tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": false,
    "noEmit": true
  }
}
```

---

**Problem**: Cache not working (slow installs)

**Solution**: Verify `pnpm-lock.yaml` is committed:
```bash
git add pnpm-lock.yaml
git commit -m "chore: add pnpm lock file"
```

---

**Problem**: Mobile checks failing

**Solution**: Ensure mobile setup is correct or disable mobile checks:
```yaml
with:
  mobile_check: false
```

---

#### Performance Optimization

**First run** (no cache):
- Install dependencies: ~2 minutes
- Lint: ~30 seconds
- Type check: ~20 seconds
- Tests: ~1 minute
- **Total**: ~4 minutes

**Subsequent runs** (with cache):
- Install dependencies: ~10 seconds ✅
- Lint: ~15 seconds
- Type check: ~10 seconds
- Tests: ~30 seconds
- **Total**: ~1-2 minutes ✅

**90%+ improvement with caching!**

---

### 3. pr-into-dev.yml

**Feature/fix PR validation before merging to dev**

#### Purpose

Validates all pull requests into the `dev` branch to ensure they meet quality standards, follow conventions, and have proper issue linking before merge.

#### Trigger

```yaml
on:
  pull_request:
    types:
      - opened
      - synchronize
      - ready_for_review
    branches:
      - dev
```

**Triggers when**: A PR targeting `dev` is opened, updated, or marked ready for review.

#### Permissions

```yaml
permissions:
  contents: read
  pull-requests: write
  issues: read
  statuses: write
```

#### What It Does

1. **Fork Safety Check**
   - Detects if PR is from a fork
   - Skips write operations for fork PRs (security)
   - Allows read-only checks to run

2. **Branch Name Validation**
   - Must start with `feature/`, `fix/`, or `hotfix/`
   - Example: `feature/issue-123-add-user-auth`
   - Rejects PRs from other branch patterns

3. **PR Title Validation (Conventional Commits)**
   - Must follow: `type(scope): Subject`
   - Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
   - Subject must start with uppercase
   - Scope is optional
   - Adds helpful comment if validation fails

4. **Linked Issue Validation**
   - Requires at least one linked issue in PR body
   - Accepts: `Closes #123`, `Fixes #456`, `Resolves #789`, `Relates to #101`
   - Adds helpful comment if missing

5. **Rate Limit Check**
   - Ensures 50+ API calls remaining
   - Circuit breaker prevents API exhaustion
   - Shows remaining calls in logs

6. **Quality Checks**
   - Calls `reusable-pr-checks.yml`
   - Runs lint, typecheck, unit tests
   - Mobile and integration tests (optional)

7. **Final Status**
   - Aggregates all validation results
   - Shows summary in PR
   - Fails if any check fails

#### Example Usage

**Valid PR**:
```markdown
Title: feat(auth): Add user authentication

Body:
## Summary
This PR implements user authentication with JWT tokens.

## Changes
- Add login endpoint
- Add JWT middleware
- Add user model

Closes #123
Fixes #124
```

✅ **Result**: All checks pass, ready to merge

---

**Invalid PR (wrong title)**:
```markdown
Title: added authentication

Body:
Implemented auth system
```

❌ **Result**: PR title validation fails, bot comments with help

---

**Invalid PR (no linked issue)**:
```markdown
Title: feat(auth): Add authentication

Body:
Implemented auth system
```

❌ **Result**: Linked issue validation fails, bot comments with help

---

#### Configuration

**Enable/disable mobile checks**:

Edit `.github/workflows/pr-into-dev.yml`:
```yaml
uses: ./.github/workflows/reusable-pr-checks.yml
with:
  mobile_check: true  # Set to false to disable
  integration_tests: true  # Set to false to disable
```

**Change Node.js version**:
```yaml
with:
  node_version: '18'  # or '20', '21'
  pnpm_version: '8'   # or '9'
```

#### Troubleshooting

**Problem**: `❌ Invalid branch name: my-feature`

**Solution**: Rename your branch to follow convention:
```bash
git branch -m feature/issue-123-my-feature
git push origin -d my-feature  # Delete old branch
git push origin feature/issue-123-my-feature
```

---

**Problem**: `❌ PR title doesn't follow conventional commit format`

**Solution**: Edit your PR title to match format:
```
feat: Add new feature
feat(auth): Add user authentication
fix(api): Resolve null pointer exception
docs: Update README
```

See bot comment for full list of valid types.

---

**Problem**: `❌ No linked issues found`

**Solution**: Edit your PR description and add:
```markdown
Closes #123
```

or

```markdown
Fixes #456
Relates to #789
```

---

**Problem**: Fork PR not running checks

**Solution**: This is **expected behavior** for security. Fork PRs run read-only checks but skip write operations. If you're a maintainer, you can manually approve workflow runs for fork PRs.

---

#### Best Practices

✅ **DO**:
- Use conventional commit format for PR titles
- Link at least one issue in PR description
- Wait for all checks to pass before requesting review
- Fix lint/test failures promptly

❌ **DON'T**:
- Merge PRs with failing checks
- Skip linking issues (breaks automation)
- Use generic PR titles like "updates" or "changes"
- Force-push after PR is opened (breaks checks)

---

### 4. dev-to-main.yml

**Release gates for production deployment**

#### Purpose

Validates release pull requests (dev → main) to ensure production readiness with additional checks beyond regular PRs.

#### Trigger

```yaml
on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
    branches:
      - main
```

**Triggers when**: A PR targeting `main` is opened or updated.

#### Permissions

```yaml
permissions:
  contents: read
  pull-requests: write
  statuses: write
```

#### What It Does

1. **Source Branch Validation**
   - Ensures source is `dev` branch only
   - Rejects PRs from other branches
   - Enforces `dev → main` release flow

2. **Production Build**
   - Runs production build: `npm run build:prod`
   - Verifies build artifacts exist
   - Uploads build artifacts (7-day retention)
   - Checks build size and file count

3. **Smoke Tests**
   - Runs critical path smoke tests
   - Tries: `npm run test:smoke`, `npm run test:e2e:smoke`
   - Falls back to basic sanity checks
   - Validates build artifacts present

4. **Security Quick Scan** (Informational Only)
   - Runs `npm audit` for vulnerabilities
   - Checks for hardcoded secrets (basic regex)
   - Checks for `console.log` and `debugger` statements
   - **Non-blocking** - warnings only

5. **Deployment Readiness**
   - Checks version in `package.json`
   - Looks for changelog file
   - Generates pre-deployment checklist
   - Shows release information

6. **Final Status**
   - Aggregates all release gate results
   - Shows comprehensive summary
   - Provides next steps for deployment

#### Example Usage

**Create release PR**:
```bash
# From dev branch
git checkout dev
git pull origin dev

# Create PR to main
gh pr create \
  --base main \
  --head dev \
  --title "release: Version 1.2.0" \
  --body "$(cat CHANGELOG.md | head -50)"
```

**Or use the `/release` slash command**:
```bash
/release
```

#### Configuration

**Required package.json scripts**:
```json
{
  "scripts": {
    "build": "next build",
    "build:prod": "NODE_ENV=production next build"
  }
}
```

**Optional scripts**:
```json
{
  "scripts": {
    "test:smoke": "jest --testNamePattern='smoke'",
    "test:e2e:smoke": "playwright test smoke/"
  }
}
```

#### Production Build Directories

The workflow checks for build outputs in these directories (in order):
1. `dist/` - Vite, Rollup, esbuild
2. `build/` - Create React App, Parcel
3. `out/` - Next.js (static export)
4. `.next/` - Next.js (server)

#### Smoke Tests

**What are smoke tests?**
Smoke tests are **critical path tests** that verify the most important features work:

**Example smoke tests**:
```typescript
describe('smoke tests', () => {
  it('should load the homepage', async () => {
    const response = await fetch('http://localhost:3000');
    expect(response.status).toBe(200);
  });

  it('should authenticate user', async () => {
    const result = await login('test@example.com', 'password');
    expect(result.success).toBe(true);
  });

  it('should process payment', async () => {
    // Critical payment flow test
  });
});
```

If no smoke tests exist, workflow validates build artifacts as basic sanity.

#### Security Quick Scan

**What it checks**:
1. **npm audit**: High/critical vulnerabilities
2. **Hardcoded secrets**: Patterns like `API_KEY`, `password`, `token`
3. **Debug statements**: `console.log`, `debugger`

**Note**: This is **informational only** and does **not block** the release. Review warnings and address before deploying.

#### Deployment Readiness Checklist

Before merging release PR, ensure:

- [ ] Version bumped in `package.json`
- [ ] Changelog updated with release notes
- [ ] All linked issues are tested
- [ ] Breaking changes documented
- [ ] Migration guide provided (if needed)
- [ ] Deployment plan reviewed
- [ ] Rollback plan documented
- [ ] Stakeholders notified

#### Troubleshooting

**Problem**: `❌ Invalid source branch: feature/my-feature`

**Solution**: Only `dev → main` PRs are allowed for releases:
```bash
# Close current PR
gh pr close

# Create correct release PR from dev
git checkout dev
gh pr create --base main --head dev
```

---

**Problem**: `❌ Production build failed`

**Solution**: Fix build errors locally first:
```bash
npm run build:prod
# Fix any errors
npm run build:prod  # Verify it works
git add .
git commit -m "fix: resolve production build issues"
git push
```

---

**Problem**: `❌ Smoke tests failed`

**Solution**: Run smoke tests locally:
```bash
npm run test:smoke
# Fix failing tests
npm run test:smoke  # Verify they pass
git add .
git commit -m "fix: resolve smoke test failures"
git push
```

---

**Problem**: `⚠️ No smoke tests found`

**Solution**: This is **not an error**. The workflow will validate build artifacts instead. To add smoke tests:

```bash
# Install playwright (or use jest)
pnpm add -D @playwright/test

# Create smoke test
mkdir -p tests/smoke
cat > tests/smoke/critical-paths.spec.ts << EOF
import { test, expect } from '@playwright/test';

test('homepage loads', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await expect(page).toHaveTitle(/My App/);
});
EOF

# Add script
# package.json:
# "test:e2e:smoke": "playwright test tests/smoke"
```

---

**Problem**: Security scan shows warnings

**Solution**: Review warnings in workflow logs:
```bash
# Check npm audit
npm audit

# Fix vulnerabilities
npm audit fix

# Or ignore false positives
npm audit --production  # Only check production deps
```

For hardcoded secrets/debug statements, search and remove:
```bash
grep -r "console.log" src/
grep -r "debugger" src/
```

---

#### Best Practices

✅ **DO**:
- Always release from `dev` branch
- Bump version before creating release PR
- Update changelog with all changes
- Run production build locally first
- Test critical paths thoroughly
- Review security scan warnings

❌ **DON'T**:
- Create release PRs from feature branches
- Skip version bumps
- Merge without smoke tests passing
- Ignore security warnings
- Deploy with failing builds

---

### 5. claude-plan-to-issues.yml

**Convert Claude Code plans (JSON) to GitHub issues**

#### Purpose

Transforms Claude Code planning output (JSON format) into organized GitHub issues with proper labels, milestones, dependencies, and project board integration.

#### Trigger

```yaml
on:
  workflow_dispatch:
    inputs:
      plan_json:
        description: 'Claude plan in JSON format'
        required: true
        type: string
      milestone_title:
        description: 'Milestone for these issues (optional)'
        required: false
        type: string
      create_milestone:
        description: 'Create milestone if it doesnt exist'
        required: false
        type: boolean
        default: true
```

**How to trigger**:
```bash
# Via GitHub Actions UI
Actions → Convert Claude Plan to Issues → Run workflow

# Or use /plan-to-issues slash command
/plan-to-issues path/to/plan.json
```

#### Permissions

```yaml
permissions:
  contents: read
  issues: write
  pull-requests: read
```

#### What It Does

1. **Validates Plan JSON**
   - Parses JSON input
   - Validates schema (tasks array, required fields)
   - Checks task count (max 10 enforced)
   - Shows clear error if invalid

2. **Rate Limit Check**
   - Requires 100+ API calls remaining
   - Circuit breaker prevents API exhaustion
   - Shows estimated API calls needed
   - Waits if close to limit

3. **Creates/Assigns Milestone** (optional)
   - Creates milestone if `create_milestone: true`
   - Assigns all issues to milestone
   - Uses `milestone_title` or extracts from plan
   - Idempotent (reuses existing)

4. **Generates GitHub Issues** (max 10)
   - Creates issue for each task
   - Sets title, description, acceptance criteria
   - Assigns labels based on task metadata
   - Links dependencies (`Depends on #123`)
   - Adds to project board in "Ready" status

5. **Label Assignment** (automatic)
   - `claude-code` (all issues)
   - `status:ready` (all issues)
   - `type:*` (feature/fix/docs/refactor/test)
   - `platform:*` (web/mobile/fullstack)
   - `priority:*` (critical/high/medium/low)

6. **Dependency Linking**
   - Parses `dependencies` array
   - Adds "Depends on #N" to description
   - Creates GitHub task lists
   - Shows blocking issues clearly

7. **Project Board Sync**
   - Adds all issues to project
   - Sets Status field to "Ready"
   - Uses GraphQL for efficiency
   - Handles bulk operations

8. **Summary Report**
   - Shows created issues with links
   - Shows milestone info
   - Shows project board link
   - Provides next steps

#### Example Usage

**Simple plan (3 tasks)**:
```json
{
  "milestone": "Sprint 1 - Authentication",
  "tasks": [
    {
      "title": "Add login endpoint",
      "description": "Create POST /api/auth/login endpoint with JWT token generation",
      "acceptanceCriteria": [
        "Accepts email and password",
        "Returns JWT token on success",
        "Returns 401 on invalid credentials"
      ],
      "type": "feature",
      "platform": "web",
      "priority": "high",
      "dependencies": []
    },
    {
      "title": "Add user authentication middleware",
      "description": "Create Express middleware to validate JWT tokens",
      "acceptanceCriteria": [
        "Validates JWT signature",
        "Attaches user object to request",
        "Returns 401 on invalid token"
      ],
      "type": "feature",
      "platform": "web",
      "priority": "high",
      "dependencies": [1]
    },
    {
      "title": "Add logout endpoint",
      "description": "Create POST /api/auth/logout endpoint",
      "acceptanceCriteria": [
        "Invalidates JWT token",
        "Returns 200 on success"
      ],
      "type": "feature",
      "platform": "web",
      "priority": "medium",
      "dependencies": [1, 2]
    }
  ]
}
```

**Trigger via GitHub Actions**:
```bash
# Save plan to file
cat > plan.json << EOF
{
  "milestone": "Sprint 1",
  "tasks": [...]
}
EOF

# Trigger workflow
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat plan.json)" \
  -f milestone_title="Sprint 1" \
  -f create_milestone=true
```

**Or use the `/plan-to-issues` slash command**:
```bash
/plan-to-issues plan.json
```

#### Configuration

**JSON Schema** (required fields):
```typescript
interface ClaudePlan {
  milestone?: string;
  tasks: Task[];  // Max 10
}

interface Task {
  title: string;  // Required
  description: string;  // Required
  acceptanceCriteria: string[];  // Required
  type: 'feature' | 'fix' | 'docs' | 'refactor' | 'test';  // Required
  platform: 'web' | 'mobile' | 'fullstack';  // Required
  priority: 'critical' | 'high' | 'medium' | 'low';  // Required
  dependencies?: number[];  // Optional, array of task indices
}
```

**Required repository secrets**:
```
PROJECT_URL=https://github.com/users/USERNAME/projects/1
```

#### Task Limit (Max 10)

**Why 10?**
- Prevents overwhelming GitHub API
- Encourages focused sprint planning
- Ensures manageable scope
- Allows room for manual issues

**If you have >10 tasks**:
1. Break plan into multiple sprints/milestones
2. Prioritize most critical tasks first
3. Run workflow multiple times with different subsets
4. Create remaining tasks manually

#### Troubleshooting

**Problem**: `❌ Invalid JSON format`

**Solution**: Validate JSON syntax:
```bash
# Validate locally
cat plan.json | jq .

# If error, fix JSON syntax
# Common issues: missing commas, trailing commas, unquoted keys
```

---

**Problem**: `❌ Too many tasks (limit: 10)`

**Solution**: Split into multiple plans:
```json
// plan-part1.json (tasks 1-10)
{
  "milestone": "Sprint 1 - Part 1",
  "tasks": [...]  // First 10 tasks
}

// plan-part2.json (tasks 11-20)
{
  "milestone": "Sprint 1 - Part 2",
  "tasks": [...]  // Next 10 tasks
}
```

---

**Problem**: `❌ Missing required field: type`

**Solution**: Ensure all tasks have required fields:
```json
{
  "title": "My task",  // ✅ Required
  "description": "Details",  // ✅ Required
  "acceptanceCriteria": ["..."],  // ✅ Required
  "type": "feature",  // ✅ Required
  "platform": "web",  // ✅ Required
  "priority": "high"  // ✅ Required
}
```

---

**Problem**: `⚠️ Rate limit low (10 remaining)`

**Solution**: Wait and retry:
```bash
# Check rate limit
gh api rate_limit

# Wait for reset (shown in response)
# Then retry workflow
```

---

**Problem**: `❌ PROJECT_URL not set`

**Solution**: Set project board URL secret:
```bash
gh secret set PROJECT_URL
# Paste: https://github.com/users/USERNAME/projects/1
```

---

#### Best Practices

✅ **DO**:
- Keep tasks focused and atomic
- Write clear acceptance criteria
- Set appropriate priorities
- Link dependencies correctly
- Use meaningful task titles
- Stay under 10 tasks per plan

❌ **DON'T**:
- Create duplicate issues (workflow checks)
- Exceed 10 tasks (hard limit)
- Use invalid types/platforms
- Forget acceptance criteria
- Skip priority assignment

---

### 6. create-branch-on-issue.yml

**Auto-create feature branches from labeled issues**

#### Purpose

Automatically creates properly-named feature branches when issues are marked as ready to work on, streamlining the development workflow.

#### Trigger

```yaml
on:
  issues:
    types:
      - labeled
```

**Triggers when**: An issue receives ANY label. Workflow then checks if BOTH required labels are present.

#### Permissions

```yaml
permissions:
  contents: write
  issues: write
  pull-requests: read
```

#### What It Does

1. **Label Validation**
   - Checks if issue has BOTH `claude-code` AND `status:ready` labels
   - Skips if either label missing
   - Skips if issue already has an associated branch

2. **Type Detection** (from labels)
   - Looks for `type:*` label
   - Determines branch prefix: `feature/`, `fix/`, `hotfix/`, etc.
   - Defaults to `feature/` if no type label

3. **Base Branch Detection**
   - Default: `dev` branch
   - Fallback: `main` if dev doesn't exist
   - Custom: Issue can have `base:staging` or `base:main` label
   - Validates base branch exists

4. **Branch Name Generation**
   - Format: `{type}/issue-{number}-{slug}`
   - Example: `feature/issue-123-add-user-authentication`
   - Slug: Kebab-case from issue title (max 50 chars)
   - Sanitized: Removes special characters

5. **Branch Creation**
   - Creates branch from base branch HEAD
   - Uses GitHub API (not git commands)
   - Idempotent: Skips if branch exists
   - Fails gracefully on errors

6. **Issue Comment**
   - Posts helpful instructions to issue
   - Includes branch name
   - Includes checkout command
   - Includes PR creation command

7. **Project Board Update**
   - Updates issue status to "In Progress"
   - Uses GraphQL for efficiency
   - Handles missing project gracefully

#### Example Usage

**Scenario: Issue created from plan**

1. Issue #123 created: "Add user authentication"
2. Labels automatically applied: `claude-code`, `status:ready`, `type:feature`, `platform:web`
3. Workflow triggers automatically
4. Branch created: `feature/issue-123-add-user-authentication`
5. Comment posted to issue with instructions

**Manual scenario**:

```bash
# Create issue
gh issue create \
  --title "Fix navigation bug" \
  --body "Navigation crashes on mobile" \
  --label "type:fix" \
  --label "platform:mobile"

# Add required labels to trigger branch creation
gh issue edit 123 \
  --add-label "claude-code" \
  --add-label "status:ready"

# Branch automatically created: fix/issue-123-fix-navigation-bug
```

#### Configuration

**Branch naming patterns**:

| Type Label | Branch Prefix | Example |
|------------|---------------|---------|
| `type:feature` | `feature/` | `feature/issue-123-add-auth` |
| `type:fix` | `fix/` | `fix/issue-456-resolve-crash` |
| `type:hotfix` | `hotfix/` | `hotfix/issue-789-security-patch` |
| `type:refactor` | `refactor/` | `refactor/issue-101-clean-code` |
| `type:docs` | `docs/` | `docs/issue-202-update-readme` |
| `type:test` | `test/` | `test/issue-303-add-unit-tests` |

**Base branch detection** (in order):

1. Check for `base:*` label (e.g., `base:staging`)
2. Try `dev` branch
3. Fall back to `main` branch

**Custom base branch**:
```bash
# Force branch to be created from staging
gh issue edit 123 --add-label "base:staging"
```

#### Checkout Instructions

After branch is created, the bot comments:

```markdown
## 🎉 Branch Created!

Your branch is ready: `feature/issue-123-add-user-authentication`

### Get Started

```bash
# Fetch and checkout the branch
git fetch origin
git checkout feature/issue-123-add-user-authentication

# Or create and track in one command
git checkout -b feature/issue-123-add-user-authentication origin/feature/issue-123-add-user-authentication

# Start working!
```

### When Ready

```bash
# Commit your changes
git add .
git commit -m "feat(auth): implement user authentication"

# Push to remote
git push origin feature/issue-123-add-user-authentication

# Create PR
gh pr create --base dev --fill
```

**Remember to link this issue in your PR description!**
```

#### Troubleshooting

**Problem**: Branch not created after labeling

**Solution**: Check both required labels are present:
```bash
# View issue labels
gh issue view 123

# Should show BOTH:
# - claude-code
# - status:ready

# Add missing label
gh issue edit 123 --add-label "claude-code"
gh issue edit 123 --add-label "status:ready"
```

---

**Problem**: `❌ Base branch 'dev' not found`

**Solution**: Create dev branch or use main:
```bash
# Option 1: Create dev branch
git checkout -b dev main
git push origin dev

# Option 2: Use main as base
gh issue edit 123 --add-label "base:main"
# Then remove and re-add status:ready to retrigger
gh issue edit 123 --remove-label "status:ready"
gh issue edit 123 --add-label "status:ready"
```

---

**Problem**: Branch name too long or weird characters

**Solution**: This is automatic slug generation. The workflow:
- Limits slug to 50 characters
- Removes special characters
- Converts spaces to hyphens
- Lowercases everything

If you need a different name, create branch manually:
```bash
git checkout -b feature/custom-name
git push origin feature/custom-name
```

---

**Problem**: `❌ Branch already exists`

**Solution**: This is normal - workflow is idempotent. The branch was already created. Just checkout:
```bash
git fetch origin
git checkout feature/issue-123-whatever
```

---

#### Best Practices

✅ **DO**:
- Use type labels for proper branch naming
- Wait for auto-branch creation (saves time)
- Follow the checkout instructions from bot comment
- Link issue in PR description

❌ **DON'T**:
- Create branches manually (defeats automation)
- Rename auto-created branches (breaks tracking)
- Remove `claude-code` label (breaks workflow)
- Work directly on dev/main branches

---

### 7. pr-status-sync.yml

**Sync PR lifecycle events with linked issues**

#### Purpose

Automatically updates issue status and project board as pull requests move through their lifecycle (opened, review, merged, closed).

#### Trigger

```yaml
on:
  pull_request:
    types:
      - opened
      - closed
      - converted_to_draft
      - ready_for_review
      - reopened
    branches:
      - dev

  pull_request_review:
    types:
      - submitted
    branches:
      - dev
```

**Triggers when**: PR events occur on PRs targeting `dev` branch.

#### Permissions

```yaml
permissions:
  contents: write
  pull-requests: write
  issues: write
```

#### Concurrency Control

```yaml
concurrency:
  group: pr-sync-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

**Prevents**: Multiple syncs running simultaneously for same PR.

#### What It Does

1. **Fork Safety Check**
   - Detects fork PRs
   - Skips write operations for security
   - Allows read-only checks

2. **Extract Linked Issues**
   - Parses PR body for issue references
   - Finds: `Closes #123`, `Fixes #456`, `Resolves #789`, `Relates to #101`
   - Deduplicates issue numbers
   - Skips if no linked issues

3. **Debounce Delay** (10 seconds)
   - Prevents infinite automation loops
   - Waits before making changes
   - Allows other workflows to settle

4. **Determine Target Status** (based on PR state)
   - **PR opened (ready)** → Issues: "In Review"
   - **PR converted to draft** → Issues: "In Progress"
   - **PR merged** → Issues: "To Deploy"
   - **PR closed (not merged)** → Issues: "In Progress"

5. **Update Issue Status**
   - Posts comment to issues about PR status change
   - Updates labels (if configured)
   - Updates project board status
   - Handles multiple linked issues

6. **Delete Merged Branch** (optional)
   - Deletes source branch after merge
   - Protects main branches (main, dev, staging)
   - Posts comment to PR confirming deletion

7. **Project Board Sync**
   - Syncs all linked issues to project
   - Updates Status field via GraphQL
   - Handles missing project gracefully

8. **Summary Report**
   - Shows updated issues
   - Shows branch deletion status
   - Shows project sync status

#### Status Transition Logic

```
PR Draft → Issues: "In Progress"
    ↓
PR Ready for Review → Issues: "In Review"
    ↓
PR Merged → Issues: "To Deploy" + Delete Branch
    ↓
(Later: main merge) → Issues: "Done" (via release-status-sync)

PR Closed (not merged) → Issues: "In Progress"
    ↓
PR Reopened → Issues: "In Review"
```

#### Example Usage

**Scenario 1: Feature PR lifecycle**

```bash
# Day 1: Create draft PR
gh pr create \
  --draft \
  --title "feat(auth): Add user authentication" \
  --body "Closes #123"

# → Workflow runs
# → Issue #123 status: "In Progress" (draft PR)

# Day 2: Mark ready for review
gh pr ready

# → Workflow runs
# → Issue #123 status: "In Review"
# → Issue #123 comment: "PR ready for review"

# Day 3: PR approved and merged
gh pr merge --squash

# → Workflow runs
# → Issue #123 status: "To Deploy"
# → Branch deleted: feature/issue-123-add-auth
# → Issue #123 comment: "PR merged to dev"
```

**Scenario 2: PR closed without merge**

```bash
# Close PR
gh pr close 456

# → Workflow runs
# → Linked issues status: "In Progress"
# → Issue comment: "PR closed without merging"
# → Branch NOT deleted (can reopen)
```

#### Configuration

**Enable/disable branch deletion**:

Edit `.github/workflows/pr-status-sync.yml`:
```yaml
delete-merged-branch:
  if: |-
    always() &&
    needs.fork-check.outputs.should-skip-writes != 'true' &&
    github.event.pull_request.merged == true
    && false  # ← Add this to disable
```

**Protected branches** (never deleted):
```yaml
protected_branches:
  - main
  - master
  - dev
  - develop
  - staging
  - production
```

**Adjust debounce delay**:
```yaml
- name: Wait 10 seconds to debounce automation loops
  run: sleep 10  # ← Change to 5, 15, 20, etc.
```

#### Troubleshooting

**Problem**: Status not updating after PR merge

**Solution**: Check for linked issues in PR body:
```markdown
# PR body must contain:
Closes #123
# or
Fixes #456
# or
Resolves #789
```

If missing, edit PR description and add.

---

**Problem**: `⚠️ No linked issues found`

**Solution**: Edit PR description:
```bash
# Edit PR
gh pr edit 456 --body "$(cat << EOF
## Summary
This PR adds authentication.

Closes #123
Fixes #124
EOF
)"
```

---

**Problem**: Branch not deleted after merge

**Solution**: Check protected branch list. If your branch name matches a protected pattern, it won't be deleted (this is by design). For feature branches, ensure they follow `feature/*`, `fix/*`, or `hotfix/*` pattern.

---

**Problem**: `❌ Infinite loop detected` (rare)

**Solution**: The 10-second debounce prevents this, but if it occurs:
1. Check if multiple workflows are modifying issues simultaneously
2. Increase debounce delay to 15-20 seconds
3. Check webhook delivery logs in repo settings

---

#### Best Practices

✅ **DO**:
- Always link issues in PR description
- Use conventional commit format for PR titles
- Wait for automation to complete before manual updates
- Review status changes in issue comments

❌ **DON'T**:
- Manually update issue status (automation does it)
- Remove linked issues from PR (breaks sync)
- Force push after PR opened (triggers re-sync)
- Close and reopen PRs frequently (wastes API calls)

---

### 8. release-status-sync.yml

**Close issues and create releases on production deployment**

#### Purpose

Automatically closes all linked issues, updates project board to "Done", and creates GitHub releases when changes are deployed to production (merged to `main`).

#### Trigger

```yaml
on:
  pull_request:
    types:
      - closed
    branches:
      - main
```

**Triggers when**: A PR targeting `main` is closed (checks for merge status internally).

#### Permissions

```yaml
permissions:
  contents: write
  issues: write
  pull-requests: read
```

#### What It Does

1. **Validate Release Conditions**
   - PR must be **merged** (not just closed)
   - PR must target **main** branch
   - PR source should be **dev** branch (configurable)
   - Skips if any condition fails

2. **Extract Linked Issues**
   - Parses PR body for issue references
   - Finds: `Closes #123`, `Fixes #456`, `Resolves #789`
   - Deduplicates issue numbers
   - Handles multiple linked issues

3. **Detect Version**
   - Reads version from `package.json`
   - Falls back to "unknown" if not found
   - Uses for release tag (v{version})

4. **Close Linked Issues**
   - Closes each linked issue
   - Skips already-closed issues
   - Adds release comment with details
   - Handles errors gracefully

5. **Update Project Board**
   - Updates all linked issues to "Done" status
   - Uses GraphQL for efficiency
   - Syncs bidirectionally

6. **Create GitHub Release** (optional)
   - Creates release tag: `v{version}`
   - Generates release notes from commits
   - Compares `dev...main` for changes
   - Includes PR links and commit history
   - Skips if version is unknown or release exists

7. **Generate Summary**
   - Lists all closed issues
   - Shows release version
   - Shows GitHub release link
   - Provides congratulations message

#### Release Comment Template

Issues receive this comment when closed:

```markdown
## 🚀 Released to Production!

This issue has been released to production in **v1.2.0**.

### 📋 Release Details
- **Release PR:** #456
- **Version:** 1.2.0
- **Released at:** 2025-11-06T10:30:00Z
- **Branch:** main

### 🎉 What's Next?
- Verify the fix/feature in production
- Monitor for any issues
- Close related tickets if applicable

---
🤖 _This issue was automatically closed by the release workflow_
```

#### Example Usage

**Standard release flow**:

```bash
# On dev branch - all features merged
git checkout dev
git pull origin dev

# Create release PR
gh pr create \
  --base main \
  --head dev \
  --title "release: Version 1.2.0" \
  --body "$(cat << EOF
## 🚀 Release v1.2.0

### Features
- User authentication (#123)
- Password reset (#124)
- Profile page (#125)

### Bug Fixes
- Navigation crash (#126)
- API timeout (#127)

Closes #123
Closes #124
Closes #125
Closes #126
Closes #127
EOF
)"

# After approval and merge:
gh pr merge 456 --squash

# → Workflow automatically:
# → Closes issues #123-127
# → Updates project board to "Done"
# → Creates GitHub release v1.2.0
# → Adds release comments to all issues
```

**Using `/release` command**:
```bash
# Simplified release command
/release

# → Prompts for version
# → Generates changelog
# → Creates release PR
# → Monitors merge
# → Triggers release-status-sync automatically
```

#### Configuration

**Version detection** (in order):

1. Reads `package.json` → `version` field
2. Falls back to "unknown" if not found
3. Can be manually specified in workflow

**Customize version source**:

Edit `.github/workflows/release-status-sync.yml`:
```yaml
- name: Detect version from package.json
  if: [ -f "package.json" ]; then
    VERSION=$(jq -r '.version' package.json)
  # Add custom version detection:
  elif [ -f "VERSION" ]; then
    VERSION=$(cat VERSION)
  elif git describe --tags >/dev/null 2>&1; then
    VERSION=$(git describe --tags --abbrev=0)
  else
    VERSION="unknown"
  fi
```

**Disable GitHub release creation**:

Set `version` to "unknown" to skip:
```yaml
- name: Create GitHub release
  if: |-
    needs.validate-release.outputs.version != 'unknown' &&
    needs.close-issues.result == 'success'
    && false  # ← Add to disable
```

#### Release Notes Generation

**Automatic changelog** (generated from commits):

```markdown
## 🚀 Release v1.2.0

This release includes changes from PR #456.

### 🎯 Changes
- feat(auth): add user authentication (abc1234)
- feat(auth): add password reset (def5678)
- fix(nav): resolve navigation crash (ghi9012)
- docs: update README (jkl3456)

### 🔗 Links
- **Release PR:** #456
- **Full Changelog:** [Compare view](../../compare/v1.1.0...v1.2.0)

---
🤖 _Release notes generated automatically_
```

**Customize release notes**:

Edit PR description with custom release notes - they'll appear in the release.

#### Troubleshooting

**Problem**: `⏭️ PR was closed without merging`

**Solution**: This is **expected**. Only merged PRs trigger releases. If you closed by accident:
```bash
# Reopen PR
gh pr reopen 456

# Merge it
gh pr merge 456 --squash
```

---

**Problem**: `⚠️ Source branch is not 'dev'`

**Solution**: This workflow expects `dev → main` releases. If you use a different branching strategy, edit the workflow:

```yaml
if [[ "$SOURCE_BRANCH" != "dev" ]]; then
  echo "⚠️  Source branch is not 'dev' (got: $SOURCE_BRANCH)"
  # Remove these lines to allow other branches:
  # echo "is-release=false" >> $GITHUB_OUTPUT
  # exit 0
fi
```

Or create a separate release workflow for your branching strategy.

---

**Problem**: `⏭️ Release v1.2.0 already exists`

**Solution**: Version has already been released. Bump version:
```json
// package.json
{
  "version": "1.2.1"  // ← Increment
}
```

Commit and push:
```bash
git add package.json
git commit -m "chore: bump version to 1.2.1"
git push
```

---

**Problem**: Issues not closing

**Solution**: Check for linked issues in release PR body:
```markdown
# Must include:
Closes #123
Closes #124
Closes #125
```

Edit PR description if missing:
```bash
gh pr edit 456 --body "Closes #123\nCloses #124"
```

---

**Problem**: `❌ package.json not found - version unknown`

**Solution**: This is **not an error** - release will still work, just without a version tag. To fix:

**Option 1**: Add package.json:
```bash
npm init -y
# Edit version
git add package.json
git commit -m "chore: add package.json"
```

**Option 2**: Use VERSION file:
```bash
echo "1.2.0" > VERSION
git add VERSION
git commit -m "chore: add VERSION file"

# Then update workflow to read VERSION file (see Configuration)
```

---

#### Best Practices

✅ **DO**:
- Always bump version before release
- Link all issues in release PR
- Generate changelog
- Test release flow in staging first
- Monitor production after release
- Document breaking changes

❌ **DON'T**:
- Merge to main from feature branches (use dev)
- Skip version bumps
- Close PRs instead of merging
- Forget to link issues
- Rush releases without testing

---

## Workflow Relationships

### Dependency Graph

```
bootstrap.yml (one-time setup)
    ↓
    ├─→ Labels created
    ├─→ Project validated
    └─→ Secrets validated
         ↓
         └─→ claude-plan-to-issues.yml
              ↓
              ├─→ Creates issues (max 10)
              ├─→ Assigns labels
              └─→ Adds to project board
                   ↓
                   └─→ create-branch-on-issue.yml
                        ↓
                        └─→ Auto-creates branches
                             ↓
                             └─→ Developer works on branch
                                  ↓
                                  └─→ Creates PR to dev
                                       ↓
                                       ├─→ pr-into-dev.yml (validation)
                                       │    └─→ reusable-pr-checks.yml
                                       │
                                       └─→ pr-status-sync.yml (lifecycle)
                                            ↓
                                            └─→ PR merged to dev
                                                 ↓
                                                 └─→ Create release PR (dev → main)
                                                      ↓
                                                      ├─→ dev-to-main.yml (release gates)
                                                      │
                                                      └─→ PR merged to main
                                                           ↓
                                                           └─→ release-status-sync.yml
                                                                ↓
                                                                ├─→ Closes issues
                                                                ├─→ Updates project
                                                                └─→ Creates release
```

### Workflow Interaction Matrix

| Workflow | Triggers | Depends On | Modifies |
|----------|----------|------------|----------|
| bootstrap.yml | Manual | None | Labels, secrets validation |
| reusable-pr-checks.yml | Called | None | PR status checks |
| pr-into-dev.yml | PR opened to dev | reusable-pr-checks | PR status, comments |
| dev-to-main.yml | PR opened to main | None | PR status, artifacts |
| claude-plan-to-issues.yml | Manual | bootstrap | Issues, project board, milestone |
| create-branch-on-issue.yml | Issue labeled | bootstrap | Branches, issue comments, project |
| pr-status-sync.yml | PR events | None | Issues, project board, branches |
| release-status-sync.yml | PR merged to main | None | Issues, project board, releases |

---

## Best Practices

### 1. Setup Phase

✅ **DO**:
- Run `bootstrap.yml` first thing
- Validate all secrets are set
- Create project board with Status field
- Test with one issue before bulk import

❌ **DON'T**:
- Skip bootstrap (creates missing labels)
- Forget to set PROJECT_URL secret
- Use classic projects (must be Projects v2)

### 2. Planning Phase

✅ **DO**:
- Keep plans to 10 tasks max
- Write clear acceptance criteria
- Set appropriate priorities
- Link task dependencies
- Use meaningful task titles

❌ **DON'T**:
- Exceed 10 tasks per plan (hard limit)
- Skip acceptance criteria
- Use vague descriptions
- Forget to assign types/platforms

### 3. Development Phase

✅ **DO**:
- Wait for auto-branch creation
- Follow conventional commit format
- Link issues in every PR
- Run quality checks locally first
- Keep PRs small and focused

❌ **DON'T**:
- Create branches manually
- Skip linking issues
- Merge failing PRs
- Work directly on dev/main

### 4. Review Phase

✅ **DO**:
- Address all quality check failures
- Respond to PR review comments
- Update PR when requirements change
- Keep PR description current

❌ **DON'T**:
- Override failing checks
- Force push after reviews
- Ignore security warnings
- Merge without approval

### 5. Release Phase

✅ **DO**:
- Bump version before release
- Generate comprehensive changelog
- Test in staging first
- Monitor production deployment
- Document breaking changes

❌ **DON'T**:
- Rush releases
- Skip smoke tests
- Merge hotfixes to main directly
- Forget to close old milestones

---

## Common Customizations

### 1. Adjust Task Limit

**Change max 10 to max 15**:

Edit `.github/workflows/claude-plan-to-issues.yml`:
```yaml
- name: Validate plan
  run: |
    TASK_COUNT=$(echo "$PLAN_JSON" | jq '.tasks | length')
    if [ "$TASK_COUNT" -gt 15 ]; then  # ← Change from 10
      echo "❌ Too many tasks: $TASK_COUNT (max: 15)"
      exit 1
    fi
```

**Note**: Higher limits consume more API calls.

---

### 2. Change Branch Naming

**Add custom prefixes**:

Edit `.github/workflows/create-branch-on-issue.yml`:
```yaml
case "$ISSUE_TYPE" in
  "type:feature") BRANCH_PREFIX="feature" ;;
  "type:fix") BRANCH_PREFIX="fix" ;;
  "type:enhancement") BRANCH_PREFIX="enhance" ;;  # ← Add custom
  "type:experimental") BRANCH_PREFIX="exp" ;;     # ← Add custom
  *) BRANCH_PREFIX="feature" ;;
esac
```

---

### 3. Disable Branch Deletion

**Keep branches after merge**:

Edit `.github/workflows/pr-status-sync.yml`:
```yaml
delete-merged-branch:
  if: |-
    false  # ← Disable completely
```

Or keep branches for specific types:
```yaml
- name: Delete source branch
  run: |
    # Don't delete hotfix branches (for audit trail)
    if [[ "$BRANCH_NAME" == hotfix/* ]]; then
      echo "Keeping hotfix branch for audit"
      exit 0
    fi
```

---

### 4. Add Slack Notifications

**Notify on releases**:

Add to `.github/workflows/release-status-sync.yml`:
```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "🚀 Released v${{ needs.validate-release.outputs.version }} to production!",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Released <https://github.com/${{ github.repository }}/releases/tag/v${{ needs.validate-release.outputs.version }}|v${{ needs.validate-release.outputs.version }}>"
            }
          }
        ]
      }
```

---

### 5. Custom Quality Checks

**Add performance tests**:

Edit `.github/workflows/reusable-pr-checks.yml`:
```yaml
performance-tests:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: ./.github/actions/setup-node-pnpm

    - name: Run performance tests
      run: pnpm run test:perf

    - name: Check bundle size
      run: |
        BUNDLE_SIZE=$(du -sh dist | cut -f1)
        echo "Bundle size: $BUNDLE_SIZE"
        # Add size limit check here
```

---

### 6. Multi-Environment Support

**Add staging environment**:

Create `.github/workflows/dev-to-staging.yml`:
```yaml
# Copy from dev-to-main.yml
# Change:
# - branches: main → branches: staging
# - Adjust quality gates as needed
```

Create `.github/workflows/staging-to-main.yml`:
```yaml
# Minimal final checks before production
```

Update pr-status-sync and release-status-sync for new flow.

---

## Troubleshooting

### General Debugging

**View workflow run logs**:
```bash
# List recent runs
gh run list --limit 10

# View specific run
gh run view 1234567890

# Watch live
gh run watch 1234567890
```

**Check rate limit**:
```bash
gh api rate_limit
```

**View repository secrets**:
```bash
gh secret list
```

**Test workflow locally** (using act):
```bash
# Install act
brew install act

# Run bootstrap workflow
act workflow_dispatch -W .github/workflows/bootstrap.yml
```

---

### Common Error Patterns

**`Error: Resource not accessible by integration`**

**Cause**: Insufficient permissions in workflow.

**Solution**: Check `permissions:` block matches workflow needs:
```yaml
permissions:
  contents: write  # For creating branches
  issues: write    # For updating issues
  pull-requests: write  # For PR comments
```

---

**`Error: GraphQL: Field 'Status' doesn't exist on type 'ProjectV2'`**

**Cause**: Project board doesn't have a Status field.

**Solution**: Add Status field to your project board:
1. Open project board → Settings
2. Fields → New field → Single select
3. Name: "Status"
4. Add options: Ready, In Progress, In Review, To Deploy, Done

---

**`Error: API rate limit exceeded`**

**Cause**: Too many API calls in short time.

**Solution**:
1. Wait for rate limit reset (check `gh api rate_limit`)
2. Reduce workflow frequency
3. Increase debounce delays
4. Consider GitHub Enterprise (higher limits)

---

**`Error: Reference does not exist`**

**Cause**: Trying to create branch from non-existent base.

**Solution**: Ensure base branch exists:
```bash
# Check branches
git branch -a

# Create missing branch
git checkout -b dev main
git push origin dev
```

---

### Workflow-Specific Issues

See individual workflow documentation above for specific troubleshooting scenarios.

### Getting Help

1. **Check workflow logs** - Most errors have clear messages
2. **Review this documentation** - Most issues are covered
3. **Search GitHub Issues** - Others may have same problem
4. **Open discussion** - Community can help
5. **File bug report** - If you find a real issue

---

---

## Next Steps

✅ **Workflows documented!** You now understand all 8 automation workflows.

**Continue Learning**:
- [Slash Commands Reference](./COMMANDS.md) - 8 interactive commands
- [Customization Guide](./CUSTOMIZATION.md) - Advanced configuration
- [Architecture Deep Dive](./ARCHITECTURE.md) - System design and decisions

**Get Started**:
1. Run `/blueprint-init` to set up your repository
2. Create your first plan with Claude Code
3. Run `/plan-to-issues` to create issues
4. Start working - branches auto-create!

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-06
**Workflows Version**: Phase 1 Complete
