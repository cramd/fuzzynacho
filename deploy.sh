#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BLOG_DIR="$SCRIPT_DIR/blog"

echo "==> Building Astro Blog"
cd "$BLOG_DIR"
npm install
npm run build

echo "==> Deploying to Proxmox server"
rsync -avz --delete \
    -e "ssh -p 22" \
    "$BLOG_DIR/dist/" \
    root@192.168.0.62:/var/www/blog/

echo "==> Deployment Complete!"
echo "    (Legacy homelab rsync — production is Cloudflare Pages; see docs/cloudflare-pages.md)"
