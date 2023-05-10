<link rel="stylesheet" href="../../libs/css/leaf.css">
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<style>
    .col-header {
    font-weight: 300;
        font-size: 100%;
        background-color: #D1DFFF;
        border: 1px solid black;
        padding: 1rem;
        /* display: table-cell; */
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
        /* display: table; */
    }

    .header-row {
        /* display: table-row; */
    }

    .slist {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .slist li {
        margin: 10px;
        padding: 15px;
        border: 1px solid #dfdfdf;
        background: #f5f5f5;
    }

    .slist li.hint {
        border: 1px solid #ffc49a;
        background: #feffb4;
    }

    .slist li.active {
        border: 1px solid #ffa5a5;
        background: #ffe7e7;
    }
</style>

<script type='text/javascript'>
    let CSRFToken = '<!--{$CSRFToken}-->';
    let sites = [];
    let dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');

    const allColumns = 'service,title,status,dateInitiated,days_since_last_action';

    const slist = (target, order) => {
        target.classList.add("slist");
        let items = target.getElementsByTagName("li"), current = null;

        for (let i of items) {
            i.draggable = true;

            i.ondragstart = e => {
                current = i;

                for (let it of items) {
                    if (it != current) { 
                        it.classList.add("hint"); 
                    }
                }
            };

            i.ondragenter = e => {
                if (i != current) { 
                    i.classList.add("active"); 
                }
            };

            i.ondragleave = () => i.classList.remove("active");

            i.ondragend = () => { for (let it of items) {
                it.classList.remove("hint");
                it.classList.remove("active");
            }};

            i.ondragover = e => e.preventDefault();

            i.ondrop = e => {
                e.preventDefault();
                if (i != current) {
                    let currentpos = 0, droppedpos = 0;

                    for (let it=0; it<items.length; it++) {
                        if (current == items[it]) { 
                            currentpos = it; 
                        }
                        if (i == items[it]) { 
                            droppedpos = it; 
                        }
                    }

                    if (currentpos < droppedpos) {
                        i.parentNode.insertBefore(current, i.nextSibling);
                    } else {
                        i.parentNode.insertBefore(current, i);
                    }

                    updateColumns(sites, items);
                }
            };
        }
    }

    const updateColumns = (sites, items) => new Promise((resolve, reject) => {
        // update site columns in new order
        sites[order].columns = Object.values(items).map(item => item.textContent.toLowerCase()).join(',');

        // reload static elements
        Promise.all([loadSiteColPreview(sites), loadSiteColMenu(sites), saveMapSites]);
    });

    const shiftColumns = (site) => new Promise((resolve, reject) => {        
        dialog.setTitle(site.name);
        dialog.setContent(`<ul id="column-list-${site.order}"></ul>`);
        dialog.show();

        const compColumns = site.columns.split(',');
        allColumns.split(',').forEach((column) => {
            document.getElementById(`column-list-${site.order}`).innerHTML += `<li id="${site.order}-${column}"><input id="${site.order}-${column}-input" type="checkbox" /> ${column}</li>`;
            document.getElementById(`${site.order}-${column}-input`).onclick = () => {
                this.parentElement.checked = !this.parentElement.checked;

            };
            if (compColumns.includes(column)) {
                // console.log(column, `${site.order}-${column}`);
                document.getElementById(`${site.order}-${column}`).checked = true;
                $(`#${site.order}-${column}-input`).attr("checked", true);
            }
        });

        slist(document.getElementById(`column-list-${site.order}`), site.order);
    });

    const loadColumnList = new Promise((resolve, reject) => {});

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
                        order: site.order,
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

    const saveMapSites = new Promise((resolve, reject) => {
        $.ajax({
            type: 'POST',
            url: '../api/site/settings/sitemap_json',
            data: {CSRFToken: CSRFToken},
            sitemap_json: JSON.stringify(sites),
            success: (res) => {
                resolve();
            },
            fail: (err) => {
                reject(err);
            },
        });
    });

    const buildHeaderColumns = (preCon, cols, postCon, capitalize = true, checkbox = false) => {
        cols = cols.split(',') ?? defaultCols;
        let headerColumns = [];
        cols.forEach(col => {
            col = capitalize ? col.charAt(0).toUpperCase() + col.slice(1) : col;
            headerColumns.push(`${preCon}${col.charAt(0).toUpperCase() + col.slice(1)}${postCon}`);
        });
        return headerColumns;
    };

    const loadSiteColPreview = (sites) => new Promise((resolve, reject) => {
        buf = [];
        sites.forEach(site => {
            let headerColumns = buildHeaderColumns(`<th class="col-header">`, site.columns, `</th>`);
            // build the preview pane and headers
            buf.push(`
            <div id="site-container-${site.order}" class="site-container" style="border-right: 8px solid ${site.backgroundColor}; border-left: 8px solid ${site.backgroundColor}; border-bottom: 8px solid ${site.backgroundColor};">
                <div class="site-title" style="background-color: ${site.backgroundColor}; color: ${site.fontColor};">
                    ${site.name}
                </div>
                <div class="inbox">
                    <table style="width: 100%;" cellspacing=0>
                        <tr>
                            <th class="col-header">UID</th>
                            ${headerColumns.join('')}
                            <th class="col-header">Action</th>
                        </tr>
                    </table>
                </div>
            </div>`);
        });

        // assign buffer to id div for display
        $('#inbox-preview').html(buf.join('<br/>'));

        sites.forEach(site => {
            $(`#site-container-${site.order}`).on("click", () => shiftColumns(site));
        });
    });

    const loadSiteColMenu = (site) => new Promise((resolve, reject) => {
        buf = [];
        sites.forEach((site) => {
            let headerOptions = buildHeaderColumns(`<li><input type="checkbox"></input>`, site.columns, `</li>`, true);
            buf.push(`
                <div>
                    ${site.name}
                </div>
                <ul id="header-list-${site.order}">
                    ${headerOptions.join('')}
                </ul>
            `);
        });

        $(`#side-bar`).html(buf.join(`<br/>`));
        sites.forEach((site) => {
            slist(document.getElementById(`header-list-${site.order}`), site.order);
        });
    });

    const updateSettings = new Promise((resolve, reject) => {
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
                Promise.all([loadSiteColPreview(sites), loadSiteColMenu(sites)])
            });
    };
</script>

<h1 style="margin: 3rem;">Combined Inbox Editor</h1>

<div id="editor-container">
    <div id="side-bar" class="inbox" style="display: block;">Edit Columns <br/></div>
    <div id="inbox-preview" style="display: block;"></div>
</div>