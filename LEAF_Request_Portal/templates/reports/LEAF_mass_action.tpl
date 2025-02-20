<style>
    div#massActionContainer {
        width: 800px;
        margin: auto;
    }
    #searchRequestsContainer, #searchResults, #errorMessage, #iconBusy {
        display: none;
    }
    #actionContainer {
        padding-bottom: 5px;
    }
    #iconBusy{
        height: 20px;
    }
    table#requests {
        border-collapse: collapse;
    }
    table#requests th {
        text-align: center;
        border: 1px solid black;
        padding: 4px 2px;
        font-size: 12px;
        background-color: rgb(209, 223, 255);
    }
    table#requests td {
        border: 1px solid black;
        padding: 8px;
        font-size: 12px;
    }
    .buttonNorm.takeAction, .buttonNorm.buttonDaySearch {
        text-align: center;
        font-weight: bold;
        white-space: normal
    }
    #comment_required {
        transition: all 0.5s ease;
        color: #c00;
        font-weight: bolder;
    }
    #comment_required.attention {
        color: #fff;
        background-color: #c00;
    }
</style>
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script id="mass-action-js" src="./js/pages/mass_action.js"
        data-token="<!--{$CSRFToken}-->"
        data-orgChartPath="<!--{$orgchartPath}-->"
        data-jsPath="<!--{$app_js_path}-->"
        type="text/javascript"></script>

<div id="massActionContainer">
    <h1>Mass Action</h1>
    <div id="actionContainer">
        <label for="action"> Choose Action </label>
        <select id="action" name="action">
            <option value="">-Select-</option>
            <option value="cancel">Cancel</option>
            <option value="restore">Restore</option>
            <option value="submit">Submit</option>
            <option value="email">Email Reminder</option>
        </select>
        <div id="comment_cancel_container" style="display:none;margin:0.75rem 0;">
            <label for="comment_cancel">Comment for cancel <span id="comment_required">* required</span></label>
            <textarea id="comment_cancel" rows="4" style="display:block;resize:vertical;width:530px;margin-top:2px"></textarea>
        </div>
    </div>

    <div id="searchRequestsContainer"></div>

    <div id="emailSection">
        <label for="lastAction">Days Since Last Action</label>
        <input type="number" id="lastAction" name="lastAction" value="7" maxlength="3" />
        <button class="buttonNorm buttonDaySearch" id="submitSearchByDays">Search Requests</button>
    </div>

    <img id="iconBusy" src="./images/indicator.gif" class="employeeSelectorIcon" alt="busy" />
    <div id="searchResults">
        <button class="buttonNorm takeAction" style="text-align: center; font-weight: bold; white-space: normal">Take Action</button>
        <div class="progress"></div>
        <table id="requests">
            <tr id="headerRow">
                <th>UID</th>
                <th>Type</th>
                <th>Service</th>
                <th>Title</th>
                <th><input type="checkbox" name="selectAllRequests" id="selectAllRequests" value=""></th>
            </tr>
        </table>
        <button class="buttonNorm takeAction" style="text-align: center; font-weight: bold; white-space: normal">Take Action</button>
    </div>
    <div class="progress"></div>
    <div id="errorMessage"></div>
</div>
<script>
$(document).ready(function () {
    document.querySelector('title').innerText = 'Mass Actions - <!--{$title}-->';
});
</script>