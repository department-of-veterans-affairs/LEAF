<style></style>

<script type='text/javascript'>
    let CSRFToken = '<!--{$CSRFToken}-->';

    let sites = [];

    const getMapSites = new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: '../api/site/settings/sitemap_json',
            success: (res) => {
                if (res === 'Admin access required') {
                    return {};
                }

                let siteMap = Object.values(JSON.parse(res[0].data))[0];
                let formattedSiteMap = siteMap.map((site) => {
                    return {
                        url: site.target,
                        name: site.description,
                        backgroundColor: site.color,
                        icon: site.icon,
                        fontColor: site.fontColor,
                        nonAdmin: true,
                        columns: site.columns ?? [],
                    };
                }).filter((site) => site.url.includes(window.location.hostname));

                sites.push(...formattedSiteMap);
                resolve(sites);
            },
            fail: (err) => {
                console.log(err);
                reject();
            }
        });
    });

    const loadSiteCols = (sites) => new Promise((resolve, reject) => {
        let buf = [];
        // for each site, show each column and process as html in separate array
        sites.forEach(site => {
            site.cols.forEach(col => {

            });
        });
    });

    const loadSiteColPreview = (siteCols) => new Promise((resolve, reject) => {

    });

    const loadhtml = new Promise((resolve, reject) => {

    });

    const updateCols = new Promise((resolve, reject) => {
        $.ajax({
            type: 'POST',
            url: '../api/site/settings/sitemap_json',
            success: (res) => {
                resolve(res);
            },
            fail: (err) => {
                console.log(err);
                reject();
            }
        });
    });

    window.onload = () => {
        getMapSites
            .then(sites => {
                loadSiteCols(sites)
                    .then(siteCols => {
                        loadSiteColPreview(siteCols);
                    });
            });
    };
</script>

<h1 style="margin: 3rem;">Combined Inbox Editor</h1>