<h1>Export PDL Options</h1>
<div id="maincontent">

    <a href="./utils/exportPDL.php">
        <span class="menuButtonSmall" style="background-color: black">
            <img class="menuIconSmall" src="dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" alt=""  />
            <span class="menuTextSmall" style="color: white">Export PDL (CSV)</span><br />
            <span class="menuDescSmall" style="color: white">Download the Position Description List</span>
        </span>
    </a>

    <a href="api/export/pdl">
        <span class="menuButtonSmall" style="background-color: black">
            <img class="menuIconSmall" src="dynicons/?img=x-office-spreadsheet.svg&amp;w=76" style="position: relative" alt=""  />
            <span class="menuTextSmall" style="color: white">Export PDL (JSON)</span><br />
            <span class="menuDescSmall" style="color: white">Download the Position Description List</span>
        </span>
    </a>

    <br style="clear: both" /><br />
    <p>
        Data Link for PowerBI / Excel / etc.: <input id="compatLink" value="Loading..." style="width: 50%"></input>
        <button id="copy" class="buttonNorm">Copy to Clipboard</button> <span id="copyStatus" style="display: none; background-color:green; padding:5px 5px; color:white;"></span>
    </p>
</div>

<script>

function main() {

    // Generate compat link
    let powerQueryURL = "<!--{$powerQueryURL}-->";
    let compatLink = powerQueryURL + window.location.pathname.replace('report.php', '') + 'api/export/pdl';
    document.querySelector('#compatLink').value = compatLink;

    document.querySelector('#copy').addEventListener('click', () => {
        let selection = window.getSelection();
        let range = document.createRange();
        range.selectNodeContents(document.querySelector('#compatLink'));
        selection.removeAllRanges();
        selection.addRange(range);

        navigator.clipboard.writeText(selection.focusNode.value);
        $("#copyStatus").show().text("Copied!");
        $("#copyStatus").fadeOut(3000);
    });
}

document.addEventListener('DOMContentLoaded', main);
</script>