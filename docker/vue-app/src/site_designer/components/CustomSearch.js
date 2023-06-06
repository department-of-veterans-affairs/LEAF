export default {
    name: 'custom-search',
    data() {
        return {
            searchIsUpdating: false,
            months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'],
            adminHeaders: {
                date: {
                    name: 'Date',
                    indicatorID: 'date',
                    editable: false,
                    callback: (data, blob) => {
                        let date = new Date(blob[data.recordID].date * 1000);
                        let now = new Date();
                        let year = now.getFullYear() != date.getFullYear() ? ' ' + date.getFullYear() : '';
                        let formattedDate = this.months[date.getMonth()] + ' ' + parseFloat(date.getDate()) + year;
                        let elContainer = document.querySelector(`#${data.cellContainerID}`);
                        if(elContainer !== null) {
                            elContainer.innerHTML = formattedDate;
                            if(blob[data.recordID].userID == this.userID) {
                                elContainer.style.backgroundColor = '#feffd1';
                            }
                        }
                    }
                },
                title: {
                    name: 'Title',
                    indicatorID: 'title',
                    callback: (data, blob) => {
                        let types = '';
                        for(let i in blob[data.recordID].categoryNames) {
                            if(blob[data.recordID].categoryNames[i] != '') {
                                types += blob[data.recordID].categoryNames[i] + ' | ';
                            }
                        }
                        types = types.slice(0, types.length - 3);
                        
                        const isEmergency = blob[data.recordID].priority == -10;
                        const priority = isEmergency ? '<span style="color: red"> ( Emergency ) </span>' : '';
                        const priorityStyle = isEmergency ? ' style="background-color: red; color: black"' : '';
                        let elContainer = document.querySelector(`#${data.cellContainerID}`);
                        if(elContainer !== null) {
                            elContainer.innerHTML = 
                            `<span class="browsecounter">
                                <a ${priorityStyle} href="${this.rootPath}index.php?a=printview&recordID=${data.recordID}" tabindex="-1">${data.recordID}</a>
                            </span>
                            <a href="${this.rootPath}index.php?a=printview&recordID=${data.recordID}">${blob[data.recordID].title}</a><br />
                            <span class="browsetypes">${types}</span>${priority}`;
                            elContainer.addEventListener('click', () => {
                                window.location = `${this.rootPath}index.php?a=printview&recordID=${data.recordID}`;
                            });
                        }
                    }
                },
                service: {
                    name: 'Service',
                    indicatorID: 'service',
                    editable: false,
                    callback: (data, blob) => {
                        let elContainer = document.querySelector(`#${data.cellContainerID}`);
                        if(elContainer !== null) {
                            elContainer.innerHTML = blob[data.recordID].service;
                            if(blob[data.recordID].userID == this.userID) {
                                elContainer.style.backgroundColor = '#feffd1';
                            }
                        }
                    }
                },
                status: {
                    name: 'Status',
                    indicatorID: 'currentStatus',
                    editable: false,
                    callback: (data, blob) => {
                        let waitText = blob[data.recordID].blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
                        let status = '';
                        if(blob[data.recordID].stepID == null && blob[data.recordID].submitted == '0') {
                            const statusTxt = blob[data.recordID].lastStatus == null ? 'Not Submitted' : 'Pending Re-submission';
                            status = `<span style="color: #e00000">${statusTxt}</span>`;
    
                        } else if(blob[data.recordID].stepID == null) {
                            let lastStatus = blob[data.recordID].lastStatus;
                            if(lastStatus == '') {
                                lastStatus = `<a href="${this.rootPath}index.php?a=printview&recordID='+ data.recordID +'">Check Status</a>`;
                            }
                            status = '<span style="font-weight: bold">' + lastStatus + '</span>';
                        } else {
                            status = waitText + blob[data.recordID].stepTitle;
                        }
    
                        if(blob[data.recordID].deleted > 0) {
                            status += ', Cancelled';
                        }
                        let elContainer = document.querySelector(`#${data.cellContainerID}`);
                        if(elContainer !== null) {
                            elContainer.innerHTML = status;
                            if(blob[data.recordID].userID == this.userID) {
                                elContainer.style.backgroundColor = '#feffd1';
                            }
                        }
                    }
                },
                initiatorName: {
                    name: 'Initiator',
                    indicatorID: 'initiator',
                    editable: false,
                    callback: function(data, blob) {
                        let elContainer = document.querySelector(`#${data.cellContainerID}`);
                        if(elContainer !== null) {
                            elContainer.innerHTML = blob[data.recordID].firstName + " " + blob[data.recordID].lastName;
                        }
                    }
                }
            },
            sort: {column:'recordID', direction: 'desc'},
            headerOptions: ['date', 'title', 'service', 'status', 'initiatorName'],
            chosenHeadersSelect: [...this.chosenHeaders],
            mostRecentHeaders: '',
            choicesSelectID: 'choices_header_select',
            /*TODO: obj, keys same, other info eg bgcolor [date:{bgcolor:#,}]?

            getData: [],
            hilite: [status === 'approved', date < #,  lastaction > #],
            hide: []*/
            //categoryName automatically included in joins because it's needed for the title
            potentialJoins:["service","status","initiatorName","action_history","stepFulfillmentOnly","recordResolutionData"]
        }
    },
    mounted() {
        //console.log('search mounted, DOM available');
        if(this.chosenHeadersSelect.length === 0) {
            this.chosenHeadersSelect = ['date','title','service','status'];
            this.createChoices();
            this.postSearchSettings();
        } else {
            this.createChoices();
            this.main();
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'userID',
        'rootPath',
        'orgchartPath',
        'isEditingMode',
        'chosenHeaders',
    ],
    methods: {
        createChoices() {
            const elSelect = document.getElementById(this.choicesSelectID);
            if (elSelect !== null && elSelect.multiple === true && elSelect?.getAttribute('data-choice') !== 'active') {
                //add any saved ones first, so that the order will be retained
                let options = [...this.chosenHeadersSelect];
                this.headerOptions.forEach(o => {
                    if (!options.includes(o)) {
                        options.push(o);
                    }
                });
                options = options.map(o =>({
                    value: o,
                    label: this.getLabel(o),
                    selected: this.chosenHeadersSelect.includes(o)
                }));
                const choices = new Choices(elSelect, {
                    allowHTML: false,
                    removeItemButton: true,
                    editItems: true,
                    shouldSort: false,
                    choices: options
                });
                elSelect.choicesjs = choices;
            }
            document.querySelector(`#${this.choicesSelectID} ~ input.choices__input`)
                .setAttribute('aria-labelledby', this.choicesSelectID + '_label');
        },
        getLabel(option) {
            let label = '';
            switch(option.toLowerCase()) {
                case 'date':
                case 'title':
                case 'service':
                case 'status':
                    label = option;
                    break;
                case 'initiatorname':
                    label = 'initiator';
                    break;
                default:
                    break;

            }
            return label;
        },
        removeChoices() {
            const elSelect = document.getElementById(this.choicesSelectID);
            if (elSelect.choicesjs !== undefined && typeof elSelect.choicesjs.destroy === 'function') {
                elSelect.choicesjs.destroy();
            }
        },
        postSearchSettings() {
            if (JSON.stringify(this.chosenHeadersSelect) !== this.mostRecentHeaders) {
                this.searchIsUpdating = true;
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}site/settings/search_design_json`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        chosen_headers: this.chosenHeadersSelect,
                    },
                    success: (res) => {
                        if(+res?.code !== 1) {
                            console.log('unexpected response returned:', res);
                        }
                        document.getElementById('searchContainer').innerHTML = '';
                        setTimeout(() => {
                            this.main();
                            this.searchIsUpdating = false;
                        }, 150);
                    },
                    error: (err) => console.log(err)
                });
            } else console.log('headers have not changed');
        },
        renderResult(leafSearch, res) {
            const searchHeaders = this.chosenHeadersSelect.map(h => ({ ...this.adminHeaders[h]}));
            this.mostRecentHeaders = JSON.stringify(this.chosenHeadersSelect);
            let grid = new LeafFormGrid(leafSearch.getResultContainerID(), { readOnly: true });
            grid.setRootURL(this.rootPath);
            grid.hideIndex();
            grid.setDataBlob(res);
            grid.setHeaders(searchHeaders);
    
            let tGridData = [];
            for(let i in res) {
                tGridData.push(res[i]);
            }
            grid.setData(tGridData);
            grid.sort(this.sort.column, this.sort.direction);
            grid.renderBody();
            grid.announceResults();
        },
        main() {
            let query = new LeafFormQuery();
            query.setRootURL(this.rootPath);

            let leafSearch = new LeafFormSearch('searchContainer');
            leafSearch.setRootURL(this.rootPath);
            leafSearch.setOrgchartPath(this.orgchartPath);
    
            let extendedQueryState = 0; // 0 = not run, 1 = completed extra query for records created by current user
            let loadAllResults = false;
            let foundOwnRequest = false;
            let resultSet = {}; // current results
            let offset = 0; // current database offset index
            let batchSize = 50;
            let abortSearch = false;
            let scrollY = 0; // track scroll position for more seamless UX when loading more records
    
            // On the first visit, if no results are owned by the user, append their results
            query.onSuccess((res, resStatus, resJqXHR) => {
                const elSearch = document.getElementById('searchContainer');
                const elMoreResults = document.getElementById('searchContainer_getMoreResults');
                if (elSearch === null || elMoreResults === null) return;
                resultSet = Object.assign(resultSet, res);
                // find records owned by user
                if(extendedQueryState == 0) {
                    for(let i in res) {
                        if(res[i].userID == this.userID) {
                            foundOwnRequest = true;
                            break;
                        }
                    }
                }
                // append user's records if none were found earlier
                if(extendedQueryState == 0
                    && foundOwnRequest == false
                    && leafSearch.getSearchInput() == '') {
                    extendedQueryState = 1;
                    query.addTerm('userID', '=', this.userID);
                    query.execute();
                    return false;
                }
                // incrementally load records
                if((Object.keys(res).length == batchSize || resJqXHR.getResponseHeader('leaf-query') == 'continue')
                    && loadAllResults
                    && !abortSearch) {
    
                    document.querySelector('#' + leafSearch.getResultContainerID()).innerHTML = `<h3>Searching ${offset}+ possible records...</h3><p><button id="btn_abortSearch" class="buttonNorm">Stop searching for more</button></p>`;
                    document.querySelector('#btn_abortSearch').addEventListener('click', () => {
                        abortSearch = true;
                    });
                    offset += batchSize;
                    query.setLimit(offset, batchSize);
                    query.execute();
                    return;
                }
    
                this.renderResult(leafSearch, resultSet);
                window.scrollTo(0, scrollY);
                // UI for "show more results" button
                document.querySelector('#searchContainer_getMoreResults').style.display = !loadAllResults ? 'inline' : 'none';
            });
            leafSearch.setSearchFunc((txt) => {
                if(txt === undefined || txt === 'undefined') {
                    txt = '';
                    let elInput = document.querySelector('input[id$="_searchtxt"]');
                    if(elInput !== null) {
                        elInput.value = '';
                    }
                }
                // prep new search
                query.clearTerms();
                resultSet = {};
                offset = 0;
                loadAllResults = false;
                scrollY = 0;
                abortSearch = false;
    
                let isJSON = true;
                let advSearch = {};
                try {
                    advSearch = JSON.parse(txt);
                } catch(err) {
                    isJSON = false;
                }

                txt = txt ? txt.trim() : '';
                if(txt == '') {
                    query.addTerm('title', 'LIKE', '*');
                } else if(!isNaN(parseFloat(txt)) && isFinite(txt)) { // check if numeric
                    query.addTerm('recordID', '=', txt);
                } else if(isJSON) {
                    for(let i in advSearch) {
                        if(advSearch[i].id != 'data'
                            && advSearch[i].id != 'dependencyID') {
                            query.addTerm(advSearch[i].id, advSearch[i].operator, advSearch[i].match, advSearch[i].gate);
                        }
                        else {
                            query.addDataTerm(advSearch[i].id, advSearch[i].indicatorID, advSearch[i].operator, advSearch[i].match, advSearch[i].gate);
                        }
                    }
                } else {
                    query.addTerm('title', 'LIKE', '*' + txt + '*');
                }
    
                // check if the user wants to search for cancelled requests
                let hasDeleteQuery = false;
                for(let i in query.getQuery().terms) {
                    if(query.getQuery().terms[i].id == 'stepID'
                        && query.getQuery().terms[i].operator == '='
                        && query.getQuery().terms[i].match == 'deleted') {
                        hasDeleteQuery = true;
                        break;
                    }
                }
                // hide cancelled requests by default
                if(!hasDeleteQuery) {
                    query.addTerm('deleted', '=', 0);
                }
    
                query.setLimit(batchSize);
                query.join('categoryName');
                this.potentialJoins.forEach(j => {
                    if (this.chosenHeadersSelect.includes(j)) {
                        query.join(j);
                    }
                });
                query.sort('date', 'DESC');
                return query.execute();
            });
            leafSearch.init();
            document.querySelector('#' + leafSearch.getResultContainerID()).innerHTML = '<h3>Searching for records...</h3>';
    
            document.querySelector('#searchContainer_getMoreResults').addEventListener('click', () => {
                loadAllResults = true;
                scrollY = window.scrollY;
                if(leafSearch.getSearchInput() == '') {
                    let tQuery = query.getQuery();
                    for(let i in tQuery.terms) {
                        if(tQuery.terms[i].id == 'userID') {
                            tQuery.terms.splice(i, 1);
                        }
                    }
                    query.setQuery(tQuery);
                }
                offset += batchSize;
                query.setLimit(offset, batchSize);
                query.execute()
            });
        }
    },
    template: `<section style="display: flex; flex-direction: column; width: fit-content;">
        <div v-show="isEditingMode" class="designer_inputs" style="margin-top: 2rem;">
            <div>
                <label :id="choicesSelectID + '_label'">Select headers in the order that you would like them to appear</label>
                <select :id="choicesSelectID" v-model="chosenHeadersSelect" multiple></select>
            </div>
            <button type="button" class="btn-confirm" style="align-self: flex-end;"
                @click="postSearchSettings" :disabled="searchIsUpdating || chosenHeadersSelect.length===0">Apply Selections
            </button>
        </div>
        <div id="searchContainer" style="padding-top:2px;"></div>
        <button id="searchContainer_getMoreResults" class="buttonNorm" style="display: none; margin-left:auto;">
            Show more records
        </button>
    </section>`
}