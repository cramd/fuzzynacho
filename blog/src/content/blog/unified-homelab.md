---
title: "The Unified Homelab: Taming Subdomain Chaos"
description: "How I nuked infrastructure bloat and built a frictionless, Caddy-driven Proxmox homelab to run my empire of side projects."
pubDate: 2026-07-05
author: "FuzzyNacho"
coverImage: "/blog/images/blog/unified-homelab/hero.jpg"
tags: ["Homelab", "Proxmox", "Caddy", "Infrastructure", "Developer Experience"]
seoTitle: "The Unified Homelab: Taming Subdomain Chaos"
seoDescription: "How to build a Caddy-driven Proxmox homelab to nuke infrastructure bloat and run side projects frictionlessly."
socialImage: "/blog/images/blog/unified-homelab/hero.jpg"
coverImageAlt: "A structured diagram of a Caddy reverse proxy server routing traffic to Proxmox VMs."
featured: false
---

Side projects are like a gas—they expand to fill whatever container you put them in. What starts as one simple idea inevitably mutates into a fragmented mess of scattered hosting. Right now, I’m juggling BdayLoot, HuntMode, partsensei.com, a custom LEGO collection tracker, and the main fuzzynacho.org portal.

In the early days, keeping this fleet afloat was a nightmare. It meant fighting with manual SSL certificates, dodging port conflicts like Neo in the Matrix, and trying to remember which bespoke service was running on which random VPS.

**Context switching is the silent killer of shipping.** When you burn an hour just trying to remember how you routed traffic for a sub-app, you aren't writing code. You're just doing digital janitorial work.

The goal was simple: nuke the bloat and build a single, unified environment. A frictionless, dashboard-driven portal for all my subdomains.

## 01. The Core Problem: Spaghetti Infrastructure

When you’re bootstrapping an empire of isolated experiments—whether it's a geographic PLG play like BdayLoot or an API-heavy tool like the Rebrickable tracker—infrastructure overhead is the enemy.

Traditional Virtual Machines (VMs) are the government bureaucracies of computing. They are heavy, they hoard resources, and they take entirely too long to do anything useful. Managing Nginx configs and Certbot cron jobs for every new subdomain is the sysadmin equivalent of watching paint dry.

> **If I want to spin up a new service on a fuzzynacho.org subdomain, it needs to take minutes, not hours. Anything slower is unacceptable friction.**

![A stressed engineer tangled hopelessly in a chaotic web of glowing, multi-colored server cables, representing infrastructure bloat](/blog/images/blog/unified-homelab/spaghetti-infrastructure.jpg)

## 02. The Architecture: Proxmox & LXC

Enter the new stack. The physical foundation is a Mac mini armed with 28GB of RAM. It's quiet, it's efficient, and it has plenty of headroom to run multiple isolated environments without breaking a sweat.

But the real magic happens at the hypervisor level with **Proxmox**. Instead of spinning up full, fat VMs for every little app, I rely heavily on **LXC (Linux Containers)**.

Think of LXCs as the sleek, tactical strike team to a VM's sluggish standing army. They are incredibly lightweight, boot almost instantly, and keep services ruthlessly isolated. They share the host kernel, meaning zero virtualization overhead. It’s exactly the balance I need: the isolation of a VM with the performance of bare metal.

## 03. The Magic Bullet: Caddy

Even with clean containers, routing traffic and managing SSL can be a nightmare. That’s where **Caddy** comes in as the ingress controller and reverse proxy. Caddy is the piece that actually tames the chaos.

Unlike Nginx or Apache—which require you to write archaic configuration files just to prove you are worthy—**Caddy handles HTTPS automatically by default.**

Here is the entire workflow for exposing a new LXC container to the open web:
1. I point the DNS record for the new subdomain (e.g., `lego.fuzzynacho.org`) to the Proxmox host.
2. I add exactly three lines to the Caddyfile.
3. I hit reload.

Caddy automatically provisions the Let's Encrypt certificate, handles the inevitable renewal, and routes the traffic to the internal IP of that specific LXC container.

**It turns a 30-minute, error-prone sysadmin chore into a 30-second configuration update.**

![A sleek, futuristic traffic cop with glowing accents calmly directing chaotic laser-beam data streams into neat, sorted LXC containers](/blog/images/blog/unified-homelab/caddy-traffic-cop.jpg)

## 04. Consolidating the Dashboard

With routing cleanly handled by Caddy and the underlying apps securely isolated in Proxmox LXCs, the root domain (`fuzzynacho.org`) is freed up to serve as the unified landing page.

This dashboard ties the entire ecosystem together. It's a single pane of glass to access BdayLoot, HuntMode, Partsensei, and this very blog. What used to be a fragmented mess of side quests is now a cohesive personal portfolio and functional workspace. It looks intentional because it *is* intentional.

## 05. The Developer Experience (DX) Wins

This homelab architecture isn't just about flexing server stats; it's about ruthlessly eliminating friction. The daily workflow has fundamentally changed. Writing content in Markdown for the Astro blog or pushing code for a new app is now completely decoupled from infrastructure headaches.

* **Network routing is centralized.**
* **Security (SSL) is automated and invisible.**
* **Resource usage is highly optimized via LXC.**

When the infrastructure finally gets out of your way, you can stop playing sysadmin and actually focus on building the product.

---

## Social Distribution Toolkit
*(Internal use only - do not render on site)*

**Share on X (Twitter):**
[Click to Tweet](https://twitter.com/intent/tweet?text=Side%20projects%20are%20like%20a%20gas%E2%80%94they%20expand%20to%20fill%20the%20container.%20I%20got%20sick%20of%20managing%20Nginx%20configs%20and%20spaghetti%20infrastructure%20for%20my%20subdomains.%20Here%20is%20how%20I%20tamed%20the%20chaos%20using%20Proxmox%2C%20LXC%2C%20and%20Caddy%20to%20make%20deployments%20frictionless.%20%F0%9F%9A%80&url=https%3A%2F%2Fwww.fuzzynacho.org%2Fblog%2Ftaming-subdomain-chaos%2F)
*Suggested Copy:* Side projects are like a gas—they expand to fill the container. I got sick of managing Nginx configs and spaghetti infrastructure for my subdomains. Here is how I tamed the chaos using Proxmox, LXC, and Caddy to make deployments frictionless. 🚀

**Share on LinkedIn:**
[Click to Share](https://www.linkedin.com/sharing/share-offsite/?url=https%3A%2F%2Fwww.fuzzynacho.org%2Fblog%2Ftaming-subdomain-chaos%2F)
*Suggested Copy:* Infrastructure overhead is the silent killer of shipping side projects. Traditional VMs are bloated, and managing reverse proxies manually is a waste of engineering cycles. I recently re-architected my homelab using Proxmox, lightweight LXC containers, and Caddy as an automated ingress controller. It turned 30-minute deployment chores into 30-second configuration updates. Read my latest breakdown on taming subdomain chaos and optimizing Developer Experience (DX).