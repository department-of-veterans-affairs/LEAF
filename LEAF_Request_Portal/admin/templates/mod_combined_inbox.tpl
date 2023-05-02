<style>
    .col-header {
        font-weight: 300;
        font-size: 100%;
        background-color: #D1DFFF;
        border: 1px solid black;
        padding: 1rem;
        display: table-cell;
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

    .inbox {
        margin-bottom: 1rem;
        display: table;
    }

    .header-row {
        display: table-row;
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

    const buildHeaderColumns = (preCon, cols, postCon) => {
        cols = cols.split(',') ?? defaultCols;
        let headerColumns = [];
        cols.forEach(col => {
            headerColumns.push(`${preCon}${col}${postCon}`);
        });
        return headerColumns;
    };

    const loadSiteColPreview = (sites) => new Promise((resolve, reject) => {
        buf = [];
        sites.forEach(site => {
            let headerColumns = buildHeaderColumns(`<div class="col-header">`, site.columns, `</div>`);
            // build the preview pane and headers
            buf.push(`
            <div class="site-container" style="border-right: 8px solid ${site.backgroundColor}; border-left: 8px solid ${site.backgroundColor}; border-bottom: 8px solid ${site.backgroundColor};">
                <div class="site-title" style="background-color: ${site.backgroundColor}; color: ${site.fontColor};">
                    ${site.name}
                </div>
                <div class="inbox">
                    <div class="header-row">
                        ${headerColumns.join('')}
                    </div>
                </div>
            </div>`);
        });

        // assign buffer to id div for display
        $('#inbox-preview').html(buf.join('<br/>'));
    });

    const loadSiteColMenu = (site) => new Promise((resolve, reject) => {
        buf = [];
        sites.forEach(site => {
            let headerOptions = buildHeaderColumns(`<div>`, site.columns, `</div>`);
            buf.push(`
                <div>
                    ${site.name}
                </div>
                <div>
                    ${headerOptions.join('')}
                </div>
            `);
        });

        $(`#side-bar`).html(buf.join(`<br/>`));
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
                Promise.all([loadSiteColPreview(sites), loadSiteColMenu(sites)]);
            });
    };
</script>

<h1 style="margin: 3rem;">Combined Inbox Editor</h1>

<div id="editor-container">
    <div id="side-bar" class="inbox" style="display: block;">Edit Columns <br/></div>
    <div id="inbox-preview" style="display: block;"></div>
</div>