<link rel="stylesheet" href="../libs/css/leaf.css">
<div class="leaf-sitemap-flex-container">
<!--{foreach $sitemap->buttons as $site}-->
	<div class="leaf-sitemap-button <!--{$site->color}-->">
		<h3><a href="<!--{$site->target}-->" target="_blank"><!--{$site->title}--></a></h3>
		<p><!--{$site->description}--></p>
	</div>
<!--{/foreach}-->
</div>
