<script src="../js/dialogController.js"></script>

<!--{include file="site_elements/generic_simple_xhrDialog.tpl"}-->

<style>
#page_breadcrumbs {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: .125rem;
}
#menu .buttonNorm {
    color: black;
    width:220px;
    padding: 4px;
    font-size:1rem;
    text-align:left;
    margin-bottom:1rem;
}
#menu .buttonNorm:hover, #menu .buttonNorm:focus, #menu .buttonNorm:active, #menu .searchfilter.active {
    color: white;
    background-color: #2372b0;
}
</style>

<script>
let query;
let grid;
let preview;
let data;
let dialog_simple;
let filter_id = '';

/*
* @param {string} input - content to remove potential html from.
* @returns scrubbed input
*/
function scrubHTML(input) {
    if(input == undefined) {
        return '';
    }
    let t = new DOMParser().parseFromString(input, 'text/html').body;
    while(input != t.textContent) {
        return scrubHTML(t.textContent);
    }
    return t.textContent;
}

function showPreview(recordID) {
    let formData = grid.getDataByRecordID(recordID);
    let title = scrubHTML(formData?.title ?? '');
    let authors = '';
    if(formData.s1.id9 != undefined
        && formData.s1.id9 != '') {
        authors = 'By ' + scrubHTML(formData.s1.id9);
    }
    if(formData.s1.id10 != undefined
        && formData.s1.id10 != '') {
        authors += ', ' + scrubHTML(formData.s1.id10);
    }
    if(formData.s1.id11 != undefined
        && formData.s1.id11 != '') {
        authors += '<br>' + scrubHTML(formData.s1.id11);
    }

    dialog_simple.setTitle('Preview');
    dialog_simple.setContent(
        '<button type="button" id="btn_download" class="buttonNorm" style="float: right">' +
        '<img src="../dynicons/?img=edit-copy.svg&w=32" alt=""> Get a copy!</button>' +
        '<div style="font-size: 120%; font-weight: bold">' + title + '</div>' +
        '<div>'+ authors +'</div><br><br>' +
        '<div id="preview"></div>'
    );
    dialog_simple.show();

    preview = new LeafPreview('preview');
    preview.setLeafDomain('<!--{$LEAF_DOMAIN}-->');
    preview.load(recordID, 1, 0);

    document.getElementById('btn_download')?.addEventListener(
        'click',
        () => {
            let formData = new FormData();
            formData.append('formPacket', JSON.stringify(preview.getRawForm()));
            formData.append('formLibraryID', recordID);
            fetch('ajaxIndex.php?a=importForm', {
                method: 'POST',
                body: formData
            }).then(res => {
                if(res.status === 200) {
                    return res.text();
                } else {
                    throw new Error('Error importing form');
                }
            }).then(newFormID => {
                const formReg = /^form_[0-9a-f]{5}$/i;
                if(formReg.test(newFormID) === true) {
                    window.location = '?a=form_vue#/forms?formID=' + newFormID;
                } else {
                    throw new Error('Unexpected response:' + newFormID);
                }
            }).catch(err => console.error("An error has occurred:", err))
        },
        { once: true }
    );
}

function applyFilter(search, btnEl) {
    const filters = [ '', 'Administrative', 'Human Resources', 'Information Technology', 'Logistics', 'Fiscal' ];
    const isFilter = filters.some(f => f === search);
    if(isFilter === true && filter_id !== search) {
        filter_id = search;
        document.querySelectorAll('.searchfilter').forEach(el => el.classList.remove('active'));
        btnEl.classList.add('active');
        query.updateDataTerm('data', '3', 'LIKE', '*' + search + '*');
        query.execute();
        announceFilter(search);
    }
}
function announceFilter(id) {
    document.getElementById('filterStatus')?.setAttribute(
        'aria-label', 'Filtering results by ' + id
    );
}

document.addEventListener("DOMContentLoaded", () => {
    dialog_simple = new dialogController(
        'simplexhrDialog',
        'simplexhr',
        'simpleloadIndicator',
        'simplebutton_save',
        'simplebutton_cancelchange'
    );
    $('#simplexhrDialog').dialog({ minWidth: (window.innerWidth * .78) + 30 });

    query = new LeafFormQuery();
    query.setRootURL('<!--{$LEAF_DOMAIN}-->LEAF/library/');
    query.onSuccess(res => {
        data = res;
        let tData = [];
        for(let i in res) {
            tData.push(res[i]);
        }
        tData.sort((a, b) => {
            if(a.s1.id53 == "Yes" && b.s1.id53 != "Yes") {
                return -1;
            }
            if(a.s1.id53 != "Yes" && b.s1.id53 == "Yes") {
                return 1;
            }
            return 0;
        });

        grid = new LeafFormGrid('forms', { readOnly: true });
        grid.setRootURL('../');
        grid.hideIndex();
        grid.importQueryResult(tData);
        grid.setHeaders([
            {
                name: 'Form', indicatorID: 'form', editable: false, sortable: true,
                callback: function(data, blob) {
                    let rowEl = document.getElementById(
                        grid.getPrefixID() + "tbody_tr" + data.recordID
                    );
                    if(blob[data.index].s1.id53 == "Yes" && rowEl !== null) {
                        rowEl.style.backgroundColor = '#ffff99';
                    }
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        const title = scrubHTML(blob[data.index].title);
                        container.innerHTML = '<span style="font-weight: bold; font-size: 100%">' + title + '</span>';
                    }
                }
            },
            {
                name: 'Description', indicatorID: 5, editable: false, sortable: true,
            },
            {
                name: 'Author(s)', indicatorID: 'authors', editable: false, sortable: true,
                callback: function(data, blob) {
                    let authors = '';
                    if(blob[data.index].s1.id9 != undefined
                        && blob[data.index].s1.id9 != '') {
                        authors = scrubHTML(blob[data.index].s1.id9);
                    }
                    if(blob[data.index].s1.id10 != undefined
                        && blob[data.index].s1.id10 != '') {
                        authors += ', ' + scrubHTML(blob[data.index].s1.id10);
                    }
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        container.textContent = authors
                    }
                }
            },
            {
                name: 'Workflow Example', indicatorID: 6, editable: false, sortable: false,
                callback: function(data, blob) {
                    if(blob[data.index]?.s1?.id6 != undefined && blob[data.index].s1.id6 != '') {
                        const recID = blob[data.index].recordID;
                        const title = scrubHTML(blob[data.index].title);
                        const imageURL = '<!--{$LEAF_DOMAIN}-->LEAF/library/image.php?form=' + blob[data.index].recordID + '&id=6&series=1&file=0';
                        let container = document.getElementById(data.cellContainerID);
                        if (container !== null) {
                            const imgElID = `workflowImg_${recID}`;
                            container.innerHTML = `<img id="${imgElID}" src="${imageURL}" alt="Screenshot of workflow" ` +
                                `style="border: 1px solid black; max-width: 150px; cursor: pointer">`;

                            document.getElementById(imgElID).addEventListener(
                                'click',
                                () => {
                                    dialog_simple.setTitle(title + ' (example workflow)');
                                    dialog_simple.setContent(
                                        `<a href="${imageURL}" target="_blank">` +
                                        `<img id="${imgElID}" src="${imageURL}" alt="Screenshot of workflow" ` + 
                                        'style="cursor: zoom-in; border: 1px solid black; width: 540px"></a>'
                                    );
                                    dialog_simple.show();
                                }
                            )
                        }
                    }
                }
            },
            {
                name: 'Preview', indicatorID: 'preview', editable: false, sortable: false,
                callback: function(data, blob) {
                    let container = document.getElementById(data.cellContainerID);
                    if (container !== null) {
                        container.innerHTML = '<button type="button" class="buttonNorm" onclick="showPreview('+ blob[data.index].recordID +')" >' +
                            '<img src="../dynicons/?img=edit-find.svg&w=32" alt=""> Preview</button>';
                    }
                }
            }
        ]);

        grid.setPostRenderFunc(() => {
            Array.from(document.querySelectorAll(
                '#' + grid.getPrefixID() + 'table > tbody > tr > td'
            )).forEach(td => {
                td.style.borderRight = '0px';
                td.style.borderLeft = '0px';
            });
        });
        grid.renderBody();

    });

    let leafSearch = new LeafFormSearch('searchContainer');
    leafSearch.setJsPath('<!--{$app_js_path}-->');
    leafSearch.setRootURL('../');
    leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');
    leafSearch.setSearchFunc(search => {
        query.clearTerms();
        query.importQuery({
            "terms":[
                {"id":"categoryID","operator":"=","match":"form_68aa4"},
                {"id":"dependencyID","indicatorID":"9","operator":"=","match":"1"},
                {"id":"deleted","operator":"=","match":0},
            ],
            "getData":["3","5","4","1","9","10","11","6","53"]
        });
        query.addDataTerm('data', '0', 'LIKE', '*' + search + '*');
        query.execute();
    });

    leafSearch.init();
    let advSearchEl = document.getElementById(leafSearch.getPrefixID() + 'advancedSearchButton');
    if(advSearchEl !== null) {
        advSearchEl.style.display = 'none';
    }
});
</script>

<section class="leaf-width-100pct" style="padding: 0 0.5em;">
    <h2 id="page_breadcrumbs">
        <a href="../admin" class="leaf-crumb-link" title="to Admin Home">Admin</a>
        <i class="fas fa-caret-right leaf-crumb-caret"></i>LEAF Library
    </h2>
    <div id="menu" style="float: left; width: 230px">
        <span style="position: absolute; color: transparent" aria-atomic="true" aria-live="assertive" id="filterStatus" role="status"></span>
        <a class="buttonNorm" href="?a=form_vue" style="display: inherit;text-decoration: none" id="backToForm"><img aria-hidden="true" src="../dynicons/?img=system-file-manager.svg&amp;w=32" alt="" title="My Forms"> My Forms</a>
        <a class="buttonNorm" href="<!--{$LEAF_DOMAIN}-->LEAF/library/?a=newform" style="display: inherit;text-decoration: none"><img aria-hidden="true" src="../dynicons/?img=list-add.svg&amp;w=32" alt="" title="Contribute my Form"> Contribute my Form</a>

        <div class="leaf-marginBot-halfRem">Filter by Business Lines:</div>
        <button type="button" class="buttonNorm searchfilter active" onclick="applyFilter('', this)">
            <img aria-hidden="true" src="../dynicons/?img=Accessories-dictionary.svg&amp;w=32" alt="" title="All Business Lines">
            All Business Lines
        </button>

        <button type="button" class="buttonNorm searchfilter" onclick="applyFilter('Administrative', this)">
            <img aria-hidden="true" src="../dynicons/?img=applications-office.svg&amp;w=32" alt="" title="Administrative">
            Administrative
        </button>
        <button type="button" class="buttonNorm searchfilter" onclick="applyFilter('Human Resources', this)">
            <img aria-hidden="true" src="../dynicons/?img=system-users.svg&amp;w=32" alt="" title="Human Resources">
            Human Resources
        </button>
        <button type="button" class="buttonNorm searchfilter" onclick="applyFilter('Information Technology', this)">
            <img aria-hidden="true" src="../dynicons/?img=network-idle.svg&amp;w=32" alt="" title="Information Technology">
            Information Technology
        </button>
        <button type="button" class="buttonNorm searchfilter" onclick="applyFilter('Logistics', this)">
            <img aria-hidden="true" src="../dynicons/?img=package-x-generic.svg&amp;w=32" alt="" title="Logistics">
            Logistics
        </button>
        <button type="button" class="buttonNorm searchfilter" onclick="applyFilter('Fiscal', this)">
            <img aria-hidden="true" src="../dynicons/?img=x-office-spreadsheet.svg&amp;w=32" alt="" title="Fiscal">
            Fiscal
        </button>
    </div>
    <div id="formEditor_content" style="margin-left: 238px; padding-left: 8px">
        <div class="leaf-marginBot-halfRem leaf-bold">Search Form Library:</div>
        <div id="searchContainer"></div>
        <div id="forms"></div>
    </div>
</section>
