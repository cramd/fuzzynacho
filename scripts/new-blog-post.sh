#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/new-blog-post.sh [--deploy] <post.md> [image ...]

Copies a blog post into blog/src/pages and any images into blog/public/images.
Run from anywhere; relative paths are resolved from your current directory.

Examples:
  ./scripts/new-blog-post.sh ~/Desktop/blogcontent.md ~/Desktop/hero.jpg
  ./scripts/new-blog-post.sh --deploy blogcontent.md images/*.png
EOF
}

deploy_after_copy=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deploy)
      deploy_after_copy=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
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
  usage >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PAGES_DIR="$REPO_ROOT/blog/src/pages"
IMAGES_DIR="$REPO_ROOT/blog/public/images"

post_path="$1"
shift

if [[ ! -f "$post_path" ]]; then
  echo "Post file not found: $post_path" >&2
  exit 1
fi

if [[ "${post_path##*.}" != "md" ]]; then
  echo "Post file must be a .md file: $post_path" >&2
  exit 1
fi

mkdir -p "$PAGES_DIR" "$IMAGES_DIR"

post_name="$(basename -- "$post_path")"
cp "$post_path" "$PAGES_DIR/$post_name"
echo "Copied post: blog/src/pages/$post_name"

for image_path in "$@"; do
  if [[ ! -f "$image_path" ]]; then
    echo "Image file not found: $image_path" >&2
    exit 1
  fi

  image_name="$(basename -- "$image_path")"
  cp "$image_path" "$IMAGES_DIR/$image_name"
  echo "Copied image: blog/public/images/$image_name"
done

if [[ "$deploy_after_copy" == true ]]; then
  "$REPO_ROOT/deploy.sh"
else
  echo "Done. Deploy with: $REPO_ROOT/deploy.sh"
fi
