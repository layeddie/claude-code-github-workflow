# Web Example - Next.js with GitHub Workflow Blueprint

A minimal Next.js 14 application pre-configured with the GitHub Workflow Blueprint for demonstration and testing purposes.

---

## 📋 Overview

This example demonstrates:
- ✅ Next.js 14 with App Router and TypeScript
- ✅ Blueprint workflows pre-configured
- ✅ Example Claude plan (5 tasks)
- ✅ Sample test data (issues, PRs)
- ✅ Works out of the box

**Perfect for**:
- Testing the blueprint in a real project
- Learning the workflow
- Training new team members
- Quick demos

---

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- pnpm 9+ (or npm/yarn)
- GitHub CLI (`gh`) authenticated
- Git configured

### Installation

```bash
# 1. Navigate to this example
cd examples/web

# 2. Install dependencies
pnpm install

# 3. Start development server
pnpm dev
```

Visit `http://localhost:3000` to see the app running.

---

## 🔧 Blueprint Setup

### Option 1: Using the Wizard (Recommended)

```bash
# From the repository root
cd ../..
./setup/wizard.sh

# Select:
# - Project type: Web (1)
# - Branching strategy: Standard (2)
# - Provide your Project URL
# - Provide your Anthropic API key
```

### Option 2: Manual Setup

```bash
# 1. Create dev branch
git checkout -b dev
git push -u origin dev
git checkout main

# 2. Set secrets
gh secret set PROJECT_URL --body "https://github.com/users/YOUR_USERNAME/projects/1"
gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."

# 3. Run bootstrap
gh workflow run bootstrap.yml

# 4. Verify setup
cd ../..
./setup/validate.sh
```

---

## 📝 Example Workflow

### Step 1: Convert Plan to Issues

The included `plan.json` contains 5 tasks for building a simple todo app.

```bash
# From repository root
claude /plan-to-issues examples/web/plan.json

# OR trigger workflow directly
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat examples/web/plan.json)"
```

**Expected**: 5 issues created with labels and milestone.

---

### Step 2: View Created Issues

```bash
gh issue list --label "claude-code"
```

You should see:
- Issue #1: Setup Next.js project structure
- Issue #2: Create Todo data model
- Issue #3: Build Todo list UI component
- Issue #4: Add create/delete Todo functionality
- Issue #5: Add Todo filtering (all/active/completed)

---

### Step 3: Start Working on Issue #1

```bash
# Wait 10 seconds for auto-branch creation
sleep 10

# Fetch new branches
git fetch

# Checkout the auto-created branch
git checkout feature/issue-1-setup-nextjs-project-structure
```

---

### Step 4: Implement Feature

```bash
# Create component structure
mkdir -p src/components

# Work on the feature (files already exist in this example)
# ...

# Commit changes
claude /commit-smart

# OR manual commit
git add .
git commit -m "feat(structure): setup Next.js project structure

- Add components directory
- Configure TypeScript
- Setup basic layout

Closes #1"
```

---

### Step 5: Create Pull Request

```bash
# Using slash command
claude /create-pr

# OR manual PR
gh pr create \
  --base dev \
  --title "feat(structure): Setup Next.js project structure" \
  --body "Closes #1"
```

---

### Step 6: Monitor Quality Checks

```bash
# Watch PR checks
gh pr checks

# View workflow logs
gh run watch
```

Expected checks:
- ✅ lint
- ✅ typecheck
- ✅ test-unit
- ✅ pr-into-dev validation

---

### Step 7: Merge PR

```bash
# Once checks pass
gh pr merge --squash --delete-branch
```

**Automatic Updates**:
- Issue #1 status → "To Deploy"
- Project board → "To Deploy" column
- Source branch deleted

---

### Step 8: Repeat for Other Issues

Follow the same process for issues #2-5:
1. Wait for auto-branch creation
2. Checkout branch
3. Implement feature
4. Commit with `/commit-smart`
5. Create PR with `/create-pr`
6. Merge after checks pass

---

### Step 9: Release to Main

```bash
# Create release PR
claude /release

# OR manual PR
gh pr create \
  --base main \
  --head dev \
  --title "release: Todo App v1.0.0" \
  --body "Initial release with complete Todo functionality.

## Features
- Project structure (#1)
- Todo data model (#2)
- Todo list UI (#3)
- Create/delete functionality (#4)
- Filtering (#5)

Closes #1, #2, #3, #4, #5"
```

---

### Step 10: Deploy to Production

```bash
# Merge release PR
gh pr merge --squash

# Verify issues closed
gh issue list --state closed --label "claude-code"
```

**Automatic Updates**:
- All 5 issues closed
- All issues → "Done" on project board
- Release comment added to each issue

---

## 📦 What's Included

### Application Files

```
examples/web/
├── README.md (this file)
├── package.json (Next.js 14, TypeScript, Jest)
├── tsconfig.json (TypeScript configuration)
├── next.config.js (Next.js configuration)
├── .gitignore (Standard Next.js gitignore)
├── src/
│   ├── app/
│   │   ├── layout.tsx (Root layout with metadata)
│   │   ├── page.tsx (Home page with demo content)
│   │   └── globals.css (Global styles)
│   └── components/ (Component directory)
├── plan.json (5-task example plan)
└── test-data/
    ├── example-issue.json (Sample issue format)
    └── example-pr.json (Sample PR format)
```

### Blueprint Files (from root)

The blueprint workflows are located in the repository root:
- `.github/workflows/` - 8 core workflows
- `.github/actions/` - 5 composite actions
- `.claude/commands/github/` - 8 slash commands
- `.claude/agents/` - 4 specialized agents

---

## 🧪 Testing the Blueprint

### Run All Quality Checks

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

All checks should pass ✅

---

### Test Individual Workflows

**Test bootstrap workflow**:
```bash
gh workflow run bootstrap.yml
gh run list --workflow=bootstrap.yml --limit 1
```

**Test plan-to-issues**:
```bash
gh workflow run claude-plan-to-issues.yml \
  -f plan_json="$(cat plan.json)"
```

**Test PR checks**:
```bash
# Create a test branch and PR
git checkout -b test/pr-checks
git commit --allow-empty -m "test: trigger PR checks"
git push -u origin test/pr-checks
gh pr create --base dev --title "test: PR checks" --body "Testing"
gh pr checks
```

---

## 📊 Example Plan Details

The included `plan.json` contains 5 tasks for building a simple Todo application:

### Task 1: Project Structure
- Setup Next.js project organization
- Configure TypeScript and ESLint
- Create component directories

### Task 2: Data Model
- Define Todo interface
- Create sample data
- Setup data utilities

### Task 3: List UI
- Build TodoList component
- Add TodoItem component
- Style with CSS modules

### Task 4: CRUD Operations
- Add Todo creation form
- Implement delete functionality
- Update state management

### Task 5: Filtering
- Add filter buttons (All/Active/Completed)
- Implement filter logic
- Persist filter selection

**Dependencies**: Tasks 3, 4, and 5 depend on Task 2 (data model).

---

## 🔍 Test Data

### example-issue.json

Sample issue format created by `claude-plan-to-issues.yml`:

```json
{
  "title": "Setup Next.js project structure",
  "body": "## Description\nConfigure Next.js project...",
  "labels": ["claude-code", "status:ready", "type:feature", "platform:web"],
  "milestone": "Todo App MVP"
}
```

### example-pr.json

Sample PR format created by workflow:

```json
{
  "title": "feat(structure): Setup Next.js project structure",
  "body": "## Summary\n...\n\nCloses #1",
  "base": "dev",
  "head": "feature/issue-1-setup-nextjs-project-structure",
  "labels": ["type:feature", "platform:web"]
}
```

---

## 🎓 Learning Resources

### Blueprint Documentation

- **Quick Start**: `../../docs/QUICK_START.md`
- **Complete Setup**: `../../docs/COMPLETE_SETUP.md`
- **Workflows Reference**: `../../docs/WORKFLOWS.md`
- **Commands Reference**: `../../docs/COMMANDS.md`
- **Troubleshooting**: `../../docs/TROUBLESHOOTING.md`

### Test Scenarios

- **End-to-End Testing**: `../../tests/scenarios.md`
- Run Scenario 3 (Plan to Production) using this example

---

## 🐛 Troubleshooting

### Issue: "workflow not found"

**Cause**: Workflows not in `.github/workflows/`

**Solution**: Ensure you're running commands from repository root, not `examples/web/`

```bash
cd ../..
gh workflow list
```

---

### Issue: "no such file: plan.json"

**Cause**: Wrong directory

**Solution**: Use full path to plan.json

```bash
# From repository root
claude /plan-to-issues examples/web/plan.json
```

---

### Issue: "permission denied" on workflows

**Cause**: Insufficient repository permissions

**Solution**: Ensure you have admin access or workflows are enabled

```bash
gh repo view --json owner,name,hasIssuesEnabled,hasWikiEnabled
```

---

### Issue: Quality checks fail

**Cause**: Code doesn't pass lint/type/test checks

**Solution**: Run checks locally first

```bash
cd examples/web
pnpm run lint
pnpm run type-check
pnpm run test
pnpm run build
```

Fix any errors before committing.

---

## 🔄 Reset Example

To reset this example to its initial state:

```bash
# Delete all issues
gh issue list --label "claude-code" --json number --jq '.[].number' | \
  xargs -I {} gh issue close {}

# Delete dev branch
git push origin --delete dev

# Delete all feature branches
git branch -r | grep "origin/feature/" | \
  sed 's/origin\///' | xargs -I {} git push origin --delete {}

# Re-run setup
cd ../..
./setup/wizard.sh
```

---

## 🎯 Next Steps

1. **Complete the workflow**: Follow Steps 1-10 above to experience the full cycle
2. **Customize**: Modify `plan.json` for your own project ideas
3. **Experiment**: Try different branching strategies and configurations
4. **Learn slash commands**: Practice with `/commit-smart`, `/create-pr`, `/review-pr`
5. **Test edge cases**: Try the scenarios in `../../tests/scenarios.md`

---

## 📝 Notes

- This is a **minimal example** - production apps need more (auth, database, deployment)
- The example focuses on **workflow demonstration**, not app functionality
- All components are intentionally simple for clarity
- Feel free to extend and customize for your needs

---

## 🤝 Contributing

Found an issue or improvement for this example?
1. Create an issue describing the problem
2. Submit a PR with the fix
3. Follow the blueprint workflow!

---

## 📄 License

Same as the parent repository - see `../../LICENSE`

---

**Generated with [Claude Code](https://claude.com/claude-code)**

**Co-Authored-By**: Claude <noreply@anthropic.com>
