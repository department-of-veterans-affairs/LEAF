<?php
/* Smarty version 3.1.33, created on 2021-08-16 15:33:39
  from '/var/www/html/LEAF_Request_Portal/templates/reports/LEAF_mass_action.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.33',
  'unifunc' => 'content_611a8553ca11f3_35994976',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '2b8d42c54fec53f8f6d89ce1cc50f49984cd8433' => 
    array (
      0 => '/var/www/html/LEAF_Request_Portal/templates/reports/LEAF_mass_action.tpl',
      1 => 1626357613,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
    'file:site_elements/generic_confirm_xhrDialog.tpl' => 1,
  ),
),false)) {
function content_611a8553ca11f3_35994976 (Smarty_Internal_Template $_smarty_tpl) {
?><style>
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
</style>
<?php $_smarty_tpl->_subTemplateRender("file:site_elements/generic_confirm_xhrDialog.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0, false);
echo '<script'; ?>
 id="mass-action-js" src="./js/pages/mass_action.js" data-token="<?php echo $_smarty_tpl->tpl_vars['CSRFToken']->value;?>
" type="text/javascript"><?php echo '</script'; ?>
>

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

    <div id="searchRequestsContainer"></div>

    <div id="emailSection">
        <label for="lastAction">Days Since Last Action</label>
        <input type="number" id="lastAction" name="lastAction" value="7" maxlength="3" />
        <button class="buttonNorm buttonDaySearch" id="submitSearchByDays">Search Requests</button>
    </div>

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
</div><?php }
}
