<link rel="stylesheet" href="../libs/css/leaf.css">
<style>
	.flex-container {
		display: flex;
		flex-wrap: wrap;
		justify-content: center;
		align-items: center;
	}

	.flex-container > div {
	 	width: 30%;
	 	box-sizing: border-box;
	}
</style>

<div class="flex-container">
<!--{foreach $sitemap->buttons as $site}-->
	<div class="leaf-sitemap-button <!--{$site->color}-->">
		<h3><a href="<!--{$site->target}-->" target="_blank"><!--{$site->title}--></a></h3>
		<p><!--{$site->description}--></p>
	</div>
<!--{/foreach}-->
</div>
