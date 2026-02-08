export default {
    name: 'sensitive-indicator',
    data() {
        return {
            inputElID: `sensitiveTypeSelect_${this.indicatorID}`,
            inputLabelID: `sensitiveTypeSelect_label_${this.indicatorID}`,
            selectedTypes: this.savedPHI_Types ?? [],
        }
    },
    props: {
        indicatorID: {
            type: Number,
            required: true
        },
        indicatorSensitive: {
            type: Boolean,
            required: true
        },
        savedPHI_Types: {
            type: Array,
            required: true
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'selectableTypesPHI',
        'LEAFS_lastCertified',
        'indicatorAddedTimestamp',
    ],
    mounted() {
        const elSelect = document.getElementById(this.inputElID);
        if (elSelect !== null && elSelect.multiple === true && elSelect?.getAttribute('data-choice') !== 'active') {
            const selectable = [ ...this.selectableTypes, 'Other' ];
            const options = selectable.map(o => ({
                value: o,
                label: o,
                selected: this.savedPHI_Types.some(v => v === o),
            }));
            const choices = new Choices(elSelect, {
                shouldSort: false,
                placeholderValue: 'Select type[s) of PHI/PII',
                allowHTML: false,
                removeItemButton: true,
                editItems: true,
                choices: options,
            });
            elSelect.choicesjs = choices;

            //accessibility update for choicesJS plugin
            this.$nextTick(() => {
                let elChoicesInput = document.querySelector(`#${this.inputElID} ~ input.choices__input`);    
                if(elChoicesInput !== null) {
                    elChoicesInput.setAttribute('aria-labelledby', this.inputLabelID);
                    elChoicesInput.setAttribute('role', 'searchbox');
                }
            });
        }

        let elSave = document.querySelector('#leaf-vue-dialog-cancel-save #button_save');
        if(elSave !== null && this.savedPHI_Types.length === 0) {
            elSave.disabled = true;
        }
    },
    beforeUnmount() {
        let elSave = document.querySelector('#leaf-vue-dialog-cancel-save #button_save');
        if(elSave !== null) {
            elSave.disabled = false;
        }
    },
    computed: {
        selectableTypes() {
            return Object.values(this.selectableTypesPHI).sort();
        },
        hasOther() {
            return this.selectedTypes.some(el => el.toLowerCase() === 'other');
        },
        /**
         * True if:
         * site is not yet certified,
         * indicator is new or was added after certification,
         * indicator is being updated to sensitive,
         * or other is chosen as the PHI/PII type
         * @returns Boolaen for conditional rendering
         */
        showPrivacyOfficerReview() {
            return this.LEAFS_lastCertified === 0 ||
                this.indAddedAfterLastCertified ||
                !this.indicatorSensitive ||
                this.hasOther;
        },
        selectionStyles() {
            return {
                margin: '1rem 0',
                display: 'flex',
                flexDirection: 'column',
                gap: '1rem'
            }
        },
        /**
         * @returns {Boolean} true if new indicator (0), certified prior to added time, or being updated to sensitive
         */
        indAddedAfterLastCertified() {
            const indTime = this.indicatorAddedTimestamp;
            return indTime === 0 || this.LEAFS_lastCertified < indTime || !this.indicatorSensitive;
        },
    },
    methods: {
        /**
         * update data property selected by choices js plugin
         * @param {Object} target (select DOM element)
         * */
        updateSelectedPHI(target = {}) {
            const selectedOptionElements = target?.selectedOptions ?? [];
            const arrSelections = Array.from(selectedOptionElements).map(opt => opt.value);
            this.selectedTypes = arrSelections;
        }
    },
    watch: {
        selectedTypes(newVal, oldVal) {
            let elSave = document.querySelector('#leaf-vue-dialog-cancel-save #button_save');
            if(elSave !== null) {
                elSave.disabled = newVal.length === 0 || this.hasOther;
            }
        }
    },
    template: `<div class="attribute_row" id="specify_sensitivity_types" :style="selectionStyles">
        <div v-if="showPrivacyOfficerReview" class="entry_warning bg-yellow-5">
            <span role="img" aria-hidden="true" alt="">⚠️</span>
            <div>
                <p v-show="hasOther">TEMP - Other type for review - New form? LEAFS?</p>
                <p v-if="indAddedAfterLastCertified">
                    Re/Certification is required.<br>
                    Logic for new/edited inds? added/edit needs to be PRIOR to cert.
                </p>
            </div>
        </div>
        <div class="entry_info bg-blue-5v">
            Specification of PHI/PII type(s) is required
        </div>
        <div>
            <label :for="inputElID">Select Type(s) of PHI/PII</label>
            <select :id="inputElID" aria-hidden="true" style="display: none;" multiple
                @change="updateSelectedPHI($event.target)">
            </select>
        </div>
    </div>`
}