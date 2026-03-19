---
layout: default
title: Home
nav_order: 1
---

# Liferay Portal Template

**One-click deployable enterprise portal powered by Liferay Community Edition 7.4**

Deploy a fully branded, production-ready portal with custom theme, pages, and widgets — configured entirely through a single `.env` file.

---

## What You Get

| Component | Details |
|-----------|---------|
| **Liferay CE 7.4** | Full-featured enterprise portal (GA120) |
| **PostgreSQL 15** | Production-grade database |
| **Elasticsearch 7.17** | Full-text search engine |
| **Nginx** | Reverse proxy with optional SSL |
| **Custom Theme** | Generated from your brand config |
| **Pre-built Pages** | Home, Products, Solutions, Blog, Docs, and more |

## Quick Start

```bash
git clone https://github.com/fractional-pm/liferay-portal-template.git
cd liferay-portal-template
cp .env.example .env    # Edit with your brand details
./scripts/generate-portal-ext.sh
docker compose up -d
```

Portal is live at [http://localhost:8080](http://localhost:8080) in about 2 minutes.

## Two Ways to Deploy

### Option A: Full Customization (GitHub)

Clone the repo, edit `.env`, deploy with Docker Compose. Full control over theme, pages, and infrastructure.

[Get Started]({{ site.baseurl }}/getting-started){: .btn .btn-primary }

### Option B: Quick Start (Docker Hub)

Pull the pre-built image with the default theme baked in.

```bash
docker pull thefractionalpm/liferay-portal-template:latest
```

[Docker Hub](https://hub.docker.com/r/thefractionalpm/liferay-portal-template){: .btn }

---

## Architecture

```
Client → Nginx (:80/:443) → Liferay (:8080) → PostgreSQL (:5432)
                                              → Elasticsearch (:9200)
```

All services run as Docker containers, orchestrated by Docker Compose. The setup container auto-builds and deploys the theme on first run.
