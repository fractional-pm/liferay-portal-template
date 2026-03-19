#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# Liferay Theme Builder
# Reads config/brand.conf → generates themed WAR → optionally deploys
#
# Usage:
#   ./scripts/build-theme.sh                  # Build only
#   ./scripts/build-theme.sh --deploy         # Build + deploy to running container
#   ./scripts/build-theme.sh --deploy --apply # Build + deploy + apply theme via DB
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
CONF="$BASE_DIR/config/brand.conf"

# ── Parse flags ───────────────────────────────────────────────────────────
DO_DEPLOY=false
DO_APPLY=false
LIFERAY_CONTAINER="${LIFERAY_CONTAINER:-liferay_portal}"
DB_CONTAINER="${DB_CONTAINER:-liferay_db}"
DB_USER="${DB_USER:-liferay}"
DB_NAME="${DB_NAME:-lportal}"
GROUP_ID="${GROUP_ID:-}"

for arg in "$@"; do
  case $arg in
    --deploy) DO_DEPLOY=true ;;
    --apply)  DO_APPLY=true ;;
    --container=*) LIFERAY_CONTAINER="${arg#*=}" ;;
    --group-id=*) GROUP_ID="${arg#*=}" ;;
  esac
done

# ── Load config ───────────────────────────────────────────────────────────
echo "Reading $CONF..."
source "$CONF"

# ── Derive values ─────────────────────────────────────────────────────────
case "$LAYOUT_STYLE" in
  sharp) BORDER_RADIUS="0" ;;
  soft)  BORDER_RADIUS="4px" ;;
  round) BORDER_RADIUS="8px" ;;
  *)     BORDER_RADIUS="0" ;;
esac

# Count footer columns
FOOTER_COL_COUNT=0
FOOTER_COLUMNS_HTML=""
for i in 1 2 3 4 5 6; do
  VAR="FOOTER_COL_$i"
  VAL="${!VAR:-}"
  if [ -n "$VAL" ]; then
    FOOTER_COL_COUNT=$((FOOTER_COL_COUNT + 1))
    # Parse "Heading|Link1:URL1|Link2:URL2"
    IFS='|' read -ra PARTS <<< "$VAL"
    HEADING="${PARTS[0]}"
    LINKS=""
    for ((j=1; j<${#PARTS[@]}; j++)); do
      IFS=':' read -r LINK_TEXT LINK_URL <<< "${PARTS[$j]}"
      LINKS="$LINKS\n\t\t\t\t\t\t\t<li><a href=\"${LINK_URL}\">${LINK_TEXT}</a></li>"
    done
    FOOTER_COLUMNS_HTML="$FOOTER_COLUMNS_HTML
\t\t\t\t\t<div class=\"unboxd-footer__col\">
\t\t\t\t\t\t<h4>${HEADING}</h4>
\t\t\t\t\t\t<ul>${LINKS}
\t\t\t\t\t\t</ul>
\t\t\t\t\t</div>"
  fi
done

# Font import conditional
FONT_IMPORT=""
if [ -n "$FONT_IMPORT_URL" ]; then
  FONT_IMPORT="@import url('${FONT_IMPORT_URL}');"
fi

# ── Build output directory ────────────────────────────────────────────────
BUILD_DIR="$BASE_DIR/build/${THEME_ID}"
WAR_DIR="$BUILD_DIR/war"
rm -rf "$BUILD_DIR"
mkdir -p "$WAR_DIR/WEB-INF" "$WAR_DIR/css" "$WAR_DIR/templates" "$WAR_DIR/js" "$WAR_DIR/images"

echo "Building theme: $THEME_DISPLAY_NAME ($THEME_ID)"

# ── Generate liferay-look-and-feel.xml ────────────────────────────────────
cat > "$WAR_DIR/WEB-INF/liferay-look-and-feel.xml" << XMLEOF
<?xml version="1.0"?>
<!DOCTYPE look-and-feel PUBLIC "-//Liferay//DTD Look and Feel 7.4.0//EN" "http://www.liferay.com/dtd/liferay-look-and-feel_7_4_0.dtd">
<look-and-feel>
	<compatibility>
		<version>7.4.3.100+</version>
	</compatibility>
	<theme id="${THEME_ID}" name="${THEME_DISPLAY_NAME}">
		<template-extension>ftl</template-extension>
		<portlet-decorator id="barebone" name="Barebone">
			<portlet-decorator-css-class>portlet-barebone</portlet-decorator-css-class>
		</portlet-decorator>
		<portlet-decorator id="borderless" name="Borderless">
			<portlet-decorator-css-class>portlet-borderless</portlet-decorator-css-class>
		</portlet-decorator>
		<portlet-decorator id="decorate" name="Decorate">
			<default-portlet-decorator>true</default-portlet-decorator>
			<portlet-decorator-css-class>portlet-decorate</portlet-decorator-css-class>
		</portlet-decorator>
	</theme>
</look-and-feel>
XMLEOF

# ── Generate liferay-plugin-package.properties ────────────────────────────
cat > "$WAR_DIR/WEB-INF/liferay-plugin-package.properties" << PROPEOF
name=${THEME_DISPLAY_NAME}
module-group-id=${THEME_ID}
module-incremental-version=1
tags=theme
short-description=${BRAND_NAME} portal theme
author=${BRAND_NAME}
licenses=Proprietary
liferay-versions=7.4.3.100+
PROPEOF

# ── Template substitution function ────────────────────────────────────────
render_template() {
  local INPUT="$1" OUTPUT="$2"
  sed \
    -e "s|{{THEME_ID}}|${THEME_ID}|g" \
    -e "s|{{THEME_DISPLAY_NAME}}|${THEME_DISPLAY_NAME}|g" \
    -e "s|{{BRAND_NAME}}|${BRAND_NAME}|g" \
    -e "s|{{BRAND_TAGLINE}}|${BRAND_TAGLINE}|g" \
    -e "s|{{BRAND_DESCRIPTION}}|${BRAND_DESCRIPTION}|g" \
    -e "s|{{BRAND_COPYRIGHT}}|${BRAND_COPYRIGHT}|g" \
    -e "s|{{COLOR_PRIMARY}}|${COLOR_PRIMARY}|g" \
    -e "s|{{COLOR_PRIMARY_LIGHT}}|${COLOR_PRIMARY_LIGHT}|g" \
    -e "s|{{COLOR_PRIMARY_LIGHTER}}|${COLOR_PRIMARY_LIGHTER}|g" \
    -e "s|{{COLOR_PRIMARY_LIGHTEST}}|${COLOR_PRIMARY_LIGHTEST}|g" \
    -e "s|{{COLOR_SECONDARY}}|${COLOR_SECONDARY}|g" \
    -e "s|{{COLOR_ACCENT}}|${COLOR_ACCENT}|g" \
    -e "s|{{NEUTRAL_100}}|${NEUTRAL_100}|g" \
    -e "s|{{NEUTRAL_200}}|${NEUTRAL_200}|g" \
    -e "s|{{NEUTRAL_300}}|${NEUTRAL_300}|g" \
    -e "s|{{NEUTRAL_400}}|${NEUTRAL_400}|g" \
    -e "s|{{NEUTRAL_500}}|${NEUTRAL_500}|g" \
    -e "s|{{NEUTRAL_600}}|${NEUTRAL_600}|g" \
    -e "s|{{NEUTRAL_700}}|${NEUTRAL_700}|g" \
    -e "s|{{NEUTRAL_800}}|${NEUTRAL_800}|g" \
    -e "s|{{NEUTRAL_900}}|${NEUTRAL_900}|g" \
    -e "s|{{COLOR_SUCCESS}}|${COLOR_SUCCESS}|g" \
    -e "s|{{COLOR_WARNING}}|${COLOR_WARNING}|g" \
    -e "s|{{COLOR_DANGER}}|${COLOR_DANGER}|g" \
    -e "s|{{COLOR_INFO}}|${COLOR_INFO}|g" \
    -e "s|{{FONT_IMPORT_URL}}|${FONT_IMPORT_URL}|g" \
    -e "s|{{FONT_FAMILY_BASE}}|${FONT_FAMILY_BASE}|g" \
    -e "s|{{FONT_FAMILY_MONO}}|${FONT_FAMILY_MONO}|g" \
    -e "s|{{FONT_SIZE_BASE}}|${FONT_SIZE_BASE}|g" \
    -e "s|{{BORDER_RADIUS}}|${BORDER_RADIUS}|g" \
    -e "s|{{CONTENT_MAX_WIDTH}}|${CONTENT_MAX_WIDTH}|g" \
    -e "s|{{HEADER_HEIGHT}}|${HEADER_HEIGHT}|g" \
    -e "s|{{FOOTER_COL_COUNT}}|${FOOTER_COL_COUNT}|g" \
    "$INPUT" > "$OUTPUT"
}

# ── Render CSS templates ──────────────────────────────────────────────────
render_template "$BASE_DIR/css/_custom.scss.tpl" "$WAR_DIR/css/_custom.scss"
render_template "$BASE_DIR/css/_clay_variables.scss.tpl" "$WAR_DIR/css/_clay_variables.scss"

# Handle font import block in _custom.scss
if [ -n "$FONT_IMPORT_URL" ]; then
  sed -i "s|{{#FONT_IMPORT}}||g; s|{{/FONT_IMPORT}}||g" "$WAR_DIR/css/_custom.scss"
else
  sed -i '/{{#FONT_IMPORT}}/,/{{\/FONT_IMPORT}}/d' "$WAR_DIR/css/_custom.scss"
fi

# ── Render FTL templates ─────────────────────────────────────────────────
render_template "$BASE_DIR/templates/portal_normal.ftl.tpl" "$WAR_DIR/templates/portal_normal.ftl"

# Insert footer columns HTML (use printf for escaped newlines)
python3 -c "
import sys
content = open('$WAR_DIR/templates/portal_normal.ftl').read()
footer = '''$(echo -e "$FOOTER_COLUMNS_HTML")'''
content = content.replace('{{FOOTER_COLUMNS_HTML}}', footer)
open('$WAR_DIR/templates/portal_normal.ftl', 'w').write(content)
"

# Copy static templates
cp "$BASE_DIR/templates/navigation.ftl" "$WAR_DIR/templates/"
cp "$BASE_DIR/templates/init.ftl" "$WAR_DIR/templates/"

# Copy images if any exist
if ls "$BASE_DIR"/images/* 1>/dev/null 2>&1; then
  cp "$BASE_DIR"/images/* "$WAR_DIR/images/"
fi

# ── Build WAR ─────────────────────────────────────────────────────────────
WAR_FILE="$BUILD_DIR/${THEME_ID}-theme.war"

if command -v jar &>/dev/null; then
  (cd "$WAR_DIR" && jar cf "$WAR_FILE" WEB-INF css templates js images)
else
  echo "No jar command found — using Docker to build WAR..."
  docker run --rm -v "$WAR_DIR":/theme -w /theme eclipse-temurin:8-jdk \
    sh -c "jar cf /theme/${THEME_ID}-theme.war WEB-INF css templates js images"
  mv "$WAR_DIR/${THEME_ID}-theme.war" "$WAR_FILE"
fi

chmod 666 "$WAR_FILE"
echo ""
echo "Theme WAR built: $WAR_FILE ($(du -h "$WAR_FILE" | cut -f1))"

# ── Deploy ────────────────────────────────────────────────────────────────
if $DO_DEPLOY; then
  echo ""
  echo "Deploying to container: $LIFERAY_CONTAINER"
  docker cp "$WAR_FILE" "$LIFERAY_CONTAINER:/opt/liferay/deploy/${THEME_ID}-theme.war"
  docker exec -u root "$LIFERAY_CONTAINER" chown liferay:liferay "/opt/liferay/deploy/${THEME_ID}-theme.war"

  echo "Waiting for deployment..."
  for i in $(seq 1 30); do
    if docker logs "$LIFERAY_CONTAINER" 2>&1 | tail -50 | grep -q "STARTED ${THEME_ID}"; then
      echo "Theme deployed and STARTED."
      break
    fi
    sleep 2
  done
fi

# ── Apply theme to site ──────────────────────────────────────────────────
if $DO_APPLY; then
  THEME_WAR_ID="${THEME_ID}_WAR_${THEME_ID}theme"

  if [ -z "$GROUP_ID" ]; then
    echo ""
    echo "ERROR: --group-id=XXXXX required with --apply"
    echo "Find it: docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \"SELECT groupid, friendlyurl FROM group_ WHERE site = true;\""
    exit 1
  fi

  echo ""
  echo "Applying theme $THEME_WAR_ID to group $GROUP_ID..."
  docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" \
    -c "UPDATE layoutset SET themeid = '${THEME_WAR_ID}' WHERE groupid = '${GROUP_ID}' AND privatelayout = false;"
  echo "Theme applied. You may need to clear Liferay's cache or restart."
fi

echo ""
echo "Done."
