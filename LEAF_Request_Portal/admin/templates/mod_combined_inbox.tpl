<link rel="stylesheet" href="../../libs/css/leaf.css">
<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<style>
    .col-header {
    font-weight: 300;
        font-size: 100%;
        background-color: #D1DFFF;
        border: 1px solid black;
        padding: 1rem;
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
        transition: box-shadow 0.3s ease;
    }

    .site-container:hover {
        box-shadow: 0 4px 6px #8a8c8d;
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

    const allColumns = 'service,title,status,dateinitiated,days_since_last_action';

    const frontEndColumns = {
        service: 'Service',
        title: 'Title',
        status: 'Status',
        dateinitiated: 'Date Initiated',
        days_since_last_action: 'Days Since Last Action'
    }

    const backEndColumns = {
        Service: 'service',
        Title: 'title',
        Status: 'status',
        "Date Initiated": 'dateinitiated',
        "Days Since Last Action": 'days_since_last_action'
    }

    const slist = (target, id = false, siteCols = false) => {
        target.classList.add("slist");
        let items = target.getElementsByTagName("li"), current = null;

        for (let i of items) {
            if (siteCols) {
                // add change event to checkboxes
                i.children[0].addEventListener('change', () => {
                    updateColumns(items, id);
                });
            }

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

                    return siteCols ? updateColumns(items, id) : updateSiteOrder();
                }
            };
        }
    }

    const updateSiteOrder = () => new Promise((resolve, reject) => {
        // get list of site li values
        const list = Object.values(document.getElementById(`header-sites-list`).getElementsByTagName('li')).map(item => item.getAttribute('value'));
        for(let key in list) {
            // update the order value for each site obj
            sites[list[key]].order = key;
        }
        // saveSettings().then(() => loadSiteColPreview(sites));
    });

    // Get site icons and name
    const getIcon = (icon, name) => {
        if (icon != '') {
            if (icon.indexOf('/') != -1) {
                icon = '<img src="' + icon + '" alt="icon for ' + name +
                    '" style="vertical-align: middle; width: 76px; height:76px;" />';
            } else {
                icon = '<img src="../libs/dynicons/?img=' + icon + '&w=76" alt="icon for ' + name +
                    '" style="vertical-align: middle" />';
            }
        }
        return icon;
    }

    const updateColumns = (items, id) => new Promise((resolve, reject) => {
        // update site columns in new order
        let checkedColumns = Object.values(items).filter(item => item.children[0].checked);
        sites[id].columns = checkedColumns.map(item => backEndColumns[item.textContent.trim()]).join(',');

        // reload elements
        // Promise.all([loadSiteColPreview(sites), loadSiteColMenu(sites)]);
    });

    const shiftColumns = (site) => new Promise((resolve, reject) => {
        dialog.setTitle(`${site.title} Column Order`);
        dialog.setContent(`<ul id="column-list-${site.id}"></ul>`);
        dialog.setSaveHandler(() => {
            saveSettings().then(() => {
                dialog.hide();
            });
        });
        dialog.show();

        const compColumns = site.columns.split(',');
        compColumns.forEach(column => {
            document.getElementById(`column-list-${site.id}`).innerHTML += `<li id="${site.id}-${column}" value="${column}"><input id="${site.id}-${column}-input" type="checkbox" /> ${frontEndColumns[column]}</li>`;
        });
        allColumns.split(',').forEach((column) => {
            if (compColumns.includes(column)) {
                $(`#${site.id}-${column}-input`).attr("checked", true);
            } else {
                document.getElementById(`column-list-${site.id}`).innerHTML += `<li id="${site.id}-${column}" value="${column}"><input id="${site.id}-${column}-input" type="checkbox" /> ${frontEndColumns[column]}</li>`;
            }
        });

        slist(document.getElementById(`column-list-${site.id}`), site.id, true);
    });

    const getMapSites = new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
            url: '../api/site/settings/sitemap_json',
            success: (res) => {
                let siteMap = Object.values(JSON.parse(res[0].data))[0];
                let formattedSiteMap = siteMap.map((site) => ({
                    ...site,
                    columns: site.columns ?? 'service,title,status',
                    show: site.show ?? true
                })).filter((site) => site.target.includes(window.location.hostname)
                ).reduce((sites, site) => {
                    sites[site.id] = site;
                    return sites;
                }, []);
                sites = formattedSiteMap.sort((a, b) => a.order - b.order);
                resolve(sites);
            },
            fail: (err) => {
                reject(err);
            }
        });
    });

    const saveSettings = () => new Promise((resolve, reject) => {
        // sort the sites by order
        let sendObj = {buttons:[]};
        for (let key in sites) {
            sendObj.buttons.push(sites[key]);
        }

        $.ajax({
            type: 'POST',
            url: '../api/site/settings/sitemap_json',
            data: {
                CSRFToken: CSRFToken,
                sitemap_json: JSON.stringify(sendObj)
            },
            success: (res) => {
                Promise.all([loadSiteColMenu(sites), loadSiteColPreview(sites)]);
                resolve();
            },
            fail: (err) => {
                reject(err);
            }
        });
    });

    const buildHeaderColumns = (preCon, cols, postCon, capitalize = true, checkbox = false) => {
        cols = cols.split(',') ?? defaultCols;
        let headerColumns = [];
        cols.forEach(col => {
            headerColumns.push(`${preCon}${frontEndColumns[col]}${postCon}`);
        });
        return headerColumns;
    };

    const loadSiteColPreview = (sites) => new Promise((resolve, reject) => {
        buf = [];
        let orderedSites = Object.values(sites).sort((a, b) => a.order - b.order);
        for (let key in orderedSites) {
            let site = orderedSites[key];

            let headerColumns = buildHeaderColumns(`<th class="col-header" value="${site.columns}">`, site.columns, `</th>`);
            // build the preview pane and headers
            buf.push(`
            <div id="site-container-${site.id}" class="site-container" style="border-right: 8px solid ${site.color}; border-left: 8px solid ${site.color}; border-bottom: 8px solid ${site.color};">
                <div class="site-title" style="background-color: ${site.color}; color: ${site.fontColor};">
                    ${getIcon(site.icon, site.title)} ${site.title}
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
        }
        // assign buffer to id div for display
        $('#inbox-preview').html(buf.join('<br/>'));

        for (let key in sites) {
            let site = sites[key];
            $(`#site-container-${site.id}`).on("click", () => shiftColumns(site));
        }
    });

    const loadSiteColMenu = (sites) => new Promise((resolve, reject) => {
        buf = [];
        let siteCols = [];
            let orderedSites = Object.values(sites).sort((a, b) => a.order - b.order);
            for (let key in orderedSites) {
                let site = orderedSites[key];

                siteCols.push(`<li value="${site.id}">${site.title}</li>`) 
            }
            buf.push(`
                <div>
                    Site Order
                </div>
                <ul id="header-sites-list">
                    ${siteCols.join('')}
                </ul>
            `);

            buf.push(`<button class="usa-button leaf-btn-med" onclick="saveSettings()">Save Site Order</button>`);

            $(`#side-bar`).html(buf.join(`<br/>`));

            slist(document.getElementById(`header-sites-list`));

        // for (let key in sites) {
        //     let site = sites[key];
        //     slist(document.getElementById(`header-list-${site.id}`), site.id);
        // }
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