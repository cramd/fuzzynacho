#!/usr/bin/env bash
# Remove apex + www fuzzynacho from homelab Caddy after Cloudflare Pages cutover.
set -euo pipefail

HOST="${HOMELAB_HOST:-root@192.168.0.62}"

ssh "$HOST" bash -s <<'REMOTE'
set -euo pipefail
python3 <<'PY'
import re
from pathlib import Path

path = Path("/etc/caddy/Caddyfile")
text = path.read_text()
blocks = ("www.fuzzynacho.org", "fuzzynacho.org")
lines = text.splitlines()
out = []
skip = False
depth = 0

for line in lines:
    stripped = line.strip()
    if not skip:
        if stripped.endswith("{") and any(stripped == f"{host} {{" for host in blocks):
            skip = True
            depth = 1
            continue
    if skip:
        open_count = line.count("{")
        close_count = line.count("}")
        if "{uri}" in line:
            open_count -= line.count("{uri}")
            close_count -= line.count("{uri}")
        depth += open_count - close_count
        if depth <= 0:
            skip = False
        continue
    out.append(line)

new_text = "\n".join(out).strip() + "\n"
for host in blocks:
    if re.search(rf"^{re.escape(host)} \\{{", new_text, re.M):
        raise SystemExit(f"Failed to remove {host} from Caddyfile")
path.write_text(new_text)
print("Removed fuzzynacho.org + www from Caddyfile (subdomains unchanged)")
PY
caddy validate --config /etc/caddy/Caddyfile
systemctl reload caddy
REMOTE

echo "Homelab Caddy reloaded."