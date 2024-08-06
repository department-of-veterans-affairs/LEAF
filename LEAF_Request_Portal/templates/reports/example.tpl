<style>
#content {
    margin: 1rem;
}
</style>
<script>
let CSRFToken = '<!--{$CSRFToken}-->';
/*
    This is an example of how to build a spreadsheet using LEAF's Query and Grid systems.

    This will:
    	1. Create a LeafFormQuery, which simplifies code that involves queries
        2. Create a LeafFormGrid, which simplifies code that involves HTML tables
    	3. Execute the query and render results in the grid

    Once the program has been completed, it can be accessed at the website:
    	https://[your server]/[your folder]/report.php?a=example

*/
async function getData() {
    
	// Initialize a new Query
	let query = new LeafFormQuery();

    /* 
     * 1. Create a report in the Report Builder.
     * 2. Click on "JSON" and copy the line containing "query.importQuery..." here.
     *
     * For manual query building, see formQuery.js
     */
    query.importQuery({"terms":[{"id":"stepID","operator":"!=","match":"resolved","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service"],"sort":{}});

    /*
     * Optional: It's helpful to show a progress indicator for large reports
     */
    query.onProgress(numProcessed => {
        document.querySelector('#status').innerText = `Processing ${numProcessed}+ records`;
    });

	// Execute the query
	let data  = await query.execute();

    // Optional: Show how many records were retrieved
    document.querySelector('#status').innerText = `${Object.keys(data).length} records`;

    // Initialize a new Grid
    let formGrid = new LeafFormGrid('grid'); // 'grid' maps to the associated HTML element ID

    // This enables the Export button
    formGrid.enableToolbar();

    // Provide data from the query to the grid
    formGrid.setDataBlob(data);

    /*
     * Configure headers and columns
     *
     * Additonal configuration examples can be found in the view_reports template, see "function addHeader"
     */
    formGrid.setHeaders([
        {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[data.recordID].service);
        }},
        {name: 'Title', indicatorID: 'title', callback: function(data, blob) { // The Title field is a bit unique, and must be implemnted this way
            $('#'+data.cellContainerID).html(blob[data.recordID].title);
            $('#'+data.cellContainerID).on('click', function() {
                window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
            });
        }},

        // Data fields within forms can use a simplifed syntax
        {name: 'HR Specialist', indicatorID: 111},
        {name: 'Closed-out', editable: false, indicatorID: 222},
        {name: 'Position Title', indicatorID: 333}
    ]);

    // Optional: The spreadsheet can be pre-sorted based on the indicatorID registered above. The "recordID" indicatorID is built in.
    formGrid.sort('recordID', 'desc');

    // Render the spreadsheet
    formGrid.renderBody();
}

async function main() {
    // Setting the title makes links look nicer when shared in Teams or Outlook
    document.querySelector('title').innerText = 'Example Report';

    getData();

}

// Ensures the webpage has fully loaded before starting the program.
document.addEventListener('DOMContentLoaded', main);
</script>

<h1>Example Report</h1>

<div id="status"></div>
<div id="grid"></div>
