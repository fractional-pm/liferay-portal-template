<!DOCTYPE html>
<#include init />

<html class="${root_css_class}" dir="${w3c_language_dir}" lang="${w3c_language_id}">
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />

	<@liferay_util["include"] page=top_head_include />

	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
</head>

<body class="${css_class}">

<@liferay_ui["quick-access"] contentId="#main-content" />
<@liferay_util["include"] page=body_top_include />
<@liferay.control_menu />

<div id="wrapper">

	<#-- ══ HEADER ══════════════════════════════════════════════════════ -->
	<header id="banner">
		<div class="unboxd-header">
			<div class="unboxd-header__inner">
				<div class="unboxd-header__brand">
					<a href="${site_default_url}">
						<#if logo_css_class?has_content>
							<span class="${logo_css_class}"></span>
						</#if>
						<span class="unboxd-header__title">${site_name}</span>
					</a>
				</div>

				<#if has_navigation>
					<nav class="unboxd-header__nav" aria-label="Main Navigation">
						<#include "${full_templates_path}/navigation.ftl" />
					</nav>
				</#if>

				<div class="unboxd-header__actions">
					<@liferay.user_personal_bar />
				</div>
			</div>
		</div>
	</header>

	<#-- ══ MAIN CONTENT ═══════════════════════════════════════════════ -->
	<section id="content">
		<div id="main-content">
			<@liferay_util["include"] page=content_include />
		</div>
	</section>

	<#-- ══ FOOTER ═════════════════════════════════════════════════════ -->
	<footer id="footer">
		<div class="unboxd-footer">
			<div class="unboxd-footer__inner">
				<div class="unboxd-footer__grid">
{{FOOTER_COLUMNS_HTML}}
				</div>
				<div class="unboxd-footer__bottom">
					<p>&copy; ${.now?string("yyyy")} {{BRAND_COPYRIGHT}}. All rights reserved.</p>
				</div>
			</div>
		</div>
	</footer>
</div>

<@liferay_util["include"] page=body_bottom_include />
</body>
</html>
