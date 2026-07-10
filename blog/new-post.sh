#!/usr/bin/env bash
# Usage: ./new-post.sh [--deploy] <slug>
#
# Reads Markdown from the clipboard and saves it to src/content/blog/<slug>.md,
# then creates a matching image folder at public/images/blog/<slug>/.
# Run from anywhere; the script anchors itself to the blog directory.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./new-post.sh [--deploy] <slug>

  slug       URL-friendly post name, e.g. my-article-slug

Options:
  --deploy   Build and deploy via ../deploy.sh after staging files

Examples:
  ./new-post.sh my-article-slug
  ./new-post.sh --deploy my-article-slug
EOF
}

deploy_after=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deploy)
      deploy_after=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  echo "Error: Please provide a slug." >&2
  usage >&2
  exit 1
fi

SLUG="$1"

CONTENT_DIR="$SCRIPT_DIR/src/content/blog"
IMAGES_DIR="$SCRIPT_DIR/public/images/blog/$SLUG"

mkdir -p "$CONTENT_DIR"
mkdir -p "$IMAGES_DIR"

POST_FILE="$CONTENT_DIR/$SLUG.md"

pbpaste > "$POST_FILE"

if [[ ! -s "$POST_FILE" ]]; then
  echo "Warning: clipboard was empty — $POST_FILE was created but is blank." >&2
fi

# Normalize image paths: replace any /images/blog/<any-slug>/ with the correct
# /blog/images/blog/<slug>/ so the base path and slug always match what was deployed.
sed -i '' \
  -e "s|/images/blog/[^/]*/|/blog/images/blog/$SLUG/|g" \
  -e "s|coverImage: \"/blog/blog/|coverImage: \"/blog/|g" \
  "$POST_FILE"

echo "Created: src/content/blog/$SLUG.md"
echo "Ready for images: public/images/blog/$SLUG/"

if [[ "$deploy_after" == true ]]; then
  "$SCRIPT_DIR/../deploy.sh"
else
  echo ""
  echo "Next steps:"
  echo "  1. Drop images into: public/images/blog/$SLUG/"
  echo "  2. Deploy with:      $SCRIPT_DIR/../deploy.sh"
fi
