#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# Page Setup Script
# Creates pages and adds widgets based on .env configuration
#
# Prerequisites:
#   1. Liferay must be running
#   2. Set auth.token.check.enabled=false in portal-ext.properties temporarily
#   3. Restart Liferay, then run this script
#   4. Re-enable auth.token.check.enabled=true and restart
#
# Usage: ./scripts/setup-pages.sh [admin-email] [admin-password]
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env
if [ -f "$BASE_DIR/.env" ]; then
  set -a
  source "$BASE_DIR/.env"
  set +a
fi

ADMIN_EMAIL="${1:-${PORTAL_ADMIN_EMAIL:-test@liferay.com}}"
ADMIN_PASS="${2:-test}"
API="http://localhost:8080"
AUTH="$ADMIN_EMAIL:$ADMIN_PASS"

echo "Liferay Page Setup"
echo "  API: $API"
echo "  Admin: $ADMIN_EMAIL"
echo ""

# ── Discover site group ID ────────────────────────────────────────────────
echo "Discovering site..."
USER_INFO=$(curl -s -u "$AUTH" "$API/o/headless-admin-user/v1.0/my-user-account")
GROUP_ID=$(echo "$USER_INFO" | python3 -c "import sys,json; sites=json.load(sys.stdin).get('siteBriefs',[]); print(sites[0]['id'] if sites else '')" 2>/dev/null)

if [ -z "$GROUP_ID" ]; then
  echo "ERROR: Could not discover site. Check admin credentials."
  exit 1
fi
echo "  Site group ID: $GROUP_ID"

# ── Create pages ──────────────────────────────────────────────────────────
echo ""
echo "Creating pages..."

IFS=',' read -ra PAGE_LIST <<< "${SITE_PAGES:-}"
for PAGE_DEF in "${PAGE_LIST[@]}"; do
  IFS='|' read -r PAGE_NAME PAGE_URL PORTLET_ID <<< "$PAGE_DEF"
  [ -z "$PAGE_NAME" ] && continue

  RESULT=$(curl -s -o /tmp/page_resp -w "%{http_code}" -u "$AUTH" -X POST "$API/api/jsonws/layout/add-layout" \
    -d "groupId=$GROUP_ID" \
    -d "privateLayout=false" \
    -d "parentLayoutId=0" \
    -d "name=$PAGE_NAME" \
    -d "title=$PAGE_NAME" \
    -d "description=" \
    -d "type=portlet" \
    -d "hidden=false" \
    -d "friendlyURL=$PAGE_URL" \
    -d "serviceContext.scopeGroupId=$GROUP_ID" \
    -d "serviceContext.addGroupPermissions=true" \
    -d "serviceContext.addGuestPermissions=true")

  BODY=$(cat /tmp/page_resp)
  LAYOUT_ID=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('layoutId',''))" 2>/dev/null)

  if [ -n "$LAYOUT_ID" ] && [ "$LAYOUT_ID" != "" ]; then
    echo "  Created: $PAGE_NAME ($PAGE_URL) layoutId=$LAYOUT_ID"

    # Add widget if specified
    if [ -n "$PORTLET_ID" ]; then
      curl -s -o /dev/null -u "$AUTH" -X POST "$API/api/jsonws/layout/update-layout" \
        -d "groupId=$GROUP_ID" \
        -d "privateLayout=false" \
        -d "layoutId=$LAYOUT_ID" \
        --data-urlencode "typeSettings=layout-template-id=1_column
column-1=${PORTLET_ID},"
      echo "    Widget: $PORTLET_ID"
    fi
  else
    if echo "$BODY" | grep -q "DuplicateFriendlyURLException\|must not be a duplicate"; then
      echo "  Skipped: $PAGE_NAME ($PAGE_URL) — already exists"
    else
      echo "  FAILED:  $PAGE_NAME ($PAGE_URL) — HTTP $RESULT"
    fi
  fi
done

echo ""
echo "Done. Re-enable auth.token.check.enabled=true and restart Liferay."
