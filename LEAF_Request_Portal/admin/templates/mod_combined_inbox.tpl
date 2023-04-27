<style>
    .col-header {
        font-weight: 300;
        font-size: 50%;
        background-color: #D1DFFF;
        border-color: black;
    }

    .col-header:hover {
        background-color: #79a2ff;
        border-color: black;
    }

    #editor-container {
        display: grid;
        margin-top: 25px;
        grid-template-columns: min-content 1fr;
        grid-column-gap: 1rem;
    }

    .site-container {
        text-align: left;
        box-shadow: 0 2px 3px #a7a9aa;
        border-radius: 4px;
        margin: 0px auto 1.5rem;
    }

    .site-title {
        margin-bottom: 1rem;
        font-weight: bold;
        font-size: 200%;
        line-height: 240%;
    }

    #side-bar {
        text-align: left;
        position: sticky;
        top: 0;
        overflow-y: auto;
        max-height: 75vh;
        width: 20vw;
        background-color: white;
        border: 1px solid black;
        padding: 1rem;
    }
</style>

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
                        columns: site.columns ?? 'service,title,status',
                        displayColumns: [],
                    };
                }).filter((site) => site.url.includes(window.location.hostname));

                sites.push(...formattedSiteMap);
                resolve(sites);
            },
            fail: (err) => {
                reject(err);
            }
        });
    });

    const loadSiteCols = (sites) => new Promise((resolve, reject) => {
        // for each site, show each column and process as html in separate array
        sites.forEach(site => {
            let displayColumnsArr = [];
            site.columns = site.columns?.split(',') ?? defaultCols;
            site.columns.forEach(column => {
                site.displayColumns.push(`<div class="col-header">${column}</div>`);
            });
        });
        resolve(sites);
    });

    const loadSiteColPreview = (sites) => new Promise((resolve, reject) => {
        buf = [];
        sites.forEach(site => {
            // build the preview pane and headers
            displayColumns = site.displayColumns.join('');
            buf.push(`<div class="site-container" style="border-right: 8px ${site.backgroundColor}; border-left: 8px ${site.backgroundColor}; border-right: 8px ${site.backgroundColor};">
                <div class="site-title" style="backgroundColor: ${site.backgroundColor} color: ${site.fontColor}">
                    ${site.name}
                    <div class="inbox">
                        ${displayColumns.replaceAll(',', '')}
                    </div>
                </div>
            </div>`);
        });

        console.log(buf.join('<br/>'));
        // assign buffer to id div for display
        $('#inbox-preview').html(buf.join('<br/>'));
    });

    const updateColumns = new Promise((resolve, reject) => {
        $.ajax({
            type: 'POST',
            url: '../api/site/settings/sitemap_json',
            success: (res) => {
                resolve(res);
            },
            fail: (err) => {
                reject(err);
            }
        });
    });

    window.onload = () => {
        getMapSites
            .then(sites => {
                loadSiteCols(sites)
                    .then(sites => {
                        loadSiteColPreview(sites);
                    });
            });
    };
</script>

<h1 style="margin: 3rem;">Combined Inbox Editor</h1>

<div id="editor-container">
    <div id="side-bar" class="inbox" style="display: block;">Jump to Section: </div>
    <div id="inbox-preview" style="display: block;"></div>
</div>