<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/dc/4.2.7/style/dc.min.css" integrity="sha512-t38Qn1jREPvzPvDLgIP2fjtOayaA1KKBuNpNj9BGgiMi+tGLOdvDB+aWLMe2BvokHg1OxRLQLE7qrlLo+A+MLA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js" integrity="sha512-M7nHCiNUOwFt6Us3r8alutZLm9qMt4s9951uo8jqO4UwJ1hziseL6O3ndFyigx6+LREfZqnhHxYjKRJ8ZQ69DQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/crossfilter2/1.5.4/crossfilter.min.js" integrity="sha512-YTblpiY3CE9zQBW//UMBfvDF2rz6bS7vhhT5zwzqQ8P7Z0ikBGG8hfcRwmmg3IuLl2Rwk95NJUEs1HCQD4EDKQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dc/4.2.7/dc.min.js" integrity="sha512-vIRU1/ofrqZ6nA3aOsDQf8kiJnAHnLrzaDh4ob8yBcJNry7Czhb8mdKIP+p8y7ixiNbT/As1Oii9IVk+ohSFiA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

<style>
#content p, #content li {
    font-size: 12pt;
    font-family: 'Source Sans Pro', helvetica;
}
.table td {
    font-size: 12pt;
}

.dc-chart g.row text {
    fill: black;
}
.dc-chart .pie-slice {
    fill: black;
}
.boxPlot svg {
    transform: rotate(90deg);
    transform-origin: right;
}
.boxPlot .axis {
    display: none;
}
.boxPlot text.box,text.whisker {
    transform-box: fill-box;
    transform-origin: center;
    transform: rotate(-90deg);
}
.activity .axis {
    display: none;
}

#content {
    padding: 0px 8px;
}

#charts {
	display: flex;
    flex-wrap: wrap;
    gap: 10px;
    justify-content: center;
}

.cardLabel {
    position: sticky;
    top: 0px;
    font-size: 0.8rem;
    margin: 0px 0px 8px 0px;
    background-color: white;
}

.card {
    height: 210px;
    width: 280px;
    padding: 8px;
    margin-left: 0px;
    overflow: hidden;
    flex-grow: 2;
    border: 0;
}

.card-small {
    height: 87px;
    width: 140px;
}

.card-wide {
    height: 175px;
    width: 560px;
}

.card-huge {
    height: 350px;
    width: 100vw;
    overflow: auto;
}
</style>
<script>
var niceColors = d3.schemeTableau10;

var facts; // crossfilter facts to feed dc.js
var charts = {}; // dc.js chart objects
var numUniques = {}; // set of indicatorIDs containing count of unique values
var fields = []; // list of data fields to display
var forms = []; // list of all forms
var chartTitle = ''; // selected chart title
var suggestions = {};
suggestions.length = [];

function isNumeric(x) {
    return !isNaN(parseFloat(x));
}

function scrubHTML(input) {
        let t = new DOMParser().parseFromString(input, 'text/html').body;
        return t.textContent;
}

// Update window title
function updateTitle(title) {
    if(title != '') {
        let siteName = document.querySelector('#headerDescription')?.innerText;
        let siteLocation = document.querySelector('#headerLabel')?.innerText;
        if(siteName == undefined) {
            document.querySelector('title').innerText = scrubHTML(`${title}`);
        }
        else {
            document.querySelector('title').innerText = scrubHTML(`${title} - ${siteName} | ${siteLocation}`);
        }
    }
}

// getFields returns an array of field types to display
function getFields(form) {
    for(let i in form) {
        switch(form[i]?.format) {
            case 'dropdown':
            case 'radio':
            case 'textarea':
            case 'text':
            case 'checkbox':
            case 'checkboxes':
            case 'multiselect':
            case 'orgchart_employee':
            case 'orgchart_group':
            case 'orgchart_position':
            case 'number':
            case 'currency':
            case 'date':
                fields.push(form[i]);
                break;
            default:
                break;
        }
        if(form[i].child != null) {
            getFields(form[i].child);
        }
    }
}

// buildFacts parses and prepares data for analysis
function buildFacts(fields, data) {
    let parsed = [];
    for(let i in data) {
        let temp = {};

        // assign common fields
        temp['recordID'] = i;
        temp['submitted'] = new Date(data[i].submitted * 1000);
        temp['timeToComplete'] = data[i].submitted - data[i].date;
        temp['status'] = data[i].stepTitle;
        if(data[i].stepID == null && data[i].submitted > 0) {
            temp['status'] = 'Resolved';
        }
        else if(data[i].submitted == 0) {
            temp['status'] = 'Not submitted';
        }

        // assign user-defined fields
        fields.forEach(field => {
        	temp[field.indicatorID] = data[i].s1?.['id' + field.indicatorID];
            if(temp[field.indicatorID] == null || temp[field.indicatorID] == '') {
                temp[field.indicatorID] = 'Blank';
            }

            // count unique reponses
            if(numUniques[field.indicatorID] == undefined) {
                numUniques[field.indicatorID] = {};
            }
            let text = temp[field.indicatorID].substring(0,20);
            if(text.length == 20) {
                text = text + '...';
            }
            numUniques[field.indicatorID][text] = {};

            // handle special formats
            if(field.format == 'date') {
                let date = new Date(temp[field.indicatorID]);
                if(date.toString() == 'Invalid Date') {
                    date = temp[field.indicatorID];
                }
                else {
                    date = date.getDay();
                }
                temp[field.indicatorID] = date;
            }
        });
        parsed.push(temp);
    }

    if(facts == undefined) {
        facts = crossfilter(parsed);
    }
    else {
        facts.add(parsed);
    }
}

// initRowChart initializes a single DC.js row chart
function initRowChart(field, dimensions, groups) {
    charts[field.indicatorID] = dc.rowChart(`#chart_${field.indicatorID}`, 'main');

    charts[field.indicatorID]
    	.useViewBoxResizing(true)
        .height(200)
        .dimension(dimensions[field.indicatorID])
        .group(groups[field.indicatorID])
        .title(d => d.key + ': ' + d.value)
        .ordering(function(d) { return -d.value; })
        .gap(2)
        .othersLabel('All others')
        .fixedBarHeight(14)
        .elasticX(true)
    	.ordinalColors(niceColors)
    	.cap(9)
        .label(d => Math.round(d.value / dimensions[field.indicatorID].groupAll().reduceCount().value() * 100) + "% " + d.key);
}

// initPieChart initializes a single DC.js pie chart
function initPieChart(field, dimensions, groups) {
    charts[field.indicatorID] = dc.pieChart(`#chart_${field.indicatorID}`, 'main');

    charts[field.indicatorID]
        .useViewBoxResizing(true)
    	.height($(`#chart_contain_${field.indicatorID}`).height() - 40)
        .dimension(dimensions[field.indicatorID])
        .group(groups[field.indicatorID])
        .title(d => Math.round(d.value / dimensions[field.indicatorID].groupAll().reduceCount().value() * 100) + "% " + d.key + ': ' + d.value)
        .ordering(function(d) { return d.value; })
        .ordinalColors(niceColors)
        .label(d => d.key);
}

// initBoxPlot initializes a single DC.js box plot
function initBoxPlot(field, dimensions, groups) {
    charts[field.indicatorID] = dc.boxPlot(`#chart_${field.indicatorID}`, 'main');

    charts[field.indicatorID]
        //.useViewBoxResizing(true)
        .width(160)
        .height(320)
        .dimension(dimensions[field.indicatorID])
        .group(groups[field.indicatorID])
        .title(d => d.key + ': ' + d.value)
        .boxPadding(0.4)
        .yRangePadding(20)
//    .showOutliers(false)
        .margins({top: 0, right: 0, bottom: 10, left: 0})
        .elasticY(true);
    document.querySelector(`#chart_${field.indicatorID}`).classList.add('boxPlot')
}

// initBarChart initializes a single DC.js bar chart
function initBarChart(field, dimensions, groups) {
    charts[field.indicatorID] = dc.barChart(`#chart_${field.indicatorID}`, 'main');

    charts[field.indicatorID]
    	.useViewBoxResizing(true)
        .height(190)
        .dimension(dimensions[field.indicatorID])
        .group(groups[field.indicatorID])
        .title(d => d.key + ': ' + d.value)
        .label(d => Math.round(d.data.value / dimensions[field.indicatorID].groupAll().reduceCount().value() * 100) + "% ")
        .x(d3.scaleBand())
        .xUnits(dc.units.ordinal)
        .margins({top: 20, right: 50, bottom: 30, left: 30})
        .clipPadding(20)
        .elasticX(true)
        .elasticY(true);
}

// initCharts initializes DC.js charts
function initCharts(fields) {
    let buf = '';
    let container = document.querySelector('#charts');
    let dimensions = {};
    let groups = {};
    
    container.innerHTML = '';

    // summarize count for unique reponses
    for(let i in numUniques) {
        numUniques[i] = {count: Object.keys(numUniques[i]).length,
                        value: Object.keys(numUniques[i])[0]};
    }

    dimensions['recordID'] = facts.dimension(function(d) { return d.recordID; });
    dimensions['submitted'] = facts.dimension(function(d) { return d.submitted; });
    dimensions['status'] = facts.dimension(function(d) { return d.status; });

    charts['recordID'] = dc.numberDisplay('#chart_numReponses', 'main');
    charts['recordID']
        .valueAccessor(d => d)
        .group(dimensions['recordID'].groupAll().reduceCount())
    	.html({
        	one: '%number response',
        	some: '%number responses',
        	none: 'No responses',
    	})
    	.formatNumber(d3.format(',.0f'));
    
    let dataColumns = [
            function(d) { return d.submitted.toLocaleDateString(); },
            function(d) { return '<a href="index.php?a=printview&recordID='+ d.recordID +'" target="_blank">' + d.recordID + '</a>'; },
    ];
    let dataHeaders = '';

    let field = {indicatorID: 'status'};
    dimensions[field.indicatorID] = facts.dimension(function(d) { return d.status; });
    groups[field.indicatorID] = dimensions[field.indicatorID].group().reduceCount();

    container.insertAdjacentHTML('beforeend', `<div class="card" id="chart_contain_${field.indicatorID}"><h2 class="cardLabel">Status</h2><div id="chart_${field.indicatorID}"></div></div>`);
    initRowChart(field, dimensions, groups);

    // generate configuration for each selected field
    fields.forEach(field => {
        let label = field.description == null || field.description == '' ? field.name : field.description;
        let tDom = document.createElement('div');
        tDom.innerHTML = label;
        label = tDom.innerText;
        
        if(label == '') {
            label = `<span style="color: red">Blank Fieldname #${field.indicatorID}</span>`;
        }
        
        if(label.split(' ').length > 3) {
            suggestions['length'].push(label);
        }

        switch(field.format) {
            case 'textarea':
            case 'text':
                dataColumns.push(function(d) {
                    return d[field.indicatorID];
                });
                dataHeaders += `<td>${label}</td>`;
                break;
            default:
        		container.insertAdjacentHTML('beforeend', `<div class="card" id="chart_contain_${field.indicatorID}"><h2 class="cardLabel">${label}</h2><div id="chart_${field.indicatorID}"></div></div>`);

                switch(field.format) {
                    case 'date':
                        dimensions[field.indicatorID] = facts.dimension(function(d) { return d[field.indicatorID]+''; }); //force to string: chromium workaround
                        groups[field.indicatorID] = dimensions[field.indicatorID].group().reduceCount();

                        initBarChart(field, dimensions, groups);
                        let days = ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'];
                        charts[field.indicatorID]
                            .title(d => {
                                let unit = days[d.key] != undefined ? days[d.key] : d.key
                                return `${unit}: ${d.value}`
                            })
                            .colorAccessor(d => {
                                if(days[d.key] == undefined) {
                                    return niceColors.length - 1;
                                }
                                return d.key;
                            })
                            .colors(k => niceColors[k])
                            .xAxis()
                            .tickFormat(d => {
                                if(days[d] == undefined) {
                                    return d;
                                }
                                return days[d];
                        });
                        break;
                    case 'number':
                    case 'currency':
                        dimensions[field.indicatorID] = facts.dimension(function(d) { return 'total'; });
                        // shuffle numbers into a sorted array
                        groups[field.indicatorID] = dimensions[field.indicatorID].group().reduce(
                            (p, v) => {
                                if(!isNumeric(v[field.indicatorID])) {
                                    return p;
                                }
                                v[field.indicatorID] = parseFloat(v[field.indicatorID]);
                                p.splice(d3.bisectLeft(p, v[field.indicatorID]), 0, v[field.indicatorID]);
                                return p;
                            },
                            (p, v) => {
                                if(!isNumeric(v[field.indicatorID])) {
                                    return p;
                                }
                                v[field.indicatorID] = parseFloat(v[field.indicatorID]);
                                p.splice(d3.bisectLeft(p, v[field.indicatorID]), 1);
                                return p;
                            },
                            () => {
                                return [];
                            }
                        );
                        initBoxPlot(field, dimensions, groups);
                        
                        charts[field.indicatorID].on('postRender', () => {
                            let boxHeight = document.querySelector(`#chart_${field.indicatorID} svg g.box>rect.box`).getAttribute('height');
                        	if(boxHeight < 5) {
                                dc.chartRegistry.deregister(charts[field.indicatorID]);
                                charts[field.indicatorID].dimension().dispose();
                                document.querySelector(`#chart_${field.indicatorID}`).classList.remove('boxPlot')

                                dimensions[field.indicatorID] = facts.dimension(function(d) { return d[field.indicatorID]+''; });
                                groups[field.indicatorID] = dimensions[field.indicatorID].group().reduceCount();
                                if(numUniques[field.indicatorID]['count'] > 6) {
                                    initRowChart(field, dimensions, groups);
                                }
                                else if(numUniques[field.indicatorID]['count'] > 1) {
                                    initPieChart(field, dimensions, groups);
                                }
                                else {
                                    document.querySelector(`#chart_${field.indicatorID}`).innerHTML = `<p>Everyone answered "${numUniques[field.indicatorID]['value']}"</p>`;
                                }
                                charts[field.indicatorID].render();
                            }
                        });

                        if(field.format == 'currency') {
                            charts[field.indicatorID].tickFormat(d => `$${d}`);
                        }
                        break;
                    default:
                        dimensions[field.indicatorID] = facts.dimension(function(d) { return d[field.indicatorID]; });
                        groups[field.indicatorID] = dimensions[field.indicatorID].group().reduceCount();
                        if(numUniques[field.indicatorID]['count'] > 6) {
                            initRowChart(field, dimensions, groups);
                        }
                        else if(numUniques[field.indicatorID]['count'] > 1) {
                            initPieChart(field, dimensions, groups);
                        }
                        else {
                            document.querySelector(`#chart_${field.indicatorID}`).innerHTML = `<p>Everyone answered "${numUniques[field.indicatorID]['value']}"</p>`;
                        }
                        break;
                }
                break;
        }
    });

	container.insertAdjacentHTML('beforeend', `<div class="card card-huge"><h2 class="cardLabel">Responses (limit 20)</h2><table id="chart_table" class="table">
    	<thead>
			<td>Date submitted</td>
			<td>UID</td>
			${dataHeaders}
    	</thead>
    </table></div>`);
    charts['table'] = dc.dataTable("#chart_table", 'main');
    charts['table']
        .dimension(dimensions['recordID'])
    	.showSections(false)
        .columns(dataColumns)
        .sortBy(function(d) { return -d.submitted; })
        .size(Infinity)
        .beginSlice(0)
        .endSlice(20);
    
    dc.renderAll('main');
    
    let suggestionText = '';
    suggestions['length'].forEach(suggestion => {
        suggestionText += `<li>${suggestion}</li>`;
    });

    if(suggestions['length'].length > 0) {
        document.querySelector('#suggestions').innerHTML = `<h2 style="color: red">Suggestions</h2><p>Short Labels help improve the readability of headings in spreadsheets. A short label should be added to these fields:</p><ol>${suggestionText}</ol>`;
    }
}

async function selectForm() {
    let buf = `<table class="table"><thead><tr>
            <th>Recent Activity</th>
            <th>Form</th>
        </tr></thead>`;
    let data = await fetch('api/formStack/categoryList/all').then(res => res.json());
    
    data.forEach(form => {
        if(form.workflowID > 0) {
            buf += `<tr>
                <td id="activity_${form.categoryID}" class="activity">...</td>
                <td><a href="report.php?a=LEAF_Data_Visualizer&form=${form.categoryID}">${form.categoryName}</a></td>
            </tr>`
        }
    });
    buf += '</table>';
    
    document.querySelector('#charts').style.visibility = 'visible';
    document.querySelector('#actionBar').style.display = 'none';
    document.querySelector('#chart_title').innerHTML = 'Please select a form to generate an overview:';
    document.querySelector('#chart_numReponses').innerHTML = '';
    document.querySelector('#charts').innerHTML = `<div>${buf}</div>`;

    // check activity
    let query = new LeafFormQuery();
    query.addTerm('dateSubmitted', '>', '30 days ago');
    query.addTerm('deleted', '=', 0);
    query.join('categoryName');
    query.setLimit(1000);
    query.setExtraParams('&x-filterData=submitted,categoryIDs');

    // prep activity data
    let recentActivity = [];
    let activityData = await query.execute();
    for(let i in activityData) {
        recentActivity.push({
            date: new Date(activityData[i].submitted * 1000),
            categoryIDs: activityData[i].categoryIDs
        });
    }

    let activitiyFacts = crossfilter(recentActivity);
    
    // setup charts
    let activityCharts = {};
    let dimActivityTime = activitiyFacts.dimension(d => d3.timeDay(d.date));
    let groupActivity = {};
    let minDate = new Date(dimActivityTime.bottom(1)[0].date);
    let maxDate = new Date(dimActivityTime.top(1)[0].date);
    data.forEach(form => {
        if(form.workflowID == 0) {
            return;
        }
        groupActivity[form.categoryID] = dimActivityTime.group().reduce(
            (p, v) => {
                v.categoryIDs.forEach(categoryID => {
                    p[categoryID] = p[categoryID] + 1 || 1;
                })
                return p;
            },
            (p, v) => {
                v.categoryIDs.forEach(categoryID => {
                    p[categoryID] -= 1;
                    if(p[categoryID] <= 0) {
                        delete p[categoryID];
                    }
                })
                return p;
            },
            () => {
                return {};
            }
        );

        activityCharts[form.categoryID] = dc.barChart(`#activity_${form.categoryID}`, 'activity');

        activityCharts[form.categoryID]
            .width(100)
            .height(24)
            .dimension(dimActivityTime)
            .group(groupActivity[form.categoryID])
            .valueAccessor(d => d.value[form.categoryID])
            .brushOn(false)
            .margins({left: 0, top: 4, right: 0, bottom: 0})
            .x(d3.scaleTime().domain([minDate, maxDate]))
            .xUnits(() => 16)
        	.gap(2);
        document.querySelector(`#activity_${form.categoryID}`).innerHTML = '';
    });

    dc.renderAll('activity');
}

let exportLink = './';
function exportData() {
    window.open(exportLink);
}

async function getDataBuildCharts(categoryID, customSearch) {
    document.querySelector('#chart_title').innerHTML = `<img src="images/largespinner.gif" style="vertical-align: middle" /> Loading...`;
	let query = new LeafFormQuery();
    query.addTerm('categoryID', '=', categoryID);
	query.addTerm('deleted', '=', 0);
    query.join('status');
    
    query.onProgress(progress => {
        document.querySelector('#chart_title').innerHTML = `<img src="images/largespinner.gif" style="vertical-align: middle" /> Processing ~${progress} records...`;
    });
    
    let queryFilter = ['recordID', 'submitted', 'stepID', 'stepTitle'];
    fields.forEach(field => {
        query.getData(field.indicatorID);
    });
    query.setExtraParams('&x-filterData=' + queryFilter.join(','));
    
    // add custom filters, if any
    let activeFilters = '';

    if(customSearch != undefined) {
        var advSearch = {};
        try {
            advSearch = JSON.parse(customSearch);
            for(let i in advSearch.terms) {
                let param = advSearch.terms[i];

                if(param.id == 'categoryID') {
                    continue;
                }
                if(param.id == 'deleted'
                  && param.operator == '='
                  && param.match == 0) {
                    continue;
                }
                if(param.id != 'data'
                    && param.id != 'dependencyID') {
                    query.addTerm(param.id, param.operator, param.match);
                    activeFilters += `<li>${param.id} ${param.operator} ${param.match}</li>`;
                }
                else {
                    query.addDataTerm(param.indicatorID, param.id, param.operator, param.match);
					activeFilters += `<li>${param.id}${param.indicatorID} ${param.operator} ${param.match}</li>`;
                }
            }
        }
        catch(err) {
        }
    }
    else {
        let today = new Date();
        today.setDate(today.getDate() - 30);
        query.addTerm('dateSubmitted', '>=', `${today.getMonth() + 1}/${today.getDate()}/${today.getFullYear()}`);
		activeFilters += `<li>Records submitted in the past 30 days</li>`;
    }
    
    // export link
    let exportFields = [];
    fields.forEach(field => {
        let t = {};
        t.indicatorID = field.indicatorID;
        t.name = field.name;
    	if(field.description != '') {
            t.name = field.description;
        }
        exportFields.push(t);
    });

    let exportQuery = LZString.compressToBase64(JSON.stringify(query.getQuery()));
    let exportIndicators = encodeURIComponent(LZString.compressToBase64(JSON.stringify(exportFields)));
    exportLink = `index.php?a=reports&v=3&query=${exportQuery}&indicators=${exportIndicators}`;
    
    window.history.pushState('Loaded Report', chartTitle, 'report.php?a=LEAF_Data_Visualizer&query=' + encodeURIComponent(exportQuery));    
    
    document.querySelector('#activeFilters').innerHTML = 'Filters:<ul>' + activeFilters + '</ul>';
    
    let index = 0;
    let data = await query.execute();
    facts = undefined;
    numUniques = {};
    buildFacts(fields, data);

    if(Object.keys(data).length == 0 && index == 0) {
        document.querySelector('#chart_numReponses').innerHTML = 'No responses';
        document.querySelector('#charts').style.visibility = 'hidden';
    }
    else {
        document.querySelector('#chart_numReponses').innerHTML = '';
        document.querySelector('#charts').style.visibility = 'visible';
    	initCharts(fields);
    }
    
    document.querySelector('#chart_title').innerHTML = chartTitle;
    updateTitle(`${chartTitle} Responses`);
}

function isSearchingDeleted(searchObj) {
    // check if the user explicitly wants to find deleted requests
    var t = searchObj.getLeafFormQuery().getQuery();
    var searchDeleted = false;
    for(let i in t.terms) {
        if(t.terms[i].id === 'stepID'
            && t.terms[i].match === 'deleted'
            && t.terms[i].operator === '=') {

            return true;
        }
    }
    return false;
}

async function main() {
    document.querySelector('title').innerText = 'Data Visualizer';
	let params = new URLSearchParams(document.location.search);
    let categoryID = '';
    if(params.get('form') != null) {
        categoryID = params.get('form');
    }
    
	var userQuery = {};
    if(params.get('query') != null) {
        userQuery = JSON.parse(LZString.decompressFromBase64(params.get('query')));
        for(let i in userQuery.terms) {
            if(userQuery.terms[i].id == 'categoryID'
              && userQuery.terms[i].operator == '=') {
                categoryID = userQuery.terms[i].match;
            }
        }
    }
    
    let form = await fetch(`api/form/_${categoryID}`)
    	.then(res => res.json());

    if(form.length == 0 || typeof form != 'object') {
        selectForm();
        return;
    }
    
    document.querySelector('#actionBar').style.display = 'inline';
    
    getFields(form);
    
    await fetch('api/formStack/categoryList/all')
    	.then(res => res.json())
    	.then(data => {
    	data.forEach(form => {
            if(categoryID == form.categoryID) {
                chartTitle = form.categoryName;
            }
        });
    });

    let dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    dialog_message.setContent('<div id="searchContainer"></div>');
    dialog_message.clearDialog = function(){};

    // setup advanced filter options
    var leafSearch = new LeafFormSearch('searchContainer');
    leafSearch.setOrgchartPath('<!--{$orgchartPath}-->');
    leafSearch.setSearchFunc(txt => {
        if(txt != '*' && txt != '') {
            userQuery.terms = JSON.parse(txt);
        	getDataBuildCharts(categoryID, JSON.stringify(userQuery));
            dialog_message.hide();
        }
    });
    leafSearch.search('');
    leafSearch.init();

    if(userQuery.terms == undefined) {
        getDataBuildCharts(categoryID);
    } else {
        getDataBuildCharts(categoryID, JSON.stringify(userQuery));
        
        // We usually don't want to see deleted requests, but this parameter still needs to be
        // passed into the API. To simplify the user interface, the parameter is removed before
        // rendering the view. Explicit searches for deleted requests are not affected.
        if(!isSearchingDeleted(leafSearch)) {
            for(let i in userQuery.terms) {
                if(userQuery.terms[i].id == 'deleted'
                   && userQuery.terms[i].operator == '='
                   && parseInt(userQuery.terms[i].match) == 0) {
                    userQuery.terms.splice(i, 1);
                }
            }
        }
        leafSearch.renderPreviousAdvancedSearch(userQuery.terms);
    }
    
    document.querySelector('#btn_addFilter').addEventListener('click', function() {
    	dialog_message.show();
        document.querySelector('#' + leafSearch.getPrefixID() + 'advancedSearchButton').click();
    });
    
}

document.addEventListener('DOMContentLoaded', main);
</script>

<div>
	<div style="float: right">
        <div id="activeFilters"></div>
        <div id="actionBar">
            <button id="btn_addFilter" class="buttonNorm">Edit Filter</button>
            <button class="buttonNorm" onclick="dc.filterAll('main'); dc.renderAll('main');">Reset Charts</button>
            <button class="buttonNorm" onclick="selectForm();">Change Type</button>
            <button class="buttonNorm" onclick="exportData();">Export</button>
        </div>
    </div>
    <h1 id="chart_title">Loading...</h1>
    <h2 id="chart_numReponses"></h2>
    <br style="clear: both" />
</div><br style="clear: both" />
<div id="charts"></div>
<div id="suggestions"></div>

<!--{include file="site_elements/generic_dialog.tpl"}-->
