# Cloudflare Pages — fuzzynacho.org

Production deploys from **`master`** on [cramd/fuzzynacho](https://github.com/cramd/fuzzynacho).

## Build settings

| Setting | Value |
|--------|--------|
| Production branch | `master` |
| Build command | `npm run build` (runs `blog/`) |
| Output directory | `blog/dist` |
| Node.js version | `22` |

## Custom domains

- `www.fuzzynacho.org` (blog at `/blog`)
- `fuzzynacho.org` (redirects to `www` via `blog/public/_redirects`)

**Stays on homelab (Caddy):** `battery.`, `dir.`, `legacylink.`, `proserveability.` subdomains.

The old `localhost:3000` portal on `www` is retired until relocated (e.g. `app.fuzzynacho.org`).

## DNS (Cloudflare dashboard)

In the **fuzzynacho.org** zone:

1. Remove **A** records for `@` and `www` that point at the homelab IP.
2. Add **proxied CNAME** `@` → `fuzzynacho.pages.dev`
3. Add **proxied CNAME** `www` → `fuzzynacho.pages.dev`
4. Do **not** change `battery`, `dir`, `legacylink`, `proserveability`, etc.

Or: `CF_API_TOKEN=… npm run dns:pages`

When Pages shows both domains **Active**, run `./scripts/apply-homelab-caddy-cutover.sh`.

## Commands

- `npm run deploy:pages` — manual Wrangler upload
- `CF_API_TOKEN=… npm run dns:pages` — apex + www → Pages
- `npm run deploy:homelab:legacy` — old rsync for `/var/www/blog` (emergency only)