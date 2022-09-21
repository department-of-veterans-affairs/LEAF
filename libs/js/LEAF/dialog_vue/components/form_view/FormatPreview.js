export default {
    data() {
        return {
            baseFormat: this.indicator.format.toLowerCase().trim(),
            inputElID: `input_preview_${this.indicator.indicatorID}`,
        }
    },
    props: {
        indicator: Object
    },
    computed: {
        truncatedOptions() {
            return this.indicator.options?.slice(0, 5) || [];
        }
    },
    methods: {
        useAdvancedEditor() {
            console.log(this.indicator);
            $('#' + this.inputElID).trumbowyg({
                btns: ['bold', 'italic', 'underline', '|', 'unorderedList', 'orderedList', '|', 'justifyLeft', 'justifyCenter', 'justifyRight', 'fullscreen']
            });
            $(`#textarea_format_button_${this.indicator.indicatorID}`).css('display', 'none');
        }

    },
    template: `<div class="format-preview">

        <input v-if="baseFormat==='text'" :id="inputElID" type="text" class="text_input_preview"/>
        <input v-if="baseFormat==='number'" :id="inputElID" type="number" class="text_input_preview"/>
        <input v-if="baseFormat==='currency'" :id="inputElID" type="number" min="0.00" step="0.01" class="text_input_preview"/>

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


    </div>`
}