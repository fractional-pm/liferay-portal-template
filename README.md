# Liferay Community Portal — One-Click Enterprise Deployment

Deploy a fully branded Liferay 7.4 CE portal with custom theme, pages, and widgets using a single configuration file.

## Quick Start

```bash
# 1. Clone and configure
git clone https://github.com/YOUR_ORG/liferay-portal-template.git
cd liferay-portal-template
cp .env.example .env
# Edit .env with your brand colors, domain, pages, etc.

# 2. Generate runtime configs
chmod +x scripts/*.sh
./scripts/generate-portal-ext.sh

# 3. Launch
docker compose up -d

# 4. Wait ~2 minutes for startup, then create pages
# First login: http://localhost:8080 (test@liferay.com / test)
# Then run page setup:
./scripts/setup-pages.sh test@liferay.com YOUR_PASSWORD
```

## What You Get

- **Liferay 7.4 CE** portal with PostgreSQL 15 + Elasticsearch 7.17
- **Custom branded theme** generated from your `.env` colors/fonts
- **Pre-configured pages**: Home, Products, Solutions, Blog, Docs, etc.
- **Nginx reverse proxy** with optional SSL
- **One config file** (`.env`) controls everything

## Configuration

Edit `.env` to customize:

| Variable | Description | Example |
|----------|-------------|---------|
| `PORTAL_DOMAIN` | Your domain | `portal.acme.com` |
| `BRAND_NAME` | Company name | `Acme Corp` |
| `COLOR_PRIMARY` | Header/heading color | `#00395E` |
| `COLOR_ACCENT` | Links/buttons color | `#0072CE` |
| `FONT_FAMILY` | Google Font name | `IBM Plex Sans` |
| `LAYOUT_STYLE` | `sharp` / `soft` / `round` | `sharp` |
| `SITE_PAGES` | Pages to create | See .env.example |
| `FOOTER_COL_*` | Footer link columns | See .env.example |

## Architecture

```
nginx (:80/:443) → liferay (:8080) → postgresql (:5432)
                                    → elasticsearch (:9200)
```

## File Structure

```
├── .env.example          # Configuration template
├── docker-compose.yml    # Full stack definition
├── config/
│   └── brand.conf        # Standalone brand config (for build-theme.sh)
├── css/
│   ├── _custom.scss.tpl  # Main styles template
│   └── _clay_variables.scss.tpl  # Bootstrap overrides template
├── templates/
│   ├── portal_normal.ftl.tpl     # Page layout template
│   ├── navigation.ftl            # Nav component
│   └── init.ftl                  # FTL initialization
├── scripts/
│   ├── generate-portal-ext.sh    # Generate runtime configs from .env
│   ├── build-theme.sh            # Standalone theme builder
│   ├── setup-pages.sh            # Create pages via API
│   └── entrypoint-setup.sh       # Docker setup container entrypoint
└── runtime/                      # Generated at runtime (gitignored)
    ├── portal-ext.properties
    ├── nginx.conf
    └── certs/
```

## License

Proprietary — [Your Company]
