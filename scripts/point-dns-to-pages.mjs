#!/usr/bin/env node
import fs from "node:fs";
/**
 * Point fuzzynacho.org + www at Cloudflare Pages.
 * Leaves other subdomains (battery, dir, legacylink, etc.) unchanged.
 */
const ZONE_ID = "b66cff248d3f3a959a04804c1811456b";
const PAGES_CNAME = "fuzzynacho.pages.dev";
const APEX = "fuzzynacho.org";

const dryRun = process.argv.includes("--dry-run");

function fail(message) {
  console.error(`ERROR: ${message}`);
  process.exit(1);
}

function readToken() {
  if (process.env.CF_API_TOKEN) return process.env.CF_API_TOKEN;
  if (process.env.CLOUDFLARE_API_TOKEN) return process.env.CLOUDFLARE_API_TOKEN;
  const tokenPath =
    process.env.CF_API_TOKEN_FILE ??
    `${process.env.HOME}/.config/marcsherwood/cf-token`;
  try {
    const raw = fs.readFileSync(tokenPath, "utf8").trim();
    if (raw) return raw;
  } catch {
    /* optional */
  }
  return null;
}

async function cf(pathSuffix, options = {}) {
  const token = readToken();
  if (!token) {
    fail("Set CF_API_TOKEN or ~/.config/marcsherwood/cf-token (Zone DNS Edit).");
  }
  const url = `https://api.cloudflare.com/client/v4${pathSuffix}`;
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      ...(options.headers ?? {}),
    },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok || body.success === false) {
    fail(`${pathSuffix}: ${JSON.stringify(body.errors ?? body)}`);
  }
  return body.result;
}

async function listRecords(name) {
  const q = new URLSearchParams({ name, per_page: "100" });
  return cf(`/zones/${ZONE_ID}/dns_records?${q}`);
}

async function deleteRecord(record) {
  if (dryRun) {
    console.log(`(dry-run) DELETE ${record.type} ${record.name}`);
    return;
  }
  await cf(`/zones/${ZONE_ID}/dns_records/${record.id}`, { method: "DELETE" });
}

async function upsertCname(name, target) {
  const fqdn = name === APEX ? APEX : `${name}.${APEX}`;
  const records = await listRecords(fqdn);
  for (const record of records.filter((r) => r.type === "A" || r.type === "AAAA")) {
    await deleteRecord(record);
  }
  const cname = records.find((r) => r.type === "CNAME");
  const payload = {
    type: "CNAME",
    name: name === APEX ? "@" : name,
    content: target,
    proxied: true,
    ttl: 1,
  };
  if (dryRun) {
    console.log(`(dry-run) UPSERT CNAME ${fqdn} → ${target}`);
    return;
  }
  if (cname) {
    await cf(`/zones/${ZONE_ID}/dns_records/${cname.id}`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    });
  } else {
    await cf(`/zones/${ZONE_ID}/dns_records`, {
      method: "POST",
      body: JSON.stringify(payload),
    });
  }
  console.log(`CNAME ${fqdn} → ${target} (proxied)`);
}

async function main() {
  await upsertCname(APEX, PAGES_CNAME);
  await upsertCname("www", PAGES_CNAME);
  console.log("Done. Confirm Pages custom domains are Active, then run scripts/apply-homelab-caddy-cutover.sh");
}

main().catch((err) => fail(err.message));