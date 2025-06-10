<style>
    section {
        width: 100%;
        border: 1px solid black;
        align-self: flex-start;
        background-color: white;
        box-shadow: 1px 1px 5px rgba(0,0,25, 0.5);
    }
    @media only screen and (max-width: 800px) {
        form {
            flex-direction: column;
        }
        section {
            width: 100%;
            margin-bottom: 1rem;
        }
    }
</style>

<script type="text/javascript">
function updateChosenAttributes(selectID = "", labelID = "", title = "List Selection") {
    $(`#${selectID}_chosen input.chosen-search-input`).attr('role', 'combobox');
    $(`#${selectID}_chosen input.chosen-search-input`).attr('aria-labelledby', labelID);
    $(`#${selectID}-chosen-search-results`).attr('title', title);
    $(`#${selectID}-chosen-search-results`).attr('role', 'listbox');
}
function updateSelectionStatus(selectEl = null, statusID = "") {
    if(selectEl !== null && statusID !== "") {
        const statusEl = document.getElementById(statusID);
        const textVal = selectEl.querySelector(`option[value="${selectEl?.value}"]`)?.innerText || "";
        if(statusEl !== null && textVal !== "") {
            statusEl.setAttribute('aria-label', `${textVal} is selected`);
        }
    }
}
function checkForm() {
    <!--{if count($services) != 0}-->
    if($("#service").val() == "") {
        alert('Service must not be blank in Step 1.');
        return false;
    }
    <!--{/if}-->
    if($("#title").val() == "") {
        alert('Title must not be blank in Step 1.');
        return false;
    }
    if($(".ischecked").is(':checked') == false) {
        alert('You must select at least one type of resource in Step 2.');
        return false;
    }
    return true;
}

$(function() {
    <!--{if count($services) != 0}-->
    $('#service').chosen({width: "90%"});
    updateChosenAttributes("service","service_label","Select Service");
    <!--{/if}-->
    $('#priority').chosen({disable_search_threshold: 5, width: "90%"});
    updateChosenAttributes("priority","priority_label","Select Priority");

    $('#record').on('submit', function() {
        if(checkForm() == true) {
            return true;
        }
        else {
            return false;
        }
    });
    document.querySelector(`button[type="submit"]`).removeAttribute('disabled');

    // comment out to allow more than one form to be submitted simultaneously
    $('.ischecked').on('change', function() {
        $('.ischecked').prop('checked', false);
        $(this).prop('checked', true);
    });
});

</script>

<div style="padding: 1rem;">
    <header style="border: 2px dotted black; padding: 0.5rem; margin-bottom: 1rem;">
        <h2 style="margin: 0 0 0.5rem 0;">Welcome, <b><!--{$recorder|sanitize}--></b>, to the <!--{$city|sanitize}--> request website.</h2>
        After clicking "proceed", you will be presented with a series of request related questions. Incomplete requests may result
        in delays. Upon completion of the request, you will be given an opportunity to print the submission.
    </header>
    <form id="record" style="display: flex;" method="post" action="ajaxIndex.php?a=newform">
        <section style="margin-right: 1rem;">
            <h3 style="background-color: black; color: white; margin: 0; padding: 0.3rem 0.5rem; font-size: 22px;">Step 1 - General Information</h3>
            <table id="step1_questions" style="width: 100%; margin: 0; padding: 1rem 0.5rem">
                <tr>
                    <td>Contact Info</td>
                    <td><input id="recorder" aria-label="auto populated requestor username" type="text" value="<!--{$recorder|sanitize}-->" disabled="disabled"/> <input id="phone" type="text" aria-label="auto populated requestor phone" value="<!--{$phone|sanitize}-->" disabled="disabled" /></td>
                </tr>
                <!--{if count($services) != 0}-->
                <tr>
                    <td><label id="service_label" for="service">Service</label></td>
                    <td>
                        <span id="service_select_status" role="status" aria-live="polite" aria-label="" style="position:absolute"></span>
                        <select id="service" name="service" title="Select Service" onchange="updateSelectionStatus(this, 'service_select_status')">
                        <option value=""></option>
                        <!--{foreach from=$services item=service}-->
                        <option value="<!--{$service.serviceID|strip_tags}-->"<!--{if $selectedService == $service}-->selected="selected"<!--{/if}-->><!--{$service.service|sanitize}--></option>
                        <!--{/foreach}-->
                        </select>
                    </td>
                </tr>
                <!--{else}-->
                <input type="hidden" id="service" name="service" value="0" />
                <!--{/if}-->
                <tr>
                    <td><label id="priority_label" for="priority">Priority</label></td>
                    <td>
                        <span id="priority_select_status" role="status" aria-live="polite" aria-label="" style="position:absolute"></span>
                        <select id="priority" name="priority" title="Select Priority" onchange="updateSelectionStatus(this, 'priority_select_status')">
                        <option value="-10">EMERGENCY</option>
                        <option value="0" selected>Normal</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td><label for="title">Title of Request</label></td>
                    <td>
                        <span>Please enter keywords to describe this request.</span><br />
                        <input class="input" id="title" type="text" name="title" maxlength="100" style="width: 90%" />
                    </td>
                </tr>
            </table>
        </section>
        <section>
            <h3 style="background-color: black; color: white; margin: 0; padding: 0.3rem 0.5rem; font-size: 22px;">Step 2 - Select type of request</h3>
            <div style="padding: 0.5rem">
                <input type="hidden" id="CSRFToken" name="CSRFToken" value="<!--{$CSRFToken}-->" />
                <!--{if count($categories) > 0}-->
                    <div tabIndex="0" style="color:black; padding: 0.1rem 0 0.5rem;"><b>Select a form using the checkboxes below</b></div>
                    <!--{foreach from=$categories item=category}-->
                        <label class="checkable leaf_check" style="float: none" for="num<!--{$category.categoryID|strip_tags}-->">
                            <input name="num<!--{$category.categoryID|strip_tags|escape}-->" type="checkbox" class="ischecked leaf_check" id="num<!--{$category.categoryID|strip_tags}-->" <!--{if $category.disabled == 1}-->disabled="disabled" <!--{/if}--> />
                            <span class="leaf_check"></span><!--{$category.categoryName|sanitize}-->
                            <!--{if $category.categoryDescription != ''}-->
                                &nbsp;(<!--{$category.categoryDescription|sanitize}-->)
                            <!--{/if}-->
                        </label>
                        <hr />
                    <!--{/foreach}-->
                <!--{else}-->
                    <span tabindex="0" style="color: #d00;">Your forms must have an associated workflow before they can be selected here.<br /><br />
                        Open the Form Editor, select your form, and click on "Edit Properties" to set a workflow.</span>
                <!--{/if}-->

                <button class="buttonNorm" type="submit" style="display: block; margin-top: 0.75rem; margin-left:auto" disabled>
                    <img src="dynicons/?img=go-next.svg&amp;w=30" alt="" />Click here to Proceed&nbsp;
                </button>
            </div>



        </section>

    </form>
</div>
