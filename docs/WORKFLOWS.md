# Workflows Reference

Complete documentation for all 8 GitHub Actions workflows in the GitHub Workflow Blueprint.

---

## Table of Contents

1. [Overview](#overview)
2. [Workflow Execution Order](#workflow-execution-order)
3. [Workflow 1: bootstrap.yml](#workflow-1-bootstrapyml)
4. [Workflow 2: reusable-pr-checks.yml](#workflow-2-reusable-pr-checksyml)
5. [Workflow 3: pr-into-dev.yml](#workflow-3-pr-into-devyml)
6. [Workflow 4: dev-to-main.yml](#workflow-4-dev-to-mainyml)
7. [Workflow 5: claude-plan-to-issues.yml](#workflow-5-claude-plan-to-issuesyml)
8. [Workflow 6: create-branch-on-issue.yml](#workflow-6-create-branch-on-issueyml)
9. [Workflow 7: pr-status-sync.yml](#workflow-7-pr-status-syncyml)
10. [Workflow 8: release-status-sync.yml](#workflow-8-release-status-syncyml)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)

---

## Overview

The blueprint includes 8 workflows that automate the complete development lifecycle:

| Workflow | Purpose | Trigger | Frequency |
|----------|---------|---------|-----------|
| **bootstrap.yml** | One-time setup | Manual | Once |
| **reusable-pr-checks.yml** | Quality checks | Called by others | Per PR |
| **pr-into-dev.yml** | Feature PR validation | PR to dev | Per PR |
| **dev-to-main.yml** | Release validation | PR to main | Per release |
| **claude-plan-to-issues.yml** | Plan to issues | Manual | As needed |
| **create-branch-on-issue.yml** | Auto-branch | Issue labeled | Per issue |
| **pr-status-sync.yml** | Status sync | PR events | Per PR event |
| **release-status-sync.yml** | Release tracking | PR merged to main | Per release |

---

## Workflow Execution Order

### Typical Development Flow

```
1. bootstrap.yml (one-time)
   ↓
2. claude-plan-to-issues.yml (creates 10 issues)
   ↓
3. create-branch-on-issue.yml (creates feature branch)
   ↓
4. Developer commits to feature branch
   ↓
5. pr-into-dev.yml triggers
   ├─→ reusable-pr-checks.yml (quality gates)
   └─→ pr-status-sync.yml (update issue status)
   ↓
6. PR merged to dev
   └─→ pr-status-sync.yml (update to "To Deploy")
   ↓
7. dev-to-main.yml triggers (release PR)
   ├─→ Production checks
   └─→ Smoke tests
   ↓
8. PR merged to main
   └─→ release-status-sync.yml (close issues, create release)
```

---

## Workflow 1: bootstrap.yml

**Purpose**: One-time repository setup that creates labels, validates configuration, and prepares the repository for automation.

### Trigger

```yaml
on:
  workflow_dispatch:  # Manual trigger only
```

**When to run**: Once after cloning the blueprint to your repository.

### What It Does

1. **Creates Repository Labels**
   - Status labels: `status:ready`, `status:in-progress`, `status:in-review`, `status:to-deploy`
   - Type labels: `type:feature`, `type:fix`, `type:hotfix`, `type:docs`, `type:refactor`, `type:test`
   - Platform labels: `platform:web`, `platform:mobile`, `platform:fullstack`
   - Priority labels: `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
   - Meta label: `claude-code`

2. **Validates Configuration**
   - Checks PROJECT_URL secret exists
   - Checks ANTHROPIC_API_KEY secret exists
   - Validates project board access
   - Confirms GitHub token permissions

3. **Generates Report**
   - Lists all created/existing labels
   - Confirms secret configuration
   - Provides next steps

### Permissions

```yaml
permissions:
  contents: write
  issues: write
  project: read
```

### Running the Workflow

```bash
# Via GitHub CLI
gh workflow run bootstrap.yml

# Wait for completion
gh run watch

# Check results
gh run view --log

# Via GitHub UI
# Go to: Actions → Bootstrap Repository → Run workflow
```

### Configuration

No configuration needed. Uses repository secrets:
- `PROJECT_URL` - Your GitHub Projects v2 board URL
- `ANTHROPIC_API_KEY` - Your Claude API key
- `GITHUB_TOKEN` - Auto-provided by GitHub

### Expected Output

```
✅ Created label: claude-code (#7e57c2)
✅ Created label: status:ready (#0e8a16)
✅ Created label: type:feature (#1d76db)
...
✅ Validated PROJECT_URL secret
✅ Validated ANTHROPIC_API_KEY secret
✅ Project board access confirmed
✅ Bootstrap complete!
```

### Troubleshooting

**Error**: "Label already exists"
- **Not an error**: Workflow is idempotent, safe to re-run
- Existing labels are skipped

**Error**: "PROJECT_URL not found"
- Check secret is set: `gh secret list | grep PROJECT_URL`
- Format: `https://github.com/users/USERNAME/projects/NUMBER`
- Set secret: `gh secret set PROJECT_URL`

**Error**: "Insufficient permissions"
- Ensure GitHub token has `contents: write` and `issues: write`
- Check Settings → Actions → General → Workflow permissions

---

## Workflow 2: reusable-pr-checks.yml

**Purpose**: Reusable workflow that runs quality checks (lint, typecheck, tests) for DRY principle.

### Trigger

```yaml
on:
  workflow_call:
    inputs:
      mobile_check:
        type: boolean
        default: false
      integration_tests:
        type: boolean
        default: false
```

**When it runs**: Called by other workflows (pr-into-dev.yml, dev-to-main.yml).

### What It Does

1. **Detects Changed Files**
   - Uses `dorny/paths-filter@v3`
   - Categorizes changes: `src`, `tests`, `mobile`, `config`

2. **Runs Quality Checks** (in parallel)
   - **Lint**: ESLint + Prettier validation
   - **Type Check**: TypeScript validation
   - **Unit Tests**: Jest/Vitest tests
   - **Integration Tests**: (if enabled)
   - **Mobile Checks**: iOS/Android builds (if enabled)

3. **Caching**
   - Caches `node_modules`
   - Caches `.pnpm-store`
   - Caches mobile dependencies (`.gradle`, `Pods`)

4. **Reports Results**
   - Sets GitHub status checks
   - Comments on PR if failures
   - Uploads test coverage artifacts

### Jobs

#### Job: `changes`
Detects which files changed to optimize subsequent jobs.

#### Job: `lint`
```bash
pnpm lint
```

#### Job: `typecheck`
```bash
pnpm type-check
```

#### Job: `test-unit`
```bash
pnpm test --ci --coverage
```

#### Job: `test-integration` (conditional)
```bash
pnpm test:integration
```

#### Job: `mobile-check` (conditional)
```bash
# iOS
cd ios && pod install
xcodebuild -workspace App.xcworkspace -scheme App build

# Android
cd android && ./gradlew assembleRelease
```

### Configuration

Called by other workflows with inputs:

```yaml
uses: ./.github/workflows/reusable-pr-checks.yml
with:
  mobile_check: false      # Enable mobile checks
  integration_tests: true  # Enable integration tests
```

### Required Scripts

Your `package.json` must include:

```json
{
  "scripts": {
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:integration": "jest --config jest.integration.config.js"
  }
}
```

### Caching Performance

| Run | Duration | Savings |
|-----|----------|---------|
| First (cold cache) | ~5 minutes | Baseline |
| Second (warm cache) | ~30 seconds | 90% faster |
| Typical PR | ~1 minute | 80% faster |

### Troubleshooting

**Error**: "pnpm: command not found"
- Ensure you're using pnpm: `npm install -g pnpm`
- Or switch to npm by editing workflow

**Error**: "Tests timing out"
- Check test configuration
- Increase timeout: `timeout-minutes: 15`
- Optimize slow tests

**Error**: "Type check fails"
- Run locally: `pnpm type-check`
- Fix type errors
- Commit and push

---

## Workflow 3: pr-into-dev.yml

**Purpose**: Validates feature/fix/hotfix PRs before merging to dev branch.

### Trigger

```yaml
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]
    branches: [dev]
```

**When it runs**: On every PR targeting the `dev` branch.

### What It Does

1. **Branch Validation**
   - Ensures PR is from valid branch pattern:
     - `feature/*`
     - `fix/*`
     - `hotfix/*`
   - Blocks PRs from invalid branches

2. **Conventional Commit Check**
   - Validates PR title format
   - Enforces: `type(scope): description`
   - Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

3. **Linked Issue Check**
   - Ensures PR body contains issue reference
   - Looks for: `Closes #N`, `Fixes #N`, `Resolves #N`
   - Blocks PRs without linked issues

4. **Quality Gates**
   - Calls `reusable-pr-checks.yml`
   - Runs lint, typecheck, tests
   - All must pass before merge allowed

5. **Fork Safety**
   - Detects fork PRs
   - Runs checks but skips write operations
   - Prevents unauthorized modifications

6. **Status Updates**
   - Updates linked issues to "In Review"
   - Comments on PR with check results
   - Sets GitHub status checks

### Permissions

```yaml
permissions:
  contents: read
  pull-requests: write
  issues: read
  statuses: write
```

### Branch Patterns

**Accepted** ✅:
- `feature/issue-123-add-login`
- `fix/issue-456-cors-error`
- `hotfix/issue-789-critical-bug`

**Rejected** ❌:
- `main`
- `dev`
- `random-branch-name`

### Conventional Commit Examples

**Valid** ✅:
```
feat: add user authentication
fix(api): resolve CORS issue
docs: update README
chore: bump dependencies
```

**Invalid** ❌:
```
Added new feature
Fixed bug
Update
```

### Linked Issue Formats

**Accepted** ✅:
```markdown
Closes #123
Fixes #456
Resolves #789
Closes #123, #456
```

**Required Location**: Must be in PR body, not just title.

### Configuration

No configuration needed. Works with repository structure.

### Troubleshooting

See [PR and Branch Issues](TROUBLESHOOTING.md#branch-and-pr-issues) in TROUBLESHOOTING.md

---

## Workflow 4: dev-to-main.yml

**Purpose**: Release gates that validate production deployments before merging dev to main.

### Trigger

```yaml
on:
  pull_request:
    types: [opened, synchronize]
    branches: [main]
```

**When it runs**: On every PR targeting the `main` branch (typically dev → main).

### What It Does

1. **Source Branch Validation**
   - Ensures PR is from `dev` branch only
   - Blocks PRs from feature branches directly to main

2. **Production Build**
   - Runs production build: `pnpm build`
   - Validates build succeeds
   - Checks bundle size (if configured)

3. **Smoke Tests**
   - Runs critical path tests
   - Validates core functionality
   - Fast execution (~1-2 minutes)

4. **Security Scan** (informational)
   - Runs `npm audit`
   - Continues on error (non-blocking)
   - Reports vulnerabilities

5. **Deployment Readiness**
   - Checks changelog updated
   - Validates version bump
   - Confirms all tests pass

### Jobs

#### Job: `validate-source`
Ensures only dev → main PRs.

#### Job: `build-prod`
```bash
NODE_ENV=production pnpm build
```

#### Job: `smoke-tests`
```bash
pnpm test:smoke
```

#### Job: `security-scan`
```bash
npm audit --production
# Continues on error
```

#### Job: `deployment-readiness`
Validates:
- ✅ CHANGELOG.md updated
- ✅ package.json version bumped
- ✅ All required checks passed

### Required Scripts

```json
{
  "scripts": {
    "build": "next build",
    "test:smoke": "jest smoke.test.js"
  }
}
```

### Configuration

#### Optional: Bundle Size Check

Add to workflow:
```yaml
- name: Check bundle size
  run: |
    SIZE=$(du -sh dist | cut -f1)
    echo "Bundle size: $SIZE"
    # Add your size limits here
```

### Troubleshooting

**Error**: "Source branch must be 'dev'"
- Create PR from dev to main, not feature to main
- Merge feature to dev first

**Error**: "Production build failed"
- Run locally: `NODE_ENV=production pnpm build`
- Fix build errors
- Commit and push

**Error**: "Smoke tests failed"
- Run locally: `pnpm test:smoke`
- Fix failing tests
- Ensure smoke tests are fast (<2 min)

---

## Workflow 5: claude-plan-to-issues.yml

**Purpose**: Converts Claude Code plan JSON into GitHub issues with proper labels, milestones, and project board integration.

### Trigger

```yaml
on:
  workflow_dispatch:
    inputs:
      plan_json:
        description: 'Claude plan JSON'
        required: true
```

**When to run**: After creating a plan in Claude Code, use this to generate GitHub issues.

### What It Does

1. **Validates Plan JSON**
   - Checks JSON structure
   - Validates required fields
   - Enforces max 10 tasks limit

2. **Creates Milestone**
   - Uses plan metadata
   - Sets title and description
   - Assigns due date (if provided)

3. **Generates Issues** (max 10)
   - Creates issue for each task
   - Sets title and description
   - Adds acceptance criteria
   - Assigns labels:
     - `claude-code` (automatic)
     - `status:ready` (automatic)
     - Type label (`type:feature`, etc.)
     - Platform label (`platform:web`, etc.)
     - Priority label (`priority:high`, etc.)

4. **Links Dependencies**
   - Parses task dependencies
   - Adds "Depends on #N" to issue body
   - Creates proper issue references

5. **Adds to Project Board**
   - Uses GraphQL API
   - Adds each issue to project
   - Sets Status field to "Ready"

6. **Calculates Priority**
   - Uses explicit priority from plan
   - Increases priority for blocking tasks
   - Ensures proper task ordering

### Input Format

```json
{
  "milestone": {
    "title": "User Authentication MVP",
    "description": "Basic auth with JWT",
    "dueDate": "2025-12-31"
  },
  "tasks": [
    {
      "title": "Create login form",
      "description": "React form with validation",
      "acceptanceCriteria": [
        "Email and password fields",
        "Client-side validation",
        "Error handling"
      ],
      "priority": "high",
      "type": "feature",
      "platform": "web",
      "dependencies": []
    },
    {
      "title": "Implement JWT auth",
      "description": "Backend auth service",
      "acceptanceCriteria": [
        "JWT generation",
        "Token validation",
        "Refresh token flow"
      ],
      "priority": "critical",
      "type": "feature",
      "platform": "web",
      "dependencies": [1]
    }
  ]
}
```

### Task Limit

**Maximum**: 10 tasks per plan

**Rationale**:
- Keeps milestones focused
- Prevents overwhelming project boards
- Encourages proper planning

**If you need more**: Create multiple plans.

### Permissions

```yaml
permissions:
  contents: read
  issues: write
  projects: write
```

### Running the Workflow

```bash
# Save your plan to file
cat > plan.json <<'EOF'
{
  "milestone": {...},
  "tasks": [...]
}
EOF

# Trigger workflow
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat plan.json)"

# Monitor progress
gh run watch

# View created issues
gh issue list --label claude-code --limit 10
```

### Rate Limiting

The workflow includes circuit breaker logic:
- Checks remaining API calls (needs 50+)
- Sleeps between operations
- Retries on transient failures

### Troubleshooting

**Error**: "Too many tasks (max 10)"
- Split plan into multiple smaller plans
- Prioritize most important tasks

**Error**: "Invalid JSON format"
- Validate JSON: `cat plan.json | jq .`
- Check required fields
- Ensure proper escaping

**Error**: "Project board not found"
- Verify PROJECT_URL secret
- Test access: `gh project view NUMBER --owner @me`

**Error**: "Rate limit exceeded"
- Wait for rate limit reset
- Reduce API calls
- Use /kill-switch if urgent

---

## Workflow 6: create-branch-on-issue.yml

**Purpose**: Automatically creates feature branches when issues are marked ready.

### Trigger

```yaml
on:
  issues:
    types: [labeled]
```

**When it runs**: Every time a label is added to an issue.

### What It Does

1. **Checks Labels**
   - Requires BOTH:
     - `claude-code` label
     - `status:ready` label
   - Skips if either missing

2. **Generates Branch Name**
   - Format: `{type}/issue-{number}-{slug}`
   - Types: `feature`, `fix`, `hotfix`, `refactor`, `test`, `docs`
   - Slug: Kebab-case from issue title (max 50 chars)
   - Example: `feature/issue-123-add-user-login`

3. **Detects Base Branch**
   - Default: `dev`
   - Fallback: `main` (if dev doesn't exist)
   - Configurable via label: `base:staging`

4. **Creates Branch**
   - Checks if branch already exists
   - Creates from base branch
   - Pushes to origin

5. **Updates Issue**
   - Comments with branch name
   - Provides checkout instructions
   - Links to branch on GitHub

6. **Updates Project Board**
   - Changes Status to "In Progress"
   - Uses GraphQL mutation

### Branch Naming Examples

| Issue Title | Type | Branch Name |
|-------------|------|-------------|
| "Add user login" | feature | `feature/issue-1-add-user-login` |
| "Fix CORS error" | fix | `fix/issue-2-fix-cors-error` |
| "Urgent security patch" | hotfix | `hotfix/issue-3-urgent-security-patch` |

### Issue Comment

```markdown
🌿 Branch created: `feature/issue-123-add-user-login`

**Checkout locally**:
\```bash
git fetch origin
git checkout feature/issue-123-add-user-login
\```

**View on GitHub**: [Branch link]

**Next steps**:
1. Make your changes
2. Commit with conventional format
3. Push to origin
4. Create PR to dev
```

### Permissions

```yaml
permissions:
  contents: write
  issues: write
  projects: write
```

### Configuration

No configuration needed. Behavior controlled by labels.

### Idempotency

Safe to re-run:
- Skips if branch exists
- Updates comment instead
- No duplicate branches

### Troubleshooting

**Issue**: Branch not created
- Check BOTH labels present: `claude-code` AND `status:ready`
- View workflow run: `gh run list --workflow=create-branch-on-issue.yml`
- Check logs: `gh run view [RUN_ID] --log`

**Issue**: Wrong branch name
- Type detected from issue labels (`type:feature`, etc.)
- Default: `feature` if no type label

**Issue**: Branch already exists
- Workflow skips creation
- Updates issue comment instead
- Delete branch to retry: `git push origin --delete feature/issue-N-name`

---

## Workflow 7: pr-status-sync.yml

**Purpose**: Syncs PR lifecycle events with linked issue statuses and project board.

### Trigger

```yaml
on:
  pull_request:
    types: [opened, closed, converted_to_draft, reopened]
  pull_request_review:
    types: [submitted]
```

**When it runs**: On every PR event (open, close, draft, review, etc.)

### What It Does

1. **Extracts Linked Issues**
   - Parses PR body for issue references
   - Supports: `Closes #N`, `Fixes #N`, `Resolves #N`
   - Handles multiple issues: `Closes #1, #2, #3`

2. **Updates Issue Status**
   - **PR opened (ready_for_review)** → Issues to "In Review"
   - **PR converted to draft** → Issues to "In Progress"
   - **PR merged to dev** → Issues to "To Deploy"
   - **PR closed (not merged)** → Issues to "In Progress"

3. **Updates Project Board**
   - Uses GraphQL API
   - Updates Status field
   - Syncs all linked issues

4. **Branch Cleanup**
   - Deletes source branch after merge
   - Only for feature/fix/hotfix branches
   - Never deletes main/dev/staging

5. **Debouncing**
   - 10-second window prevents loops
   - Skips if same event occurred recently
   - Prevents infinite triggers

### Status Transitions

| Event | Issue Status | PR Status |
|-------|-------------|-----------|
| PR opened (ready) | **In Review** | Open |
| PR converted to draft | **In Progress** | Draft |
| Approval submitted | **In Review** | Approved |
| PR merged to dev | **To Deploy** | Merged |
| PR closed (not merged) | **In Progress** | Closed |

### Permissions

```yaml
permissions:
  contents: write      # For branch deletion
  pull-requests: read
  issues: write
  projects: write
```

### Debouncing Logic

```javascript
// Pseudo-code
if (event_occurred_within_last_10_seconds(event_key)) {
  skip_processing()
} else {
  process_event()
  record_timestamp(event_key)
}
```

This prevents infinite loops from:
- Rapid label changes
- Simultaneous PR updates
- Cascading automations

### Linked Issue Extraction

**Supported Formats**:
```markdown
Closes #123
Fixes #456, #789
Resolves #100

This PR closes #200 and fixes #300.
```

**Regex Pattern**:
```regex
(Closes|Fixes|Resolves)\s+#(\d+)
```

### Fork Safety

For fork PRs:
- Runs checks ✅
- Skips write operations ✅
- No branch deletion ✅
- No status updates ✅

### Troubleshooting

**Issue**: Status not updating
- Check linked issues in PR body
- Verify format: `Closes #N`
- Check workflow logs: `gh run view --log`
- Check 10-second debounce window

**Issue**: Multiple issues not updating
- Ensure format: `Closes #1, #2, #3`
- Check each issue has correct labels
- Verify project board access

**Issue**: Branch not deleted
- Only deletes feature/fix/hotfix branches
- Waits for successful merge
- Check branch protection rules

---

## Workflow 8: release-status-sync.yml

**Purpose**: Closes issues and creates releases when PRs merge to main (production deployment).

### Trigger

```yaml
on:
  pull_request:
    types: [closed]
    branches: [main]
```

**When it runs**: When a PR to main is closed.

### What It Does

1. **Validates Merge**
   - Checks PR was merged (not just closed)
   - Ensures source is `dev` branch
   - Skips if conditions not met

2. **Extracts Linked Issues**
   - Parses PR body for issue references
   - Same format as pr-status-sync.yml

3. **Closes Issues**
   - Closes all linked issues
   - Adds closing comment
   - Updates timestamps

4. **Updates Project Board**
   - Sets Status to "Done"
   - Uses GraphQL mutation
   - Archives completed items (optional)

5. **Creates GitHub Release** (optional)
   - Detects version from package.json
   - Generates changelog from commits
   - Lists closed issues
   - Publishes release notes

6. **Adds Release Comment**
   - Comments on each closed issue
   - Links to release
   - Shows version number

### Permissions

```yaml
permissions:
  contents: write      # For releases
  pull-requests: read
  issues: write
  projects: write
```

### Release Comment Format

```markdown
🚀 **Released to production** in [v1.2.3](release_url)

This issue was resolved and deployed to production.

**Release Date**: 2025-11-06
**Version**: 1.2.3
**Changelog**: [View full changelog](changelog_url)

Thank you for your contribution! 🎉
```

### Changelog Generation

**From commits**:
```markdown
## Version 1.2.3 (2025-11-06)

### Features
- Add user authentication (#123)
- Implement dark mode (#145)

### Bug Fixes
- Fix CORS issue (#456)
- Resolve memory leak (#478)

### Closed Issues
Closes #123, #145, #456, #478
```

### Version Detection

**From package.json**:
```json
{
  "version": "1.2.3"
}
```

**Manual input** (optional):
Can override via workflow input if needed.

### Configuration

#### Enable GitHub Releases

Set in workflow file:
```yaml
create_release: true  # Default: false
```

#### Customize Release Notes

Add `.github/release-template.md`:
```markdown
## What's Changed
$CHANGES

## Closed Issues
$ISSUES

Full Changelog: $PREVIOUS_TAG...$CURRENT_TAG
```

### Troubleshooting

**Issue**: Issues not closing
- Check PR was merged (not just closed)
- Verify source branch is `dev`
- Check issue references in PR body

**Issue**: Release not created
- Check `create_release: true` in workflow
- Verify GITHUB_TOKEN permissions
- Check version in package.json

**Issue**: Wrong version detected
- Update package.json version
- Or pass version manually

---

## Best Practices

### 1. Always Link Issues to PRs

**Why**: Enables automatic status tracking

**How**:
```markdown
Closes #123

## Summary
My changes...
```

### 2. Use Conventional Commits

**Why**: Enables automated changelogs

**Format**: `type(scope): description`

**Examples**:
- `feat: add user login`
- `fix(api): resolve CORS issue`
- `docs: update README`

### 3. Run Bootstrap Once

**When**: Immediately after cloning blueprint

**Command**:
```bash
gh workflow run bootstrap.yml
```

### 4. Test Locally Before Pushing

**Recommended**:
```bash
pnpm lint
pnpm type-check
pnpm test
pnpm build
```

This catches issues before CI runs.

### 5. Monitor Workflow Runs

**Commands**:
```bash
# List recent runs
gh run list --limit 10

# Watch current run
gh run watch

# View logs
gh run view --log
```

### 6. Use Draft PRs for WIP

**Why**: Keeps issues in "In Progress" until ready

**How**:
```bash
gh pr create --draft
# Work on changes
gh pr ready  # When ready for review
```

### 7. Keep Branches Short-Lived

**Best Practice**: Merge within 1-2 days

**Why**:
- Reduces merge conflicts
- Faster feedback
- Easier code review

### 8. Use /kill-switch for Emergencies

**When**: Workflows causing issues

**Command**:
```bash
/kill-switch enable
# Fix the issue
/kill-switch disable
```

---

## Troubleshooting

For detailed troubleshooting of specific workflows, see:

- **[Setup Issues](TROUBLESHOOTING.md#setup-issues)** - Bootstrap and configuration
- **[Workflow Failures](TROUBLESHOOTING.md#workflow-failures)** - General workflow issues
- **[Branch and PR Issues](TROUBLESHOOTING.md#branch-and-pr-issues)** - PR and branch automation
- **[Project Board Sync](TROUBLESHOOTING.md#project-board-sync-issues)** - Status sync problems

### Quick Diagnostics

```bash
# Check workflow status
gh workflow list

# View recent runs
gh run list --limit 10

# Check specific workflow
gh run list --workflow=[NAME] --limit 5

# View logs
gh run view [RUN_ID] --log

# Check secrets
gh secret list

# Test project access
gh project view NUMBER --owner @me

# Check rate limit
gh api rate_limit
```

### Common Issues

1. **"Workflow not triggering"**
   - Check trigger conditions
   - Verify branch names
   - Check file paths

2. **"Rate limit exceeded"**
   - Wait for reset
   - Use /kill-switch
   - Reduce frequency

3. **"Permission denied"**
   - Check token permissions
   - Verify secret access
   - Check branch protections

4. **"Infinite loop detected"**
   - Check debouncing (10-second window)
   - Review workflow triggers
   - Use /kill-switch

---

## Additional Resources

- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 minutes
- **[Complete Setup Guide](COMPLETE_SETUP.md)** - Detailed configuration
- **[Commands Reference](COMMANDS.md)** - All 8 slash commands
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Comprehensive solutions
- **[Customization Guide](CUSTOMIZATION.md)** - Advanced configuration
- **[Architecture Guide](ARCHITECTURE.md)** - System design

---

**Questions?** Open an issue with the `question` label or check [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

**Found a bug?** Open an issue with the `bug` label and include workflow logs.
