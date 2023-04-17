<h2>TEST entry</h2>
<div id="site-designer-app">
    <p>{{ CSRFToken }}</p>
    <p>{{ test }}</p>
    <mod-home-menu></mod-home-menu>
</div>

<script type="text/javascript" src="<!--{$libsPath}-->js/vue-dest/site_designer/LEAF_designer_main_build.js" defer></script>

<script>
    const CSRFToken = '<!--{$CSRFToken}-->';
</script>