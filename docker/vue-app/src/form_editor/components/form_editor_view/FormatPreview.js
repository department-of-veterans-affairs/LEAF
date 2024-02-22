export default {
    name: 'format-preview',
    data() {
        return {
            indID: this.indicator.indicatorID
        }
    },
    props: {
        indicator: Object
    },
    inject: [
        'libsPath',
        'initializeOrgSelector',
        'orgchartFormats',
        'decodeAndStripHTML',
        'updateChosenAttributes',
    ],
    computed: {
        baseFormat() {
            return this.indicator.format?.toLowerCase()?.trim() || '';
        },
        truncatedOptions() {
            return this.indicator.options?.slice(0, 6) || [];
        },
        defaultValue() {
            return this.indicator?.default || '';
        },
        strippedDefault() {
            return this.decodeAndStripHTML(this.defaultValue || '');
        },
        inputElID() {
            return `input_preview_${this.indID}`;
        },
        selType() {
            return this.baseFormat.slice(this.baseFormat.indexOf('_') + 1);
        },
        labelSelector() {
            return 'format_label_' + this.indID;
        },
        printResponseID() {
            return `xhrIndicator_${this.indID}_${this.indicator.series}`;
        },
        gridOptions() {
            //NOTE: uses LEAF global XSSHelpers
            let options = JSON.parse(this.indicator?.options || '[]');
            options.map(o => {
                o.name = XSSHelpers.stripAllTags(o.name);
                if (o?.options) {
                    o.options.map(ele => ele = XSSHelpers.stripAllTags(ele));
                }
            })
            return options;
        }
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
                        $('#' + this.indID + '_focusfix').focus();
                    }
                });
                document.getElementById(this.inputElID)?.setAttribute('aria-labelledby', this.labelSelector);
                break;
            case 'dropdown':
                $(`#${this.inputElID}`).chosen({
                    disable_search_threshold: 5,
                    allow_single_deselect: true, 
                    width: '50%'
                });
                this.updateChosenAttributes(this.inputElID, this.labelSelector, "Select Question Option");
                break;
            case 'multiselect':
                const elSelect = document.getElementById(this.inputElID);
                if (elSelect !== null && elSelect.multiple === true && elSelect?.getAttribute('data-choice') !== 'active') {
                    let options = this.indicator.options || [];
                    options = options.map(o =>({
                        value: o,
                        label: o,
                        selected: this.strippedDefault !== '' && this.strippedDefault === o
                    }));
                    const choices = new Choices(elSelect, {
                        allowHTML: false,
                        removeItemButton: true,
                        editItems: true,
                        choices: options.filter(o => o.value !== "")
                    });
                    elSelect.choicesjs = choices;
                }
                document.querySelector(`#${this.inputElID} ~ input.choices__input`).setAttribute('aria-labelledby', this.labelSelector);
                break;
            case 'orgchart_group':
            case 'orgchart_position':
            case 'orgchart_employee':
                this.initializeOrgSelector(this.selType, this.indID, '', this.indicator?.default || '');
                break;
            case 'checkbox':
                document.getElementById(this.inputElID + '_check0')?.setAttribute('aria-labelledby', this.labelSelector);
                break;
            case 'checkboxes':
            case 'radio':
                document.querySelector(`#${this.printResponseID} .format-preview`)?.setAttribute('aria-labelledby', this.labelSelector);
                break;
            default: 
                document.getElementById(this.inputElID)?.setAttribute('aria-labelledby', this.labelSelector);
                break;
        
        }
    },
    methods: {
        useAdvancedEditor() {
            $('#' + this.inputElID).trumbowyg({
                btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'justifyLeft', 'justifyCenter', 'justifyRight', 'fullscreen']
            });
            $(`#textarea_format_button_${this.indID}`).css('display', 'none');
        }
    },
    template: `<div class="format_preview">
        <input v-if="baseFormat === 'text'" :id="inputElID" type="text" :value="strippedDefault" class="text_input_preview"/>
        <input v-if="baseFormat === 'number'" :id="inputElID" type="number" :value="strippedDefault" class="text_input_preview"/>

        <template v-if="baseFormat === 'currency'">
            $&nbsp;<input :id="inputElID" type="number" :value="strippedDefault"
            min="0.00" step="0.01" class="text_input_preview"/>
        </template>

        <template v-if="baseFormat === 'raw_data'">
            Custom Widget
        </template>

        <template v-if="baseFormat === 'textarea'">
            <textarea :id="inputElID" rows="6" class="textarea_input_preview" :value="strippedDefault"></textarea>
            <div :id="'textarea_format_button_' + indicator.indicatorID"
                @click="useAdvancedEditor" 
                style="text-align: right; font-size: 12px"><span class="link">formatting options</span>
            </div>
        </template>

        <template v-if="baseFormat === 'radio'">
            <template v-for="o, i in truncatedOptions" :key="'radio_prev_' + indicator.indicatorID + '_' + i">
                <label class="checkable leaf_check" :for="inputElID + '_radio' + i">
                    <input type="radio" :id="inputElID + '_radio' + i" 
                    :name="indicator.indicatorID" class="icheck leaf_check"
                    :checked="strippedDefault !== '' && strippedDefault === o" />
                    <span class="leaf_check"></span>{{ o }}
                </label>
            </template>
            <div v-if="indicator?.options?.length > 5" style="padding-left: 0.4em"><b> ...</b></div>
        </template>

        <template v-if="baseFormat === 'checkboxes' || baseFormat === 'checkbox'">
            <template v-for="o, i in truncatedOptions" :key="'check_prev_' + indicator.indicatorID + '_' + i">
                <label class="checkable leaf_check" :for="inputElID + '_check' + i">
                    <input type="checkbox" :id="inputElID + '_check' + i" :name="indicator.indicatorID" class="icheck leaf_check"  :checked="strippedDefault !== '' && strippedDefault === o" />
                    <span class="leaf_check"></span>{{ o }}
                </label>
            </template>
            <div v-if="indicator?.options?.length > 5" style="padding-left: 0.4em"><b> ...</b></div>
        </template>
        
        <fieldset v-if="baseFormat === 'fileupload' || baseFormat === 'image'" 
            style="padding: 0.5em;"><legend>File Attachment(s)</legend>
            <p style="margin-bottom: 0.5em;">Select File to attach:</p>
            <input :id="inputElID" name="formPacket" type="file" />
        </fieldset>

        <template v-if="baseFormat === 'date'">
            <input type="text" :id="inputElID"
            :style="'background: white url(' + libsPath + 'dynicons/svg/office-calendar.svg) no-repeat 4px center; background-size: 16px;'"
            style="padding-left: 24px; font-size: 1.3em; font-family: monospace;" :value="indicator.default" />
        </template>

        <select v-if="baseFormat === 'dropdown'" :id="inputElID" style="width: 50%" :value="strippedDefault">
            <option v-for="o, i in truncatedOptions" :key="'drop_prev_' + indicator.indicatorID + '_' + i">
            {{o}}
            </option>
            <option v-if="indicator?.options?.length > 5" style="padding-left: 0.4em" disabled>(preview showing first 5)</option>
        </select>
        
        <select v-if="baseFormat === 'multiselect'" multiple 
            :id="inputElID">
            :name="'multi_prev_' + indicator.indicatorID + '_multiselect[]'"
            style="display:none">
        </select>
        
        <template v-if="orgchartFormats.includes(baseFormat)">
            <div :id="'orgSel_' + indicator.indicatorID" style="min-height:30px"></div>
        </template>

        <template v-if="baseFormat === 'grid'">
            <div class="tableinput">
                <table class="table" :id="'grid_' + indicator.indicatorID + '_' + indicator.series + '_input'"
                    style="word-wrap: break-word; table-layout: fixed; height: 100%; display: table">

                    <thead :id="'gridTableHead_' + indicator.indicatorID">
                        <tr>
                            <td v-for="o in gridOptions" :key="'grid_head_' + o.id">{{ o.name }}</td>
                        </tr>
                    </thead>
                    <tbody :id="'gridTableBody_' + indicator.indicatorID">
                        <tr>
                            <td v-for="o in gridOptions" style="min-width: 150px;" :key="'grid_body_' + o.id">
                                <input v-if="o.type === 'text'" style="width: 100%;" :aria-label="o.name" />
                                <textarea v-if="o.type === 'textarea'" rows="3" style="resize:none; width: 100%;" :aria-label="o.name"></textarea>
                                <input type="date" v-if="o.type === 'date'" style="width: 100%;" :aria-label="o.name" />
                                <select v-if="o.type === 'dropdown'" style="width: 100%;" :aria-label="o.name">
                                    <option v-for="option in o.options" :key="'grid_drop_' + option">{{option}}</option>
                                </select>
                                <select v-if="o.type === 'dropdown_file'" style="width: 100%;" :aria-label="o.name">
                                    <option value="">Dropdown from File</option>
                                </select>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </template>
    </div>`
}