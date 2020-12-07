<style>
/* 2 column grid */
.group:after,.section{clear:both}.section{padding:0;margin:0}.col{display:block;float:left;margin:1% 0 1% 1.6%}.col:first-child{margin-left:0}.group:after,.group:before{content:"";display:table}.group{zoom:1}.span_2_of_2{width:100%}.span_1_of_2{width:49.2%}@media only screen and (max-width:840px){.col{margin:1% 0}.span_1_of_2,.span_2_of_2{width:100%}}
</style>

<script type="text/javascript">
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
    $('#service').chosen();
    <!--{/if}-->
    $('#priority').chosen({disable_search_threshold: 5});
    <!--{foreach from=$categories item=category}-->
    $('#num<!--{$category.categoryID|strip_tags|escape}-->').icheck({checkboxClass: 'icheckbox_square-blue', radioClass: 'iradio_square-blue'});
    <!--{/foreach}-->

    $('#record').on('submit', function() {
        if(checkForm() == true) {
            return true;
        }
        else {
            return false;
        }
    });

    // comment out to allow more than one form to be submitted simultaneously
    $('.ischecked').on('change', function() {
        $('.ischecked').icheck('unchecked');
        $(this).icheck('checked');
    });
});

</script>

<form id="record" method="post" action="ajaxIndex.php?a=newform">
    <div class="item" style="text-align: left; border: 2px dotted black; padding: 5px">
        <span>Welcome, <b><!--{$recorder|sanitize}--></b>, to the <!--{$city|sanitize}--> request website.<br />
        After clicking "proceed", you will be presented with a series of request related questions. Incomplete requests may result
        in delays. Upon completion of the request, you will be given an opportunity to print the submission.</span>
    </div>


<div class="section group">
    <div class="col span_1_of_2">
    <div class="card">
        <div style="background-color: black; color: white; padding: 4px; font-size: 22px; font-weight: bold">Step 1 - General Information</div>
        <br style="clear: both"/>

        <table id="step1_questions" style="width: 100%; margin: 8px">
            <tr>
                <td>Contact Info</td>
                <td><input id="recorder" aria-label="recorder" type="text" title="" value="<!--{$recorder|sanitize}-->" disabled="disabled"/> <input id="phone" type="text" aria-label="phone" title="" value="<!--{$phone|sanitize}-->" disabled="disabled" /></td>
            </tr>
            <!--{if count($services) != 0}-->
            <tr>
                <td><label for="service">Service</label></td>
                <td>
                    <select id="service" name="service" style=" width: 150px;">
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
                <td><label for="priority">Priority</label></td>
                <td>
                    <select id="priority" name="priority" aria-label="priority" style="width: 150px;">
                    <option value="-10">EMERGENCY</option>
                    <option value="0" selected="selected">Normal</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td><label for="title">Title of Request</label></td>
                <td>
                <span style="font-size: 80%">Please enter keywords to describe this request.</span><br />
                    <input class="input" id="title" type="text" name="title" maxlength="100" style="width: 80%"></input>
                </td>
            </tr>
        </table>

        <br />

    </div>
    </div>
    <div class="col span_1_of_2">
    <div class="card">
        <div style="background-color: black; color: white; padding: 4px; font-size: 22px; font-weight: bold">Step 2 - Select type of request</div>

        <div style="text-align: left; padding: 8px"><span>
          <input type="hidden" id="CSRFToken" name="CSRFToken" value="<!--{$CSRFToken}-->" />
    <!--{foreach from=$categories item=category}-->
        <input name="num<!--{$category.categoryID|strip_tags|escape}-->" type="checkbox" class="ischecked" id="num<!--{$category.categoryID|strip_tags}-->" <!--{if $category.disabled == 1}-->disabled="disabled" <!--{/if}-->style="font-family: Courier; font-size: 24px; font-weight: bold; margin: 4px" />
        <label class="checkable" style="float: none" for="num<!--{$category.categoryID|strip_tags}-->"> <!--{$category.categoryName|sanitize}-->
            <!--{if $category.categoryDescription != ''}-->
            &nbsp;(<!--{$category.categoryDescription|sanitize}-->)
            <!--{/if}-->
        </label>
        <br />
    <!--{/foreach}-->
    <!--{if count($categories) == 0}-->
        <span style="color: red">Your forms must have an associated workflow before they can be selected here.<br /><br />Open the Form Editor, select your form, and click on "Edit Properties" to set a workflow.</span>
    <!--{/if}-->
          </span>
        </div>

        <div class="item" style="text-align: right; padding: 4px">
            <button class="buttonNorm" type="submit"><img src="../libs/dynicons/?img=go-next.svg&amp;w=32" alt="Next" /> Click here to Proceed</button>
        </div>
    </div>
    </div>
</div>

</form>
