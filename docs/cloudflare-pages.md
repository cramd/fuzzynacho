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

## Commands

- `npm run deploy:pages` — manual Wrangler upload
- `npm run deploy:homelab:legacy` — old rsync for `/var/www/blog` (emergency only)