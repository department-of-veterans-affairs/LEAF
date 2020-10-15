<link rel="stylesheet" href="../libs/css/leaf.css">

<div class="leaf-marginAll-1rem">

	<h1><!--{$city}--> Sitemap</h1>

</div>

<div class="leaf-sitemap-flex-container">

	<!--{foreach $sitemap->buttons as $site}-->
		<div class="leaf-sitemap-card <!--{$site->color}-->">
			<h3><a href="<!--{$site->target}-->" target="_blank"><!--{$site->title}--></a></h3>
			<p><!--{$site->description}--></p>
		</div>
	<!--{/foreach}-->

</div>
