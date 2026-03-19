/* ==========================================================================
   {{THEME_DISPLAY_NAME}} — Generated Theme
   Brand: {{BRAND_NAME}}
   ========================================================================== */

/* ── Font Import ────────────────────────────────────────────────────────── */
{{#FONT_IMPORT}}
@import url('{{FONT_IMPORT_URL}}');
{{/FONT_IMPORT}}

/* ── Brand Variables ────────────────────────────────────────────────────── */
:root {
	--brand-primary: {{COLOR_PRIMARY}};
	--brand-primary-light: {{COLOR_PRIMARY_LIGHT}};
	--brand-primary-lighter: {{COLOR_PRIMARY_LIGHTER}};
	--brand-primary-lightest: {{COLOR_PRIMARY_LIGHTEST}};
	--brand-secondary: {{COLOR_SECONDARY}};
	--brand-accent: {{COLOR_ACCENT}};

	--neutral-100: {{NEUTRAL_100}};
	--neutral-200: {{NEUTRAL_200}};
	--neutral-300: {{NEUTRAL_300}};
	--neutral-400: {{NEUTRAL_400}};
	--neutral-500: {{NEUTRAL_500}};
	--neutral-600: {{NEUTRAL_600}};
	--neutral-700: {{NEUTRAL_700}};
	--neutral-800: {{NEUTRAL_800}};
	--neutral-900: {{NEUTRAL_900}};

	--success: {{COLOR_SUCCESS}};
	--warning: {{COLOR_WARNING}};
	--danger: {{COLOR_DANGER}};
	--info: {{COLOR_INFO}};

	--font-family-base: {{FONT_FAMILY_BASE}};
	--font-family-mono: {{FONT_FAMILY_MONO}};

	--content-max-width: {{CONTENT_MAX_WIDTH}};
	--header-height: {{HEADER_HEIGHT}};
	--border-radius: {{BORDER_RADIUS}};
}

/* ── Base Typography ────────────────────────────────────────────────────── */
body {
	font-family: var(--font-family-base) !important;
	font-size: {{FONT_SIZE_BASE}};
	font-weight: 400;
	line-height: 1.5;
	color: var(--neutral-900);
	background-color: var(--neutral-100);
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
}

h1, h2, h3, h4, h5, h6,
.portlet-title-text,
.site-title {
	font-family: var(--font-family-base) !important;
	font-weight: 600;
	color: var(--brand-primary);
	letter-spacing: -0.01em;
}

h1 { font-size: 2.625rem; line-height: 1.2; }
h2 { font-size: 2rem; line-height: 1.25; }
h3 { font-size: 1.5rem; line-height: 1.3; }
h4 { font-size: 1.25rem; line-height: 1.35; }
h5 { font-size: 1rem; line-height: 1.4; }
h6 { font-size: 0.875rem; line-height: 1.5; }

p { line-height: 1.65; color: var(--neutral-700); }

a {
	color: var(--brand-accent);
	text-decoration: none;
	transition: color 0.15s ease;
	&:hover { color: var(--brand-primary); text-decoration: underline; }
}

code, pre { font-family: var(--font-family-mono); }

/* ── Header ─────────────────────────────────────────────────────────────── */
#banner {
	background-color: var(--brand-primary) !important;
	border-bottom: 3px solid var(--brand-accent);
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12);
}

.unboxd-header__inner {
	max-width: var(--content-max-width);
	margin: 0 auto;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 1.5rem;
	min-height: var(--header-height);
}

.unboxd-header__brand a {
	display: flex;
	align-items: center;
	gap: 0.5rem;
	text-decoration: none;
}

.unboxd-header__title {
	color: #FFFFFF;
	font-size: 1.125rem;
	font-weight: 600;
	letter-spacing: 0.02em;
}

.unboxd-header__nav { flex: 1; display: flex; justify-content: center; }
.unboxd-header__actions { display: flex; align-items: center; }

/* ── Navigation ─────────────────────────────────────────────────────────── */
.unboxd-nav {
	display: flex;
	list-style: none;
	margin: 0;
	padding: 0;
}

.unboxd-nav__item { position: relative; }

.unboxd-nav__link {
	display: block;
	color: rgba(255, 255, 255, 0.85) !important;
	font-size: 0.875rem;
	font-weight: 500;
	padding: 0.875rem 1rem;
	text-decoration: none;
	border-bottom: 2px solid transparent;
	transition: all 0.15s ease;
	white-space: nowrap;

	&:hover {
		color: #FFFFFF !important;
		background-color: rgba(255, 255, 255, 0.08);
		border-bottom-color: var(--brand-primary-light);
		text-decoration: none;
	}
}

.unboxd-nav__item--active .unboxd-nav__link {
	color: #FFFFFF !important;
	border-bottom-color: #FFFFFF;
}

.unboxd-nav__dropdown {
	display: none;
	position: absolute;
	top: 100%;
	left: 0;
	min-width: 220px;
	background: #FFFFFF;
	border: 1px solid var(--neutral-200);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
	list-style: none;
	padding: 0.25rem 0;
	margin: 0;
	z-index: 1000;
	border-radius: var(--border-radius);
}

.unboxd-nav__item:hover .unboxd-nav__dropdown { display: block; }

.unboxd-nav__dropdown-item a {
	display: block;
	padding: 0.5rem 1rem;
	color: var(--neutral-700) !important;
	font-size: 0.875rem;
	text-decoration: none;
	&:hover { background-color: var(--brand-primary-lightest); color: var(--brand-primary) !important; }
}

/* ── Content Area ───────────────────────────────────────────────────────── */
#content {
	max-width: var(--content-max-width);
	margin: 0 auto;
	padding: 2rem 1.5rem;
}

.portlet {
	background: #FFFFFF;
	border: 1px solid var(--neutral-200);
	border-radius: var(--border-radius);
	margin-bottom: 1.5rem;
	box-shadow: none;
	transition: box-shadow 0.15s ease;
	&:hover { box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08); }
}

.portlet-topper {
	background-color: #FFFFFF !important;
	border-bottom: 1px solid var(--neutral-200);
	padding: 1rem 1.5rem;
}

.portlet-title-text {
	font-size: 0.875rem;
	font-weight: 600;
	text-transform: uppercase;
	letter-spacing: 0.04em;
	color: var(--neutral-700) !important;
}

.portlet-content { padding: 1.5rem; }

/* ── Buttons ────────────────────────────────────────────────────────────── */
.btn, .btn-primary {
	font-family: var(--font-family-base);
	font-size: 0.875rem;
	font-weight: 500;
	letter-spacing: 0.02em;
	padding: 0.6875rem 1rem;
	border-radius: var(--border-radius);
	border: none;
	transition: all 0.15s ease;
	cursor: pointer;
}

.btn-primary {
	background-color: var(--brand-accent) !important;
	color: #FFFFFF !important;
	&:hover, &:focus { background-color: var(--brand-primary) !important; }
	&:active { background-color: var(--brand-secondary) !important; }
}

.btn-secondary, .btn-default {
	background-color: var(--neutral-700) !important;
	color: #FFFFFF !important;
	&:hover { background-color: var(--neutral-800) !important; }
}

.btn-outline-primary {
	background-color: transparent !important;
	color: var(--brand-accent) !important;
	border: 1px solid var(--brand-accent) !important;
	border-radius: var(--border-radius);
	&:hover { background-color: var(--brand-accent) !important; color: #FFFFFF !important; }
}

.btn-link {
	color: var(--brand-accent);
	padding: 0.6875rem 1rem;
	&:hover { background-color: var(--brand-primary-lightest); text-decoration: none; }
}

/* ── Forms ──────────────────────────────────────────────────────────────── */
.form-control, input[type="text"], input[type="email"],
input[type="password"], input[type="search"], textarea, select {
	font-family: var(--font-family-base);
	font-size: 0.875rem;
	border: none;
	border-bottom: 1px solid var(--neutral-300);
	border-radius: var(--border-radius);
	background-color: var(--neutral-100);
	padding: 0.6875rem 1rem;
	color: var(--neutral-900);
	transition: border-color 0.15s ease;

	&:focus {
		border-bottom-color: var(--brand-accent);
		outline: 2px solid var(--brand-accent);
		outline-offset: -2px;
		background-color: var(--neutral-100);
		box-shadow: none;
	}
}

label {
	font-size: 0.75rem;
	font-weight: 500;
	color: var(--neutral-600);
	letter-spacing: 0.02em;
	margin-bottom: 0.25rem;
}

/* ── Cards ──────────────────────────────────────────────────────────────── */
.card, .panel {
	border: 1px solid var(--neutral-200);
	border-radius: var(--border-radius);
	box-shadow: none;
	background: #FFFFFF;
}

.card-header, .panel-heading {
	background-color: #FFFFFF;
	border-bottom: 1px solid var(--neutral-200);
	font-weight: 600;
	font-size: 0.875rem;
	padding: 1rem 1.5rem;
}

/* ── Tables ─────────────────────────────────────────────────────────────── */
.table, .table-autofit {
	font-size: 0.875rem;
	th {
		background-color: var(--neutral-100);
		font-weight: 600;
		font-size: 0.75rem;
		text-transform: uppercase;
		letter-spacing: 0.04em;
		color: var(--neutral-600);
		border-bottom: 2px solid var(--neutral-200);
		padding: 0.75rem 1rem;
	}
	td {
		padding: 0.75rem 1rem;
		border-bottom: 1px solid var(--neutral-200);
		vertical-align: middle;
	}
	tbody tr:hover { background-color: var(--brand-primary-lightest); }
}

/* ── Alerts ─────────────────────────────────────────────────────────────── */
.alert {
	border-radius: var(--border-radius);
	border-left: 3px solid;
	font-size: 0.875rem;
}

.alert-info    { background-color: var(--brand-primary-lightest); border-left-color: var(--brand-accent); color: var(--brand-primary); }
.alert-success { border-left-color: var(--success); }
.alert-warning { border-left-color: var(--warning); }
.alert-danger  { border-left-color: var(--danger); }

/* ── Dropdowns ──────────────────────────────────────────────────────────── */
.dropdown-menu {
	border-radius: var(--border-radius);
	border: 1px solid var(--neutral-200);
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
	padding: 0.25rem 0;
}

.dropdown-item {
	font-size: 0.875rem;
	padding: 0.5rem 1rem;
	&:hover { background-color: var(--brand-primary-lightest); color: var(--brand-primary); }
}

/* ── Pagination ─────────────────────────────────────────────────────────── */
.pagination .page-link {
	border-radius: var(--border-radius);
	color: var(--brand-accent);
	border-color: var(--neutral-200);
}
.pagination .page-item.active .page-link {
	background-color: var(--brand-accent);
	border-color: var(--brand-accent);
}

/* ── Breadcrumbs ────────────────────────────────────────────────────────── */
.breadcrumb {
	background: transparent;
	padding: 0.5rem 0;
	font-size: 0.75rem;
	.breadcrumb-item a { color: var(--brand-accent); }
	.breadcrumb-item.active { color: var(--neutral-500); }
}

/* ── Footer ─────────────────────────────────────────────────────────────── */
.unboxd-footer {
	background-color: var(--neutral-900);
	border-top: 3px solid var(--brand-accent);
	padding: 3rem 0 2rem;
}

.unboxd-footer__inner {
	max-width: var(--content-max-width);
	margin: 0 auto;
	padding: 0 1.5rem;
}

.unboxd-footer__grid {
	display: grid;
	grid-template-columns: repeat({{FOOTER_COL_COUNT}}, 1fr);
	gap: 2rem;
	margin-bottom: 2.5rem;
}

.unboxd-footer__col h4 {
	color: #FFFFFF;
	font-size: 0.875rem;
	font-weight: 600;
	text-transform: uppercase;
	letter-spacing: 0.04em;
	margin-bottom: 1rem;
}

.unboxd-footer__col ul { list-style: none; padding: 0; margin: 0; }
.unboxd-footer__col ul li { margin-bottom: 0.5rem; }
.unboxd-footer__col ul a {
	color: var(--neutral-400) !important;
	font-size: 0.875rem;
	text-decoration: none;
	transition: color 0.15s ease;
	&:hover { color: #FFFFFF !important; }
}

.unboxd-footer__bottom {
	border-top: 1px solid var(--neutral-700);
	padding-top: 1.5rem;
	p { color: var(--neutral-500); font-size: 0.75rem; margin: 0; }
}

/* ── Utilities ──────────────────────────────────────────────────────────── */
::selection { background-color: var(--brand-primary-light); color: #FFFFFF; }
html { scroll-behavior: smooth; }
*:focus-visible { outline: 2px solid var(--brand-accent); outline-offset: 2px; }

/* ── Responsive ─────────────────────────────────────────────────────────── */
@media (max-width: 1024px) {
	.unboxd-footer__grid { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 768px) {
	.unboxd-header__inner { flex-wrap: wrap; padding: 0.5rem 1rem; }
	.unboxd-header__nav { order: 3; width: 100%; justify-content: flex-start; overflow-x: auto; }
	.unboxd-footer__grid { grid-template-columns: 1fr; gap: 1.5rem; }
}
