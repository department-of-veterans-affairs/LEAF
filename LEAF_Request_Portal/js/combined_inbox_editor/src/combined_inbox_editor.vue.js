const CombinedInboxEditor = Vue.createApp({
    data() {
        return {
            sites: [],
            choices: [],
            CSRFToken: CSRFToken,
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
        };
    },
    methods: {
        startDrag(evt, site) {
            evt.dataTransfer.dropEffect = 'move';
            evt.dataTransfer.effectAllowed = 'move';
            evt.dataTransfer.setData('siteID', site.id);
        },

        onDrop(evt) {
            const site = this.sites.find((site) => site.id == evt.dataTransfer.getData('siteID'));
            const target = this.sites.find((site) => site.id == evt.target.attributes.value.value);

            if (site.order < target.order) {
                for (let i = site.order; i <= target.order; i++) {
                    this.sites.find((site) => site.order == i).order--;
                }
                site.order = target.order + 1;
            } else {
                for (let i = target.order; i <= site.order; i++) {
                    this.sites.find((site) => site.order == i).order++;
                }
                site.order = target.order - 1;
            }
            this.sortSites();
            this.saveSettings();
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
            return new Promise(() => {
                $.ajax({
                    type: 'GET',
                    url: '../api/site/settings/sitemap_json',
                    success: (res) => {
                        let siteMap = Object.values(JSON.parse(res[0].data))[0];
                        let formattedSiteMap = siteMap.map((site) => ({
                            ...site,
                            columns: site.columns ?? 'service,title,status',
                            show: site.show ?? true
                        })).filter((site) => site.target.includes(window.location.hostname));
                        this.sites = formattedSiteMap.sort((a, b) => a.order - b.order);
                        this.sites.forEach((site) => {
                            this.choices.push({id: site.id, choices: []})
                            let tmp = [];
                            site.columns.split(',').forEach((col, index) => {
                                tmp.push({value: col, label: this.frontEndColumns[col], id: index});
                            })
                            this.choices.find((choice) => choice.id == site.id).choices = tmp;
                        });
                    },
                    fail: (err) => {
                        console.log(err);
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
                        resolve();
                    },
                    fail: (err) => {
                        reject(err);
                    }
                });
            })
        },

        sortSites() {
            this.sites.sort((a, b) => a.order - b.order);
        },
    },
    created() {
        this.getMapSites();
    },
    mounted() {
        this.sites.forEach((site) => {
            let selectElement = document.getElementById('choice-' + site.id);

            this.choices.push(new Choices(selectElement, {
                allowHTML: false,
                removeItemButton: true,
                editItems: true,
                items: site.columns,
                choices: this.allColumns.split(',').map((col) => ({value: col, label: frontEndColumns[col]}))
            }));
            
            selectElement.addEventListener('change', (event) => {
                const selectedValue = event.target.value;
                console.log(selectedValue);
            });
        });
    },
    computed: {
    },
    template: `
    <h1 style="margin: 3rem;">Combined Inbox Editor</h1>

    <div id="editor-container">
        <div id="side-bar" class="inbox" style="display: block;">
            Edit Columns 
            <br/>
            <div @dragover.prevent 
            @dragenter.prevent
            style="margin: 1rem 0;">
                <div
                class="drag-el"
                v-for="site in sites"
                draggable="true"
                @dragstart="startDrag($event, site)"
                @drop="onDrop($event, site)"
                :value="site.id"
                :key="site.order">
                    {{site.title}}
                </div>
            </div>
        </div>
        <div id="inbox-preview" style="display: block;">
            <template v-for="site in sites" :key="site.id">
                <div :id="'site-container-' + site.id" 
                class="site-container" 
                :style="{
                    borderRight: '8px solid' + site.color, 
                    borderLeft: '8px solid' + site.color, 
                    borderBottom: '8px solid' + site.color}"
                >
                    <div class="site-title" :style="{backgroundColor: site.color, color: site.fontColor}">
                        <span v-html="getIcon(site.icon, site.title)"></span>
                        {{site.title}}
                    </div>
                    <div class="inbox">
                        <select :id="'choice-' + site.id" placeholder="select some options" multiple="true"></select>
                        <table style="width: 100%;" cellspacing=0>
                            <tr>
                                <th class="col-header">UID</th>
                                <template v-for="column in site.columns.split(',')" :key="column">
                                    <th class='col-header' value='column'>{{frontEndColumns[column]}}</th>
                                </template>
                                <th class="col-header">Action</th>
                            </tr>
                        </table>
                    </div>
                </div>
            </template>
        </div>
    </div>`
});

CombinedInboxEditor.mount("#LEAF_combined_inbox_editor");