<!--{if $empMembership['groupID'][1]}-->
<script src="<!--{$app_js_path}-->/LEAF/intervalQueue.js"></script>
<style>
li {
    padding: 8px;
}
</style>
<div id="loadingIndicator"><h1>Loading...</h1>
    <h2 id="loadingStatus"></h2>
</div>
<div id="errors"></div>
<div id="ui_container" style="display: none">
    <h2>
        This utility is used to deploy nationally standardized changes to associated LEAF sites.
    </h2>

    <ol>
        <li><button id="prepare">Prepare Package</button></li>
        <li><button id="test" disabled="disabled">Distribute Package to Test site</button>
            <br />Test site: <a id="testURL" href="#" target="_blank">Loading link...</a>
        </li>
        <li><button id="distribute" disabled="disabled">Distribute Package to Production sites</button><div id="prodStatus"></div></li>
    </ol>

    Server Log (please copy/paste and save this after running all steps):<br />
    <textarea id="outputLog" rows='20' cols='80'></textarea>
</div>
<script>

var sites;
$(function() {

    $('#prepare').on('click', function() {
        $.ajax({
            url: './utils/LEAF_exportStandardConfig.php',
            dataType: 'text',
            success: function(res) {
                $('#outputLog').val($('#outputLog').val() + res + '... Done.');
                $('#test').attr('disabled', false);
                $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
            }
        });
    });

    $('#test').on('click', function() {
        $('#outputLog').val($('#outputLog').val() + "\r\nDistributing to test site...");
        $.ajax({
            url: sites[0] + 'utils/LEAF_importStandardConfig.php',
            dataType: 'text',
            success: function(res) {
                $('#outputLog').val($('#outputLog').val() + "\r\nDistributed to test site.");
                $('#distribute').attr('disabled', false);
                $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
            }
        });
    });

    $('#distribute').on('click', function() {
        let totalCount = 0;
        let currCount = 0;
        let queue = new intervalQueue();
        queue.setConcurrency(3);
        queue.setWorker(function(item) {
            return $.ajax({
                url: item + 'utils/LEAF_importStandardConfig.php',
                dataType: 'text',
                success: function(res) {
                    currCount++;
                    if(res.indexOf('ERROR') == -1) {
                        $('#prodStatus').append(`${currCount} of ${totalCount} - Pushed to ` + item + '.<br />');
                    }
                    else {
                        $('#prodStatus').append('Error Pushing to ' + item);
                    }

                },
                error: function(xhr, error, errorThrown) {
                    $('#prodStatus').append('Error Pushing to ' + item + ' ('+ errorThrown +'). ');
                }
            });
        });

        queue.setOnWorkerError(function(item, reason) { // Errors can be logged here
            console.log(`Error processing: ${item}`);
        });

        queue.onComplete(function() {
            return 'Complete';
        });

        for(var i in sites) {
            queue.push(sites[i]);
            totalCount++;
        }

    	queue.start().then(function() {
			$('#outputLog').val($('#outputLog').val() + "\r\nDistribution complete!");
            $('#prodStatus').append('Distribution complete!<br />');
        });
        $('#outputLog').val($('#outputLog').val() + "\r\nDistributing to all sites...");
        $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
    });


    var sitesLoaded = 0;
    var siteErrors = 0;
    $.ajax({
        type: 'GET',
        url: './api/system/settings',
        cache: false
    })
    .then(function(res) {
        if(res.siteType != 'national_primary') {
            $('#ui_container').html('<h1>This site is not configured as a primary national distribution site.</h1>');
            $('#loadingIndicator').slideUp();
            $('#ui_container').fadeIn();
        }
        else {
            sites = res.national_linkedSubordinateList.split(/\n/).filter(function(site) {
                return site != "" ? true : false;
            });

			let queue = new intervalQueue();
            queue.setConcurrency(3);
            queue.setWorker(function(site) {
               return $.ajax({
                    type: 'GET',
                    url: site + 'api/form/version',
                    error: function(xhr, status, errMsg) {
                        siteErrors++;
                        $('#errors').append('<span style="font-size: 140%; color: red">Error. ' + errMsg + ': '+ site + '</span><br />');
                    },
                    cache: false
                }).then(function() {
					$('#loadingStatus').html(`Checking ${queue.getLoaded()} of ${sites.length} sites`);
               });
            });

            sites.forEach(function(site, i) {
 				queue.push(site);
            });

            queue.start().then(function() {
                $('#loadingIndicator').slideUp();
                if(siteErrors == 0) {
                    $('#ui_container').fadeIn();
                }
            });

            $('#testURL').html(sites[0]);
            $('#testURL').attr('href', sites[0]);
        }
    });
});

</script>

<!--{else}-->
<h1>Admin access required</h1>
<!--{/if}-->
