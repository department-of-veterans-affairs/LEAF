export default {
    name: 'conditions-editor-dialog',
    data() {
        return {
            requiredDataProperties: ['indicatorID'],
            indicators: [],
            appIsLoadingIndicators: true,
            parentIndID: 0,
            selectedOperator: '',
            selectedParentValue: '',
            selectedOutcome: '',
            selectedChildValue: '',
            showRemoveModal: false,
            showConditionEditor: false,
            ariaStatus: '',
            selectedConditionJSON: '',
            enabledParentFormats: {
                "dropdown": 1,
                "multiselect": 1,
                "radio": 1,
                "checkboxes": 1,
                "number": 1,
                "currency": 1,
            },
            multiOptionFormats: [ //formats where users can select more than one value during data entry
                'multiselect', 'checkboxes'
            ],
            choicesJS_parentValueFormats: [ //formats where choicesJS is used to add more than one comparison to facilitate setup
                'multiselect', 'checkboxes', 'dropdown', 'radio'
            ],
            orgchartSelectData: {},
            crosswalkFile: '',
            crosswalkHasHeader: false,
            level2IndID: null,
            canPrefillChild: {
                "text": 1,
                "textarea": 1,
                "dropdown": 1,
                "multiselect": 1,
                "radio": 1,
                "checkboxes": 1,
                "orgchart_employee": 1,
                "orgchart_group": 1,
                "orgchart_position": 1,
            },
            numericOperators: ['gt', 'gte', 'lt', 'lte'],
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'dialogData',
        'checkRequiredData',
        'orgchartFormats',
        'focusedFormRecord',
        'focusedFormTree',
        'getFormByCategoryID',
        'closeFormDialog',
        'truncateText',
        'decodeAndStripHTML',
        'fileManagerTextFiles',
        'initializeOrgSelector',
        'lastModalTab',
    ],
    created() {
        this.checkRequiredData(this.requiredDataProperties);
        this.setDialogSaveFunction(this.onSave);
        this.getFormIndicators();
    },
    mounted() {
        const elSaveDiv = document.querySelector('#leaf-vue-dialog-cancel-save #button_save');
        if (elSaveDiv !== null) {
            elSaveDiv.style.display = 'none';
        }
    },
    methods: {
        /**
         * create flat array for indicators from current form using injected form tree.
         * Ensures number types for indIDs, trimmed lower format, trimmed options in array
         */
        getFormIndicators() {
            let formIndicators = [];
            const addIndicator = (index, parentID, node) => {
              let options = Array.isArray(node?.options) ? node.options.map(o => o.trim()) : [];
              options = options.filter(o => o !== "");

              formIndicators.push({
                formPage: index,
                parentID: +parentID, //null will become 0
                indicatorID: +node.indicatorID,
                name: node.name || "",
                format: node.format.toLowerCase().trim(),
                options: options,
                conditions: node.conditions,
                hasSubquestions: node.child !== null,
              });
              if(node.child !== null) {
                for(let c in node.child) {
                  addIndicator(index, node.indicatorID, node.child[c])
                }
              }
            }
            this.focusedFormTree.forEach((page, index) => {
                addIndicator(index, null, page);
            });
            this.indicators = formIndicators;
            this.appIsLoadingIndicators = false;
        },
        /**
        * @param {number} indicatorID
        */
        updateSelectedParentIndicator(indicatorID = 0) {
            this.parentIndID = indicatorID;
            if(!this.selectedParentValueOptions.includes(this.selectedParentValue)) {
                this.selectedParentValue = "";
            }
        },
        /**
         * @param {string} outcome (condition outcome options: Hide, Show, Pre-Fill)
         */
        updateSelectedOutcome(outcome = '') {
            this.selectedOutcome = outcome.toLowerCase();
            this.selectedChildValue = "";
            this.crosswalkFile = "";
            this.crosswalkHasHeader = false;
            this.level2IndID = null;
            if(this.selectedOutcome === 'pre-fill') {
                this.addOrgSelector();
            }
        },
        /**
         * @param {Object} target (DOM element)
         * @param {string} type parent or child
         */
        updateSelectedOptionValue(target = {}, type = 'parent') {
            let value = '';
            if (target?.multiple === true) {
                const arrSelections = Array.from(target.selectedOptions);
                arrSelections.forEach(sel => {
                    value += sel.label.trim() + '\n';
                });
                value = value.trim();
            } else {
                value = target.value.trim();
            }
            if (type.toLowerCase() === 'parent') {
                this.selectedParentValue = XSSHelpers.stripAllTags(value);
                if(this.parentFormat === 'number' || this.parentFormat === 'currency') {
                    if (/^(\d*)(\.\d+)?$/.test(value)) {
                        const floatValue = parseFloat(value);
                        this.selectedParentValue = this.parentFormat === 'currency' ?
                            (Math.round(100 * floatValue) / 100).toFixed(2) : String(floatValue);
                    } else {
                        this.selectedParentValue = '';
                    }
                }
            } else if (type.toLowerCase() === 'child') {
                this.selectedChildValue = XSSHelpers.stripAllTags(value);
            }
        },
        newCondition(showEditor = true) {
            this.selectedConditionJSON = '';
            this.showConditionEditor = showEditor;
            this.selectedOperator = '';
            this.parentIndID = 0;
            this.selectedParentValue = '';
            this.selectedOutcome = '';
            this.selectedChildValue = '';
            if(showEditor) {
                this.ariaStatus = 'Entering new condition';
            }
        },
        /** post conditions json.
         * @param {bool} addSelected whether json should include the currently selected condition (deleting saves all but current)
        */
        postConditions(addSelected = true) {
            if (this.conditionComplete || addSelected === false) {
                this.ariaStatus = '';
                //copy of all conditions on child, and filter using stored JSON val
                let currConditions = [...this.savedConditions];
                let newConditions = currConditions.filter(c => JSON.stringify(c) !== this.selectedConditionJSON);
                //clean up some possible data type issues after php8 and br tags before saving.
                newConditions.forEach(c => {
                    c.childIndID = parseInt(c.childIndID);
                    c.parentIndID = parseInt(c.parentIndID);
                    c.selectedChildValue = XSSHelpers.stripAllTags(c.selectedChildValue);
                    c.selectedParentValue = XSSHelpers.stripAllTags(c.selectedParentValue);
                });

                //if adding, confirm new conditions is unique
                const newConditionJSON = JSON.stringify(this.conditions);
                const newConditionIsUnique = newConditions.every(c => JSON.stringify(c) !== newConditionJSON);
                if (addSelected === true && newConditionIsUnique) {
                    newConditions.push(this.conditions);
                }
                newConditions = newConditions.length > 0 ? JSON.stringify(newConditions) : '';
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formEditor/${this.childIndID}/conditions`,
                    data: {
                        conditions: newConditions,
                        CSRFToken: this.CSRFToken
                    },
                    success: (res)=> {
                        if (res !== 'Invalid Token.') {
                            this.getFormByCategoryID(this.formID);
                            let refIndicator = this.indicators.find(ind => ind.indicatorID === this.childIndID);
                            refIndicator.conditions = newConditions;
                            this.showRemoveModal = false;
                            this.newCondition(false);
                            const elClose = document.getElementById('leaf-vue-dialog-close');
                            if(elClose !== null) {
                                elClose.focus();
                            }
                            this.$nextTick(() => {
                                this.ariaStatus = 'Updated question conditions';
                            });

                        } else { console.log('error adding condition', res) }
                    },
                    error:(err) => console.log(err)
                });
            }
        },
        /**
         * @param {Object} (destructured object {confirmDelete:boolean, condition:Object})
         */
        removeCondition({confirmDelete = false, condition = {}} = {}) {
            if(confirmDelete === true) { //delete btn confirm modal
                this.postConditions(false);
            } else { //X button select from list and open the confirm delete modal
                this.selectConditionFromList(condition);
                this.showRemoveModal = true;
            }
        },
        /**
         * store the selected condition in a string and update associated app values
         * @param {Object} conditionObj 
         */
        selectConditionFromList(conditionObj = {}) {
            this.selectedConditionJSON = JSON.stringify(conditionObj);
            this.parentIndID = parseInt(conditionObj?.parentIndID || 0);
            this.selectedOperator = conditionObj?.selectedOp || '';
            this.selectedOutcome = (conditionObj?.selectedOutcome || '').toLowerCase();
            this.selectedParentValue = conditionObj?.selectedParentValue || '';
            this.selectedChildValue = conditionObj?.selectedChildValue || '';
            this.crosswalkFile = conditionObj?.crosswalkFile || '';
            this.crosswalkHasHeader = conditionObj?.crosswalkHasHeader || false;
            this.level2IndID = conditionObj?.level2IndID || null;
            this.showConditionEditor = true;
            this.ariaStatus = 'Editing conditions';
            this.addOrgSelector();
        },
        /**
         * @param {number} id 
         * @returns {string}
         */
        getIndicatorName(id = 0) {
            let indicatorName = this.indicators.find(i => parseInt(i.indicatorID) === id)?.name || "";
            indicatorName = this.decodeAndStripHTML(indicatorName);
            return this.truncateText(indicatorName);
        },
        getConditionCompareValues(selectedParentValues = "") {
            let decodedValues = this.decodeAndStripHTML(selectedParentValues);
            let comparisons = decodedValues.split('\n');
            return comparisons.join(", ");
        },
        /**
         * @param {Object} condition 
         * @returns {string}
         */
        getOperatorText(condition = {}) {
            const parFormat = condition.parentFormat.toLowerCase();
            let text = condition.selectedOp;

            const op = condition.selectedOp;
            switch(op) {
                case '==':
                    text = this.choicesJS_parentValueFormats.includes(parFormat) ? 'includes' : 'is';
                    break;
                case '!=':
                    text = this.choicesJS_parentValueFormats.includes(parFormat) ? 'does not include' : 'is not';
                    break;
                case 'gt':
                case 'gte':
                case 'lt':
                case 'lte':
                    const glText = op.includes('g') ? 'greater than' : 'less than';
                    const orEq = op.includes('e') ? ' or equal to' : '';
                    text = `is ${glText}${orEq}`;
                    break;
                default:
                    break;
            }
            return text;
        },
        /**
         * @param {object} condition
         * @returns {boolean} is parent for a non-crosswalk outcome not in the list of selectable parents
         */
        isOrphan(condition = {}) {
            const indID = parseInt(condition?.parentIndID || 0);
            const outcome = condition.selectedOutcome.toLowerCase();
            return outcome !== 'crosswalk' && !this.selectableParents.some(p => parseInt(p.indicatorID) === indID);
        },
        /**
         * @param {String} conditionType
         * @returns {String}
         */
        listHeaderText(conditionType = '') {
            const type = conditionType.toLowerCase();
            let text = '';
            let clarifier = '';
            if(this.conditionTypes[type]?.length > 1) {
                clarifier = ' (any of the following)'
            }
            switch(type) {
                case 'show':
                    text = `This field will be shown IF${clarifier}:`
                    break;
                case 'hide':
                    text = `This field will be hidden IF${clarifier}:`
                    break;
                case 'prefill':
                    text = `This field will be pre-filled IF${clarifier}:`
                    break;
                case 'crosswalk':
                    text = `This field has loaded dropdown(s)`
                    break;
                default:
                    break;
            }
            return text;
        },
        /**
         * @param {Object} condition
         * @returns {boolean} whether the child or parent format does not match that of the condition
         */
        childFormatChangedSinceSave(condition = {}) {
            const savedChildFormat = (condition?.childFormat || '').toLowerCase().trim();
            const savedParentFormat = (condition?.parentFormat || '').toLowerCase().trim();
            const savedParIndID = parseInt(condition?.parentIndID || 0);

            const parentInd = this.selectableParents.find(p => p.indicatorID === savedParIndID);
            const parentIndFormat = parentInd?.format || ''
            return savedChildFormat !== this.childFormat || savedParentFormat !== parentIndFormat;
        },
        /**
         * called to create choicejs combobox instances for multi option formats
         */
        updateChoicesJS() {
            this.$nextTick(() => {
                const elExistingChoicesChild = document.querySelector('#child_choices_wrapper > div.choices');
                const elSelectParent = document.getElementById('parent_compValue_entry_multi');
                const elSelectChild = document.getElementById('child_prefill_entry_multi');
                const outcome = this.conditions.selectedOutcome;

                if(this.choicesJS_parentValueFormats.includes(this.parentFormat) &&
                    elSelectParent !== null &&
                    !(elSelectParent?.choicesjs?.initialised === true)
                ) {
                    let arrValues = this.conditions.selectedParentValue.split('\n') || [];
                    arrValues = arrValues.map(v => this.decodeAndStripHTML(v).trim());

                    let options = this.selectedParentValueOptions;
                    options = options.map(o =>({
                        value: o.trim(),
                        label: o.trim(),
                        selected: arrValues.includes(o.trim())
                    }));
                    const choices = new Choices(elSelectParent, {
                        placeholderValue: 'Type here to search',
                        allowHTML: false,
                        removeItemButton: true,
                        editItems: true,
                        choices: options.filter(o => o.value !== "")
                    });
                    elSelectParent.choicesjs = choices;

                    let elChoicesInput = document.querySelector('#parent_compValue_entry_multi ~ input.choices__input');
                    if(elChoicesInput !== null) {
                        elChoicesInput.setAttribute('aria-label', 'parent value choices');
                        elChoicesInput.setAttribute('role', 'searchbox');
                        //remove an incorrect aria attribute from a div wrapping the delete buttons (which already have labels)
                        let currentSelections = Array.from(
                            document.querySelectorAll(
                                '#parent_compValue_entry_multi ~ .choices__list--multiple .choices__item'
                            )
                        );
                        currentSelections.forEach(s => s.removeAttribute("aria-selected"));
                    }
                }

                if(outcome === 'pre-fill' && this.multiOptionFormats.includes(this.childFormat) &&
                    elSelectChild !== null && elExistingChoicesChild === null
                ) {
                    let arrValues = this.conditions.selectedChildValue.split('\n') || [];
                    arrValues = arrValues.map(v => this.decodeAndStripHTML(v).trim());

                    let options = this.selectedChildValueOptions;
                    options = options.map(o =>({
                        value: o.trim(),
                        label: o.trim(),
                        selected: arrValues.includes(o.trim())
                    }));
                    const choices = new Choices(elSelectChild, {
                        placeholderValue: 'Type here to search',
                        allowHTML: false,
                        removeItemButton: true,
                        editItems: true,
                        choices: options.filter(o => o.value !== "")
                    });
                    elSelectChild.choicesjs = choices;

                    let elChoicesInput = document.querySelector('#child_prefill_entry_multi ~ input.choices__input');
                    if(elChoicesInput !== null) {
                        elChoicesInput.setAttribute('aria-label', 'child prefill value choices');
                        elChoicesInput.setAttribute('role', 'searchbox');
                        //remove an incorrect aria attribute from a div wrapping the delete buttons (which already have labels)
                        let currentSelections = Array.from(
                            document.querySelectorAll(
                                '#child_prefill_entry_multi ~ .choices__list--multiple .choices__item'
                            )
                        );
                        currentSelections.forEach(s => s.removeAttribute("aria-selected"));
                    }
                }
            });
        },
        addOrgSelector() {
            if (this.selectedOutcome === 'pre-fill' && this.orgchartFormats.includes(this.childFormat)) {
                const selType = this.childFormat.slice(this.childFormat.indexOf('_') + 1);
                this.$nextTick(() => {
                    this.initializeOrgSelector(
                        selType, this.childIndID, 'ifthen_child_', this.selectedChildValue, this.setOrgSelChildValue
                    );
                });
            }
        },
        setOrgSelChildValue(orgSelector = {}) {
            if(orgSelector.selection !== undefined) {
                this.orgchartSelectData = orgSelector.selectionData[orgSelector.selection];
                this.selectedChildValue = orgSelector.selection.toString();
            }
        },
        onSave() {
            this.postConditions(true);
        }
    },
    computed: {
        formID() {
            return this.focusedFormRecord.categoryID;
        },
        showSetup() {
            return  this.showConditionEditor && this.selectedOutcome &&
                (this.selectedOutcome === 'crosswalk' || this.selectableParents.length > 0);
        },
        conditionOverviewText() {
            let out = '';
            if(this.selectedOutcome.toLowerCase() !== 'crosswalk') {
                out = `If ${this.getIndicatorName(this.parentIndID)} ${this.getOperatorText(this.conditions)} ${this.decodeAndStripHTML(this.selectedParentValue)}
                    then ${this.selectedOutcome} this question.`
            } else {
                out =  `Question options loaded from ${this.conditions.crosswalkFile}`
            }
            return out;
        },
        noOptions() {
            return !['', 'crosswalk'].includes(this.selectedOutcome) && this.selectableParents.length < 1;
        },
        childIndID() {
            return this.dialogData.indicatorID;
        },
        childIndicator() {
            return this.indicators.find(i => i.indicatorID === this.childIndID);
        },
        childHasSubquestions() {
            return this.childIndicator.hasSubquestions;
        },
        /**
         * @returns {object} current parent selection
         */
        selectedParentIndicator() {
            const indicator = this.selectableParents.find(
                i => i.indicatorID === parseInt(this.parentIndID)
            );
            return indicator === undefined ? {} : {...indicator};
        },
        /**
         * @returns {string} format of the parent question if there is one
         */
        parentFormat() {
            return this.selectedParentIndicator?.format || ''
        },
        /**
         * @returns {string} format of the child question
         */
        childFormat() {
            return this.childIndicator?.format || '';
        },
        /**
         * @returns list of indicators that are on the same page, enabled as parents, and different than child 
         */
        selectableParents() {
            return this.indicators.filter(i =>
                i.formPage === this.childIndicator.formPage &&
                i.indicatorID !== this.childIndID &&
                this.enabledParentFormats[i.format] === 1
            );
        },
        /**
         * @returns list of operators and human readable text base on parent format
         */
        selectedParentOperators() {
            let operators = [];
            switch(this.parentFormat) {
              case 'multiselect':
              case 'checkboxes':
              case 'dropdown':
              case 'radio':
                operators = this.choicesJS_parentValueFormats.includes(this.parentFormat) ?
                  [
                    {val:"==", text: "includes"},
                    {val:"!=", text: "does not include"}
                  ] :
                  [
                    {val:"==", text: "is"},
                    {val:"!=", text: "is not"}
                  ];
                if (this.selectedParentValueOptionsHasNumbers) {
                  operators = operators.concat([
                    {val:"gt", text: "is greater than"},
                    {val:"gte", text: "is greater or equal to"},
                    {val:"lt", text: "is less than"},
                    {val:"lte", text: "is less or equal to"},
                  ]);
                }
                break;
              case 'number':
              case 'currency':
                operators = [
                  {val:"gt", text: "is greater than"},
                  {val:"gte", text: "is greater or equal to"},
                  {val:"lt", text: "is less than"},
                  {val:"lte", text: "is less or equal to"},
                ];
                break;
              default:
                break;
            }
            return operators;
        },
        selectedOperatorText() {
            let text = '';
            switch(this.selectedOperator) {
                case '==':
                    text = this.choicesJS_parentValueFormats.includes(this.parentFormat) ? 'includes' : 'is';
                    break;
                case '!=':
                    text = this.choicesJS_parentValueFormats.includes(this.parentFormat) ? 'does not include' : 'is not';
                    break;
                case 'gt':
                    text = 'is greater than';
                    break;
                case 'gte':
                    text = 'is greater or equal to';
                    break;
                case 'lt':
                    text = 'is less than';
                    break;
                case 'lte':
                    text = 'is less or equal to';
                    break;
                default:
                break;
            }
            return text;
        },
        crosswalkLevelTwo() {
            const formPage = this.childIndicator.formPage;
            return this.indicators.filter(i =>
                i.formPage === formPage &&
                i.indicatorID !== this.childIndID &&
                ['dropdown', 'multiselect'].includes(i.format)
            );
        },
        /**
         * @returns list of options for comparison based on parent indicator selection
         */
        selectedParentValueOptions() {
            return this.selectedParentIndicator?.options || []
        },
        selectedParentValueOptionsHasNumbers() {
            return this.selectedParentValueOptions.some(opt => Number.isFinite(+opt));
        },
        selectedParentValueIsNumber() {
            return Number.isFinite(+this.selectedParentValue);
        },
        /**
         * @returns list of options for prefill outcomes.  Does not combine with file loaded options.
         */
        selectedChildValueOptions() {
            return this.childIndicator?.options || [];
        },
        canAddCrosswalk() {
            return (this.childFormat === 'dropdown' || this.childFormat === 'multiselect');
        },
        parentTriggersDisplay() {
            let display = this.decodeAndStripHTML(this.selectedParentValue ?? '').split('\n');

            let buffer = '';
            if(display.length > 1) {
                buffer = '<ul id="parentTriggerList">';
                display.forEach(item => {
                    buffer += '<li>' + item + '</li>';
                }); 
                buffer += '</ul>'
            } else {
                buffer = "<strong>" + display.join() + "</strong><br>";
            }
            return buffer;
        },
        childPrefillDisplay() {
            let returnVal = '';
            switch(this.childFormat) {
                case 'orgchart_employee':
                    returnVal = ` '${this.orgchartSelectData?.firstName || ''} ${this.orgchartSelectData?.lastName || ''}'`;
                    break;
                case 'orgchart_group':
                    returnVal = ` '${this.orgchartSelectData?.groupTitle || ''}'`;
                    break;
                case 'orgchart_position':
                    returnVal = ` '${this.orgchartSelectData?.positionTitle || ''}'`;
                    break;
                case 'multiselect':
                case 'checkboxes':
                    const pluralTxt = this.selectedChildValue.split('\n').length > 1 ? 's' : '';
                    returnVal = `${pluralTxt} '${this.decodeAndStripHTML(this.selectedChildValue)}'`;
                    break;
                default:
                    returnVal = ` '${this.decodeAndStripHTML(this.selectedChildValue)}'`;
                    break;
            }
            return returnVal;
        },
        childChoicesKey() { //key for choicesJS box for child prefill.  update on list selection, outcome change
            return this.selectedConditionJSON + this.selectedOutcome;
        },
        parentChoicesKey() {//key for choicesJS box for parent value selection.  update on list selection, parID change, op change
            return this.selectedConditionJSON + String(this.parentIndID) + this.selectedOperator;
        },
        /**
         * @returns {Object} current conditions object, properties to lower and tags removed as needed
         */
        conditions() {
            return {
                childIndID: parseInt(this.childIndicator?.indicatorID || 0),
                parentIndID: parseInt(this.selectedParentIndicator?.indicatorID || 0),
                selectedOp: this.selectedOperator, 
                selectedParentValue: XSSHelpers.stripAllTags(this.selectedParentValue),
                selectedChildValue: XSSHelpers.stripAllTags(this.selectedChildValue),
                selectedOutcome: this.selectedOutcome.toLowerCase(),
                crosswalkFile: this.crosswalkFile,
                crosswalkHasHeader: this.crosswalkHasHeader,
                level2IndID: this.level2IndID,
                childFormat: this.childFormat,
                parentFormat: this.parentFormat
            }    
        },
        /**
         * @returns {boolean} if all required fields are entered for the current condition type
         */
        conditionComplete() {
            const {
                parentIndID,
                selectedOp,
                selectedParentValue,
                selectedChildValue,
                selectedOutcome,
                crosswalkFile
            } = this.conditions;

            let returnValue = false;
            if (!this.showRemoveModal) { //don't bother w this logic if showing delete view
                switch(selectedOutcome) {
                    case 'pre-fill':
                        returnValue = parentIndID !== 0
                                    && selectedOp !== ""
                                    && selectedParentValue !== ""
                                    && selectedChildValue !== "";
                        break;
                    case 'hide':
                    case 'show':
                        returnValue = parentIndID !== 0
                                    && selectedOp !== ""
                                    && selectedParentValue !== "";
                        break;
                    case 'crosswalk':
                        returnValue = crosswalkFile !== "";
                        break;
                    default:
                        break;
                }
            }
            //btn is part of the LEAF modal
            const elSave = document.getElementById('button_save');
            if (elSave !== null) elSave.style.display = returnValue === true ? 'block' : 'none';

            return returnValue;
        },
        /**
         * @returns {Array} of conditions where conditions is a string rep of array.  Accounts for prior import issue
         */
        savedConditions() {
            return typeof this.childIndicator.conditions === 'string' && this.childIndicator.conditions[0] === '[' ?
                JSON.parse(this.childIndicator.conditions) : [];
        },
        /**
         * @returns {Object} of conditions by type
         */
        conditionTypes() {
            return {
                show: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "show"),
                hide: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "hide"),
                prefill: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "pre-fill"),
                crosswalk: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "crosswalk"),
            };
        },
        /* true if user has saved both display states, or if they choose a display state that conflicts with current state */
        hasDisplayConflict() {
            return (this.conditionTypes.show.length > 0 && this.conditionTypes.hide.length > 0) || 
            (this.conditionTypes.show.length > 0 && this.selectedOutcome === 'hide') ||
            (this.conditionTypes.hide.length > 0 && this.selectedOutcome === 'show')
        }
    },
    watch: {
        showRemoveModal(newVal) {
            //if the remove condition part of the modal is being shown, hide the normal save / cancel area
            const elSaveDiv = document.getElementById('leaf-vue-dialog-cancel-save');
            if (elSaveDiv !== null) {
                elSaveDiv.style.display = newVal === true ? 'none' : 'flex';
                if(newVal === true) {
                    elSaveDiv.setAttribute('aria-hidden', true);
                } else {
                    elSaveDiv.removeAttribute('aria-hidden');
                }
                this.ariaStatus = newVal === true ? 'Confirm Deletion' : '';
            }
        },
        childChoicesKey(newVal, oldVal) {
            if(this.selectedOutcome.toLowerCase() == 'pre-fill' && this.multiOptionFormats.includes(this.childFormat)) {
                this.updateChoicesJS()
            }
         },
        parentChoicesKey(newVal, oldVal) {
            if(this.choicesJS_parentValueFormats.includes(this.parentFormat)) {
                this.updateChoicesJS()
            }
        },
        selectedOperator(newVal, oldVal) {
            if (oldVal !== "" && this.numericOperators.includes(newVal) && !this.selectedParentValueIsNumber) {
              this.selectedParentValue = ""
            }
        }
    },
    template: `<div id="condition_editor_dialog_content">
            <!-- LOADING SPINNER -->
            <div v-if="appIsLoadingIndicators" class="page_loading">
                Loading... <img src="../images/largespinner.gif" alt="" />
            </div>
            <div v-else id="condition_editor_inputs">
                <!-- NOTE: DELETION DIALOG -->
                <div id="status_condition_entry" role="status" style="position: absolute; opacity:0" aria-live="assertive" :aria-label="ariaStatus"></div>
                <div v-if="showRemoveModal" id="ifthen_deletion_dialog">
                    <div>Choose <b>Delete</b> to remove this condition, or <b>cancel</b> to return to the editor</div>
                    <div style="padding: 1rem 0;"><b>{{ conditionOverviewText }}</b></div>
                    <div class="options">
                        <button type="button" class="btn_remove_condition"
                            @click="removeCondition({confirmDelete: true, condition: {}})">
                            Delete
                        </button>
                        <button type="button" class="btn-general" @click="showRemoveModal=false" @keydown.tab="lastModalTab">
                            Cancel
                        </button>
                    </div>
                </div>
                <template v-else>
                    <!-- NOTE: LISTS BY CONDITION TYPE -->
                    <div v-if="savedConditions.length > 0" id="savedConditionsLists">
                        <div v-if="hasDisplayConflict" class="entry_warning bg-yellow-5" style="margin-bottom:1.5rem;">
                            <span role="img" alt="warning">⚠️</span> Having both 'hidden' and 'shown' can cause fields to display incorrectly.
                        </div>
                        <div v-if="childHasSubquestions" class="entry_info bg-blue-5v" style="margin-bottom:1.5rem;">
                            <span role="img" aria-hidden="true" alt="">ℹ️</span>Subquestions will also be hidden when this question is hidden.
                        </div>
                        <template v-for="typeVal, typeKey in conditionTypes" :key="typeVal">
                            <template v-if="typeVal.length > 0">
                                <p><b>{{ listHeaderText(typeKey) }}</b></p>
                                <ul>
                                    <li v-for="c in typeVal" :key="c" class="savedConditionsCard">
                                        <div class="itemSavedConditions" 
                                            :class="{selectedConditionEdit: JSON.stringify(c) === selectedConditionJSON, isOrphan: isOrphan(c)}">
                                            <template v-if="!isOrphan(c)">
                                                <div v-if="c.selectedOutcome.toLowerCase() !== 'crosswalk'">
                                                    '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                                    {{getOperatorText(c)}}
                                                    <strong>{{getConditionCompareValues(c.selectedParentValue)}}</strong>
                                                </div>
                                                <div v-else>Options for this question will be loaded from <b>{{ c.crosswalkFile }}</b></div>
                                                <div v-if="childFormatChangedSinceSave(c)" class="changesDetected">
                                                    Format changes detected.  Please review and save to update this condition.
                                                </div>
                                            </template>
                                            <div v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived, deleted or is on another page.</div>
                                        </div>
                                        <button type="button" class="btn_edit_condition"
                                            title="Edit this Condition" aria-label="Edit this condition"
                                            @click="selectConditionFromList(c)">
                                            <span role="img" aria-hidden="true" alt="">✏️</span>
                                        </button>
                                        <button type="button" class="btn_remove_condition"
                                            title="Delete this condition" aria-label="Delete this condition"
                                            @click="removeCondition({confirmDelete: false, condition: c})">
                                            <i class="fa fa-trash" role="img" aria-hidden="true"></i>
                                        </button>
                                    </li>
                                </ul>
                            </template>
                        </template>
                    </div>
                    <button type="button" @click="newCondition" class="btn-confirm new" aria-label="New Condition">+ New Condition</button>
                    <!-- NOTE: OUTCOME SELECTION and PREFILL AREAS -->
                    <div v-if="showConditionEditor" id="outcome-editor">
                        <!-- SELECT TYPE OF LOGIC -->
                        <label class="ifthen_label" for="outcome_select">Select an outcome</label>
                        <select title="select outcome" id="outcome_select" class="usa-input" @change="updateSelectedOutcome($event.target.value)">
                            <option v-if="conditions.selectedOutcome === ''" value="" selected>Select an outcome</option>
                            <option value="show" :selected="conditions.selectedOutcome === 'show'">Show this question ...</option>
                            <option value="hide" :selected="conditions.selectedOutcome === 'hide'">Hide this question ...</option>
                            <option v-if="canPrefillChild[childFormat] === 1" 
                                value="pre-fill" :selected="conditions.selectedOutcome === 'pre-fill'">Pre-fill this Question
                            </option>
                            <option v-if="canAddCrosswalk"
                                value="crosswalk" :selected="conditions.selectedOutcome === 'crosswalk'">Load Dropdown Options
                            </option>
                        </select>
                        <!-- PREFILL -->
                        <template v-if="!noOptions && conditions.selectedOutcome === 'pre-fill'">
                            <label class="ifthen_label" for="child_prefill_entry" id="prefill_value_entry">Enter a pre-fill value</label>
                            <select v-if="childFormat==='dropdown' || childFormat==='radio'"
                                id="child_prefill_entry" class="usa-input"
                                @change="updateSelectedOptionValue($event.target, 'child')">
                                <option v-if="conditions.selectedChildValue === ''" value="" selected>Select a value</option>
                                <option v-for="val in selectedChildValueOptions" 
                                    :value="val"
                                    :key="'child_prefill_' + val"
                                    :selected="decodeAndStripHTML(conditions.selectedChildValue) === val">
                                    {{ val }} 
                                </option>
                            </select>
                            <div v-else-if="multiOptionFormats.includes(childFormat)"
                                id="child_choices_wrapper" :key="'prefill_' + childChoicesKey">
                                <select v-if="childFormat === 'multiselect' || childFormat === 'checkboxes'"
                                    placeholder="select some options"
                                    multiple="true"
                                    id="child_prefill_entry_multi" aria-hidden="true"
                                    style="display: none;"
                                    @change="updateSelectedOptionValue($event.target, 'child')">
                                </select>
                            </div>
                            <input v-else-if="childFormat==='text' || childFormat==='textarea'" 
                                id="child_prefill_entry" class="usa-input"
                                @change="updateSelectedOptionValue($event.target, 'child')"
                                :value="decodeAndStripHTML(conditions.selectedChildValue)" />
                            <div v-if="orgchartFormats.includes(childFormat)" :id="'ifthen_child_orgSel_' + conditions.childIndID"
                                style="min-height:30px" aria-labelledby="prefill_value_entry">
                            </div>
                        </template>
                    </div>
                    <div v-if="showSetup" id="if-then-setup">
                        <!-- CONDITIONAL DISPLAY (HIDE or SHOW) -->
                        <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                            <div style="font-size:1.25rem;"><b>IF</b></div>
                            <!-- NOTE: PARENT CONTROLLER SELECTION -->
                            <select title="select controller question" aria-label="select controller question"
                                id="controller_select" class="usa-input"
                                @change="updateSelectedParentIndicator(parseInt($event.target.value))">
                                <option v-if="!conditions.parentIndID" :value="0" selected>Select an Indicator</option>
                                <option v-for="i in selectableParents" :key="'parent_' + i.indicatorID"
                                :title="i.name"
                                :value="i.indicatorID"
                                :selected="parseInt(conditions.parentIndID)===parseInt(i.indicatorID)" >
                                {{getIndicatorName(parseInt(i.indicatorID)) }} (indicator {{i.indicatorID}})
                                </option>
                            </select>
                            <!-- NOTE: OPERATOR SELECTION -->
                            <select v-model="selectedOperator"
                                id="operator_select" class="usa-input"
                                title="select condition" aria-label="select condition">
                                <option v-if="selectedOperator === ''" value="" selected>Select a condition</option>
                                <option v-for="o in selectedParentOperators" :key="o.val" :value="o.val" >
                                {{ o.text }}
                                </option>
                            </select>
                            <!-- NOTE: COMPARED VALUE SELECTIONS -->
                            <input v-if="numericOperators.includes(selectedOperator)"
                                id="numeric_comparison" class="usa-input" :key="'comp_numeric' + selectedParentValue"
                                title="enter a numeric value" aria-label="enter a numeric value"
                                type="number" :value="conditions.selectedParentValue"
                                @change="updateSelectedOptionValue($event.target, 'parent')"
                                placeholder="enter a number" />
                            <div v-else-if="choicesJS_parentValueFormats.includes(parentFormat)"
                                id="parent_choices_wrapper" :key="'comp_' + parentChoicesKey">
                                <select id="parent_compValue_entry_multi" aria-hidden="true" style="display: none;"
                                    placeholder="select some options" multiple="true"
                                    @change="updateSelectedOptionValue($event.target, 'parent')">
                                </select>
                            </div>
                        </template>
                        <!-- NOTE: LOADED DROPDOWNS -->
                        <div v-else class="crosswalks">
                            <label for="select-crosswalk-file">File&nbsp;
                                <select v-model="crosswalkFile" id="select-crosswalk-file" class="usa-input" style="width: 200px;">
                                    <option value="">Select a file</option>
                                    <option v-for="f in fileManagerTextFiles" :key="f" :value="f">{{f}}</option>
                                </select>
                            </label>
                            <label for="select-crosswalk-header">Does file contain headers?&nbsp;
                                <select v-model="crosswalkHasHeader" id="select-crosswalk-header" class="usa-input" style="width:60px;">
                                    <option :value="false">No</option>
                                    <option :value="true">Yes</option>
                                </select>
                            </label>
                            <label for="select-level-two">Linked Dropdown&nbsp;
                                <select v-model.number="level2IndID" id="select-level-two" class="usa-input" style="width: 200px;">
                                    <option :value="null">none (single dropdown)</option>
                                    <option v-for="indicator in crosswalkLevelTwo"
                                        :key="'level2_' + indicator.indicatorID"
                                        :value="parseInt(indicator.indicatorID)">
                                        {{indicator.indicatorID}}: {{getIndicatorName(parseInt(indicator.indicatorID))}}
                                    </option>
                                </select>
                            </label>
                        </div>
                    </div>
                    <!-- SUMMARY / REVIEW -->
                    <div v-if="conditionComplete" id="condition_preview">
                        <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                            <b>Review Condition Setup</b>
                            <hr>
                            <b>IF</b>
                            '{{getIndicatorName(parentIndID)}}' 
                            {{selectedOperatorText}}
                            <span v-html="parentTriggersDisplay"></span>
                            <b>THEN</b>
                            '{{getIndicatorName(childIndID)}}'
                            <span v-if="conditions.selectedOutcome === 'pre-fill'">will 
                                <span style="font-weight: bold;"> have the value{{childPrefillDisplay}}</span>
                            </span>
                            <span v-else>will 
                                <span style="font-weight: bold;">
                                    be {{conditions.selectedOutcome === "show" ? 'shown' : 'hidden'}}
                                </span>
                            </span>
                        </template>
                        <template v-else>
                            <p>Selection options will be loaded from <b>{{ conditions.crosswalkFile }}</b></p>
                        </template>
                    </div>
                    <div v-if="noOptions">No options are currently available for this selection</div>
                </template>
            </div>
        </div>` 
}