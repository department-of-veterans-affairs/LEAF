const CombinedInboxEditor = Vue.createApp({
    data() {
        return {
            sites: [],
            dialog: new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange'),
            allColumns: 'service,title,status,dateinitiated,days_since_last_action',
            frontEndColumns: {
                'service': 'Service',
                'title': 'Title',
                'status': 'Status',
                'dateinitiated': 'Date Initiated',
                'days_since_last_action': 'Days Since Last Action'
            },
            backEndColumns: {
                'Service': 'service',
                'Title': 'title',
                'Status': 'status',
                "Date Initiated": 'dateinitiated',
                "Days Since Last Action": 'days_since_last_action'
            },
            template: ''
        };
    },
    props: {

    },
    methods: {
        slist(target, id = false, siteCols = false) {
            target.classList.add("slist");
            let items = target.getElementsByTagName("li"), current = null;
    
            for (let i of items) {
                if (siteCols) {
                    // add change event to checkboxes
                    i.children[0].addEventListener('change', () => {
                        this.updateColumns(items, id);
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
    
                        return siteCols ? this.updateColumns(items, id) : this.updateSiteOrder();
                    }
                };
            }
        },
    
        updateSiteOrder() {
            return new Promise(() => {
                // get list of site li values
                const list = Object.values(document.getElementById(`header-sites-list`).getElementsByTagName('li')).map(item => item.getAttribute('value'));
                for(let key in list) {
                    // update the order value for each site obj
                    this.sites[list[key]].order = key;
                }
            })
        },
    
        // Get site icons and name
        getIcon(icon, name) {
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
        },
    
        updateColumns(items, id) {
            return new Promise((resolve, reject) => {
                // update site columns in new order
                let checkedColumns = Object.values(items).filter(item => item.children[0].checked);
                this.sites[id].columns = checkedColumns.map(item => backEndColumns[item.textContent.trim()]).join(',');
            })
        },
    
        shiftColumns(site) {
            return new Promise((resolve, reject) => {
                this.dialog.setTitle(`${site.title} Column Order`);
                this.dialog.setContent(`<ul id="column-list-${site.id}"></ul>`);
                this.dialog.setSaveHandler(() => {
                    this.saveSettings().then(() => {
                        this.dialog.hide();
                    });
                });
                this.dialog.show();
        
                const compColumns = site.columns.split(',');
                compColumns.forEach(column => {
                    document.getElementById(`column-list-${site.id}`).innerHTML += `<li id="${site.id}-${column}" value="${column}"><input id="${site.id}-${column}-input" type="checkbox" /> ${this.frontEndColumns[column]}</li>`;
                });
                allColumns.split(',').forEach((column) => {
                    if (compColumns.includes(column)) {
                        $(`#${site.id}-${column}-input`).attr("checked", true);
                    } else {
                        document.getElementById(`column-list-${site.id}`).innerHTML += `<li id="${site.id}-${column}" value="${column}"><input id="${site.id}-${column}-input" type="checkbox" /> ${this.frontEndColumns[column]}</li>`;
                    }
                });
        
                this.slist(document.getElementById(`column-list-${site.id}`), site.id, true);
            })
        },
    
        getMapSites() {
            return new Promise((resolve, reject) => {
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
                        this.sites = formattedSiteMap.sort((a, b) => a.order - b.order);
                        console.log(this.sites);
                        resolve(this.sites);
                    },
                    fail: (err) => {
                        reject(err);
                    }
                });
            })
        },
    
        saveSettings() { 
            new Promise((resolve, reject) => {
                // sort the sites by order
                let sendObj = {buttons:[]};
                for (let key in this.sites) {
                    sendObj.buttons.push(this.sites[key]);
                }
        
                $.ajax({
                    type: 'POST',
                    url: '../api/site/settings/sitemap_json',
                    data: {
                        CSRFToken: CSRFToken,
                        sitemap_json: JSON.stringify(sendObj)
                    },
                    success: (res) => {
                        Promise.all([this.loadSiteColMenu(this.sites), this.loadSiteColPreview(this.sites)]);
                        resolve();
                    },
                    fail: (err) => {
                        reject(err);
                    }
                });
            })
        },
    
        buildHeaderColumns(preCon, cols, postCon) {
            cols = cols.split(',') ?? defaultCols;
            let headerColumns = [];
            cols.forEach(col => {
                headerColumns.push(`${preCon}${this.frontEndColumns[col]}${postCon}`);
            });
            return headerColumns;
        },
    
        loadSiteColPreview() {
           return new Promise(() => {
                buf = [];
                let orderedSites = Object.values(this.sites).sort((a, b) => a.order - b.order);
                for (let key in orderedSites) {
                    let site = orderedSites[key];
        
                    let headerColumns = this.buildHeaderColumns(`<th class="col-header" value="${site.columns}">`, site.columns, `</th>`);
                    // build the preview pane and headers
                    buf.push(`
                    <div id="site-container-${site.id}" class="site-container" style="border-right: 8px solid ${site.color}; border-left: 8px solid ${site.color}; border-bottom: 8px solid ${site.color};">
                        <div class="site-title" style="background-color: ${site.color}; color: ${site.fontColor};">
                            ${this.getIcon(site.icon, site.title)} ${site.title}
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
        
                for (let key in this.sites) {
                    let site = this.sites[key];
                    $(`#site-container-${site.id}`).on("click", () => this.shiftColumns(site));
                }
            })
        },
    
        loadSiteColMenu() {
            return new Promise(() => {
                buf = [];
                let siteCols = [];
                    let orderedSites = Object.values(this.sites).sort((a, b) => a.order - b.order);
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
        
                    buf.push(`<button class="usa-button leaf-btn-med" onclick="this.saveSettings()">Save Site Order</button>`);
        
                    $(`#side-bar`).html(buf.join(`<br/>`));
        
                    this.slist(document.getElementById(`header-sites-list`));
        
                // for (let key in sites) {
                //     let site = sites[key];
                //     slist(document.getElementById(`header-list-${site.id}`), site.id);
                // }
            })
        }
    },
    created() {
        this.getMapSites()
            .then(() => {
                Promise.all([this.loadSiteColPreview(this.sites), this.loadSiteColMenu(this.sites)])
            });
    },
    // beforeMount() {
    //     fetch('../js/combined_inbox_editor/src/combined_inbox_editor.vue.html').then((res) => {
    //             console.log('here', res.text());
    //             this.template = res.text();
    //         }).catch((err) => {
    //             console.warn('Something went wrong.', err);
    //         });
    // },
    computed() {},
    template: `
    <h1 style="margin: 3rem;">Combined Inbox Editor</h1>

    <div id="editor-container">
        <div id="side-bar" class="inbox" style="display: block;">Edit Columns <br/></div>
        <div id="inbox-preview" style="display: block;">
            <div v-for "i in sites"
            :id=""
            
            ></div> 
        </div>
    </div>`
});

CombinedInboxEditor.mount("#LEAF_combined_inbox_editor");