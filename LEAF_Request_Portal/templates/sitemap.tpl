<link rel="stylesheet" href="<!--{$css_path}-->/leaf.css">

<div class="leaf-marginAll-1rem">

	<h1>
		<!--{$city}--> Sitemap
	</h1>
	<button class="usa-button" onclick="window.open('./report.php?a=LEAF_inbox_combined', '_blank')">
		View Combined Inbox
	</button>

</div>

<div class="leaf-sitemap-flex-container">
	<!--{foreach $sitemap as $site}-->
		<div class="leaf-sitemap-card" onclick="window.location.href='<!--{$site['target']}-->'"
			style="cursor:pointer; background-color: <!--{$site['color']}-->; color: <!--{$site['fontColor']}-->;" tabindex="0">
			<!--{if $site['icon'] !== ''}-->
				<img style="float: left; margin-right: 1rem; height: 48px; width: 48px;" src="<!--{$site['icon']}-->">
			<!--{/if}-->
			<h3 style="color: <!--{$site['fontColor']}-->;">
				<!--{$site['title']}-->
			</h3>
			<p>
				<!--{$site['description']}-->
			</p>
		</div>
	<!--{/foreach}-->

</div>

<script>
	$('.leaf-sitemap-card').on('keydown', function() {
		if (event.keyCode === 13) {
			event.preventDefault();
			event.target.click();
		}
	});
</script>