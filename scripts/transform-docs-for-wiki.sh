#!/bin/bash

# Transform documentation from docs/ folder to GitHub Wiki format
# Handles link conversion, filename normalization, and content adaptation

set -e

# Configuration
SOURCE_DIR="${SOURCE_DIR:-docs}"
OUTPUT_DIR="${OUTPUT_DIR:-wiki}"
REPO_NAME="${REPO_NAME:-your-org/your-repo}"

echo "🔄 Transforming documentation for GitHub Wiki..."
echo "   Source: $SOURCE_DIR"
echo "   Output: $OUTPUT_DIR"

# Create clean output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Function to convert filename to wiki page name
# Example: QUICK_START.md → Quick-Start.md
convert_to_wiki_name() {
    local filename="$1"
    local basename="${filename%.md}"

    # Convert underscores and spaces to hyphens
    basename="${basename//_/-}"
    basename="${basename// /-}"

    # Capitalize first letter of each word
    basename=$(echo "$basename" | sed 's/-\(.\)/\U\1/g' | sed 's/^\(.\)/\U\1/')

    echo "${basename}.md"
}

# Function to transform internal links
# Converts: [text](./file.md) → [[Page Name|file]]
# Converts: [text](../file.md) → [[Page Name|file]]
# Converts: [text](file.md#section) → [[file#section]]
transform_links() {
    local content="$1"

    # Transform relative doc links to wiki links
    # Pattern 1: [text](./file.md) or [text](file.md)
    content=$(echo "$content" | sed -E 's|\[([^]]+)\]\(\./([^)#]+)\.md\)|[[\2\|\1]]|g')
    content=$(echo "$content" | sed -E 's|\[([^]]+)\]\(([^/)#]+)\.md\)|[[\2\|\1]]|g')

    # Pattern 2: [text](file.md#section)
    content=$(echo "$content" | sed -E 's|\[([^]]+)\]\(([^/)]+)\.md#([^)]+)\)|[[\2#\3\|\1]]|g')

    # Pattern 3: [text](../docs/file.md)
    content=$(echo "$content" | sed -E 's|\[([^]]+)\]\(\.\./docs/([^)#]+)\.md\)|[[\2\|\1]]|g')

    # Convert kebab-case and snake_case wiki links to Title-Case
    content=$(echo "$content" | perl -pe 's/\[\[([a-z0-9_-]+)(\||\]\])/my $s=$1; $s=~s|[-_]([a-z])|uc($1)|ge; $s=~s|^([a-z])|uc($1)|e; "[[$s$2"/ge')

    echo "$content"
}

# Function to add wiki navigation footer
add_wiki_footer() {
    local page_name="$1"
    local content="$2"

    # Don't add footer to special pages
    if [[ "$page_name" =~ ^_(Sidebar|Footer)\.md$ ]]; then
        echo "$content"
        return
    fi

    cat << EOF

$content

---

**Navigation:** [[Home]] | [[Quick Start|Quick-Start]] | [[Workflows]] | [[Commands]] | [[Troubleshooting]]

_This page is automatically synced from the [docs/](https://github.com/$REPO_NAME/tree/main/docs) folder._
EOF
}

# Process each markdown file in docs/
echo "📄 Processing documentation files..."

file_count=0

while IFS= read -r -d '' source_file; do
    # Get relative path from docs/
    rel_path="${source_file#$SOURCE_DIR/}"

    # Skip certain files
    if [[ "$rel_path" =~ ^\..*|README\.md$ ]]; then
        echo "   ⏭️  Skipping: $rel_path"
        continue
    fi

    # Convert filename to wiki format
    wiki_name=$(convert_to_wiki_name "$(basename "$rel_path")")
    output_file="$OUTPUT_DIR/$wiki_name"

    echo "   📝 Processing: $rel_path → $wiki_name"

    # Read source content
    content=$(<"$source_file")

    # Transform links
    content=$(transform_links "$content")

    # Add wiki navigation footer
    content=$(add_wiki_footer "$wiki_name" "$content")

    # Remove any YAML frontmatter (if present from static site generators)
    content=$(echo "$content" | awk 'BEGIN{p=1} /^---$/{if(NR==1){p=0}else if(p==0){p=1;next}} p')

    # Write to output
    echo "$content" > "$output_file"

    file_count=$((file_count + 1))

done < <(find "$SOURCE_DIR" -name "*.md" -type f -print0)

echo "✅ Processed $file_count documentation files"

# Copy README.md as a reference page (optional)
if [ -f "README.md" ]; then
    echo "📄 Processing README.md..."
    content=$(<"README.md")
    content=$(transform_links "$content")
    content=$(add_wiki_footer "README.md" "$content")
    echo "$content" > "$OUTPUT_DIR/README.md"
    echo "✅ README.md copied to wiki"
fi

# Create a manifest file for tracking
cat > "$OUTPUT_DIR/.manifest" << EOF
# Wiki Content Manifest
Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Source: $SOURCE_DIR
Files processed: $file_count
Repository: $REPO_NAME

## Pages Created:
EOF

find "$OUTPUT_DIR" -name "*.md" -type f | sort | while read -r file; do
    page_name=$(basename "$file" .md)
    echo "- $page_name" >> "$OUTPUT_DIR/.manifest"
done

echo "✅ Transformation complete!"
echo "📁 Wiki content ready in: $OUTPUT_DIR"
echo "📄 Total pages: $(find "$OUTPUT_DIR" -name "*.md" | wc -l | tr -d ' ')"
