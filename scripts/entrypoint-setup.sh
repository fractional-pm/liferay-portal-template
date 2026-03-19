#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# Liferay Setup Container
# Waits for Liferay to start, builds theme, deploys, creates pages
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

echo "============================================"
echo " Liferay Portal Setup"
echo " Brand: $BRAND_NAME"
echo " Theme: $THEME_DISPLAY_NAME ($THEME_ID)"
echo "============================================"

# ── Wait for Liferay ──────────────────────────────────────────────────────
echo ""
echo "[1/5] Waiting for Liferay to start..."
for i in $(seq 1 120); do
  if wget -q --spider "http://liferay:8080" 2>/dev/null; then
    echo "  Liferay is responding."
    break
  fi
  if [ "$i" = "120" ]; then
    echo "  ERROR: Liferay did not start within 10 minutes."
    exit 1
  fi
  sleep 5
done

# Extra wait for full initialization
sleep 30
echo "  Liferay fully initialized."

# ── Derive values ─────────────────────────────────────────────────────────
case "${LAYOUT_STYLE:-sharp}" in
  sharp) BORDER_RADIUS="0" ;;
  soft)  BORDER_RADIUS="4px" ;;
  round) BORDER_RADIUS="8px" ;;
  *)     BORDER_RADIUS="0" ;;
esac

FONT_FAMILY_FULL="'${FONT_FAMILY}', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
FONT_FAMILY_MONO="'IBM Plex Mono', 'SFMono-Regular', monospace"

# ── Build theme WAR ──────────────────────────────────────────────────────
echo ""
echo "[2/5] Building theme WAR..."

WORK=/tmp/theme-build
mkdir -p "$WORK/WEB-INF" "$WORK/css" "$WORK/templates" "$WORK/js" "$WORK/images"

# liferay-look-and-feel.xml
cat > "$WORK/WEB-INF/liferay-look-and-feel.xml" << XMLEOF
<?xml version="1.0"?>
<!DOCTYPE look-and-feel PUBLIC "-//Liferay//DTD Look and Feel 7.4.0//EN" "http://www.liferay.com/dtd/liferay-look-and-feel_7_4_0.dtd">
<look-and-feel>
  <compatibility><version>7.4.3.100+</version></compatibility>
  <theme id="${THEME_ID}" name="${THEME_DISPLAY_NAME}">
    <template-extension>ftl</template-extension>
    <portlet-decorator id="barebone" name="Barebone"><portlet-decorator-css-class>portlet-barebone</portlet-decorator-css-class></portlet-decorator>
    <portlet-decorator id="borderless" name="Borderless"><portlet-decorator-css-class>portlet-borderless</portlet-decorator-css-class></portlet-decorator>
    <portlet-decorator id="decorate" name="Decorate"><default-portlet-decorator>true</default-portlet-decorator><portlet-decorator-css-class>portlet-decorate</portlet-decorator-css-class></portlet-decorator>
  </theme>
</look-and-feel>
XMLEOF

# liferay-plugin-package.properties
cat > "$WORK/WEB-INF/liferay-plugin-package.properties" << PROPEOF
name=${THEME_DISPLAY_NAME}
module-group-id=${THEME_ID}
module-incremental-version=1
tags=theme
short-description=${BRAND_NAME} portal theme
author=${BRAND_NAME}
licenses=Proprietary
liferay-versions=7.4.3.100+
PROPEOF

# Process CSS templates
for TPL in /workspace/css/*.tpl; do
  OUTNAME=$(basename "$TPL" .tpl)
  sed \
    -e "s|{{THEME_DISPLAY_NAME}}|${THEME_DISPLAY_NAME}|g" \
    -e "s|{{BRAND_NAME}}|${BRAND_NAME}|g" \
    -e "s|{{COLOR_PRIMARY}}|${COLOR_PRIMARY}|g" \
    -e "s|{{COLOR_PRIMARY_LIGHT}}|${COLOR_PRIMARY_LIGHT}|g" \
    -e "s|{{COLOR_PRIMARY_LIGHTER}}|${COLOR_PRIMARY_LIGHTER}|g" \
    -e "s|{{COLOR_PRIMARY_LIGHTEST}}|${COLOR_PRIMARY_LIGHTEST}|g" \
    -e "s|{{COLOR_SECONDARY}}|${COLOR_SECONDARY}|g" \
    -e "s|{{COLOR_ACCENT}}|${COLOR_ACCENT}|g" \
    -e "s|{{NEUTRAL_100}}|${NEUTRAL_100:-#F4F4F4}|g" \
    -e "s|{{NEUTRAL_200}}|${NEUTRAL_200:-#E0E0E0}|g" \
    -e "s|{{NEUTRAL_300}}|${NEUTRAL_300:-#C6C6C6}|g" \
    -e "s|{{NEUTRAL_400}}|${NEUTRAL_400:-#A8A8A8}|g" \
    -e "s|{{NEUTRAL_500}}|${NEUTRAL_500:-#6F6F6F}|g" \
    -e "s|{{NEUTRAL_600}}|${NEUTRAL_600:-#525252}|g" \
    -e "s|{{NEUTRAL_700}}|${NEUTRAL_700:-#393939}|g" \
    -e "s|{{NEUTRAL_800}}|${NEUTRAL_800:-#262626}|g" \
    -e "s|{{NEUTRAL_900}}|${NEUTRAL_900:-#161616}|g" \
    -e "s|{{COLOR_SUCCESS}}|${COLOR_SUCCESS:-#198038}|g" \
    -e "s|{{COLOR_WARNING}}|${COLOR_WARNING:-#F1C21B}|g" \
    -e "s|{{COLOR_DANGER}}|${COLOR_DANGER:-#DA1E28}|g" \
    -e "s|{{COLOR_INFO}}|${COLOR_INFO:-#0072CE}|g" \
    -e "s|{{FONT_IMPORT_URL}}|${FONT_IMPORT_URL}|g" \
    -e "s|{{FONT_FAMILY_BASE}}|${FONT_FAMILY_FULL}|g" \
    -e "s|{{FONT_FAMILY_MONO}}|${FONT_FAMILY_MONO}|g" \
    -e "s|{{FONT_SIZE_BASE}}|${FONT_SIZE_BASE}|g" \
    -e "s|{{BORDER_RADIUS}}|${BORDER_RADIUS}|g" \
    -e "s|{{CONTENT_MAX_WIDTH}}|${CONTENT_MAX_WIDTH}|g" \
    -e "s|{{HEADER_HEIGHT}}|${HEADER_HEIGHT:-48px}|g" \
    -e "s|{{FOOTER_COL_COUNT}}|6|g" \
    "$TPL" > "$WORK/css/$OUTNAME"
done

# Handle font import conditional
if [ -n "${FONT_IMPORT_URL}" ]; then
  sed -i "s|{{#FONT_IMPORT}}||g; s|{{/FONT_IMPORT}}||g" "$WORK/css/_custom.scss"
else
  sed -i '/{{#FONT_IMPORT}}/,/{{\/FONT_IMPORT}}/d' "$WORK/css/_custom.scss"
fi

# Build footer HTML from env vars
FOOTER_HTML=""
for i in 1 2 3 4 5 6; do
  VAR="FOOTER_COL_$i"
  VAL="${!VAR:-}"
  [ -z "$VAL" ] && continue
  IFS='|' read -ra PARTS <<< "$VAL"
  HEADING="${PARTS[0]}"
  LINKS=""
  for ((j=1; j<${#PARTS[@]}; j++)); do
    IFS=':' read -r LTXT LURL <<< "${PARTS[$j]}"
    LINKS="${LINKS}<li><a href=\"${LURL}\">${LTXT}</a></li>"
  done
  FOOTER_HTML="${FOOTER_HTML}<div class=\"unboxd-footer__col\"><h4>${HEADING}</h4><ul>${LINKS}</ul></div>"
done

# Process FTL template
sed \
  -e "s|{{BRAND_COPYRIGHT}}|${BRAND_NAME}|g" \
  -e "s|{{FOOTER_COLUMNS_HTML}}|${FOOTER_HTML}|g" \
  /workspace/templates/portal_normal.ftl.tpl > "$WORK/templates/portal_normal.ftl"

cp /workspace/templates/navigation.ftl "$WORK/templates/"
cp /workspace/templates/init.ftl "$WORK/templates/"

# Build WAR
cd "$WORK"
jar cf "/tmp/${THEME_ID}-theme.war" WEB-INF css templates js images
echo "  WAR built: ${THEME_ID}-theme.war"

# ── Deploy theme ──────────────────────────────────────────────────────────
echo ""
echo "[3/5] Deploying theme..."
cp "/tmp/${THEME_ID}-theme.war" /opt/liferay/deploy/
echo "  Theme copied to deploy directory."

# Wait for theme to be picked up
sleep 20
echo "  Theme deployment initiated."

# ── Temporarily disable auth token for API calls ─────────────────────────
echo ""
echo "[4/5] Creating pages and applying theme..."

# Wait for API to be ready and auth token check to not block us
# We'll use wget since curl may not be in temurin image
API_BASE="http://liferay:8080"
AUTH_HEADER="$(echo -n "${PORTAL_ADMIN_EMAIL:-test@liferay.com}:test" | base64)"

# Try creating pages via JSON-WS (need auth token disabled for this to work)
# The portal-ext.properties should have auth.token.check.enabled=false for initial setup
if [ -n "${SITE_PAGES:-}" ]; then
  echo "  Page creation requires auth.token.check.enabled=false in portal-ext.properties"
  echo "  Pages defined in SITE_PAGES will need to be created after initial setup."
  echo "  Run: ./scripts/setup-pages.sh after first login."
fi

# ── Apply theme via DB ───────────────────────────────────────────────────
echo ""
echo "[5/5] Applying theme via database..."

# Install psql client
apt-get update -qq > /dev/null 2>&1 && apt-get install -qq -y postgresql-client > /dev/null 2>&1 || true

THEME_WAR_ID="${THEME_ID}_WAR_${THEME_ID}theme"

# Wait for layout set to exist
for i in $(seq 1 30); do
  RESULT=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h postgresql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -c "SELECT COUNT(*) FROM layoutset WHERE privatelayout = false;" 2>/dev/null || echo "0")
  if [ "$(echo "$RESULT" | tr -d ' ')" != "0" ]; then
    break
  fi
  sleep 5
done

# Find the site group ID
GROUP_ID=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h postgresql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -c "SELECT groupid FROM group_ WHERE site = true AND classnameid = (SELECT classnameid FROM classname_ WHERE value = 'com.liferay.portal.kernel.model.Group') LIMIT 1;" 2>/dev/null | tr -d ' ')

if [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "" ]; then
  PGPASSWORD="${POSTGRES_PASSWORD}" psql -h postgresql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -c "UPDATE layoutset SET themeid = '${THEME_WAR_ID}' WHERE groupid = '${GROUP_ID}' AND privatelayout = false;" 2>/dev/null
  echo "  Theme $THEME_WAR_ID applied to group $GROUP_ID"
else
  echo "  WARNING: Could not find site group ID. Apply theme manually."
fi

echo ""
echo "============================================"
echo " Setup complete!"
echo ""
echo " Portal: http://${PORTAL_DOMAIN}:8080"
echo " Theme:  ${THEME_DISPLAY_NAME}"
echo ""
echo " Next steps:"
echo "  1. Login and change admin password"
echo "  2. Run ./scripts/setup-pages.sh to create pages"
echo "  3. Configure SSL if needed"
echo "============================================"
