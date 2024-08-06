<style>
    #no_code_search {
        font-size: 14px;
    }
    #searchContainer {
        margin-top: 0.25rem;
    }
    legend {
        color: black;
    }
</style>

<section id="no_code_search" style="display: flex; flex-direction: column; width: fit-content;">
    <div id="searchContainer"></div>
    <button id="searchContainer_getMoreResults" class="buttonNorm" style="display: none; margin-left:auto;">Show more records</button>
</section>

<script>
    const userID = '<!--{$userID|unescape|escape:'quotes'}-->';
    const searchData = JSON.parse('<!--{$searchDesignJSON}-->');
    const chosenHeaders = searchData?.chosenHeaders || [];

    const sort = { column: 'recordID', direction: 'desc' }; //NOTE: prep in case option

    function renderResult(leafSearch, res) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
        const headers = {
            date: {
                name: 'Date',
                indicatorID: 'date',
                editable: false,
                callback: function(data, blob) {
                    let date = new Date(blob[data.recordID].date * 1000);
                    let now = new Date();
                    let year = now.getFullYear() != date.getFullYear() ? ' ' + date.getFullYear() : '';
                    let formattedDate = months[date.getMonth()] + ' ' + parseFloat(date.getDate()) + year;
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = formattedDate;
                    if(blob[data.recordID].userID == userID) {
                        document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#feffd1';
                    }
                }
            },
            title: {
                name: 'Title',
                indicatorID: 'title',
                callback: function(data, blob) {
                    let types = '';
                    for(let i in blob[data.recordID].categoryNames) {
                        if(blob[data.recordID].categoryNames[i] != '') {
                            types += blob[data.recordID].categoryNames[i] + ' | ';
                        }
                    }
                    types = types.substr(0, types.length - 3);

                    priority = '';
                    priorityStyle = '';
                    if(blob[data.recordID].priority == -10) {
                        priority = '<span style="color: red"> ( Emergency ) </span>';
                        priorityStyle = ' style="background-color: red; color: black"';
                    }

                    document.querySelector(`#${data.cellContainerID}`).innerHTML =
                        `<span class="browsecounter">
                            <a ${priorityStyle} href="index.php?a=printview&recordID=${data.recordID}" tabindex="-1">${data.recordID}</a>
                        </span>
                        <a href="index.php?a=printview&recordID=${data.recordID}">${blob[data.recordID].title}</a><br />
                        <span class="browsetypes">${types}</span>${priority}`;
                    document.querySelector(`#${data.cellContainerID}`).addEventListener('click', function() {
                        window.location = 'index.php?a=printview&recordID='+data.recordID;
                    });
                }
            },
            service: {
                name: 'Service',
                indicatorID: 'service',
                editable: false,
                callback: function(data, blob) {
                    document.querySelector(`#${data.cellContainerID}`).innerHTML = blob[data.recordID].service;
                    if(blob[data.recordID].userID == userID) {
                        document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#feffd1';
                    }
                }
            },
            status: {
                name: 'Status',
                indicatorID: 'currentStatus',
                editable: false,
                callback: function(data, blob) {
                    let waitText = blob[data.recordID].blockingStepID == 0 ? 'Pending ' : 'Waiting for ';
                    let status = '';
                    if(blob[data.recordID].stepID == null && blob[data.recordID].submitted == '0') {
                        if(blob[data.recordID].lastStatus == null) {
                            status = '<span style="color: #e00000">Not Submitted</span>';
                        } else {
                            status = '<span style="color: #e00000">Pending Re-submission</span>';
                        }

                    } else if(blob[data.recordID].stepID == null) {
                        let lastStatus = blob[data.recordID].lastStatus;
                        if(lastStatus == '') {
                            lastStatus = '<a href="index.php?a=printview&recordID='+ data.recordID +'">Check Status</a>';
                        }
                        status = '<span style="font-weight: bold">' + lastStatus + '</span>';
                    } else {
                        status = waitText + blob[data.recordID].stepTitle;
                    }

                    if(blob[data.recordID].deleted > 0) {
                        status += ', Cancelled';
                    }

                    document.querySelector(`#${data.cellContainerID}`).innerHTML = status;
                    if(blob[data.recordID].userID == userID) {
                        document.querySelector(`#${data.cellContainerID}`).style.backgroundColor = '#feffd1';
                    }
                }
            },
            initiatorName: {
                name: 'Initiator',
                indicatorID: 'initiator',
                editable: false,
                callback: function(data, blob) {
                    $('#'+data.cellContainerID).html(blob[data.recordID].firstName + " " + blob[data.recordID].lastName);
                }
            }
        };
        const searchHeaders = chosenHeaders.map(h => ({ ...headers[h]}));

        let grid = new LeafFormGrid(leafSearch.getResultContainerID(), { readOnly: true });
        grid.hideIndex();
        grid.setDataBlob(res);
        grid.setHeaders(searchHeaders);
        grid.setPostProcessDataFunc(function(data) {
            let data2 = [];
            for(let i in data) {
                <!--{if !$is_admin}-->
                if(data[i].submitted == '0'
                    && data[i].userID == userID) {
                    data2.push(data[i]);
                }
                else if(data[i].submitted != '0') {
                    data2.push(data[i]);
                }
                <!--{else}-->
                data2.push(data[i]);
                <!--{/if}-->
            }
            return data2;
        });

        grid.sort(sort.column, sort.direction);
        grid.renderBody();
        grid.announceResults();
    }

    function main() {
        let query = new LeafFormQuery();
        let leafSearch = new LeafFormSearch('searchContainer');
        leafSearch.setJsPath('<!--{$app_js_path}-->');
        leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');

        let extendedQueryState = 0; // 0 = not run, 1 = completed extra query for records created by current user
        let loadAllResults = false;
        let foundOwnRequest = false;
        let resultSet = {}; // current results
        let offset = 0; // current database offset index
        let batchSize = 50;
        let abortSearch = false;
        let scrollY = 0; // track scroll position for more seamless UX when loading more records

        // On the first visit, if no results are owned by the user, append their results
        query.onSuccess(function(res, resStatus, resJqXHR) {
            resultSet = Object.assign(resultSet, res);
            // find records owned by user
            if(extendedQueryState == 0) {
                for(let i in res) {
                    if(res[i].userID == userID) {
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
                query.addTerm('userID', '=', userID);
                query.execute();
                return false;
            }
            // incrementally load records
            if((Object.keys(res).length == batchSize || resJqXHR.getResponseHeader('leaf-query') == 'continue')
                && loadAllResults
                && !abortSearch) {

                document.querySelector('#' + leafSearch.getResultContainerID()).innerHTML = `<h3>Searching ${offset}+ possible records...</h3><p><button id="btn_abortSearch" class="buttonNorm">Stop searching for more</button></p>`;
                document.querySelector('#btn_abortSearch').addEventListener('click', function() {
                    abortSearch = true;
                });
                offset += batchSize;
                query.setLimit(offset, batchSize);
                query.execute();
                return;
            }

            renderResult(leafSearch, resultSet);
            window.scrollTo(0, scrollY);
            // UI for "show more results" button
            document.querySelector('#searchContainer_getMoreResults').style.display = !loadAllResults ? 'inline' : 'none';
        });
        leafSearch.setSearchFunc(function(txt) {
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

            txt = txt.trim();
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
            const potentialJoins = ["service","status","initiatorName","action_history","stepFulfillmentOnly","recordResolutionData"]
            potentialJoins.forEach(j => {
                if (chosenHeaders.includes(j)) {
                    query.join(j);
                }
            });

            query.sort('date', 'DESC');
            return query.execute();
        });
        leafSearch.init();
        document.querySelector('#' + leafSearch.getResultContainerID()).innerHTML = '<h3>Searching for records...</h3>';

        document.querySelector('#searchContainer_getMoreResults').addEventListener('click', function() {
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

    document.addEventListener('DOMContentLoaded', main);
</script>
