---
layout: default
title: API Reference
nav_order: 5
---

# API Reference

Liferay 7.4 CE provides two API systems. This guide documents the working patterns validated for this template.

---

## Authentication

All API calls use HTTP Basic Auth:

```bash
curl -s -u admin@example.com:password http://localhost:8080/api/jsonws/...
```

{: .important }
> `auth.token.check.enabled=true` in portal-ext.properties blocks all JSON-WS POST calls. Disable temporarily for API automation, then re-enable.

## Discovering Your Site

```bash
# Get your user profile and site IDs
curl -s -u $AUTH \
  "http://localhost:8080/o/headless-admin-user/v1.0/my-user-account"

# List companies
curl -s -u $AUTH \
  "http://localhost:8080/api/jsonws/company/get-companies"

# List installed themes
curl -s -u $AUTH \
  "http://localhost:8080/api/jsonws/theme/get-war-themes"
```

---

## Pages

### Create a Page

```bash
curl -s -u $AUTH -X POST \
  "http://localhost:8080/api/jsonws/layout/add-layout" \
  -d "groupId=GROUP_ID" \
  -d "privateLayout=false" \
  -d "parentLayoutId=0" \
  -d "name=Page Name" \
  -d "title=Page Name" \
  -d "description=" \
  -d "type=portlet" \
  -d "hidden=false" \
  -d "friendlyURL=/page-url" \
  -d "serviceContext.scopeGroupId=GROUP_ID" \
  -d "serviceContext.addGroupPermissions=true" \
  -d "serviceContext.addGuestPermissions=true"
```

**Page types:** `portlet` (widget page), `content` (content page), `panel`, `embedded`, `link_to_layout`, `url`

### List Pages

```bash
curl -s -u $AUTH \
  "http://localhost:8080/api/jsonws/layout/get-layouts/group-id/GROUP_ID/private-layout/false"
```

### Add Widget to Page

```bash
curl -s -u $AUTH -X POST \
  "http://localhost:8080/api/jsonws/layout/update-layout" \
  -d "groupId=GROUP_ID" \
  -d "privateLayout=false" \
  -d "layoutId=LAYOUT_ID" \
  --data-urlencode "typeSettings=layout-template-id=1_column
column-1=PORTLET_ID,"
```

**Layout templates:** `1_column`, `2_columns_i` (30/70), `2_columns_ii` (70/30), `2_columns_iii` (50/50), `3_columns`

---

## Content

### Create Blog Post

```bash
curl -s -u $AUTH -X POST \
  "http://localhost:8080/o/headless-delivery/v1.0/sites/GROUP_ID/blog-postings" \
  -H "Content-Type: application/json" \
  -d '{
    "headline": "Blog Title",
    "articleBody": "<p>Content here</p>"
  }'
```

### Upload Document

```bash
curl -s -u $AUTH -X POST \
  "http://localhost:8080/o/headless-delivery/v1.0/sites/GROUP_ID/documents" \
  -F "file=@/path/to/file.pdf" \
  -F "document={\"title\":\"My Document\"};type=application/json"
```

### Create Navigation Menu

```bash
curl -s -u $AUTH -X POST \
  "http://localhost:8080/o/headless-delivery/v1.0/sites/GROUP_ID/navigation-menus" \
  -H "Content-Type: application/json" \
  -d '{"name": "Main Navigation"}'
```

---

## Theme Management

### Apply Theme (Database Method)

The JSON-WS theme endpoint does not exist in CE 7.4. Use direct database update:

```bash
docker exec liferay_db psql -U liferay -d lportal \
  -c "UPDATE layoutset SET themeid = 'THEME_ID' \
      WHERE groupid = GROUP_ID AND privatelayout = false;"
```

### List Installed Themes

```bash
curl -s -u $AUTH \
  "http://localhost:8080/api/jsonws/theme/get-war-themes"
```

---

## Common Widget Portlet IDs

| Widget | Portlet ID |
|--------|-----------|
| Web Content Display | `com_liferay_journal_content_web_portlet_JournalContentPortlet` |
| Blogs | `com_liferay_blogs_web_portlet_BlogsPortlet` |
| Document Library | `com_liferay_document_library_web_portlet_DLPortlet` |
| Asset Publisher | `com_liferay_asset_publisher_web_portlet_AssetPublisherPortlet` |
| Navigation Menu | `com_liferay_site_navigation_menu_web_portlet_SiteNavigationMenuPortlet` |
| Search Bar | `com_liferay_portal_search_web_portlet_SearchBarPortlet` |
| Search Results | `com_liferay_portal_search_web_portlet_SearchResultsPortlet` |
| Wiki | `com_liferay_wiki_web_portlet_WikiPortlet` |
| Message Boards | `com_liferay_message_boards_web_portlet_MBPortlet` |
| IFrame | `com_liferay_iframe_web_portlet_IFramePortlet` |

---

## API Discovery

Browse all available JSON-WS endpoints from your running instance:

```
http://localhost:8080/api/jsonws
```

Get the OpenAPI spec for headless APIs:

```
http://localhost:8080/o/headless-delivery/v1.0/openapi.json
```

{: .note }
> In Liferay CE 7.4, `POST /o/headless-delivery/v1.0/sites/{siteId}/site-pages` returns `UnsupportedOperationException`. This is a DXP-only feature. Use the JSON-WS `layout/add-layout` endpoint instead.
