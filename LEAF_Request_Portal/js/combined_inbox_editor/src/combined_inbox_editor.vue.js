const CombinedInboxEditor = Vue.createApp({
    data() {
        return {
            sites: [],
            choices: [],
            CSRFToken: CSRFToken,
            allColumns: 'service,title,status,dateInitiated,days_since_last_action',
            frontEndColumns: {
                'service': 'Service',
                'title': 'Title',
                'status': 'Status',
                'dateInitiated': 'Date Initiated',
                'days_since_last_action': 'Days Since Last Action'
            },
            backEndColumns: {
                'Service': 'service',
                'Title': 'title',
                'Status': 'status',
                "Date Initiated": 'dateInitiated',
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
            } else if (site.order > target.order) {
                for (let i = site.order; i >= target.order; i--) {
                    this.sites.find((site) => site.order == i).order++;
                }
                site.order = target.order - 1;
            }

            this.sortSites();
            this.saveSettings();
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
                        })).filter((site) => site.target.includes(window.location.hostname));
                        this.sites = formattedSiteMap.sort((a, b) => a.order - b.order);
                        this.sites.forEach((site) => {
                            this.choices.push({id: site.id, choices: []})
                            let tmp = [];
                            if (site.columns.split(',')[0] !== '') {
                                site.columns.split(',').forEach((col, index) => {
                                    if (isNaN(col)) {
                                        tmp.push({value: col, label: this.frontEndColumns[col], selected: true, customProperties: { header: this.frontEndColumns[col] }});
                                    }
                                });
                            }
                            this.allColumns.split(',').forEach((col) => {
                                if (!site.columns.includes(col)) {
                                    tmp.push({value: col, label: this.frontEndColumns[col], selected: false, customProperties: { header: this.frontEndColumns[col] }});
                                }
                            });
                            this.choices.find((choice) => choice.id == site.id).choices = tmp;
                            resolve();
                        });
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

        setupChoices(site) {
            return new Promise((resolve, reject) => {
                setTimeout(() => {
                    let selectElement = document.getElementById('choice-' + site.id);
                    let allCols = this.allColumns.split(',');
                    let choicejs = new Choices(selectElement, {
                        allowHTML: false,
                        removeItemButton: true,
                        editItems: true,
                        maxItemCount: 7,
                        shouldSort: false,
                        choices: this.choices.find((choice) => choice.id == site.id).choices,
                    });
                    
                    selectElement.addEventListener('change', (event) => {
                        let selectedValue = Array.prototype.slice.call(event.target.children).map((child) => child.value).join(',');
                        site.columns = selectedValue;
                        this.saveSettings();
                    });
                });
                resolve();
            });
        },
        async getIndicators(site) {
            if (typeof site == 'undefined' || typeof site.target == 'undefined') {
                return [];
            }
            const indicators = await fetch(site.target + "api/form/indicator/list", {
                headers: {
                    "Content-Type": "application/json",
                },
                cache: "no-cache"
            });
    
            return indicators.json();
        }
    },
    created() {
        this.getMapSites().then(() => {
            this.sites.forEach((site) => {
                this.getIndicators(site).then((indicators) => {
                    this.choices.find((choice) => choice.id == site.id).choices.push(...indicators.map((indicator => ({
                        label: indicator.name + " (ID: " + indicator.indicatorID + ")",
                        selected: site.columns.includes(indicator.indicatorID),
                        value: indicator.indicatorID,
                        customProperties: {
                            header: indicator.name
                        }
                    }))));
                }).then(() => {
                    this.setupChoices(site);
                });
            });
        });
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
                @drop="onDrop($event)"
                :value="site.id"
                :key="site.order">
                    &#x2630; {{site.title}}
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
                        <table style="width: 100%;" cellspacing=0>
                            <tr>
                            <th class="col-header">UID</th>
                            <template v-if="site.columns.split(',')[0] !== ''">
                                <template v-for="column in site.columns.split(',')" :key="column">
                                <th class='col-header' value='column'>{{choices.find((choice) => choice.id == site.id)?.choices?.find((choice) => choice.value == column)?.customProperties?.header}}</th>
                                </template>
                            </template>
                            <th class="col-header">Action</th>
                            </tr>
                        </table>
                        <select :id="'choice-' + site.id" placeholder="select some options" multiple></select>
                    </div>
                </div>
            </template>
        </div>
    </div>`
});

CombinedInboxEditor.mount("#LEAF_combined_inbox_editor");