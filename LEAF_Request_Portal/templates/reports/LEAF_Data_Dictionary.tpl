<style>
#content {
    margin: 1rem;
}
</style>
<script>
async function getData() {

    let indicators = await fetch('api/form/indicator/list').then(res => res.json());

    // Initialize the Grid
    let formGrid = new LeafFormGrid('grid'); // 'grid' maps to the associated HTML element ID

    formGrid.enableToolbar();
    formGrid.hideIndex();

    // Required to initialize data for the grid
    formGrid.setData(Object.keys(indicators).map(key => {
        indicators[key].recordID = key; // formGrid expects there to be a recordID property that contains unique integers
        return indicators[key];
    }));
    formGrid.setDataBlob(indicators);

    // The column headers are configured here
    formGrid.setHeaders([
        {name: 'Field ID', indicatorID: 'indicatorID', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[data.recordID].indicatorID);
        }},
        {name: 'Form ID', indicatorID: 'categoryID', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[data.recordID].categoryID);
        }},
        {name: 'Form Name', indicatorID: 'categoryName', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[data.recordID].categoryName);
        }},
        {name: 'Format', indicatorID: 'format', editable: false, callback: function(data, blob) {
            let rawFormat = blob[data.recordID].format;
            let format = rawFormat.split("\n")[0];
            $('#'+data.cellContainerID).html(format);
        }},
		{name: 'Short Label', indicatorID: 'label', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[data.recordID].description);
        }},
        {name: 'Name', indicatorID: 'name', editable: false, callback: function(data, blob) {
            $('#'+data.cellContainerID).html(blob[data.recordID].name);
        }},
    ]);

    // Load and populate the spreadsheet
    formGrid.sort('indicatorID', 'asc');
    formGrid.renderBody();
}

async function main() {
    document.querySelector('title').innerText = 'Data Dictionary';
    getData();

}

// Ensures the webpage has fully loaded before starting the program.
document.addEventListener('DOMContentLoaded', main);
</script>

<h1>Data Dictionary</h1>
<p>API endpoints: <a href="api/form/indicator/list" target="_blank">JSON</a> | <a href="api/form/indicator/list?format=csv" target="_blank">CSV</a> | <a href="api/form/indicator/list?format=htmltable&sort=indicatorID" target="_blank">HTML</a></p>
<div id="grid"></div>
