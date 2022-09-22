export default {
    props: {
        indicator: Object
    },
    computed: {
        truncatedOptions() {
            return this.indicator.options?.slice(0, 5) || [];
        },
        baseFormat() {
            return this.indicator.format?.toLowerCase()?.trim() || '';
        },
        inputElID() {
            return `input_preview_${this.indicator.indicatorID}`;
        }
    },
    mounted() {
        console.log(this.baseFormat);
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
                const elSelect = document.getElementById(`multi_prev_${this.indicator.indicatorID}`);
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
            default: break;
        
        }
    },
    methods: {
        useAdvancedEditor() {
            $('#' + this.inputElID).trumbowyg({
                btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'justifyLeft', 'justifyCenter', 'justifyRight', 'fullscreen']
            });
            $(`#textarea_format_button_${this.indicator.indicatorID}`).css('display', 'none');
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

        <template v-if="baseFormat==='fileupload' || baseFormat==='image'">
            <fieldset style="padding: 0.5em;"><legend>File Attachment(s)</legend>
                <p style="margin-bottom: 0.5em;">Select File to attach:</p>
                <input :id="'file_prev_' + indicator.indicatorID" name="formPacket" type="file" />
            </fieldset>
        </template>

        <template v-if="baseFormat==='date'">
            <input type="text" :id="'date_prev_' + indicator.indicatorID" 
            style="background: url(../../libs/dynicons/?img=office-calendar.svg&w=16); background-repeat: no-repeat; background-position: 4px center; padding-left: 24px; font-size: 1.3em; font-family: monospace" value="" />
            <input class="ui-helper-hidden-accessible" :id="indicator.indicatorID + '_focusfix'" type="text" />
        </template>

        <template v-if="baseFormat==='dropdown'">
            <select :id="'drop_prev_' + indicator.indicatorID" style="width: 50%">
                <option v-for="o, i in truncatedOptions" :key="'drop_prev_' + indicator.indicatorID + '_' + i">
                {{o}}
                </option>
                <option v-if="indicator?.options?.length > 5" style="padding-left: 0.4em" disabled>(preview showing first 5)</option>
            </select>
        </template>

        <template v-if="baseFormat==='multiselect'">
            <select multiple 
                :id="'multi_prev_' + indicator.indicatorID">
                :name="'multi_prev_' + indicator.indicatorID + '_multiselect[]'"
                style="display:none">
            </select>
        </template>


    </div>`
}