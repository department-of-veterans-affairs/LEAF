<style>
    main {
        min-width: 300px;
    }
    main * {
        box-sizing: border-box;
    }
    #custom_header_wrapper.active {
        margin: 1rem auto 2rem auto;
        width: fit-content;
        justify-content: center;
        height: auto;
        display: flex;
        gap: 0.5em;
    }
    #custom_header_image_container {
        overflow: hidden;
    }
    #custom_header_outer_text, #custom_header_inner_text {
        display: none;
    }
    #custom_header_outer_text.active {
        display: block;
        padding: 0;
    }
    #custom_header_inner_text.active {
        display: block;
        position: absolute;
        top: 0;
        padding: 0.25em 0.5em;
    }
    #custom_header_outer_text.active *, #custom_header_inner_text.active * {
        margin: 0;
    }
    #custom_header_wrapper h1 {
        font-size: 32px;
    }
    #custom_header_wrapper h2 {
        font-size: 24px;
    }
    #custom_header_wrapper h3 {
        font-size: 20.8px;
    }
    #custom_header_wrapper h4 {
        font-size: 16px;
    }

    #menu_and_search {
        margin: auto;
        width: fit-content;
        padding: 1em 1.5em;
        display: flex;
        flex-wrap: wrap;
        gap: 1.25rem;
    }
    #custom_menu_wrapper {
        font-size: 14px;
        font-family: Verdana, sans-serif;
    }
    #custom_menu_wrapper.horizontal {
        width: 100%;
        display: flex;
        justify-content: center;
    }
    ul#menu {
        list-style-type: none;
        margin: 0;
        padding: 0;
        display: flex;
        gap: 1em 0;
        justify-content: center;
    }
    ul#menu > li {
        display: flex;
    }
    legend {
        color: black;
    }

    a.custom_menu_card {
        display: flex;
        align-items: center;
        width: 300px;
        min-height: 55px;
        padding: 4px 6px;
        text-decoration: none;
        border: 2px solid transparent;
        box-shadow: 0 0 6px rgba(0,0,25,0.3);
        transition: all 0.35s ease;
    }
    a.disableClick {
        pointer-events: none;
    }
    a.custom_menu_card:hover, a.custom_menu_card:focus, a.custom_menu_card:active {
        border: 2px solid white;
        box-shadow: 0 0 8px rgba(0,0,25,0.6);
        z-index: 10;
    }
    a.custom_menu_card h2 {
        margin: 0;
        font-size: 20px;
    }
    div.card_text {
        font-family: Verdana, sans-serif;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-self: stretch;
        width: 100%;
        min-height: 55px;
    }
    img.icon_choice {
        cursor: auto;
        margin-right: 0.5rem;
        width: 50px;
        height: 50px;
    }
</style>

<main>
    <div id="custom_header_wrapper"></div>
    <div id="menu_and_search">
        <div id="custom_menu_wrapper"></div>
        <section style="margin: auto; font-size: 14px;">
            <div id="searchContainer"></div>
            <button id="searchContainer_getMoreResults" class="buttonNorm" style="display: none; margin-left:auto;">Show more records</button>
        </section>
    </div>
</main>

<script>
    const userID = '<!--{$userID|unescape|escape:'quotes'}-->';
    const searchDesignData = JSON.parse('<!--{$homeDesignJSON}-->');
    const chosenHeaders = searchDesignData?.chosenHeaders || [];

    function headerWrapperFlex(headerType) {
        let dir = 'row';
        switch(+headerType) {
            case 2:
                dir = 'row-reverse';
                break;
            case 3:
                dir = 'column-reverse';
                break;
            case 4:
                dir = 'column';
                break;
            default:
            break
        }
        return dir;
    }

    function renderHeader() {
        const headerInfo = JSON.parse('<!--{$homeDesignJSON}-->' || '{}')?.header || null;
        if (headerInfo !== null && +headerInfo.enabled === 1) {
            const headerType = headerInfo?.headerType || 1;
            const flexDir = headerWrapperFlex(headerType);
            document.getElementById('custom_header_wrapper').style.flexDirection = flexDir;
            document.getElementById('custom_header_wrapper').classList.add('active');

            const title = headerInfo?.title || '';
            const color = headerInfo?.titleColor || '#000';
            const imageFile = headerInfo?.imageFile || '';

            let content = `<div id="custom_header_outer_text" style="color: ${color};" class="${headerType === 5 ? '' : 'active'}"></div>
                <div id="custom_header_image_container" style="position: relative;">`
            if (imageFile !== '') {
                content += `<img src="./files/${headerInfo?.imageFile}" style="display: block; width: ${headerInfo?.imageW}px;" />`
            }  
            content += `<div id="custom_header_inner_text" style="color: ${color}" class="${headerType === 5 ? 'active' : ''}"></div></div>`;
            $('#custom_header_wrapper').html(content);
            headerType === 5 ? $('#custom_header_inner_text').html(title) : $('#custom_header_outer_text').html(title);
        }
    }

    function renderMenu() {
        const dyniconsPath = "../libs/dynicons/svg/";
        const menuDesignData = JSON.parse('<!--{$homeDesignJSON}-->');
        const direction = menuDesignData?.direction || 'v';
        if (direction === 'h') {
            document.getElementById('custom_menu_wrapper').classList.add('horizontal');
        }

        const listStyle = direction === 'h' ? 'flex-wrap: wrap;' : 'flex-direction: column;';

        let menuCards = menuDesignData?.menuCards || [];
        menuCards = menuCards.filter(item => +item?.enabled === 1);
        menuCards = menuCards.sort((a, b) => a.order - b.order);

        const empMembership = JSON.parse('<!--{$empMembership['groupID']|json_encode}-->');
        let renderCards = [];
        menuCards.forEach(card => {
            const groups = card?.groups || [];
            const len = groups.length;
            //NOTE: group info is not currently added, so this just adds them all. evtl can display based on group membership
            if (len === 0) {
                renderCards.push({ ...card });
            } else {
                for (let i=0; i < len; i++) {
                    if(+empMembership[groups[i]] === 1) {
                        renderCards.push({ ...card });
                        break;
                    }
                }
            }
        });
        let buffer = `<ul style="${listStyle}" id="menu">`;
        renderCards.forEach(item => {
            const title = XSSHelpers.stripAllTags(XSSHelpers.decodeHTMLEntities(item.title));
            const subtitle = XSSHelpers.stripAllTags(XSSHelpers.decodeHTMLEntities(item.subtitle));
            const link = XSSHelpers.stripAllTags(item.link).trim();
            const disableClick = link === '' ? ' disableClick' : '';
            buffer += `<li><a href="${link}" target="_blank" style="background-color:${item.bgColor};" class="custom_menu_card${disableClick}">`
            if (item.icon !== '') {
                buffer += `<img v-if="menuItem.icon" src="${dyniconsPath}${item.icon}" alt="" class="icon_choice "/>`
            }
            buffer += `<div class="card_text">
                <h2 style="color:${item.titleColor};">${title}</h2>
                <div style="color:${item.subtitleColor};">${subtitle}</div>
            </div></a></li>`
        });
        buffer += `</ul>`;
        $('#custom_menu_wrapper').html(buffer);
    }

    function renderSearchResult(leafSearch, res) {
        const sort = { column: 'recordID', direction: 'desc' };
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

        let tGridData = [];
        for(let i in res) {
            tGridData.push(res[i]);
        }
        grid.setData(tGridData);
        grid.sort(sort.column, sort.direction);
        grid.renderBody();
        grid.announceResults();
    }

    function main() {
        renderHeader();
        renderMenu();

        let query = new LeafFormQuery();
        let leafSearch = new LeafFormSearch('searchContainer');
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

            renderSearchResult(leafSearch, resultSet);
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