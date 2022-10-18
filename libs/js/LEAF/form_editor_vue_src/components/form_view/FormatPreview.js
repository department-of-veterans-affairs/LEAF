export default {
    props: {
        indicator: Object
    },
    inject: [
        'orgchartPath',
        'addOrgSelector',
        'orgSelectorClassesAdded',     //JS classes for orgchart formats
        'updateGridInstances',
        'gridInstances'
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
        },
        labelSelector() {
            return this.indicator.indicatorID + '_format_label';
        },
        printResponseID() {
            return `xhrIndicator_${this.indicator.indicatorID}_${this.indicator.series}`;
        },
    },
    mounted() {
        switch(this.baseFormat) {
            case 'raw_data':
                break;
            case 'date': 
                $(`#${this.inputElID}`).datepicker({
                    autoHide: true,
                    showAnim: "slideDown",
                    onSelect: ()=> {
                        $('#' + this.indicator.indicatorID + '_focusfix').focus();
                    }
                });
                document.getElementById(this.inputElID).setAttribute('aria-labelledby', this.labelSelector);
                break;
            case 'dropdown':
                $(`#${this.inputElID}`).chosen({
                    disable_search_threshold: 5,
                    allow_single_deselect: true, 
                    width: '50%'
                });
                $(`#${this.inputElID}_chosen input.chosen-search-input`).attr('aria-labelledby', this.labelSelector);
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
                $(`#${this.inputElID} ~ input.choices__input`).attr('aria-labelledby', this.labelSelector);
                break;
            case 'orgchart_group':
            case 'orgchart_position':
            case 'orgchart_employee':
                if(this.orgSelectorClassesAdded[this.selType] === false) {
                    $('head').append(`<link type="text/css" rel="stylesheet" href="${this.orgchartPath}/css/${this.selType}Selector.css" />`);

                    $.ajax({
                        type: 'GET',
                        url: `${this.orgchartPath}/js/${this.selType}Selector.js`,
                        dataType: 'script',
                        success: ()=> {
                            this.addOrgSelector(this.selType);
                            this.createOrgSelector();
                        }
                    });

                } else {
                    console.log("already fetched");
                    this.createOrgSelector(); 
                }
                break;
            case 'grid':
                const options = JSON.parse(this.indicator.options);
                this.updateGridInstances(options, parseInt(this.indicator.indicatorID), parseInt(this.indicator.series));
                this.gridInstances[this.indicator.indicatorID].input();
                break;
            case 'checkbox':
                document.getElementById(this.inputElID + '_check0')?.setAttribute('aria-labelledby', this.labelSelector);
                break;
            case 'checkboxes':
            case 'radio':
                document.querySelector(`#${this.printResponseID} .format-preview`)?.setAttribute('aria-labelledby', this.labelSelector);
                break;
            default: 
                document.getElementById(this.inputElID).setAttribute('aria-labelledby', this.labelSelector);
                break;
        
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
        },
        addGridRow() {
            this.gridInstances[this.indicator.indicatorID].addRow();

            //update hardcoded img paths, and listeners to use methods from the gridinstances object
            const elSelector = `#grid_${this.indicator.indicatorID}_${this.indicator.series}_input tbody > tr > td`;
            const elTDs = document.querySelectorAll(elSelector);
            const arrowIndex = elTDs.length - 1;
            const rmRowIndex = elTDs.length - 2;
            let arrowImgs = elTDs[arrowIndex].querySelectorAll('img');  //[up, down ]
            let rmRowImg = elTDs[rmRowIndex].querySelector('img');

            const deleteRow = this.gridInstances[this.indicator.indicatorID].deleteRow;
            const moveUp = this.gridInstances[this.indicator.indicatorID].moveUp;
            const moveDown = this.gridInstances[this.indicator.indicatorID].moveDown;
            const triggerClick = this.gridInstances[this.indicator.indicatorID].triggerClick;

            arrowImgs[0]?.setAttribute('src', '../' + arrowImgs[0]?.getAttribute('src'));
            arrowImgs[0].onclick = ()=> moveUp(event);
            arrowImgs[0].onkeydown = ()=> triggerClick(event);
            arrowImgs[1]?.setAttribute('src', '../' + arrowImgs[1]?.getAttribute('src'));
            arrowImgs[1].onclick = ()=> moveDown(event);
            arrowImgs[1].onkeydown = ()=> triggerClick(event);

            rmRowImg?.setAttribute('src', '../' + rmRowImg.getAttribute('src'));
            rmRowImg.onclick = ()=> deleteRow(event);
            rmRowImg.onkeydown = ()=> triggerClick(event);
        }
    },
    template: `<div class="format-preview">

        <input v-if="baseFormat==='text'" :id="inputElID" type="text" class="text_input_preview"/>
        <input v-if="baseFormat==='number'" :id="inputElID" type="number" class="text_input_preview"/>

        <template v-if="baseFormat==='currency'">
            $&nbsp;<input :id="inputElID" type="number" min="0.00" step="0.01" class="text_input_preview"/>
        </template>

        <template v-if="baseFormat==='textarea'">
            <textarea :id="inputElID" rows="6" class="textarea_input_preview"></textarea>
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
        
        <template v-if="baseFormat==='orgchart_group' || baseFormat==='orgchart_position' || baseFormat==='orgchart_employee'">
            <div :id="'orgSel_' + indicator.indicatorID" style="min-height:30px"></div>
            <input :id="'sel_prev_' + indicator.indicatorID" style="display: none;">
        </template>

        <template v-if="baseFormat==='grid'">
            <span style="position: absolute; color: transparent" aria-atomic="true" aria-live="polite" :id="'tableStatus_' + indicator.indicatorID" role="status"></span>
            <div class="tableinput">
                <table class="table" 
                :id="'grid_' + indicator.indicatorID + '_' + indicator.series + '_input'" 
                style="word-wrap: break-word; table-layout: fixed; height: 100%; display: table">
                    <thead>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <button type="button" class="buttonNorm" :id="'addRowBtn_' + indicator.indicatorID" 
                title="Grid input add row" aria-label="Grid input add row" 
                @click="addGridRow">
                + Add row
            </button>
        </template>

    </div>`
}