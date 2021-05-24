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
</style>
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<script id="mass-action-js" src="./js/pages/mass_action.js" data-token="<!--{$CSRFToken}-->" type="text/javascript"></script>

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
    </div>
    <div id="emailSection">
        <label for="lastAction">Time Since Last Action</label>
        <select id="lastAction" name="lastAction">
            <option value="">-- Select Time --</option>
            <option value="7">&nbsp;7+ days</option>
            <option value="14">14+ days</option>
            <option value="30">30+ days</option>
        </select>
    </div>

    <div id="searchRequestsContainer"></div>
    <img id="iconBusy" src="./images/indicator.gif" class="employeeSelectorIcon" alt="busy">
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