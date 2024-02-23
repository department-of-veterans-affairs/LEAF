const CombinedInboxEditor = Vue.createApp({
    data() {
        return {
            loading: true,
            updateKey: 0,
            sites: [],
            otherSitemapSites: [],
            portalForms: {},
            choices: {},
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
    computed: {
        siteForms() {
            let data = {};
            this.sites.forEach(site => {
                data[site.id] = {
                    forms: [],
                    formTable: {},
                }
                const portalURL = this.getPortalURL(site.target);
                const forms = this.portalForms[portalURL]?.forms || [];
                data[site.id].forms = forms;
                forms.forEach(f => {
                    const formColumns = (site.formColumns?.[f.categoryID] || "").split(",");
                    let inboxHeaders = "";
                    formColumns.forEach(col => {
                        inboxHeaders += (+col > 0 ? `id#${col}` : this.frontEndColumns[col] || "") + ", ";
                    });
                    if (inboxHeaders !== "") {
                        inboxHeaders = inboxHeaders.slice(0, inboxHeaders.length - 2);
                    }
                    data[site.id].formTable[f.categoryID] = {...f, inboxHeaders, categoryName: f.categoryName || 'Untitled'};
                });
            });
            return data;
        },
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
        
        getIcon(icon) {
            if (icon != '') {
                if (icon.indexOf('/') != -1) {
                    icon = '<img src="' + icon + '" alt="" style="vertical-align: middle; width: 76px; height:76px;" />';
                } else {
                    icon = '<img src="../libs/dynicons/?img=' + icon + '&w=76" alt="" style="vertical-align: middle" />';
                }
            }
            return icon;
        },
        /**
         * get sitemap JSON. setup base column values for LEAF cards.  save non-LEAF cards
        */
        runSetup() {
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
                        columns: site?.columns || '',
                        formColumns: site?.formColumns || {},
                        show: site.show ?? true
                    }));
                    this.sites = formattedSiteMap.sort((a, b) => a.order - b.order);

                    let portalURLs = {};
                    let portalColumns = {};
                    /* Initial pass to get URL and columns for each portal (no other great way to get columns at the moment).
                    If there are multiple cards for a portal, the one with the most cols is used.  This is to prevent newly created cards
                    without columns from overriding existing setup values */
                    this.sites.forEach((site) => {
                        const siteCols = (site.columns || "").split(',').filter(c => c !== "");
                        const portalURL = this.getPortalURL(site.target);
                        portalURLs[portalURL] = 1;
                        if (portalColumns[portalURL] === undefined) {
                            portalColumns[portalURL] = siteCols;
                        }
                        if (siteCols.length > portalColumns[portalURL].length) {
                            portalColumns[portalURL] = siteCols;
                        }
                        this.choices[site.id] = {
                            portalURL,
                            choices: [],
                        };
                    });
                    this.sites.forEach((site) => {
                        const portalURL = this.choices[site.id].portalURL;
                        let tmp = [];
                        //Add selected cols first to retain their order.  Add defaults if no columns exist across all cards.
                        const siteCols = portalColumns[portalURL].length > 0 ? portalColumns[portalURL] : ['service','title','status'];
                        site.columns = siteCols.join();
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
                            if (!siteCols.includes(col)) {
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
                        this.choices[site.id].choices = tmp;
                    });

                    const totalURLs = Object.keys(portalURLs).length;
                    let count = 0;
                    for (let key in portalURLs) {
                        this.getPortalForms(key)
                        .then(() => {
                            count += 1;
                            if (count === totalURLs) {
                                this.loading = false;

                                this.sites.forEach((site) => {
                                    this.setupChoices(site);
                                });
                                this.saveSettings(); //save any column updates from initial sync
                            }
                        })
                        .catch(err => {
                            console.log(err);
                        });
                    }
                },
                error: (err) => {
                    reject(err);
                }
            });
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
                    if(+res === 1) {
                        this.sites.forEach(site => {
                            const formID = document.getElementById('form_select_' + site.id)?.value || null;
                            let columns = formID !== null ? site.formColumns[formID] || "service,title,status" : site.columns;
                            columns = columns.split(",");
                            this.choices[site.id].choices.map(c => {
                                c.selected = columns.includes(c.value);
                            });
                            this.updateChoiceSelections(site.id, columns);
                        });
                    }
                },
                error: (err) => {
                    console.log(err);
                }
            });
        },

        sortSites() {
            this.sites.sort((a, b) => a.order - b.order);
        },
        updateChoiceSelections(siteID, arrColumns) {
            const choices = this.choices[siteID]?.choices || [];
            const elChoicesSelect = document.getElementById('choice-' + siteID);
            if(typeof elChoicesSelect?.choicesjs !== undefined) {
                elChoicesSelect.choicesjs.clearChoices();
                elChoicesSelect.choicesjs.setChoices(choices);
                elChoicesSelect.choicesjs.removeActiveItems();
                arrColumns.forEach(col => {
                    const val = this.allColumns.includes(col) ? col : +col;
                    const choice = choices.find(choice => choice.value === val) || null;
                    if(choice !== null) {
                        elChoicesSelect.choicesjs.setChoiceByValue(val);
                    }
                });
                this.updateKey += 1;
            }
        },
        setupChoices(site) {
            setTimeout(() => {
                let selectElement = document.getElementById('choice-' + site.id);
                const siteChoices = this.choices[site.id]?.choices || [];

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
                    //update columns and formColumns properties of sites with the same portalURL
                    const portalURL = this.getPortalURL(site.target);
                    this.sites.forEach(s => {
                        const sitePortalURL = this.getPortalURL(s.target);
                        if(s.id !== site.id && sitePortalURL === portalURL) {
                            s.columns = site.columns;
                            s.formColumns = site.formColumns;
                        }
                    })
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
        async getPortalForms(portalURL) {
            const resForms = await fetch(`${portalURL}api/formStack/categoryList`, {
                headers: {
                    "Content-Type": "application/json",
                },
                cache: "no-cache"
            });
            const forms = await resForms.json();
            this.portalForms[portalURL] = {
                forms: forms,
            };
        },

        /** Used when a form selection is made.  Updates options and selection status.
         * @param {object} event form select element onchange event
         * @param {object} site object containing information about the specific card
         * @returns removes encoded chars by passing through div and then strips all tags
         */
        async setIndicatorChoices(event, site) {
            const siteID = site.id;
            const portalURL = this.getPortalURL(site.target);
            const formID = event.currentTarget.value || null;

            let enabledIndicators = [];
            if(formID !== null) {
                const resIndicators = await fetch(portalURL + `api/form/indicator/list?forms=${formID}`, {
                    headers: {
                        "Content-Type": "application/json",
                    },
                    cache: "no-cache"
                });
                const indicators = await resIndicators.json();
                enabledIndicators = indicators.filter(i => i.isDisabled === 0);
            }
            const formColumns = formID === null ?
                (site.columns || "service,title,status").split(",") :
                (site.formColumns?.[formID] || "service,title,status").split(",");

            //rm prior indicators and re-add new
            let siteChoices = this.choices[siteID];
            siteChoices.choices = siteChoices.choices.filter(c => this.allColumns.includes(c.value));
            siteChoices.choices.map(c => {
                c.selected = formColumns.includes(c.value);
            });
            const indicatorChoices = enabledIndicators.map(i => {
                const indName = XSSHelpers.stripAllTags(i.description || i.name);
                const strIndID = String(i.indicatorID);
                return {
                    label: i.categoryName + ': ' + indName + " (ID: " + i.indicatorID + ")",
                    selected: formColumns.includes(strIndID),
                    value: i.indicatorID,
                    customProperties: {
                        header: indName
                    }
                }
            });
            siteChoices.choices.push(...indicatorChoices);

            this.updateChoiceSelections(site.id, formColumns);
        },

        getHeaderHTML(site) {
            const formID = document.getElementById('form_select_' + site.id)?.value || null;
            let html = `<tr><th class="col-header">UID</th>`;
            let indChoices = [];
            let filteredIndChoices = [];

            const siteCols = formID === null ?
                (site.columns || "").split(',').filter(c => c !== "") :
                (site.formColumns[formID] || "service,title,status").split(',');

            const numericCols = siteCols.filter(str => +str > 0);
            if(numericCols.length > 0) { //don't bother getting and filtering if there aren't any indicator columns
                indChoices = this.choices?.[site.id]?.choices || [];
                filteredIndChoices = indChoices.filter(c => numericCols.includes(String(c.value)));
            }
            siteCols.forEach(col => {
                let header = this.frontEndColumns[col] || null; //look here first
                if (header === null && filteredIndChoices.length > 0) {
                    header = filteredIndChoices.find(c => +c.value === +col)?.customProperties?.header || "";
                }
                html += `<th class="col-header">${header}</th>`;
            });
            html += `<th class="col-header">Action</th></tr>`;
            return html;
        }
    },
    created() {
        this.runSetup();
    },
    template: `
    <h1 style="margin: 3rem;">Combined Inbox Editor (beta)</h1>

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
                :key="site.id + '_' + site.order + 'site.title'">
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
                        <span v-html="getIcon(site.icon)"></span>
                        {{site.title}}
                    </div>
                    <div class="inbox">
                        <table style="width: 100%;" cellspacing=0 v-html="getHeaderHTML(site)" :key="'headers_' + site.id + updateKey"></table>
                        <select :id="'choice-' + site.id" placeholder="select some options" multiple></select>
                        <p>If no form is selected, choices will be applied to the 'organize by role' view and to all forms without specific settings.</p>
                        <template v-if="siteForms[site.id]?.forms?.length > 0">
                            <label :for="'form_select_' + site.id">Select a form to add specific settings</label><br/>
                            <select :id="'form_select_' + site.id" placeholder="select a form" @change="setIndicatorChoices($event, site)">
                                <option value="">Select a form</option>
                                <option v-for="form in siteForms[site.id].forms" :value="form.categoryID" :key="'form_' + site.id + '_' + form.categoryID">
                                    {{form.categoryName}} ({{form.categoryID}})
                                </option>
                            </select>
                        </template>
                        <div v-if="Object.keys(site.formColumns).length > 0" class="custom_forms">
                            <h3>Form specific settings exist for the forms listed below</h3>
                            <template v-for="val, key in site.formColumns">
                                <div v-if="siteForms[site.id]?.formTable?.[key]" :key="'site_form_table_' + key + val" style="display:flex; gap: 0.5rem;">
                                    <div><b>{{siteForms[site.id]?.formTable?.[key].categoryName}}</b><span style="font-size: 85%;"> ({{key}})</span></div>
                                    <div>{{siteForms[site.id]?.formTable?.[key].inboxHeaders}}</div>
                                </div>
                            </template>
                        </div>
                    </div>
                </div>
            </template>
        </div>
    </div>`
});

CombinedInboxEditor.mount("#LEAF_combined_inbox_editor");