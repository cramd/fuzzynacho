# Rules

- We must ensure that we do not leak any secrets ever. 
- Keeping API costs down is a key goal, unless a direct command to do otherwise is given. 
- This is locally hosted (on Proxmox and Caddy), so keep that in mind when making decisions.

## Production Deployment Details (Proxmox + Caddy)
- **Server IP:** `192.168.0.62`
- **SSH User:** `root` (Authenticate using local SSH keys)
- **Web Roots:** Located in `/var/www/`
- **Caddy Configuration:** `/etc/caddy/Caddyfile`

**Deployment Workflow:**
1. Copy files directly to the server via `scp` (e.g., `scp <file> root@192.168.0.62:/var/www/<dir>`).
2. Never use `cat` to edit remote files. Instead, download the remote Caddyfile via `scp`, edit it locally, and `scp` it back.
3. Always validate and reload Caddy securely: `ssh root@192.168.0.62 "caddy validate --config /etc/caddy/Caddyfile && systemctl reload caddy"`.
