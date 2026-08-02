# Infra Pulse

**Realtime infrastructure monitoring platform** — live server health, application uptime checks, and source→target connectivity, in one dashboard.

> This public repository contains **documentation** and a **static UI preview** only.  
> Application source code is **not** published here.

**Static pages (after GitHub Pages is enabled):**

| Page | URL |
|------|-----|
| UI preview | https://mahfuztoolbox.github.io/infra-pulse/ |
| README page | https://mahfuztoolbox.github.io/infra-pulse/readme.html |
| Architecture image | https://mahfuztoolbox.github.io/infra-pulse/images/architecture.png |

Local files: [`index.html`](index.html) · [`readme.html`](readme.html)

---

## At a glance (for recruiters & reviewers)

| | |
|---|---|
| **Type** | Full-stack monitoring platform |
| **Role** | End-to-end design & development — agents, API, UI, deployment |
| **Stack** | React, TypeScript, Node.js, Express, MongoDB, Python, WebSocket, Nginx, PM2 |
| **Monitors** | Linux servers · HTTP/TCP applications · source→target connectivity paths |
| **Extras** | RBAC · incident lifecycle · email/SMS/Telegram alerts · audit logs |

**One-line summary:** *A Datadog-style monitoring hub — live server metrics, scheduled application probes, and path-based connectivity checks from specific source hosts.*

---

## What problem does it solve?

1. **Servers** — Is each machine healthy? (CPU, memory, disk, network)
2. **Applications** — Are our APIs and services responding?
3. **Connectivity** — Can server A reach server B on the network?

Infra Pulse answers all three in one product, with alerting and incident history when something fails.

---

## Architecture

![Infra Pulse system architecture](images/architecture.png)

| Component | Purpose |
|-----------|---------|
| Web UI | React dashboard (Nginx static) |
| API | Express + MongoDB — probes, incidents, alerts |
| Metrics agent | Python WebSocket stream per server |
| Connectivity agent | TCP path checks from each source host |

---

## Three monitoring modules

### 1. Server monitoring
Live host health via Python agents over WebSocket.

### 2. Application monitoring
HTTP/TCP fleet probes with uptime status and incidents.

### 3. Connectivity monitoring
Source→target TCP checks from distributed agents (real network paths).

---

## Repository contents

| Path | What it is |
|------|------------|
| `README.md` | This project write-up (Markdown source) |
| `readme.html` | README as a static web page |
| `index.html` | Static UI design preview |
| `images/architecture.png` | Architecture diagram |
| `docs/screenshots/` | Optional sanitized UI screenshots |
| `deploy-github.sh` | Push updates to this GitHub repo |

No API source, no React source, no deploy secrets.

### Update / push to GitHub

```bash
cd infra-pulse

# first time only (if .git is missing)
./deploy-github.sh --init

# after editing README.md or index.html
./deploy-github.sh
./deploy-github.sh "Update static UI preview"
./deploy-github.sh --sync
```

Or manually:

```bash
cd infra-pulse
git init
git add README.md index.html images docs .gitignore deploy-github.sh
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/mahfuztoolbox/infra-pulse.git
git push -u origin main
```

---

## Portfolio / CV blurb

> **Infra Pulse** — Full-stack infrastructure monitoring platform. Python WebSocket agents stream server metrics; Node.js API runs fleet-wide HTTP/TCP application probes and multi-hop connectivity checks; React dashboard provides RBAC, incident tracking, and email/SMS/Telegram alerting.

---

## License

Portfolio / demonstration materials. Application source remains private.
