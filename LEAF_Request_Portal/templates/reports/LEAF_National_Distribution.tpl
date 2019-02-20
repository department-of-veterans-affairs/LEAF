<!--{if $empMembership['groupID'][1]}-->

<style>
li {
    padding: 8px;
}
</style>

<h2>
    This dashboard is used to distribute centrally maintained CCU configurations to all national CCU sites.
</h2>

<ol>
    <li><button id="prepare">Prepare Package</button></li>
    <li><button id="test" disabled="disabled">Distribute Package to Test site</button>
        <br />Test site: <a href="https://URL/NATIONAL/CCU/TEST/standard/" target="_blank">https://URL/NATIONAL/CCU/TEST/standard/</a>
    </li>
    <li><button id="distribute" disabled="disabled">Distribute Package to Production sites</button><div id="prodStatus"></div></li>
</ol>

Server Log (please copy/paste and save this somewhere after running all steps):<br />
<textarea id="outputLog" rows='20' cols='80'></textarea>

<script>

$(function() {

    $('#prepare').on('click', function() {
        $.ajax({
            url: './utils/exportStandardConfig.php',
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
            url: '../../TEST/standard/utils/importStandardConfig.php',
            dataType: 'text',
            success: function(res) {
                $('#outputLog').val($('#outputLog').val() + res);
                $('#distribute').attr('disabled', false);
                $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
            }
        });
    });

    var sites = ['VISN1/New',
                'VISN2/New',
                'VISN4/New',
                'VISN5/New',
                'VISN6/New',
                'VISN7/New',
                'VISN8/New',
                'VISN9/New',
                'VISN10/New',
                'VISN12/New',
                'VISN15/New',
                'VISN16/New',
                'VISN17/New',
                'VISN19/New',
                'VISN20/New',
                'VISN21/New',
                'VISN22/New',
                'VISN23/New',
                'WMC/NATIONAL'];

    $('#distribute').on('click', function() {
        for(var i in sites) {
            $.ajax({
                url: '../../'+ sites[i] +'/utils/importStandardConfig.php',
                dataType: 'text',
                async: false,
                success: function(res) {
                    $('#outputLog').val($('#outputLog').val() + res);
                    $('#outputLog').scrollTop($('#outputLog')[0].scrollHeight);
                    $('#prodStatus').append('Pushed to ' + sites[i] + '. ');
                },
                error: function(xhr, error, errorThrown) {
                    $('#prodStatus').append('Error Pushing to ' + sites[i] + ' ('+ errorThrown +'). ');
                }
            });
        }
    });
});

</script>

<!--{else}-->
<h1>Admin access required</h1>
<!--{/if}-->