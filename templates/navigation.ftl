<#if has_navigation && is_setup_complete>
	<ul class="unboxd-nav">
		<#list nav_items as nav_item>
			<#assign
				nav_item_attr_has_popup = ""
				nav_item_css_class = ""
			/>

			<#if nav_item.isSelected()>
				<#assign nav_item_css_class = "unboxd-nav__item--active" />
			</#if>

			<#if nav_item.hasChildren()>
				<#assign nav_item_attr_has_popup = "aria-haspopup=\"true\"" />
			</#if>

			<li class="unboxd-nav__item ${nav_item_css_class}">
				<a class="unboxd-nav__link" ${nav_item_attr_has_popup} href="${nav_item.getURL()}" ${nav_item.getTarget()}>
					${nav_item.getName()}
				</a>

				<#if nav_item.hasChildren()>
					<ul class="unboxd-nav__dropdown">
						<#list nav_item.getChildren() as child_item>
							<li class="unboxd-nav__dropdown-item">
								<a href="${child_item.getURL()}" ${child_item.getTarget()}>
									${child_item.getName()}
								</a>
							</li>
						</#list>
					</ul>
				</#if>
			</li>
		</#list>
	</ul>
</#if>
