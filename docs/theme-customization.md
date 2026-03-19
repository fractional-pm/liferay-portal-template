---
layout: default
title: Theme Customization
nav_order: 4
---

# Theme Customization

The theme is generated from templates at build time. For most use cases, editing `.env` color/font variables is sufficient. For deeper customization, you can modify the CSS and FreeMarker templates directly.

---

## How the Theme System Works

```
.env / brand.conf
       │
       ▼
┌──────────────────┐     ┌──────────────────┐
│ css/*.scss.tpl   │────▶│ Generated .scss  │
│ templates/*.tpl  │     │ Generated .ftl   │
└──────────────────┘     └────────┬─────────┘
                                  │
                                  ▼
                         ┌────────────────┐
                         │ theme.war      │
                         │ (deployed to   │
                         │  Liferay)      │
                         └────────────────┘
```

Template files use `{{VARIABLE}}` placeholders that are replaced with values from `.env` or `config/brand.conf`.

## File Structure

| File | Purpose | Edit for... |
|------|---------|-------------|
| `css/_custom.scss.tpl` | All custom styles | Colors, spacing, component styles |
| `css/_clay_variables.scss.tpl` | Bootstrap/Clay overrides | Font families, button sizing, border radius |
| `templates/portal_normal.ftl.tpl` | Page layout | Header, footer, page structure |
| `templates/navigation.ftl` | Navigation menu | Nav item rendering, dropdowns |
| `templates/init.ftl` | Variable initialization | Template variables |

## CSS Architecture

### Layer 1: Clay Variables (`_clay_variables.scss`)

Loaded **before** Liferay's Clay CSS framework. Override Bootstrap/Clay variables here:

```scss
$primary: {{COLOR_PRIMARY_LIGHT}};
$font-family-base: {{FONT_FAMILY_BASE}};
$border-radius: {{BORDER_RADIUS}};
$btn-border-radius: {{BORDER_RADIUS}};
```

### Layer 2: Custom Styles (`_custom.scss`)

Loaded **after** Clay. All component-level styles go here:

```scss
:root {
  --brand-primary: {{COLOR_PRIMARY}};
  --brand-accent: {{COLOR_ACCENT}};
}

#banner {
  background-color: var(--brand-primary) !important;
  border-bottom: 3px solid var(--brand-accent);
}
```

## Adding a New CSS Component

1. Add the styles to `css/_custom.scss.tpl`
2. Use `{{VARIABLE}}` for any configurable value
3. If you need a new variable, add it to `.env.example` and update the build scripts

**Example — Adding a hero banner style:**

```scss
/* In css/_custom.scss.tpl */
.hero-banner {
  background: linear-gradient(135deg, {{COLOR_PRIMARY}} 0%, {{COLOR_PRIMARY_LIGHT}} 100%);
  color: #FFFFFF;
  padding: 5rem 2rem;
  text-align: center;
}

.hero-banner h1 {
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.hero-banner p {
  font-size: 1.25rem;
  opacity: 0.9;
  max-width: 700px;
  margin: 0 auto;
}
```

## Page Template (FreeMarker)

### Available Variables

| Variable | Description |
|----------|-------------|
| `${site_name}` | Site name |
| `${site_default_url}` | Site home URL |
| `${company_name}` | Company name |
| `${has_navigation}` | Whether navigation exists |
| `${full_templates_path}` | Path to templates directory |
| `${css_class}` | Body CSS class |

### Required Includes

Every `portal_normal.ftl` must include these Liferay directives:

```ftl
<@liferay_util["include"] page=top_head_include />     <!-- In <head> -->
<@liferay_util["include"] page=body_top_include />      <!-- After <body> -->
<@liferay.control_menu />                                <!-- Admin toolbar -->
<@liferay_util["include"] page=content_include />        <!-- Page content -->
<@liferay_util["include"] page=body_bottom_include />    <!-- Before </body> -->
```

### Customizing the Header

Edit the header section in `templates/portal_normal.ftl.tpl`:

```html
<header id="banner">
  <div class="unboxd-header">
    <div class="unboxd-header__inner">
      <!-- Logo and brand name -->
      <div class="unboxd-header__brand">
        <a href="${site_default_url}">
          <span class="unboxd-header__title">${site_name}</span>
        </a>
      </div>

      <!-- Navigation -->
      <nav class="unboxd-header__nav">
        <#include "${full_templates_path}/navigation.ftl" />
      </nav>

      <!-- User menu -->
      <div class="unboxd-header__actions">
        <@liferay.user_personal_bar />
      </div>
    </div>
  </div>
</header>
```

### Customizing the Footer

Footer columns are generated from `FOOTER_COL_*` environment variables. To change the structure, edit the footer section in `templates/portal_normal.ftl.tpl`.

## Rebuilding the Theme

After making changes to templates:

```bash
# Standalone build
./scripts/build-theme.sh --deploy --apply --group-id=YOUR_GROUP_ID

# Or rebuild everything
docker compose up -d --force-recreate setup
```

## Building a Docker Image with Custom Theme

```bash
# Build theme WAR
./scripts/build-theme.sh

# Build Docker image
docker build --build-arg THEME_ID=acmetheme -t yourcompany/portal:latest .

# Push
docker push yourcompany/portal:latest
```
