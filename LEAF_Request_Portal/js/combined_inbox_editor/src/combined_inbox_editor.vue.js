const CombinedInboxEditor = Vue.createApp({
    data() {
        return {
            loading: true,
            sites: [],
            otherSitemapSites: [],
            portalData: {},
            choices: [],
            CSRFToken: CSRFToken,
            allColumns: ['service','title','status','dateInitiated','days_since_last_action','priority','dateSubmitted'],
            frontEndColumns: {
                'service': 'Service',
                'title': 'Title',
                'status': 'Status',
                'dateInitiated': 'Date Initiated',
                'days_since_last_action': 'Days Since Last Action',
                'priority': 'Priority',
                'dateSubmitted': 'Date Submitted'
            },
            backEndColumns: {
                'Service': 'service',
                'Title': 'title',
                'Status': 'status',
                "Date Initiated": 'dateInitiated',
                "Days Since Last Action": 'days_since_last_action',
                'Priority': 'priority',
                'Date Submitted': 'dateSubmitted',
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
                    const site = this.sites.find((site) => site.order == i) || null;
                    if(site !== null) {
                        site.order--;
                    }
                }
                site.order = target.order + 1;
            } else if (site.order > target.order) {
                for (let i = site.order; i >= target.order; i--) {
                    const site = this.sites.find((site) => site.order == i) || null;
                    if(site !== null) {
                        site.order++;
                    }
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
        /**
         * get sitemap JSON. setup base column values for LEAF cards.  save non-LEAF cards
        */
        runSetup() {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: '../api/site/settings/sitemap_json',
                    success: (res) => {
                        const siteMap = Object.values(JSON.parse(res[0].data))[0];
                        let inboxSites = [];
                        let otherSitemapSites = [];
                        siteMap.forEach(s => {
                            if(s.target.includes(window.location.hostname)) {
                                inboxSites.push(s);
                            } else {
                                otherSitemapSites.push(s);
                            }
                        });
                        this.otherSitemapSites = otherSitemapSites;

                        const formattedSiteMap = inboxSites.map((site) => ({
                            ...site,
                            columns: site?.columns || 'service,title,status',
                            formColumns: site?.formColumns || {},
                            show: site.show ?? true
                        }));
                        this.sites = formattedSiteMap.sort((a, b) => a.order - b.order);

                        let count = 0; //TODO: try to optimize once per portal
                        this.sites.forEach((site) => {
                            this.choices.push({
                                id: site.id,
                                choices: []
                            });
                            let tmp = [];
                            //add selected cols first to retain their order
                            const siteCols = (site.columns || "").split(',').filter(c => c !== "");
                            siteCols.forEach((col) => {
                                if (this.allColumns.includes(col)) {
                                    tmp.push({
                                        value: col,
                                        label: this.frontEndColumns[col],
                                        selected: true,
                                        customProperties: {
                                            header: this.frontEndColumns[col]
                                        }
                                    });
                                }
                            });
                            this.allColumns.forEach((col) => {
                                if (!site.columns.includes(col)) {
                                    tmp.push({
                                        value: col,
                                        label: this.frontEndColumns[col],
                                        selected: false,
                                        customProperties: {
                                            header: this.frontEndColumns[col]
                                        }
                                    });
                                }
                            });
                            this.choices.find((choice) => choice.id == site.id).choices = tmp;

                            const portalURL = this.getPortalURL(site.target);

                            this.getPortalData(site.id, portalURL)
                            .then(() => {
                                count += 1;
                                if (count === this.sites.length) {
                                    resolve();
                                }
                            })
                            .catch(err => {
                                console.log(err);
                                reject(err);
                            });
                        });
                    },
                    error: (err) => {
                        reject(err);
                    }
                });
            })
        },

        saveSettings() { 
            // sort the edited sites by order
            let sendObj = {
                buttons:[]
            };
            for (let key in this.sites) {
                sendObj.buttons.push(this.sites[key]);
            }
            //re-add other sitemap sites
            sendObj.buttons = sendObj.buttons.concat(this.otherSitemapSites);
            $.ajax({
                type: 'POST',
                url: '../api/site/settings/sitemap_json',
                data: {
                    CSRFToken: CSRFToken,
                    sitemap_json: JSON.stringify(sendObj)
                },
                success: (res) => {
                    //1 if ok
                },
                error: (err) => {
                    console.log(err);
                }
            });
        },

        sortSites() {
            this.sites.sort((a, b) => a.order - b.order);
        },

        setupChoices(site) {
            setTimeout(() => {
                let selectElement = document.getElementById('choice-' + site.id);
                const siteChoices = this.choices.find((choice) => choice.id == site.id)?.choices || [];

                const selChoices = new Choices(selectElement, {
                    allowHTML: false,
                    removeItemButton: true,
                    editItems: true,
                    maxItemCount: 7,
                    shouldSort: false,
                    placeholderValue: "Click to search. Limit 7 columns.",
                    choices: siteChoices,
                });
                selectElement.choicesjs = selChoices;
                selectElement.addEventListener('change', (event) => {
                    const selectedValue = Array.prototype.slice.call(event.target.children).map((child) => child.value).join(',');
                    const selectedForm = document.getElementById(`form_select_${site.id}`)?.value || null;
                    if(selectedForm === null) {
                        site.columns = selectedValue;
                    } else {
                        site.formColumns[selectedForm] = selectedValue;
                    }
                    this.saveSettings();
                });
            });
        },
        getPortalURL(cardURL) {
            let portalURL = cardURL;
            if(portalURL.indexOf('/admin/') != -1) {
                portalURL = portalURL.substring(0, portalURL.indexOf('/admin/') + 1);
            } else if(portalURL.indexOf('/?') != -1) {
                portalURL = portalURL.substring(0, portalURL.indexOf('/?') + 1);
            } else if(portalURL.indexOf('/index.php?') != -1) {
                portalURL = portalURL.substring(0, portalURL.indexOf('/index.php?') + 1);
            } else if(portalURL.indexOf('/report.php?') != -1) {
                portalURL = portalURL.substring(0, portalURL.indexOf('/report.php?') + 1);
            } else if(portalURL.indexOf('/api/open/form/query/') != -1) {
                portalURL = portalURL.substring(0, portalURL.indexOf('/api/open/form/query/') + 1);
            } else if(portalURL.indexOf('/open.php?') != -1) {
                portalURL = portalURL.substring(0, portalURL.indexOf('/open.php?') + 1);
            }
            if(!portalURL.endsWith('/')) {
                portalURL += '/';
            }
            return portalURL;
        },
        async getPortalData(siteID, portalURL) {
            const resForms = await fetch(`${portalURL}api/form/categories`, {
                headers: {
                    "Content-Type": "application/json",
                },
                cache: "no-cache"
            });
            const forms = await resForms.json();

            const resIndicators = await fetch(portalURL + "api/form/indicator/list", {
                headers: {
                    "Content-Type": "application/json",
                },
                cache: "no-cache"
            });
            const indicators = await resIndicators.json();
            const enabledIndicators = indicators.filter(i => i.isDisabled === 0);

            this.portalData[siteID] = {
                id: siteID,
                portalURL: portalURL,
                forms: forms,
                indicators: enabledIndicators,
            };
        },
        setIndicatorChoices(event, site) {
            let elChoicesSelect = document.getElementById('choice-' + site.id);
            const siteID = site.id;
            const formID = event.currentTarget.value;
            const indicators = this.portalData[siteID]?.indicators || [];
            const formIndicators = indicators.filter(i => i.categoryID === formID);

            let siteChoices = this.choices.find(choice => choice.id === siteID);
            siteChoices.choices = siteChoices.choices.filter(c => !Number.isInteger(+c.value));

            const choicesInfo = formIndicators.map(i => {
                const indName = XSSHelpers.stripAllTags(i.description || i.name);
                return {
                    label: i.categoryName + ': ' + indName + " (ID: " + i.indicatorID + ")",
                    selected: site.columns.includes(i.indicatorID),
                    value: i.indicatorID,
                    customProperties: {
                        header: indName
                    }
                }
            });
            siteChoices.choices.push(...choicesInfo);
            if(typeof elChoicesSelect?.choicesjs !== undefined) {
                elChoicesSelect.choicesjs.clearChoices();
                elChoicesSelect.choicesjs.setChoices(siteChoices.choices);
                elChoicesSelect.choicesjs.removeActiveItems();
                const formColumns = site?.formColumns?.[formID] || null;
                const baseColumns = site?.columns || 'service,title,status';
                const columns = (formColumns || baseColumns).split(',');

                let choices = [];
                columns.forEach(c => {
                    const val = isNaN(c) ? c : +c;
                    let choice = siteChoices.choices.find(choice => choice.value === val) || null;
                    if(choice !== null) {
                        choices.push({ ...choice });
                    }
                });
                elChoicesSelect.choicesjs.setValue(choices);
            }
        },
        getHeaderHTML(site) {
            let html = `<th class="col-header">UID</th>`;
            let indChoices = [];
            let filteredIndChoices = [];

            const siteCols = site.columns.split(',').filter(c => c !== "");
            const numericCols = siteCols.filter(str => +str > 0);
            if(numericCols.length > 0) { //don't bother getting and filtering if there aren't any indicator columns
                indChoices = this.choices.find(choice => choice.id == site.id)?.choices || [];
                filteredIndChoices = indChoices.filter(c => numericCols.includes(String(c.value)));
            }
            siteCols.forEach(col => {
                let header = this.frontEndColumns[col] || null; //look here first
                if (header === null && filteredIndChoices.length > 0) {
                    header = filteredIndChoices.find(c => +c.value === +col)?.customProperties?.header || "";
                }
                html += `<th class="col-header">${header}</th>`;
            });
            html += `<th class="col-header">Action</th>`;
            return html;
        }
    },
    created() {
        this.runSetup().then(() => {
            this.loading = false;

            this.sites.forEach((site) => {
                this.setupChoices(site);
            });
        });
    },
    template: `
    <h1 style="margin: 3rem;">Combined Inbox Editor</h1>

    <h2 v-if="loading">Loading Site Data ...</h2>
    <div v-else id="editor-container">
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
                :key="site.order + 'site.title'">
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
                        borderBottom: '8px solid' + site.color
                    }"
                >
                    <div class="site-title" :style="{backgroundColor: site.color, color: site.fontColor}">
                        <span v-html="getIcon(site.icon, site.title)"></span>
                        {{site.title}}
                    </div>
                    <div class="inbox">
                        <table style="width: 100%;" cellspacing=0>
                            <tr v-html="getHeaderHTML(site)"></tr>
                        </table>
                        <select :id="'choice-' + site.id" placeholder="select some options" multiple></select>

                        <template v-if="portalData[site.id]?.forms">
                            <label :for="'form_select_' + site.id">Select a form to add question headers</label><br/>
                            <select :id="'form_select_' + site.id" placeholder="select a form" @change="setIndicatorChoices($event, site)">
                                <option value="">Select a form</option>
                                <option v-for="form in portalData[site.id].forms" :value="form.categoryID" :key="'form_' + site.id + '_' + form.categoryID">
                                    {{form.categoryName}} ({{form.categoryID}})
                                </option>
                            </select>
                        </template>
                    </div>
                </div>
            </template>
        </div>
    </div>`
});

CombinedInboxEditor.mount("#LEAF_combined_inbox_editor");