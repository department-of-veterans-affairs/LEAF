<!--{if $empMembership['groupID'][1]}-->
<style>
li {
    padding: 8px;
}
</style>
<div id="loadingIndicator"><h1>Loading...</h1></div>
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
                $('#outputLog').val($('#outputLog').val() + res);
                $('#test').attr('disabled', false);
                $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
            }
        });
    });

    $('#test').on('click', function() {
        $.ajax({
            url: sites[0] + 'utils/LEAF_importStandardConfig.php',
            dataType: 'text',
            success: function(res) {
                $('#outputLog').val($('#outputLog').val() + "\r\nDistributing to test site..." + res);
                $('#distribute').attr('disabled', false);
                $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
            }
        });
    });

    $('#distribute').on('click', function() {
        for(var i in sites) {
            $.ajax({
                url: sites[i] + 'utils/LEAF_importStandardConfig.php',
                dataType: 'text',
                async: false,
                success: function(res) {
                    $('#outputLog').val($('#outputLog').val() + "\r\nDistributing to all sites..." + res);
                    $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
                    if(res.indexOf('ERROR') == -1) {
                        $('#prodStatus').append('Pushed to ' + sites[i] + '.<br />');
                    }
                    else {
                        $('#prodStatus').append('Error Pushing to ' + sites[i]);
                    }
                    
                },
                error: function(xhr, error, errorThrown) {
                    $('#prodStatus').append('Error Pushing to ' + sites[i] + ' ('+ errorThrown +'). ');
                }
            });
        }
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
            sites.forEach(function(site, i) {
                site = site.trim();
                sites[i] = site.trim();
                $.ajax({
                    type: 'GET',
                    url: site + 'api/form/version',
                    success: function() {
                        sitesLoaded++;
                    },
                    error: function(xhr, status, errMsg) {
                        sitesLoaded++;
                        siteErrors++;
                        $('#errors').append('<span style="font-size: 140%; color: red">Error. ' + errMsg + ': '+ site + '</span><br />');
                    },
                    cache: false
                });
            });

            $('#testURL').html(sites[0]);
            $('#testURL').attr('href', sites[0]);
            var checkLoaded = setInterval(function() {
                if(sitesLoaded == sites.length) {
                    clearInterval(checkLoaded);
                    $('#loadingIndicator').slideUp();
                    if(siteErrors == 0) {
                        $('#ui_container').fadeIn();
                    }
                }
            }, 500);
        }
    });
});

</script>

<!--{else}-->
<h1>Admin access required</h1>
<!--{/if}-->