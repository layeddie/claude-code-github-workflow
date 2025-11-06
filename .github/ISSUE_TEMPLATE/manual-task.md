---
name: Manual Task
about: Create a task manually (use this for user-created issues)
title: ''
labels: ['status:to-triage']
assignees: ''
---

## Description
<!-- Provide a clear and concise description of the task -->



## Problem Statement
<!-- What problem does this solve? Why is this needed? -->



## Acceptance Criteria
<!-- Define what "done" looks like for this task -->

- [ ]
- [ ]
- [ ]

## Type
<!-- Check one that best describes this task -->

- [ ] ✨ Feature (new functionality)
- [ ] 🐛 Bug Fix (fix an issue)
- [ ] 📝 Documentation (docs update)
- [ ] ♻️ Refactor (code improvement)
- [ ] ✅ Test (add/update tests)
- [ ] 🔧 Configuration (settings, setup)
- [ ] ⚡ Performance (optimization)
- [ ] 🔒 Security (security improvement)

## Priority
<!-- Check one -->

- [ ] 🔴 Critical (blocking, immediate attention)
- [ ] 🟠 High (important, should be done soon)
- [ ] 🟡 Medium (normal priority)
- [ ] 🟢 Low (nice to have, when time permits)

## Platform
<!-- Check all that apply -->

- [ ] 🌐 Web
- [ ] 📱 Mobile (iOS)
- [ ] 📱 Mobile (Android)
- [ ] 🔧 Infrastructure/DevOps
- [ ] 📚 Documentation

## Estimated Effort
<!-- Optional: How much effort do you estimate? -->

- [ ] XS (< 2 hours)
- [ ] S (2-4 hours)
- [ ] M (1-2 days)
- [ ] L (3-5 days)
- [ ] XL (> 1 week)

## Dependencies
<!-- Are there any dependencies on other issues or tasks? -->

**Depends on:**
<!-- - #123 -->
<!-- - #456 -->

**Blocks:**
<!-- - #789 -->

## Implementation Notes
<!-- Optional: Technical details, approach suggestions, or constraints -->



## Additional Context
<!-- Optional: Add any other context, screenshots, or references -->



---

## For Maintainers

**To enable automated workflows for this issue:**
1. Review and triage this issue
2. Add appropriate labels:
   - Add `claude-code` label to enable automation
   - Change `status:to-triage` to `status:ready` when ready to work
3. Assign to milestone (optional)
4. Auto-branch will be created once labeled correctly

**Labels for automation:**
- `claude-code` + `status:ready` = Auto-branch creation
- Without these labels = Manual workflow only
