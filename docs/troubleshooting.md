---
layout: default
title: Troubleshooting
nav_order: 6
---

# Troubleshooting

---

## Startup Issues

### Liferay takes too long to start

**First run** creates the database schema and can take 3-5 minutes. Subsequent starts take ~60-90 seconds.

Monitor progress:
```bash
docker logs -f liferay_portal 2>&1 | grep -E "startup|Started|ERROR"
```

### Liferay can't connect to database

Check that PostgreSQL is healthy:
```bash
docker exec liferay_db pg_isready -U liferay -d lportal
```

Verify credentials match between `.env` and `runtime/portal-ext.properties`:
```bash
grep jdbc runtime/portal-ext.properties
```

### Port 80/443 already in use

If another service (e.g., Dokploy's Traefik) uses ports 80/443, change the nginx ports in `docker-compose.yml`:

```yaml
nginx:
  ports:
    - "8443:443"
    - "8080:80"
```

---

## Theme Issues

### Theme not visible in Liferay admin

Check deployment logs:
```bash
docker logs liferay_portal 2>&1 | grep -i "theme\|STARTED\|ERROR"
```

Expected output:
```
Processing acmetheme-theme.war
Themes for .../acmetheme-theme.war copied successfully
STARTED acmetheme_7.4.3.120 [BUNDLE_ID]
```

### "Unable to write" theme WAR

The deploy directory file is owned by root but the container runs as `liferay:1000`:

```bash
docker exec -u root liferay_portal \
  chown liferay:liferay /opt/liferay/deploy/acmetheme-theme.war
```

### ClassNotFoundException: InvokerFilter

Your theme WAR contains a `web.xml` file. Remove it and rebuild:

```bash
rm -f WEB-INF/web.xml
./scripts/build-theme.sh --deploy
```

### Theme applied but styles don't show

1. Hard-refresh the browser: `Ctrl + Shift + R`
2. Clear Liferay's cache: *Control Panel > Server Administration > Resources > Clear all caches*
3. Verify theme is set in database:
   ```bash
   docker exec liferay_db psql -U liferay -d lportal \
     -c "SELECT themeid FROM layoutset WHERE privatelayout = false;"
   ```

---

## API Issues

### POST returns empty `{}`

`auth.token.check.enabled=true` blocks JSON-WS POST calls.

Fix: Set to `false` in `runtime/portal-ext.properties`, restart Liferay, run your API calls, then set back to `true`.

### POST returns 404

The endpoint URL or method signature is wrong. Browse available methods at:
```
http://localhost:8080/api/jsonws
```

### POST returns 500

Wrong parameter count or types. Liferay matches methods by parameter count. Ensure all parameters are provided, even empty ones.

### UnsupportedOperationException on headless API

You're using a DXP-only endpoint. In CE 7.4, use JSON-WS instead:

| Don't use (DXP only) | Use instead (CE) |
|----------------------|------------------|
| `POST /o/headless-delivery/v1.0/sites/{id}/site-pages` | `POST /api/jsonws/layout/add-layout` |

---

## Database Issues

### Find table names

Liferay uses lowercase table names without trailing underscore in PostgreSQL (except `user_`, `group_`):

```bash
docker exec liferay_db psql -U liferay -d lportal \
  -c "\dt" | grep layout
```

### Reset admin password

```bash
docker exec liferay_db psql -U liferay -d lportal \
  -c "UPDATE user_ SET password_ = 'test', passwordencrypted = false \
      WHERE emailaddress = 'test@liferay.com';"
docker restart liferay_portal
```

Then login with password `test` and change it.

---

## Common Error Reference

| Error | Cause | Fix |
|-------|-------|-----|
| `Connection refused: postgresql:5432` | DB not ready | Wait for healthcheck or check credentials |
| `Theme WAR Unable to write` | Root ownership | `docker exec -u root ... chown` |
| `ClassNotFoundException InvokerFilter` | web.xml in WAR | Remove web.xml, rebuild |
| JSON-WS POST returns `{}` | Auth token check | Disable temporarily |
| `DuplicateFriendlyURLException` | Page URL exists | Page already created, skip |
| Blank page after login | Elasticsearch down | `docker restart liferay_search` |
| SSL redirect loop | Missing X-Forwarded-Proto | Check nginx proxy_set_header |
