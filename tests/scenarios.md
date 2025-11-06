# Test Scenarios - GitHub Workflow Blueprint

**Document Version**: 1.0
**Date**: 2025-11-06
**Purpose**: End-to-end testing scenarios for blueprint validation

---

## 📋 Overview

This document contains 8 comprehensive test scenarios covering the complete lifecycle of the GitHub Workflow Blueprint from initial setup to production deployment and emergency procedures.

**Test Environment Requirements**:
- Clean GitHub repository (or willing to reset)
- GitHub CLI (`gh`) authenticated
- Git configured with user credentials
- Node.js 20+ and pnpm 9+ installed
- GitHub Project board created
- Anthropic API key available

**Testing Strategy**:
- Run scenarios sequentially (each builds on previous state)
- Document actual results vs expected
- Note any deviations or issues
- Track completion time for each scenario

---

## 🎯 Scenario Summary

| # | Scenario | Focus Area | Estimated Time | Status |
|---|----------|------------|----------------|---------|
| 1 | [First-Time Setup](#scenario-1-first-time-setup) | Installation & Configuration | 10 min | ❌ Not Tested |
| 2 | [Manual Setup](#scenario-2-manual-setup) | Alternative Installation | 15 min | ❌ Not Tested |
| 3 | [Plan to Production](#scenario-3-plan-to-production) | Complete Workflow | 30 min | ❌ Not Tested |
| 4 | [Feature Development](#scenario-4-feature-development) | Issue to PR Flow | 20 min | ❌ Not Tested |
| 5 | [Hotfix Workflow](#scenario-5-hotfix-workflow) | Emergency Procedures | 15 min | ❌ Not Tested |
| 6 | [Status Synchronization](#scenario-6-status-synchronization) | Manual Corrections | 10 min | ❌ Not Tested |
| 7 | [Quality Gate Failures](#scenario-7-quality-gate-failures) | Error Handling | 15 min | ❌ Not Tested |
| 8 | [Emergency Procedures](#scenario-8-emergency-procedures) | Kill Switch & Rollback | 10 min | ❌ Not Tested |

**Total Estimated Time**: ~2 hours

---

## Scenario 1: First-Time Setup

**Goal**: Verify clean installation from scratch using the interactive wizard

**Prerequisites**:
- Clean repository (no existing workflows)
- GitHub Project board created and URL available
- Anthropic API key available
- All tools installed (gh, git, node, pnpm)

### Steps

#### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

**Verify**:
```bash
git status  # Should show clean working tree
ls -la      # Should show minimal structure
```

---

#### 2. Run Setup Wizard
```bash
chmod +x setup/wizard.sh
./setup/wizard.sh
```

**Interactive Inputs**:
1. Project type: Select `2` (Standard Web - Recommended)
2. Branching strategy: Select `2` (Standard: dev → main)
3. Project URL: Paste your GitHub Project board URL
   - Example: `https://github.com/users/USERNAME/projects/1`
4. API Key: Paste your Anthropic API key (input is masked)

**Monitor Output**:
- Prerequisites check should pass ✅
- Configuration summary should display
- Branches should be created (main, dev)
- Secrets should be set
- Bootstrap workflow should run
- Branch protections should be applied
- Validation should pass

---

#### 3. Verify Setup
```bash
./setup/validate.sh
```

**Check Output Sections**:
```
✅ 1. Checking Git Branches
✅ 2. Checking Repository Secrets
✅ 3. Checking GitHub Actions Workflows
✅ 4. Checking Composite Actions
✅ 5. Checking Configuration Templates
✅ 6. Checking Labels
✅ 7. Checking Project Board Connection
✅ 8. Checking Documentation
✅ 9. Checking Claude Code Integration
✅ 10. Checking Environment Tools
```

---

#### 4. Verify GitHub State
```bash
# Check branches
git branch -a

# Check workflows
ls -la .github/workflows/

# Check labels
gh label list

# Check secrets
gh secret list

# Check project board
gh project view --owner YOUR_USERNAME 1
```

---

### Expected Results

**Setup Completion**:
- ✅ Wizard completes in <5 minutes
- ✅ No errors during execution
- ✅ All progress indicators show ✅
- ✅ Final summary displays

**Repository State**:
- ✅ Branches created: `main`, `dev`
- ✅ 8 workflows present in `.github/workflows/`
- ✅ 5 composite actions in `.github/actions/`
- ✅ All configuration templates present
- ✅ 20+ labels created (status, type, platform, priority)

**Secrets Configured**:
- ✅ `PROJECT_URL` set
- ✅ `ANTHROPIC_API_KEY` set
- ✅ `GITHUB_TOKEN` auto-available

**Validation**:
- ✅ All 10 validation categories pass
- ✅ Exit code 0
- ✅ Summary shows 0 failures

**Project Board**:
- ✅ Connection successful
- ✅ Status field detected
- ✅ Ready to receive issues

**Time**:
- ✅ Total time <10 minutes

---

### Actual Results

**Date Tested**: ___________
**Tester**: ___________
**Time Taken**: ___________

**Setup Output**:
```
[Paste wizard output here]
```

**Validation Output**:
```
[Paste validate.sh output here]
```

**Issues Encountered**:
- [ ] None
- [ ] Issue 1: ___________
- [ ] Issue 2: ___________

**Notes**:
___________

---

### Common Pitfalls

**Issue**: Wizard fails at prerequisites check
**Cause**: Missing tool (gh, git, node, pnpm)
**Solution**: Install missing tool, rerun wizard

**Issue**: Bootstrap workflow fails
**Cause**: PROJECT_URL incorrect format
**Solution**: Ensure URL is `https://github.com/users/USERNAME/projects/NUMBER`

**Issue**: Branch protection fails
**Cause**: Insufficient repository permissions
**Solution**: Ensure you have admin access to repository

---

## Scenario 2: Manual Setup

**Goal**: Verify manual step-by-step setup (alternative to wizard)

**Prerequisites**:
- Clean repository OR willingness to remove wizard-created configuration
- Same requirements as Scenario 1

**Use Case**: When wizard cannot be used (Windows without Git Bash, custom requirements, automation scripts)

### Steps

#### 1. Create Branches
```bash
# Ensure you're on main
git checkout main

# Create and push dev branch
git checkout -b dev
git push -u origin dev

# Optional: Create staging branch (complex strategy)
git checkout -b staging
git push -u origin staging

# Return to main
git checkout main
```

**Verify**:
```bash
git branch -a
# Should show: main, dev, (staging if complex)
```

---

#### 2. Set Repository Secrets
```bash
# Set PROJECT_URL
gh secret set PROJECT_URL --body "https://github.com/users/USERNAME/projects/1"

# Set ANTHROPIC_API_KEY
gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."

# Verify secrets
gh secret list
```

---

#### 3. Run Bootstrap Workflow
```bash
# Trigger bootstrap workflow manually
gh workflow run bootstrap.yml

# Wait 30 seconds
sleep 30

# Check workflow status
gh run list --workflow=bootstrap.yml --limit 1

# View workflow logs if needed
gh run view --log
```

---

#### 4. Apply Branch Protections

**Main Branch**:
```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks=null \
  --field enforce_admins=true \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

**Dev Branch**:
```bash
gh api repos/{owner}/{repo}/branches/dev/protection \
  --method PUT \
  --field required_status_checks=null \
  --field enforce_admins=false \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_linear_history=true \
  --field allow_force_pushes=false
```

---

#### 5. Validate Setup
```bash
./setup/validate.sh
```

---

### Expected Results

**Manual Setup**:
- ✅ All branches created and pushed
- ✅ Secrets set correctly
- ✅ Bootstrap workflow completes successfully
- ✅ Branch protections applied
- ✅ Validation passes

**Comparison to Wizard**:
- ✅ Same end state as wizard setup
- ✅ More manual control over configuration
- ✅ Takes longer (~15 minutes vs 5 minutes)
- ✅ More error-prone (manual commands)

**Time**:
- ✅ Total time <15 minutes

---

### Actual Results

**Date Tested**: ___________
**Time Taken**: ___________

**Notes**:
___________

---

## Scenario 3: Plan to Production

**Goal**: Complete end-to-end workflow from Claude plan to production deployment

**Prerequisites**:
- Repository fully set up (Scenario 1 or 2 complete)
- Claude Code CLI installed
- Example plan file ready

**Duration**: ~30 minutes

### Steps

#### 1. Create Example Plan
Create `test-plan.json`:
```json
{
  "milestone": "User Authentication Sprint",
  "description": "Implement basic user authentication system",
  "tasks": [
    {
      "title": "Setup authentication middleware",
      "description": "Configure JWT middleware for API routes",
      "acceptanceCriteria": [
        "JWT tokens validated on protected routes",
        "Proper error handling for invalid tokens",
        "Unit tests passing"
      ],
      "priority": "high",
      "type": "feature",
      "platform": "web",
      "dependencies": []
    },
    {
      "title": "Create login API endpoint",
      "description": "POST /api/auth/login endpoint with email/password",
      "acceptanceCriteria": [
        "Validates credentials against database",
        "Returns JWT token on success",
        "Returns 401 on failure"
      ],
      "priority": "high",
      "type": "feature",
      "platform": "web",
      "dependencies": [1]
    },
    {
      "title": "Create signup API endpoint",
      "description": "POST /api/auth/signup with user registration",
      "acceptanceCriteria": [
        "Validates email format and uniqueness",
        "Hashes password with bcrypt",
        "Creates user in database"
      ],
      "priority": "high",
      "type": "feature",
      "platform": "web",
      "dependencies": [1]
    }
  ]
}
```

---

#### 2. Convert Plan to Issues
```bash
# Using slash command (recommended)
claude /plan-to-issues test-plan.json

# OR trigger workflow directly
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat test-plan.json)"
```

**Wait 30 seconds**, then verify:
```bash
# List created issues
gh issue list --label "claude-code"

# View project board
gh project view --owner USERNAME 1
```

**Expected**: 3 issues created with:
- Labels: `claude-code`, `status:ready`, `type:feature`, `platform:web`, `priority:high`
- Milestone: "User Authentication Sprint"
- Dependency linking (issue #2 and #3 reference #1)
- All in "Ready" status on project board

---

#### 3. Start Work on First Issue
```bash
# The create-branch-on-issue workflow should auto-trigger
# when the 'status:ready' label is added

# Wait 10 seconds for workflow
sleep 10

# Check for created branch
git fetch
git branch -r | grep "feature/issue"

# Should see: origin/feature/issue-1-setup-authentication-middleware

# Checkout the branch
git checkout feature/issue-1-setup-authentication-middleware
```

**Verify Branch Created**:
```bash
git status
# Should show: On branch feature/issue-1-setup-authentication-middleware
```

---

#### 4. Make Code Changes
```bash
# Create example auth middleware
mkdir -p src/middleware
cat > src/middleware/auth.ts <<'EOF'
import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';

export function authMiddleware(req: NextRequest) {
  const token = req.headers.get('authorization')?.replace('Bearer ', '');

  if (!token) {
    return NextResponse.json({ error: 'No token provided' }, { status: 401 });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    return NextResponse.next();
  } catch (error) {
    return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
  }
}
EOF

# Create basic test
mkdir -p src/middleware/__tests__
cat > src/middleware/__tests__/auth.test.ts <<'EOF'
import { authMiddleware } from '../auth';
import { NextRequest } from 'next/server';

describe('Auth Middleware', () => {
  it('should reject requests without token', () => {
    const req = new NextRequest('http://localhost:3000/api/protected');
    const response = authMiddleware(req);
    expect(response.status).toBe(401);
  });
});
EOF
```

---

#### 5. Commit Changes (Smart Commit)
```bash
# Using slash command with quality checks
claude /commit-smart

# OR manual commit
git add src/middleware/
git commit -m "feat(auth): setup JWT authentication middleware

- Add JWT verification middleware
- Handle missing/invalid tokens
- Add unit tests for auth logic

Closes #1"
```

**Commit Message Requirements**:
- Conventional commit format (`feat:`, `fix:`, etc.)
- Reference issue number (`Closes #1`)
- Clear description

---

#### 6. Create Pull Request
```bash
# Using slash command (recommended)
claude /create-pr

# OR use gh CLI
gh pr create \
  --base dev \
  --title "feat(auth): Setup authentication middleware" \
  --body "## Summary
Implement JWT authentication middleware for API routes

## Changes
- Added auth middleware with JWT verification
- Error handling for missing/invalid tokens
- Unit tests for middleware logic

## Testing
- Unit tests passing
- Manual testing with test tokens

Closes #1" \
  --label "type:feature" \
  --label "platform:web"
```

**Verify PR Created**:
```bash
# View PR
gh pr view

# Check workflow status
gh run list --limit 3
```

---

#### 7. Monitor Quality Checks
```bash
# Watch workflow progress
gh run watch

# OR check status
gh pr checks
```

**Expected Checks**:
- `lint` - ✅ Pass
- `typecheck` - ✅ Pass
- `test-unit` - ✅ Pass
- `pr-into-dev` validation - ✅ Pass

**Project Board Update**:
- Issue #1 status → "In Review"

---

#### 8. Review and Merge PR
```bash
# Optional: Request review with Claude
claude /review-pr 1

# Approve PR (if you have permissions)
gh pr review 1 --approve --body "LGTM! Quality checks passed."

# Merge PR (squash merge)
gh pr merge 1 --squash --delete-branch
```

**Verify Merge**:
```bash
# Check dev branch updated
git checkout dev
git pull

# Check project board
gh project view --owner USERNAME 1
```

**Expected**:
- PR merged to `dev`
- Source branch deleted
- Issue #1 status → "To Deploy"

---

#### 9. Repeat for Remaining Issues

**Issue #2** (Login endpoint):
```bash
# Branch should auto-create when issue #2 status changes to ready
gh issue edit 2 --add-label "status:in-progress"

# ... implement login endpoint ...
# ... commit, PR, review, merge ...
```

**Issue #3** (Signup endpoint):
```bash
# ... same process ...
```

---

#### 10. Create Release PR (dev → main)
```bash
# Using slash command
claude /release

# OR manual PR
gh pr create \
  --base main \
  --head dev \
  --title "release: User Authentication v1.0.0" \
  --body "## Release Summary
Complete user authentication system

## Features
- JWT authentication middleware (#1)
- Login API endpoint (#2)
- Signup API endpoint (#3)

## Testing
- All unit tests passing
- Integration tests passing
- Manual QA complete

## Issues Resolved
Closes #1, #2, #3"
```

---

#### 11. Monitor Release Workflow
```bash
# Check release workflow
gh run list --workflow=dev-to-main.yml

# Watch checks
gh pr checks

# View smoke test results
gh run view --log
```

**Expected Checks**:
- `build-prod` - ✅ Pass
- `smoke-tests` - ✅ Pass
- `security-quickscan` - ⚠️ Warning (informational)
- `deployment-readiness` - ✅ Pass

---

#### 12. Merge Release
```bash
# Approve release PR
gh pr review --approve

# Merge to main
gh pr merge --squash

# Wait for release-status-sync workflow
sleep 10

# Verify issues closed
gh issue list --state closed
```

**Expected Final State**:
- All issues (#1, #2, #3) closed
- Project board: All issues → "Done"
- Issues commented: "Released to production in v1.0.0"
- GitHub release created (optional)

---

### Expected Results

**Complete Workflow**:
- ✅ Plan JSON → 3 GitHub issues
- ✅ Issues auto-assigned to milestone
- ✅ Issues appear on project board (Ready status)
- ✅ Auto-branch creation on issue start
- ✅ PR creation with proper linking
- ✅ Quality checks run automatically
- ✅ Project board syncs on PR merge (To Deploy)
- ✅ Release PR created (dev → main)
- ✅ Release checks pass
- ✅ Issues closed and moved to Done on main merge

**Time**:
- ✅ Issue creation: <1 minute
- ✅ Development per issue: ~5 minutes
- ✅ PR checks: <2 minutes per PR
- ✅ Release process: ~5 minutes
- ✅ **Total: ~25-30 minutes**

**Quality**:
- ✅ All commits conventional format
- ✅ All PRs properly linked to issues
- ✅ All quality gates passed
- ✅ No manual status updates needed
- ✅ Full audit trail in issues/PRs

---

### Actual Results

**Date Tested**: ___________
**Total Time**: ___________

**Plan to Issues**:
- Issues Created: ___________
- Time Taken: ___________

**Development Cycle** (per issue):
- Issue #1 Time: ___________
- Issue #2 Time: ___________
- Issue #3 Time: ___________

**Release to Main**:
- Time Taken: ___________

**Issues Encountered**:
___________

---

## Scenario 4: Feature Development

**Goal**: Test standard feature development workflow (issue → branch → PR → merge)

**Prerequisites**:
- Repository set up
- At least one manual issue created

**Duration**: ~20 minutes

### Steps

#### 1. Create Manual Issue
```bash
gh issue create \
  --title "Add dark mode toggle" \
  --body "## Description
Add a toggle button in the header to switch between light and dark themes.

## Acceptance Criteria
- [ ] Toggle button visible in header
- [ ] Click toggles theme state
- [ ] Theme persists across page refreshes
- [ ] Smooth transition between themes

## Type
Feature

## Platform
Web

## Priority
Medium" \
  --label "type:feature" \
  --label "platform:web" \
  --label "priority:medium" \
  --label "status:ready"
```

**Verify Issue Created**:
```bash
gh issue list --label "status:ready"
```

---

#### 2. Wait for Auto-Branch Creation
```bash
# The create-branch-on-issue workflow triggers on label addition
# Wait 15 seconds
sleep 15

# Check for branch
git fetch
git branch -r | grep "feature/issue"

# Example: origin/feature/issue-4-add-dark-mode-toggle

# Checkout branch
git checkout feature/issue-4-add-dark-mode-toggle
```

**Verify**:
```bash
git status
# Should show: On branch feature/issue-4-add-dark-mode-toggle

# Check issue comment
gh issue view 4
# Should see comment with branch name and checkout instructions
```

---

#### 3. Implement Feature
```bash
# Create dark mode toggle component
mkdir -p src/components
cat > src/components/ThemeToggle.tsx <<'EOF'
'use client';

import { useState, useEffect } from 'react';

export function ThemeToggle() {
  const [theme, setTheme] = useState('light');

  useEffect(() => {
    const stored = localStorage.getItem('theme') || 'light';
    setTheme(stored);
    document.documentElement.setAttribute('data-theme', stored);
  }, []);

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  };

  return (
    <button onClick={toggleTheme} className="theme-toggle">
      {theme === 'light' ? '🌙' : '☀️'}
    </button>
  );
}
EOF

# Add CSS
cat > src/styles/theme.css <<'EOF'
[data-theme="light"] {
  --bg: #ffffff;
  --text: #000000;
}

[data-theme="dark"] {
  --bg: #1a1a1a;
  --text: #ffffff;
}

body {
  background-color: var(--bg);
  color: var(--text);
  transition: background-color 0.3s, color 0.3s;
}

.theme-toggle {
  font-size: 1.5rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
}
EOF
```

---

#### 4. Run Quality Checks Locally
```bash
# Lint
pnpm run lint

# Type check
pnpm run type-check

# Tests
pnpm run test

# Build
pnpm run build
```

**Expected**: All checks pass locally before committing

---

#### 5. Commit with Quality Checks
```bash
# Smart commit (runs quality checks automatically)
claude /commit-smart

# Enter commit message when prompted:
# "feat(ui): add dark mode toggle
#
# - Implement theme toggle component
# - Add CSS custom properties for themes
# - Persist theme choice in localStorage
# - Smooth transition animations
#
# Closes #4"
```

**Verify Commit**:
```bash
git log -1 --oneline
# Should show conventional commit format
```

---

#### 6. Create and Monitor PR
```bash
# Create PR using slash command
claude /create-pr

# OR manual PR
gh pr create \
  --base dev \
  --title "feat(ui): Add dark mode toggle" \
  --body "## Summary
Adds theme toggle for light/dark mode

## Changes
- Theme toggle component in header
- CSS custom properties for theme values
- LocalStorage persistence
- Smooth transitions

## Testing
- Manually tested toggle functionality
- Theme persists across refreshes
- Smooth transitions working

Closes #4" \
  --label "type:feature" \
  --label "platform:web"

# Monitor PR checks
gh pr checks
```

**Expected Checks**:
- pr-into-dev workflow runs
- Conventional commit validation - ✅
- Linked issue check - ✅
- Quality gates (lint, typecheck, test) - ✅
- Project board sync - Issue #4 → "In Review"

---

#### 7. Optional Code Review
```bash
# Request Claude-powered review
claude /review-pr 4

# Review will check:
# - Code quality
# - Security issues
# - Best practices
# - Performance concerns
```

---

#### 8. Merge PR
```bash
# Approve (if needed)
gh pr review 4 --approve

# Merge with squash
gh pr merge 4 --squash --delete-branch
```

**Verify Post-Merge**:
```bash
# Issue #4 should update
gh issue view 4
# Status: To Deploy

# Project board should update
gh project view --owner USERNAME 1
# Issue #4 in "To Deploy" column
```

---

### Expected Results

**Feature Workflow**:
- ✅ Manual issue created successfully
- ✅ Auto-branch created within 15 seconds
- ✅ Branch name follows convention
- ✅ Issue commented with instructions
- ✅ Local quality checks pass
- ✅ Smart commit validates before committing
- ✅ PR created with proper linking
- ✅ All PR checks pass
- ✅ Project board syncs automatically
- ✅ PR merges cleanly
- ✅ Source branch deleted
- ✅ Issue status updates (Ready → In Progress → In Review → To Deploy)

**Time**:
- ✅ Issue creation: 1 minute
- ✅ Development: 5-10 minutes
- ✅ PR creation and review: 3-5 minutes
- ✅ **Total: ~20 minutes**

---

### Actual Results

**Date Tested**: ___________
**Time Taken**: ___________

**Notes**:
___________

---

## Scenario 5: Hotfix Workflow

**Goal**: Test emergency hotfix process (fast-track to production)

**Prerequisites**:
- Production code in `main` branch
- Critical bug discovered

**Duration**: ~15 minutes

### Steps

#### 1. Create Hotfix Issue
```bash
gh issue create \
  --title "Fix: Critical auth token expiration bug" \
  --body "## Critical Bug
Users are getting logged out after 1 minute instead of 1 hour.

## Impact
- Severity: Critical
- Affected users: All authenticated users
- Data loss: No

## Root Cause
JWT expiration set to 60 seconds instead of 3600 seconds

## Fix
Change JWT_EXPIRY in auth middleware from '60s' to '3600s'

## Testing
- Verify tokens last 1 hour
- Test token refresh logic" \
  --label "type:hotfix" \
  --label "priority:critical" \
  --label "status:ready"
```

---

#### 2. Create Hotfix Branch (Manual)
```bash
# For standard strategy: branch from dev
git checkout dev
git pull
git checkout -b hotfix/issue-5-fix-auth-token-expiration
git push -u origin hotfix/issue-5-fix-auth-token-expiration

# For complex strategy: branch from staging (if available)
# git checkout staging
# git checkout -b hotfix/issue-5-fix-auth-token-expiration
```

---

#### 3. Apply Fix
```bash
# Fix the bug
cat > src/middleware/auth.ts <<'EOF'
// ... existing imports ...

const JWT_EXPIRY = 3600; // 1 hour (was 60 seconds - BUG FIX)

export function generateToken(userId: string) {
  return jwt.sign({ userId }, process.env.JWT_SECRET!, {
    expiresIn: JWT_EXPIRY
  });
}

// ... rest of file ...
EOF

# Add test to verify fix
cat > src/middleware/__tests__/auth.test.ts <<'EOF'
describe('Auth Token Expiration', () => {
  it('should set token expiry to 1 hour', () => {
    const token = generateToken('user123');
    const decoded = jwt.decode(token);
    const expiresIn = decoded.exp - decoded.iat;
    expect(expiresIn).toBe(3600); // 1 hour in seconds
  });
});
EOF
```

---

#### 4. Test Fix Locally
```bash
# Run tests
pnpm run test src/middleware/__tests__/auth.test.ts

# Run full test suite
pnpm run test

# Type check
pnpm run type-check
```

---

#### 5. Commit and Create PR
```bash
# Commit
git add src/middleware/
git commit -m "fix(auth): correct JWT token expiration to 1 hour

Previously tokens expired after 60 seconds due to incorrect
JWT_EXPIRY constant. Changed from 60s to 3600s (1 hour).

- Update JWT_EXPIRY constant
- Add test to verify 1-hour expiration
- Verified token refresh logic unaffected

Closes #5"

# Push
git push

# Create HOTFIX PR to dev (or staging if complex)
gh pr create \
  --base dev \
  --head hotfix/issue-5-fix-auth-token-expiration \
  --title "fix(auth): Critical - Correct JWT expiration to 1 hour" \
  --body "## 🚨 HOTFIX - Critical Priority

## Problem
Users logged out after 1 minute instead of 1 hour

## Root Cause
JWT_EXPIRY incorrectly set to 60 seconds

## Fix
Changed JWT_EXPIRY from 60 to 3600 (1 hour)

## Testing
- ✅ Unit tests verify 1-hour expiration
- ✅ Manual testing with test tokens
- ✅ Token refresh logic unaffected

## Impact
- Affects all authenticated users
- No breaking changes
- No database migration needed

Closes #5" \
  --label "type:hotfix" \
  --label "priority:critical"
```

---

#### 6. Fast-Track Review
```bash
# Request immediate review
gh pr review --request @tech-lead

# OR auto-approve if you have authority
gh pr review --approve --body "HOTFIX: Critical bug fix verified. Fast-tracking to production."

# Merge immediately after checks pass
gh pr merge --squash --delete-branch

# Wait for dev → staging sync (if complex strategy)
sleep 30
```

---

#### 7. Create Emergency Release
```bash
# Immediately create release PR (dev → main)
gh pr create \
  --base main \
  --head dev \
  --title "hotfix: Critical auth token expiration fix v1.0.1" \
  --body "## 🚨 HOTFIX RELEASE

## Critical Issue
JWT tokens expiring after 1 minute instead of 1 hour

## Fix
- Corrected JWT_EXPIRY constant (#5)

## Verification
- All quality checks passed
- Smoke tests passed
- Emergency deployment authorized

Closes #5" \
  --label "type:hotfix" \
  --label "priority:critical"

# Monitor release checks
gh pr checks

# Merge to main once checks pass
gh pr merge --squash
```

---

#### 8. Verify Hotfix Deployed
```bash
# Check issue closed
gh issue view 5
# Should be closed with "Released to production" comment

# Check project board
gh project view --owner USERNAME 1
# Issue #5 should be in "Done" column

# Optional: Verify production
# curl https://your-production-api.com/api/auth/status
```

---

### Expected Results

**Hotfix Workflow**:
- ✅ Critical issue created and labeled
- ✅ Hotfix branch created from appropriate base
- ✅ Fix applied and tested
- ✅ PR fast-tracked (minimal review time)
- ✅ Quality checks still enforced
- ✅ Emergency release to main
- ✅ Issue closed and marked done
- ✅ Production fix deployed

**Time**:
- ✅ Issue creation: 2 minutes
- ✅ Fix implementation: 5 minutes
- ✅ Testing: 2 minutes
- ✅ PR creation and merge: 3 minutes
- ✅ Release to production: 3 minutes
- ✅ **Total: ~15 minutes** (vs 30+ for normal workflow)

**Quality**:
- ✅ All tests still run
- ✅ Quality gates not skipped
- ✅ Proper audit trail maintained
- ✅ Fast but not reckless

---

### Actual Results

**Date Tested**: ___________
**Time Taken**: ___________

**Notes**:
___________

---

## Scenario 6: Status Synchronization

**Goal**: Test manual status synchronization and correction

**Prerequisites**:
- Multiple issues in various states
- Some issues may have incorrect statuses

**Duration**: ~10 minutes

### Steps

#### 1. Create Test Issues with Mismatched States
```bash
# Create issue that should be "In Progress" but is marked "Ready"
gh issue create \
  --title "Update API documentation" \
  --body "Update API docs with new endpoints" \
  --label "type:docs" \
  --label "status:ready"

# Note the issue number (e.g., #10)

# Create branch manually (simulating someone starting work)
git checkout -b feature/issue-10-update-api-docs
git push -u origin feature/issue-10-update-api-docs

# Issue is now "Ready" but work has started (should be "In Progress")
```

---

#### 2. Create Issue with PR but Wrong Status
```bash
# Create another issue
gh issue create \
  --title "Add health check endpoint" \
  --body "Add /health endpoint for monitoring" \
  --label "type:feature" \
  --label "status:ready"

# Note issue number (e.g., #11)

# Create branch and PR manually
git checkout -b feature/issue-11-add-health-check
git push -u origin feature/issue-11-add-health-check

# Create empty commit for PR
git commit --allow-empty -m "feat(api): add health check endpoint

Closes #11"
git push

# Create PR
gh pr create \
  --base dev \
  --title "feat(api): Add health check endpoint" \
  --body "Closes #11" \
  --label "type:feature"

# Issue is "Ready" but PR exists (should be "In Review")
```

---

#### 3. Run Manual Status Sync
```bash
# Use slash command to sync all issues
claude /sync-status

# OR trigger workflow manually
gh workflow run pr-status-sync.yml
```

**Monitor Output**:
```bash
# Check workflow logs
gh run list --workflow=pr-status-sync.yml --limit 1
gh run view --log
```

---

#### 4. Verify Status Corrections
```bash
# Check issue #10 status
gh issue view 10
# Should now show "status:in-progress" label

# Check issue #11 status
gh issue view 11
# Should now show "status:in-review" label

# Check project board
gh project view --owner USERNAME 1
# Issue #10 should be in "In Progress"
# Issue #11 should be in "In Review"
```

---

#### 5. Test Sync with Merged PR
```bash
# Merge PR #11
gh pr merge 11 --squash

# Wait for auto-sync
sleep 10

# Check issue #11
gh issue view 11
# Should show "status:to-deploy" label

# Check project board
# Issue #11 should be in "To Deploy" column
```

---

#### 6. Test Sync After Release
```bash
# Create release PR
gh pr create \
  --base main \
  --head dev \
  --title "release: API improvements v1.1.0" \
  --body "Closes #11"

# Get PR number (e.g., #12)

# Merge release PR
gh pr merge 12 --squash

# Wait for release-status-sync
sleep 10

# Check issue #11
gh issue view 11
# Should be closed

# Check project board
# Issue #11 should be in "Done"
```

---

### Expected Results

**Status Synchronization**:
- ✅ `/sync-status` identifies all inconsistencies
- ✅ Issues with branches → "In Progress"
- ✅ Issues with open PRs → "In Review"
- ✅ Issues with merged PRs → "To Deploy"
- ✅ Issues in main → "Done" (closed)
- ✅ Project board matches issue states
- ✅ No duplicate status labels
- ✅ Sync completes in <30 seconds

**Manual Corrections**:
- ✅ Can manually adjust statuses
- ✅ Next sync respects manual changes
- ✅ Conflicts resolved (PR state wins over label)

**Time**:
- ✅ Setup: 3 minutes
- ✅ Sync execution: <1 minute
- ✅ Verification: 2 minutes
- ✅ **Total: ~10 minutes**

---

### Actual Results

**Date Tested**: ___________
**Issues Synced**: ___________
**Corrections Made**: ___________

**Notes**:
___________

---

## Scenario 7: Quality Gate Failures

**Goal**: Test handling of lint, test, and build failures

**Prerequisites**:
- Working feature branch
- Ability to introduce intentional errors

**Duration**: ~15 minutes

### Steps

#### 1. Create Branch with Lint Errors
```bash
# Create new branch
git checkout dev
git pull
git checkout -b feature/test-quality-failures

# Create file with lint errors
cat > src/utils/buggy.ts <<'EOF'
export function calculateTotal(items: any[]) {
  let total = 0
  for (let i = 0; i < items.length; i++) {
    total += items[i].price
  }
  return total
}

// Unused variable (lint error)
const unused = "This will fail lint";

// Missing semicolons (lint error)
console.log("test")
EOF

# Commit
git add src/utils/buggy.ts
git commit -m "feat: add buggy calculation function"
git push -u origin feature/test-quality-failures
```

---

#### 2. Create PR and Monitor Failure
```bash
# Create PR
gh pr create \
  --base dev \
  --title "feat: Test quality gate failures" \
  --body "Testing lint failures" \
  --label "type:test"

# Monitor checks
gh pr checks

# Should see FAILED checks:
# ❌ lint - ESLint errors detected
```

**View Failure Details**:
```bash
# View workflow logs
gh run list --limit 1
gh run view --log

# Should see lint errors:
# - Unused variable 'unused'
# - Missing semicolons
```

---

#### 3. Fix Lint Errors
```bash
# Fix the file
cat > src/utils/buggy.ts <<'EOF'
export function calculateTotal(items: any[]): number {
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].price;
  }
  return total;
}
EOF

# Commit fix
git add src/utils/buggy.ts
git commit -m "fix: resolve lint errors"
git push
```

**Monitor Re-check**:
```bash
gh pr checks
# ✅ lint should now pass
```

---

#### 4. Introduce Type Error
```bash
# Add type error
cat > src/utils/buggy.ts <<'EOF'
export function calculateTotal(items: { price: number }[]): number {
  let total: number = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].name; // TYPE ERROR: name doesn't exist
  }
  return total;
}
EOF

git add src/utils/buggy.ts
git commit -m "feat: add type error"
git push
```

**Monitor Typecheck Failure**:
```bash
gh pr checks
# ❌ typecheck - Type errors detected
```

---

#### 5. Fix Type Error
```bash
cat > src/utils/buggy.ts <<'EOF'
export function calculateTotal(items: { price: number }[]): number {
  let total: number = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].price; // Fixed
  }
  return total;
}
EOF

git add src/utils/buggy.ts
git commit -m "fix: resolve type errors"
git push
```

---

#### 6. Introduce Test Failure
```bash
# Add failing test
cat > src/utils/__tests__/buggy.test.ts <<'EOF'
import { calculateTotal } from '../buggy';

describe('calculateTotal', () => {
  it('should calculate correct total', () => {
    const items = [{ price: 10 }, { price: 20 }];
    const result = calculateTotal(items);
    expect(result).toBe(100); // WRONG: Should be 30
  });
});
EOF

git add src/utils/__tests__/buggy.test.ts
git commit -m "test: add failing test"
git push
```

**Monitor Test Failure**:
```bash
gh pr checks
# ❌ test-unit - Tests failed

# View failure
gh run view --log
# Expected: 100
# Received: 30
```

---

#### 7. Fix Test
```bash
# Fix test assertion
cat > src/utils/__tests__/buggy.test.ts <<'EOF'
import { calculateTotal } from '../buggy';

describe('calculateTotal', () => {
  it('should calculate correct total', () => {
    const items = [{ price: 10 }, { price: 20 }];
    const result = calculateTotal(items);
    expect(result).toBe(30); // Correct
  });
});
EOF

git add src/utils/__tests__/buggy.test.ts
git commit -m "fix: correct test assertion"
git push
```

**Verify All Pass**:
```bash
gh pr checks
# ✅ lint
# ✅ typecheck
# ✅ test-unit
# ✅ All checks passed
```

---

#### 8. Test PR Merge Blocking
```bash
# Try to merge before checks pass (if you introduced errors again)
gh pr merge --squash
# Should get error: "Required status checks have not passed"

# After all checks pass
gh pr merge --squash --delete-branch
# Should succeed
```

---

### Expected Results

**Quality Gate Behavior**:
- ✅ Lint errors block PR merge
- ✅ Type errors block PR merge
- ✅ Test failures block PR merge
- ✅ Build errors block PR merge
- ✅ Clear error messages in PR checks
- ✅ Failed workflow logs accessible
- ✅ Retries work after fixes
- ✅ PR mergeable only after all checks pass

**Developer Experience**:
- ✅ Fast feedback (<2 minutes per check)
- ✅ Clear error messages
- ✅ Easy to identify which check failed
- ✅ Logs accessible for debugging
- ✅ No manual re-trigger needed (auto on push)

**Time**:
- ✅ Setup: 2 minutes
- ✅ Each failure cycle: 2-3 minutes
- ✅ **Total: ~15 minutes for 3 failure types**

---

### Actual Results

**Date Tested**: ___________
**Failure Types Tested**: ___________

**Notes**:
___________

---

## Scenario 8: Emergency Procedures

**Goal**: Test kill switch and rollback mechanisms

**Prerequisites**:
- System operational
- Understanding of emergency procedures

**Duration**: ~10 minutes

### Steps

#### 1. Test Kill Switch Activation
```bash
# Activate kill switch using slash command
claude /kill-switch disable

# OR create killswitch file manually
echo "WORKFLOWS_DISABLED: true
REASON: Testing kill switch
DATE: $(date)
CONTACT: your-email@example.com" > WORKFLOW_KILLSWITCH

git add WORKFLOW_KILLSWITCH
git commit --no-verify -m "emergency: activate workflow kill switch"
git push
```

**Verify Kill Switch Active**:
```bash
# Try to trigger a workflow
gh workflow run bootstrap.yml

# Check if it runs or gets killed
gh run list --limit 1
```

---

#### 2. Verify Workflows Respect Kill Switch
```bash
# Try to create a PR (should trigger pr-into-dev)
git checkout -b test/kill-switch-test
git commit --allow-empty -m "test: verify kill switch"
git push -u origin test/kill-switch-test

gh pr create \
  --base dev \
  --title "test: Verify kill switch" \
  --body "Testing kill switch"

# Check workflow
gh run list --workflow=pr-into-dev.yml --limit 1

# Workflow should either:
# - Not trigger, OR
# - Exit immediately with message about kill switch
```

---

#### 3. Check Kill Switch Status
```bash
# Using slash command
claude /kill-switch status

# OR manual check
cat WORKFLOW_KILLSWITCH
gh run list --limit 5
```

---

#### 4. Deactivate Kill Switch
```bash
# Using slash command
claude /kill-switch enable

# OR manual removal
git rm WORKFLOW_KILLSWITCH
git commit -m "emergency: deactivate workflow kill switch - issue resolved"
git push
```

**Verify Workflows Resume**:
```bash
# Try triggering workflow again
gh workflow run bootstrap.yml

# Check it runs successfully
gh run list --limit 1
```

---

#### 5. Test Rollback Scenario

**Simulate Bad Deployment**:
```bash
# Assume a bad release was merged to main
# Need to rollback to previous working version

# View commit history
git log --oneline -5 main

# Identify last working commit (e.g., abc1234)
# Identify bad commit (e.g., def5678)
```

**Create Revert PR**:
```bash
# Checkout main
git checkout main
git pull

# Create revert branch
git checkout -b revert/bad-deployment

# Revert the bad commit
git revert def5678 --no-edit

# Push revert
git push -u origin revert/bad-deployment

# Create emergency revert PR
gh pr create \
  --base main \
  --head revert/bad-deployment \
  --title "revert: Rollback bad deployment (def5678)" \
  --body "## 🚨 EMERGENCY ROLLBACK

## Issue
Bad deployment causing production issues

## Commit Being Reverted
- Commit: def5678
- Reason: [Describe issue]

## Impact
- Affected users: [Describe]
- Downtime: [Estimate]

## Verification
- Previous working version: abc1234
- Revert tested locally

## Post-Rollback Actions
- [ ] Investigate root cause
- [ ] Create fix
- [ ] Test thoroughly before re-deploy" \
  --label "type:hotfix" \
  --label "priority:critical"

# Fast-track merge
gh pr review --approve
gh pr merge --squash
```

---

#### 6. Verify Rollback
```bash
# Check main branch
git checkout main
git pull
git log --oneline -3

# Should see revert commit at top

# Verify production (if deployed)
# curl https://your-production-api.com/health
```

---

### Expected Results

**Kill Switch**:
- ✅ Kill switch activates immediately
- ✅ All workflows respect kill switch
- ✅ Clear status visible
- ✅ Easy to activate/deactivate
- ✅ Bypass commit hooks when needed
- ✅ Audit trail maintained

**Rollback**:
- ✅ Revert commit created correctly
- ✅ Emergency PR fast-tracked
- ✅ Previous working state restored
- ✅ No data loss
- ✅ Audit trail clear

**Time**:
- ✅ Kill switch activation: <1 minute
- ✅ Verification: 2 minutes
- ✅ Rollback execution: 5 minutes
- ✅ **Total: ~10 minutes**

**Recovery**:
- ✅ System returns to normal after procedures
- ✅ No side effects from emergency actions

---

### Actual Results

**Date Tested**: ___________
**Emergency Type**: ___________

**Kill Switch**:
- Activation Time: ___________
- Deactivation Time: ___________

**Rollback**:
- Revert Time: ___________

**Notes**:
___________

---

## 📊 Test Summary

**Testing Completed By**: ___________
**Date Range**: ___________ to ___________
**Total Time Invested**: ___________

### Overall Results

| Scenario | Status | Time | Issues Found |
|----------|--------|------|--------------|
| 1. First-Time Setup | ❌ | _____ | _____ |
| 2. Manual Setup | ❌ | _____ | _____ |
| 3. Plan to Production | ❌ | _____ | _____ |
| 4. Feature Development | ❌ | _____ | _____ |
| 5. Hotfix Workflow | ❌ | _____ | _____ |
| 6. Status Synchronization | ❌ | _____ | _____ |
| 7. Quality Gate Failures | ❌ | _____ | _____ |
| 8. Emergency Procedures | ❌ | _____ | _____ |

**Legend**: ✅ Passed | ⚠️ Passed with Issues | ❌ Failed | ⏳ Not Tested

---

### Critical Issues Found

1. ___________
2. ___________
3. ___________

### Minor Issues Found

1. ___________
2. ___________
3. ___________

### Improvements Recommended

1. ___________
2. ___________
3. ___________

---

## 🔄 Retesting Checklist

After fixes are applied:

- [ ] Re-run failed scenarios
- [ ] Verify all issues resolved
- [ ] Document any workarounds
- [ ] Update troubleshooting docs if needed
- [ ] Mark scenarios as ✅ when passing

---

## 📝 Additional Notes

**Environment Details**:
- OS: ___________
- Node Version: ___________
- pnpm Version: ___________
- gh CLI Version: ___________

**Repository**:
- Owner: ___________
- Name: ___________
- Project Board: ___________

**Notes**:
___________

---

## ✅ Certification

I certify that the above testing scenarios have been completed according to the specified procedures.

**Name**: ___________
**Date**: ___________
**Signature**: ___________

---

**Generated with [Claude Code](https://claude.com/claude-code)**

**Co-Authored-By**: Claude <noreply@anthropic.com>
