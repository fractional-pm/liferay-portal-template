---
layout: default
title: Getting Started
nav_order: 2
---

# Getting Started

## Prerequisites

- **Docker** 24+ and **Docker Compose** v2+
- **2 GB RAM** minimum (4 GB recommended)
- A Linux server (Ubuntu 22.04+ recommended) or macOS/Windows with Docker Desktop

## Step 1: Clone and Configure

```bash
git clone https://github.com/fractional-pm/liferay-portal-template.git
cd liferay-portal-template
cp .env.example .env
```

Open `.env` in your editor and set at minimum:

```bash
PORTAL_DOMAIN=portal.yourcompany.com
BRAND_NAME=Your Company
POSTGRES_PASSWORD=YourSecurePassword123!
COLOR_PRIMARY=#00395E        # Your brand color
COLOR_ACCENT=#0072CE         # Links and buttons
```

See [Configuration Reference]({{ site.baseurl }}/configuration) for all options.

## Step 2: Generate Runtime Configs

```bash
chmod +x scripts/*.sh
./scripts/generate-portal-ext.sh
```

This creates `runtime/portal-ext.properties` and `runtime/nginx.conf` from your `.env`.

## Step 3: Launch

```bash
docker compose up -d
```

Wait approximately 2 minutes for all services to initialize. Monitor progress:

```bash
docker logs -f liferay_portal 2>&1 | grep "Server startup"
```

When you see `Server startup in [XXXX] milliseconds`, the portal is ready.

## Step 4: First Login

Open your browser to `http://localhost:8080` (or your configured domain).

**Default credentials:**
- Email: `test@liferay.com`
- Password: `test`

**Change the admin password immediately** after first login via *Control Panel > Users > Account Settings*.

## Step 5: Create Pages

After logging in and setting your password:

```bash
./scripts/setup-pages.sh test@liferay.com YOUR_NEW_PASSWORD
```

This creates all pages defined in your `.env` `SITE_PAGES` variable and adds the configured widgets.

{: .warning }
> The page setup script requires `auth.token.check.enabled=false` in portal-ext.properties. The generated config has this set for initial setup. After running the script, update to `true` in `runtime/portal-ext.properties` and restart: `docker restart liferay_portal`

## Step 6: Enable SSL (Optional)

1. Place your SSL certificates in `runtime/certs/`:
   - `fullchain.pem`
   - `privkey.pem`

2. Set `SSL_ENABLED=true` in `.env`

3. Regenerate and restart:
   ```bash
   ./scripts/generate-portal-ext.sh
   docker compose restart nginx liferay_portal
   ```

## Verify Installation

| Check | Command |
|-------|---------|
| All containers running | `docker compose ps` |
| Liferay responding | `curl -s -o /dev/null -w "%{http_code}" http://localhost:8080` |
| Database connected | `docker exec liferay_db psql -U liferay -d lportal -c "SELECT 1;"` |
| Theme applied | `docker exec liferay_db psql -U liferay -d lportal -c "SELECT themeid FROM layoutset WHERE privatelayout = false;"` |
| Pages created | `docker exec liferay_db psql -U liferay -d lportal -c "SELECT friendlyurl FROM layout WHERE privatelayout = false;"` |
