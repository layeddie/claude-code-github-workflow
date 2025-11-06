#!/bin/bash

# Generate GitHub Wiki sidebar navigation from documentation structure
# This script creates _Sidebar.md with hierarchical navigation

set -e

# Configuration
WIKI_DIR="${WIKI_DIR:-wiki}"
REPO_URL="${REPO_URL:-https://github.com/your-org/your-repo}"
PAGES_URL="${PAGES_URL:-https://your-org.github.io/your-repo}"

echo "📝 Generating wiki sidebar navigation..."

# Create sidebar file
SIDEBAR_FILE="$WIKI_DIR/_Sidebar.md"

cat > "$SIDEBAR_FILE" << 'SIDEBAR_START'
# Navigation

## 🚀 Getting Started

- [[Home]]
- [[Quick Start|Quick-Start]]
- [[Complete Setup|Complete-Setup]]

## 📋 Core Workflows

- [[Workflows Overview|Workflows]]
- [[Bootstrap Workflow|Workflows#bootstrap-workflow]]
- [[PR Quality Checks|Workflows#reusable-pr-checks]]
- [[PR into Dev|Workflows#pr-into-dev]]
- [[Dev to Main|Workflows#dev-to-main]]
- [[Plan to Issues|Workflows#claude-plan-to-issues]]
- [[Auto Branch Creation|Workflows#create-branch-on-issue]]
- [[PR Status Sync|Workflows#pr-status-sync]]
- [[Release Status Sync|Workflows#release-status-sync]]

## 💻 Slash Commands

- [[Commands Overview|Commands]]
- [[/blueprint-init|Commands#blueprint-init]]
- [[/plan-to-issues|Commands#plan-to-issues]]
- [[/commit-smart|Commands#commit-smart]]
- [[/create-pr|Commands#create-pr]]
- [[/review-pr|Commands#review-pr]]
- [[/release|Commands#release]]
- [[/sync-status|Commands#sync-status]]
- [[/kill-switch|Commands#kill-switch]]

## 📚 Guides

- [[Troubleshooting]]
- [[Customization]]
- [[Architecture]]

## 📖 Reference

- [[Phase 1 Workplan|PHASE1-WORKPLAN]]
- [[Phase 2 Workplan|PHASE2-WORKPLAN]]
- [[Phase 3 Workplan|PHASE3-WORKPLAN]]

SIDEBAR_START

# Add external links section
cat >> "$SIDEBAR_FILE" << SIDEBAR_EXTERNAL

---

## 🔗 External Links

- [📖 Full Docs Site]($PAGES_URL)
- [🏠 Repository]($REPO_URL)
- [🐛 Issues]($REPO_URL/issues)
- [💬 Discussions]($REPO_URL/discussions)
- [📦 Releases]($REPO_URL/releases)

---

_Auto-generated sidebar_
SIDEBAR_EXTERNAL

echo "✅ Sidebar created at $SIDEBAR_FILE"

# Count pages in wiki
page_count=$(find "$WIKI_DIR" -name "*.md" -not -name "_*" | wc -l | tr -d ' ')
echo "📄 Sidebar will link to $page_count documentation pages"

# Validate sidebar links
echo "🔍 Validating sidebar links..."

# Extract all wiki links from sidebar
wiki_links=$(grep -oE '\[\[[^]]+\]\]' "$SIDEBAR_FILE" | sed 's/\[\[\([^]|]*\).*/\1/' | sort -u)

# Check if corresponding pages exist
missing_pages=0
for link in $wiki_links; do
    # Convert wiki link to filename
    filename="$WIKI_DIR/${link}.md"

    # Handle special cases
    if [ "$link" = "Home" ]; then
        continue  # Home.md is created separately
    fi

    # Check if file exists (case-insensitive search)
    if ! find "$WIKI_DIR" -iname "${link}.md" -type f | grep -q .; then
        echo "⚠️  Warning: Page not found for link: $link"
        missing_pages=$((missing_pages + 1))
    fi
done

if [ $missing_pages -eq 0 ]; then
    echo "✅ All sidebar links validated successfully"
else
    echo "⚠️  $missing_pages sidebar link(s) may not have corresponding pages"
    echo "   This is OK if pages are referenced with anchors (#section)"
fi

echo "✅ Sidebar generation complete!"
