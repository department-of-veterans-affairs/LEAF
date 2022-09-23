export default {
    props: {
        indicator: Object
    },
    inject: [
        'orgchartPath',
        'addOrgSelector',
        'orgSelectorClassesAdded'     //JS classes for orgchart formats
    ],
    computed: {
        truncatedOptions() {
            return this.indicator.options?.slice(0, 5) || [];
        },
        baseFormat() {
            return this.indicator.format?.toLowerCase()?.trim() || '';
        },
        inputElID() {
            return `input_preview_${this.indicator.indicatorID}`;
        },
        selectorInputPrefix() {
            return this.baseFormat === 'orgchart_group' ? 'group#' : '#';
        },
        selType() {
            return this.baseFormat.slice(this.baseFormat.indexOf('_') + 1);
        }
    },
    mounted() {
        switch(this.baseFormat) {
            case 'date': 
                $('#date_prev_' + this.indicator.indicatorID).datepicker({
                    autoHide: true,
                    showAnim: "slideDown",
                    onSelect: ()=> {
                        $('#' + this.indicator.indicatorID + '_focusfix').focus();
                    }
                });
                break;
            case 'dropdown':
                $('#drop_prev_' + this.indicator.indicatorID).chosen({
                    disable_search_threshold: 5, 
                    allow_single_deselect: true, 
                    width: '50%'
                });
                break;
            case 'multiselect':
                const elSelect = document.getElementById(this.inputElID);
                if (elSelect !== null && elSelect.multiple === true && elSelect.getAttribute('data-choice') !== 'active') {

                    let options = this.indicator.options || [];
                    options = options.map(o =>({
                        value: o,
                        label: o,
                        selected: false
                    }));
                    const choices = new Choices(elSelect, {
                        allowHTML: false,
                        removeItemButton: true,
                        editItems: true,
                        choices: options.filter(o => o.value !== "")
                    });
                    elSelect.choicesjs = choices;
                    elSelect.addEventListener('change', ()=> {
                        let elEmptyOption = document.getElementById(`${this.indicator.indicatorID}_empty_value`);
                        if (elEmptyOption === null) {
                            let opt = document.createElement('option');
                            opt.id = `${this.indicator.indicatorID}_empty_value`;
                            opt.value = "";
                            elSelect.appendChild(opt);
                            elEmptyOption = document.getElementById(`${this.indicator.indicatorID}_empty_value`);
                        }
                        elEmptyOption.selected = elSelect.value === '';
                    });
                }
                break;
            case 'orgchart_group':
            case 'orgchart_position':
            case 'orgchart_employee':
                if(this.orgSelectorClassesAdded[this.selType]===false) {
                    console.log(`get and track addition of ${this.selType} class and styles`);
                    $('head').append(`<link type="text/css" rel="stylesheet" href="${this.orgchartPath}/css/${this.selType}Selector.css" />`);

                    $.ajax({
                        type: 'GET',
                        url: `${this.orgchartPath}/js/${this.selType}Selector.js`,
                        dataType: 'script',
                        success: ()=> {
                            this.addOrgSelector(this.selType, true);
                            this.createOrgSelector();
                        }
                    });

                } else {
                    console.log("already fetched");
                    this.createOrgSelector();
                }
                
                break;
            default: break;
        
        }
    },
    methods: {
        useAdvancedEditor() {
            $('#' + this.inputElID).trumbowyg({
                btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'justifyLeft', 'justifyCenter', 'justifyRight', 'fullscreen']
            });
            $(`#textarea_format_button_${this.indicator.indicatorID}`).css('display', 'none');
        },
        createOrgSelector() {
            let orgSelector = {};
            if (this.selType==='group') {
                orgSelector = new groupSelector(`orgSel_${this.indicator.indicatorID}`);
            } else if (this.selType==='position') {
                orgSelector = new positionSelector(`orgSel_${this.indicator.indicatorID}`);
            } else {
                orgSelector = new employeeSelector(`orgSel_${this.indicator.indicatorID}`);
            }
            orgSelector.apiPath = `${this.orgchartPath}/api/`;
            orgSelector.rootPath = `${this.orgchartPath}/`;
            orgSelector.basePath = `${this.orgchartPath}/`;
            orgSelector.setSelectHandler(()=> {
                $(`#sel_prev_${this.indicator.indicatorID}`).val(orgSelector.selection);
                $(`#orgSel_${this.indicator.indicatorID} input.${this.selType}SelectorInput`).val(`${this.selectorInputPrefix}` + orgSelector.selection);
            });
            if(orgSelector.enableEmployeeSearch !== undefined) orgSelector.enableEmployeeSearch();
            orgSelector.initialize();
        }
    },
    template: `<div class="format-preview">

        <input v-if="baseFormat==='text'" :id="inputElID" type="text" class="text_input_preview"/>
        <input v-if="baseFormat==='number'" :id="inputElID" type="number" class="text_input_preview"/>

        <template v-if="baseFormat==='currency'">
            $&nbsp;<input :id="inputElID" type="number" min="0.00" step="0.01" class="text_input_preview"/>
        </template>

        <template v-if="baseFormat==='textarea'">
            <textarea :id="inputElID" rows="10" class="textarea_input_preview"></textarea>
            <div :id="'textarea_format_button_' + indicator.indicatorID" 
                @click="useAdvancedEditor" 
                style="text-align: right; font-size: 12px"><span class="link">formatting options</span>
            </div>
        </template>

        <template v-if="baseFormat==='radio'">
            <template v-for="o, i in truncatedOptions" :key="'radio_prev_' + indicator.indicatorID + '_' + i">
                <label class="checkable leaf_check" :for="inputElID + '_radio' + i">
                    <input type="radio" :id="inputElID + '_radio' + i" :name="indicator.indicatorID" class="icheck leaf_check"  />
                    <span class="leaf_check"></span>{{ o }}
                </label>
            </template>
            <div v-if="indicator?.options?.length > 5" style="padding-left: 0.4em"><b> ...</b></div>
        </template>

        <template v-if="baseFormat==='checkboxes' || baseFormat==='checkbox'">
            <template v-for="o, i in truncatedOptions" :key="'check_prev_' + indicator.indicatorID + '_' + i">
                <label class="checkable leaf_check" :for="inputElID + '_check' + i">
                    <input type="checkbox" :id="inputElID + '_check' + i" :name="indicator.indicatorID" class="icheck leaf_check"  />
                    <span class="leaf_check"></span>{{ o }}
                </label>
            </template>
            <div v-if="indicator?.options?.length > 5" style="padding-left: 0.4em"><b> ...</b></div>
        </template>
        
        <fieldset v-if="baseFormat==='fileupload' || baseFormat==='image'" 
            style="padding: 0.5em;"><legend>File Attachment(s)</legend>
            <p style="margin-bottom: 0.5em;">Select File to attach:</p>
            <input :id="inputElID" name="formPacket" type="file" />
        </fieldset>

        <template v-if="baseFormat==='date'">
            <input type="text" :id="inputElID" 
            style="background: url(../../libs/dynicons/?img=office-calendar.svg&w=16); background-repeat: no-repeat; background-position: 4px center; padding-left: 24px; font-size: 1.3em; font-family: monospace" value="" />
            <input class="ui-helper-hidden-accessible" :id="indicator.indicatorID + '_focusfix'" type="text" />
        </template>

        
        <select v-if="baseFormat==='dropdown'" :id="inputElID" style="width: 50%">
            <option v-for="o, i in truncatedOptions" :key="'drop_prev_' + indicator.indicatorID + '_' + i">
            {{o}}
            </option>
            <option v-if="indicator?.options?.length > 5" style="padding-left: 0.4em" disabled>(preview showing first 5)</option>
        </select>
        
        <select v-if="baseFormat==='multiselect'" multiple 
            :id="inputElID">
            :name="'multi_prev_' + indicator.indicatorID + '_multiselect[]'"
            style="display:none">
        </select>
        
        <template  v-if="baseFormat==='orgchart_group' || baseFormat==='orgchart_position' || baseFormat==='orgchart_employee'">
            <div :id="'orgSel_' + indicator.indicatorID" style="min-height:30px"></div>
            <input :id="'sel_prev_' + indicator.indicatorID" style="display: none;">
        </template>
        

    </div>`
}