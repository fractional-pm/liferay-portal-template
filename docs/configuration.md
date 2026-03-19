---
layout: default
title: Configuration
nav_order: 3
---

# Configuration Reference

All configuration lives in a single `.env` file. Copy `.env.example` to `.env` and edit.

---

## Portal Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PORTAL_DOMAIN` | `portal.example.com` | Domain name for the portal |
| `PORTAL_COMPANY_NAME` | `Acme Corp` | Company name shown in portal settings |
| `PORTAL_ADMIN_EMAIL` | `admin@example.com` | Initial admin email |

## Database

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_DB` | `lportal` | Database name |
| `POSTGRES_USER` | `liferay` | Database user |
| `POSTGRES_PASSWORD` | *required* | Database password |

## JVM & Performance

| Variable | Default | Description |
|----------|---------|-------------|
| `LIFERAY_JVM_XMS` | `1g` | JVM initial heap |
| `LIFERAY_JVM_XMX` | `2g` | JVM maximum heap |
| `ELASTICSEARCH_HEAP` | `512m` | Elasticsearch heap |

---

## Theme Branding

### Identity

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAND_NAME` | `Acme Corp` | Brand name (footer copyright, metadata) |
| `THEME_ID` | `acmetheme` | Internal theme ID (lowercase, no spaces) |
| `THEME_DISPLAY_NAME` | `Acme Theme` | Theme name in Liferay admin |

### Colors

The color system is built on 6 brand variables:

| Variable | Default | Usage |
|----------|---------|-------|
| `COLOR_PRIMARY` | `#00395E` | Header background, headings, dark buttons |
| `COLOR_PRIMARY_LIGHT` | `#0072CE` | Links, active states, primary buttons |
| `COLOR_PRIMARY_LIGHTER` | `#4DA3E5` | Hover highlights |
| `COLOR_PRIMARY_LIGHTEST` | `#E8F4FD` | Tinted backgrounds, info alerts |
| `COLOR_SECONDARY` | `#1A1A2E` | Footer background |
| `COLOR_ACCENT` | `#0072CE` | Call-to-action elements |

#### Color Presets

**Gartner Blue** (default):
```
COLOR_PRIMARY=#00395E
COLOR_ACCENT=#0072CE
```

**Corporate Red:**
```
COLOR_PRIMARY=#8B0000
COLOR_ACCENT=#DC143C
```

**Forest Green:**
```
COLOR_PRIMARY=#1B4332
COLOR_ACCENT=#2D6A4F
```

**Slate Purple:**
```
COLOR_PRIMARY=#2D1B69
COLOR_ACCENT=#6C63FF
```

### Typography

| Variable | Default | Description |
|----------|---------|-------------|
| `FONT_IMPORT_URL` | IBM Plex Sans URL | Google Fonts import URL |
| `FONT_FAMILY` | `IBM Plex Sans` | Primary font family |
| `FONT_SIZE_BASE` | `0.875rem` | Base font size (14px) |

Popular alternatives:
- `Inter` — Clean, modern sans-serif
- `Source Sans 3` — Adobe's open-source workhorse
- `Roboto` — Google's Material Design font
- `Nunito Sans` — Friendly, rounded sans-serif

### Layout

| Variable | Default | Options |
|----------|---------|---------|
| `LAYOUT_STYLE` | `sharp` | `sharp` (0 radius), `soft` (4px), `round` (8px) |
| `CONTENT_MAX_WIDTH` | `1584px` | IBM 2xl grid. Alternatives: `1280px`, `1440px` |

---

## Site Pages

Define pages in `SITE_PAGES` as a comma-separated list:

```
SITE_PAGES=PageName|/url|portlet-id,PageName|/url|portlet-id,...
```

### Available Widgets

| Widget | Portlet ID |
|--------|-----------|
| Web Content Display | `com_liferay_journal_content_web_portlet_JournalContentPortlet` |
| Blogs | `com_liferay_blogs_web_portlet_BlogsPortlet` |
| Document Library | `com_liferay_document_library_web_portlet_DLPortlet` |
| Asset Publisher | `com_liferay_asset_publisher_web_portlet_AssetPublisherPortlet` |
| Wiki | `com_liferay_wiki_web_portlet_WikiPortlet` |
| Message Boards | `com_liferay_message_boards_web_portlet_MBPortlet` |
| Navigation Menu | `com_liferay_site_navigation_menu_web_portlet_SiteNavigationMenuPortlet` |
| Search Bar | `com_liferay_portal_search_web_portlet_SearchBarPortlet` |
| Search Results | `com_liferay_portal_search_web_portlet_SearchResultsPortlet` |

### Example Page Configurations

**Enterprise Website:**
```
SITE_PAGES=Home|/home|com_liferay_journal_content_web_portlet_JournalContentPortlet,Products|/products|com_liferay_journal_content_web_portlet_JournalContentPortlet,Solutions|/solutions|com_liferay_journal_content_web_portlet_JournalContentPortlet,Blog|/blog|com_liferay_blogs_web_portlet_BlogsPortlet,Documents|/docs|com_liferay_document_library_web_portlet_DLPortlet
```

**Community Portal:**
```
SITE_PAGES=Home|/home|com_liferay_journal_content_web_portlet_JournalContentPortlet,Forum|/forum|com_liferay_message_boards_web_portlet_MBPortlet,Wiki|/wiki|com_liferay_wiki_web_portlet_WikiPortlet,Blog|/blog|com_liferay_blogs_web_portlet_BlogsPortlet,Files|/files|com_liferay_document_library_web_portlet_DLPortlet
```

**Intranet:**
```
SITE_PAGES=Home|/home|com_liferay_journal_content_web_portlet_JournalContentPortlet,News|/news|com_liferay_blogs_web_portlet_BlogsPortlet,Documents|/documents|com_liferay_document_library_web_portlet_DLPortlet,Directory|/directory|com_liferay_asset_publisher_web_portlet_AssetPublisherPortlet
```

---

## Footer Columns

Define up to 6 footer columns using `FOOTER_COL_1` through `FOOTER_COL_6`:

```
FOOTER_COL_1=Heading|Link Text:URL|Link Text:URL|...
```

### Example

```bash
FOOTER_COL_1=Products|Platform:#|API:#|Integrations:#
FOOTER_COL_2=Company|About:#|Careers:#|Contact:#
FOOTER_COL_3=Resources|Docs:#|Blog:#|Support:#
```

---

## Email / SMTP

| Variable | Default | Description |
|----------|---------|-------------|
| `SMTP_HOST` | *(empty)* | SMTP server hostname |
| `SMTP_PORT` | `587` | SMTP port |
| `SMTP_USER` | *(empty)* | SMTP username |
| `SMTP_PASSWORD` | *(empty)* | SMTP password |
| `SMTP_TLS` | `true` | Enable STARTTLS |

---

## SSL

| Variable | Default | Description |
|----------|---------|-------------|
| `SSL_ENABLED` | `false` | Enable HTTPS |

When enabled, place certificates at:
- `runtime/certs/fullchain.pem`
- `runtime/certs/privkey.pem`
