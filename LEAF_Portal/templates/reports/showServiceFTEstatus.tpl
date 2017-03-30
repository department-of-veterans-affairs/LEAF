<script>
var CSRFToken = '<!--{$CSRFToken}-->';
function invertTable() {
    $("table").each(function() {
        var $this = $(this);
        var newrows = [];
        $this.find("tr").each(function(){
            var i = 0;
            $(this).find("td").each(function(){
                i++;
                if(newrows[i] === undefined) { newrows[i] = $("<tr></tr>"); }
                newrows[i].append($(this));
            });
        });
        $this.find("tr").remove();
        $.each(newrows, function(){
            $this.append(this);
        });
    });
}

function getFTEs(serviceID) {
	var query = new LeafFormQuery();
	if(serviceID != 0) {
    	query.addTerm('serviceID', '=', serviceID);
    }
	query.addTerm('deleted', '=', 0);
	query.addTerm('submitted', '>', 0);
	query.addTerm('categoryID', 'RIGHT JOIN', 'fte');
	query.join('service');
	query.onSuccess(function(res) {
        var recordIDs = '';
        for (var i in res) {
            recordIDs += res[i].recordID + ',';
        }

        var formGrid = new LeafFormGrid('grid');
        formGrid.enableToolbar();
        formGrid.hideIndex();
        formGrid.setDataBlob(res);
        formGrid.setHeaders([
                            {name: 'PMC', indicatorID: 'pmc', editable: false, callback: function(data, blob) {
                                $('#'+data.cellContainerID).html('<a href="index.php?a=printview&recordID='+ data.recordID +'">' + data.recordID + '</a>');
                            }},
                                 {name: 'ARPA Number', indicatorID: 372},
                                {name: 'WebHR ID', indicatorID: 423},
                            {name: 'Service', indicatorID: 'service', editable: false, callback: function(data, blob) {
                                $('#'+data.cellContainerID).html(blob[data.recordID].service);
                            }},
                            {name: 'Title', indicatorID: 'title', callback: function(data, blob) {
                                $('#'+data.cellContainerID).html(blob[data.recordID].title);
                                $('#'+data.cellContainerID).on('click', function() {
                                    window.open('index.php?a=printview&recordID='+data.recordID, 'LEAF', 'width=800,resizable=yes,scrollbars=yes,menubar=yes');
                                });
                            }},
                                 {name: 'Team', indicatorID: 421},
                                {name: 'HR Specialist', indicatorID: 256},
                                 {name: 'Closed-out', indicatorID: 299, callback: function(data, blob) {
                                    if(data.data == 'Yes') {
                                        $('#' + formGrid.getPrefixID() + 'tbody_tr' + data.recordID + '>td').css('background-color', '#949494');
                                    }
                                 }},
                                 {name: 'Position Title', indicatorID: 355},
                                 {name: 'ARPA Status', indicatorID: 419},
                                 {name: 'Announcement Number', indicatorID: 354},
                                {name: 'Initiative', indicatorID: 420},
                                 {name: 'Complete Recruitment Package Received in HR', indicatorID: 366},
                                 {name: 'Date of Announcement', indicatorID: 250},
                                 {name: 'Closing Date', indicatorID: 251},
                                {name: 'Date Cert. to Service', indicatorID: 252},
                                {name: 'Cert Due From Service', indicatorID: 424},
                                {name: 'Date Cert. Returned to HR', indicatorID: 253},
                                 {name: 'Tentative Job Offer Date', indicatorID: 257},
                                 {name: 'Name of Selectee', indicatorID: 255},
                                 {name: 'Date Fingerprints Taken (SAC)', indicatorID: 402},
                                 {name: 'Date Fingerprints Adjudicated (SAC)', indicatorID: 425},
                                 {name: 'Date Background Check Initiated (eQIP)', indicatorID: 403},
                                 {name: 'Date Background Check Results Adjudicated', indicatorID: 404},
                                 {name: 'Date Credentialing Started (VETPRO)', indicatorID: 405},
                                 {name: 'Date Credentialing Completed (VETPRO)', indicatorID: 406},
                                 {name: 'Date of Physical Examination', indicatorID: 411},
                                 {name: 'Date Physical Exam Cleared', indicatorID: 412},
                                 {name: 'Date Comp Panel Completed', indicatorID: 408},
                                 {name: 'Date PSB Completed', indicatorID: 410},
                                 {name: 'Classification Start Date', indicatorID: 293},
                                 {name: 'Classification End Date', indicatorID: 294},
                                 {name: 'Date of EOD', indicatorID: 328},
                                 {name: 'HR Remarks', indicatorID: 422}
                             ]);
        formGrid.loadData(recordIDs);
    });
	query.execute();
}

$(function() {
    $('#service').chosen();
    $('#service').on('change', function() {
    	getFTEs($('#service').val());
    });
    getFTEs($('#service').val());
    
    
    
    $("#invert").click(function(){
        invertTable();
    });
});

</script>
<span id="invert" class="buttonNorm">Invert Spreadsheet</span><br /><br />
<div>
  <label for="service">Service:&nbsp;</label>
  <select id="service" name="service">
  <option value=""></option>
  <option value ="0">ALL Services</option>
  <!--{foreach from=$services item=service}-->
  <option value ="<!--{$service.serviceID}-->"<!--{if $resolvedServiceID == $service.serviceID}-->selected="selected"<!--{/if}-->><!--{$service.service}--></option>
  <!--{/foreach}-->
  </select>
</div>

<div id="grid"></div>
