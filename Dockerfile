# Pre-built Liferay with theme baked in
# Usage: docker build --build-arg THEME_ID=acmetheme -t mycompany/liferay-portal .
FROM liferay/portal:7.4.3.120-ga120

ARG THEME_ID=acmetheme

# Copy pre-built theme WAR (build it first with build-theme.sh)
COPY build/${THEME_ID}/${THEME_ID}-theme.war /opt/liferay/deploy/

# Copy portal-ext.properties if you want to bake it in
# COPY runtime/portal-ext.properties /opt/liferay/portal-ext.properties
