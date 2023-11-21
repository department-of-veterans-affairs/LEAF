const ConditionsEditor = Vue.createApp({
  data() {
    return {
      orgchartPath: orgchartPath,
      childIndID: 0,
      parentIndID: 0,
      windowTop: 0,

      indicators: [],
      currFormIndicators: [],
      selectedOperator: "",
      selectedParentValue: "",
      selectedOutcome: "",
      selectedChildValue: "",
      showRemoveModal: false,
      showConditionEditor: false,
      selectedConditionJSON: "",
      enabledParentFormats: ["dropdown", "multiselect", "radio", "checkboxes"],
      multiOptionFormats: ["multiselect", "checkboxes"],
      orgchartFormats: ["orgchart_employee","orgchart_group","orgchart_position"],
      orgchartSelectData: {},
      fileManagerFiles: [],
      crosswalkFile: '',
      crosswalkHasHeader: false,
      level2IndID: null,
      noPrefillFormats: ['', 'fileupload', 'image']
    };
  },
  created() {
    this.getAllIndicators();
    this.getFileManagerFiles();
  },
  mounted() {
    document.addEventListener("scroll", this.onScroll);
  },
  beforeUnmount() {
    document.removeEventListener("scroll", this.onScroll);
  },
  methods: {
    onScroll() {
      if (this.childIndID !== 0) return;
      this.windowTop = window.top.scrollY;
    },
    getAllIndicators() {
      //get all enabled indicators + headings
      $.ajax({
        type: "GET",
        url: "../api/form/indicator/list/unabridged",
        success: (res) => {
          this.indicators = res.filter(ele => parseInt(ele.indicatorID) > 0 && parseInt(ele.isDisabled) === 0);
          this.updateCurrFormIndicators();
        },
        error: (err) => {
          console.log(err);
        },
      });
    },
    getFileManagerFiles() {
      $.ajax({
        type: 'GET',
        url: '../api/system/files',
        success: (res) => {
          const files = res || [];
          this.fileManagerFiles = files.filter(
            filename => filename.indexOf('.txt') > -1 || filename.indexOf('.csv') > -1
          );
        },
        error: (err) => {
          console.log(err);
        },
        cache: false
      });
    },
    updateTooltips(formID = '') {
      const formIndicators = this.indicators.filter(i => i.categoryID === formID);
      formIndicators.map(i => {
        const tooltip = typeof i.conditions === 'string' && i.conditions.startsWith('[') ? 'Edit conditions (conditions present)' : 'Edit conditions';
        let elIcon = document.getElementById(`edit_conditions_${i.indicatorID}`);
        if(elIcon !== null) {
          elIcon.title = tooltip;
        }
      });
    },
    clearSelections(resetAll = false) {
      //cleared when either the form or child indicator changes
      if (resetAll) {
        this.childIndID = 0;
        ifThenIndicatorID = 0;
        this.showConditionEditor = false;
      }
      this.parentIndID = 0;
      this.selectedOperator = "";
      this.selectedParentValue = "";
      this.selectedOutcome = "";
      this.selectedChildValue = "";
      this.crosswalkFile = "";
      this.crosswalkHasHeader = false;
      this.level2IndID = null;
      this.selectedConditionJSON = "";
    },
    /**
     * @param {number} indicatorID
     */
    updateSelectedParentIndicator(indicatorID = 0) {
      this.parentIndID = parseInt(indicatorID);
      if(!this.selectedParentValueOptions.includes(this.selectedParentValue)) {
        this.selectedParentValue = "";
      }
      this.updateChoicesJS();
    },
    /**
    * @param {string} outcome (condition outcome options: Hide, Show, Pre-Fill, crosswalk)
    */
    updateSelectedOutcome(outcome = "") {
      this.selectedOutcome = outcome.toLowerCase();
      this.selectedChildValue = ""; //reset possible prefill and crosswalk data
      this.crosswalkFile = "";
      this.crosswalkHasHeader = false;
      this.level2IndID = null;
      if(this.selectedOutcome === 'pre-fill') {
        this.updateChoicesJS();
        this.addOrgSelector();
      }
    },
    /**
    * @param {Object} target (DOM element)
    * @param {string} type parent or child
    */
    updateSelectedOptionValue(target = {}, type = 'parent') {
      type = type.toLowerCase();
      const format = type === 'parent' ? this.parentFormat : this.childFormat;

      let value = '';
      if (this.multiOptionFormats.includes(format)) {
          const arrSelections = Array.from(target.selectedOptions);
          arrSelections.forEach(sel => {
              value += sel.label.trim() + '\n';
          });
          value = value.trim();
      } else {
          value = target.value.trim();
      }
      if (type === 'parent') {
          this.selectedParentValue = XSSHelpers.stripAllTags(value);
      } else if (type === 'child') {
          this.selectedChildValue = XSSHelpers.stripAllTags(value);
      }
    },
    selectNewChildIndicator() {
      this.clearSelections();
      if (this.childIndID !== 0) {
        this.dragElement(
          document.getElementById("condition_editor_center_panel")
        );
      }
    },
    /**
     * Recursively searches indicators to add headerIndicatorID to the indicators list.
     * The headerIndicatorID is used to track which indicators are on the same page.
     * @param {Number} indID parent ID of indicator at the current depth
     * @param {Object} initialIndicator reference to the indicator to update
     */
    addHeaderIDs(indID = 0, initialIndicator = {}) {
      const parent = this.currFormIndicators.find(i => parseInt(i.indicatorID) === indID);
      if(parent === undefined) return;
      //if the parent has a null parentID, then this is the header, update the passed reference
      if (parent?.parentIndicatorID === null) {
        initialIndicator.headerIndicatorID = indID;
      } else {
        this.addHeaderIDs(parseInt(parent.parentIndicatorID), initialIndicator);
      }
    },
    newCondition() {
      this.selectedConditionJSON = "";
      this.showConditionEditor = true;
      this.parentIndID = 0;
      this.selectedOperator = "";
      this.selectedParentValue = "";
      this.selectedOutcome = "";
      this.selectedChildValue = "";
      this.crosswalkFile = "";
      this.crosswalkHasHeader = false;
      this.level2IndID = null;
      if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    },
    postConditions(addSelected = true) {
      if (this.conditionComplete || addSelected === false) {
        const childID = this.childIndID;
        let indToUpdate = this.currFormIndicators.find(i => parseInt(i.indicatorID) === childID);
        //copy of all conditions on child, and filter using stored JSON val
        let currConditions = [...this.savedConditions];
        let newConditions = currConditions.filter(c => JSON.stringify(c) !== this.selectedConditionJSON);
        //clean up some possible data type issues and br tags before saving.
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
        const newJSON = newConditions.length > 0 ? JSON.stringify(newConditions) : '';

        $.ajax({
            type: 'POST',
            url: `../api/formEditor/${childID}/conditions`,
            data: {
                conditions: newJSON,
                CSRFToken: CSRFToken
            },
            success: (res)=> {
                if (res !== 'Invalid Token.') {
                  indToUpdate.conditions = newJSON;
                  this.showRemoveModal = false;
                  this.clearSelections(true);
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
     * @param {Object} conditionObj
     */
    selectConditionFromList(conditionObj = {}) {
      this.selectedConditionJSON = JSON.stringify(conditionObj);
      this.showConditionEditor = true;
      this.parentIndID = parseInt(conditionObj?.parentIndID || 0);
      this.selectedOperator = conditionObj?.selectedOp || '';
      this.selectedParentValue = conditionObj?.selectedParentValue || '';
      this.selectedOutcome = conditionObj?.selectedOutcome?.toLowerCase() || '';
      this.selectedChildValue = XSSHelpers.stripAllTags(conditionObj?.selectedChildValue || '');
      this.crosswalkFile = conditionObj?.crosswalkFile;
      this.crosswalkHasHeader = conditionObj?.crosswalkHasHeader;
      this.level2IndID = conditionObj?.level2IndID;
      this.updateChoicesJS();
      this.addOrgSelector();
    },
    /**
     *
     * @param {Object} el (DOM element)
     */
    dragElement(el = {}) {
      let pos1 = 0,
        pos2 = 0,
        pos3 = 0,
        pos4 = 0;

      if (document.getElementById(el.id + "_header")) {
        document.getElementById(el.id + "_header").onmousedown = dragMouseDown;
      }

      function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        document.onmousemove = elementDrag;
      }

      function elementDrag(e) {
        e = e || window.event;
        e.preventDefault();
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;
        el.style.top = el.offsetTop - pos2 + "px";
        el.style.left = el.offsetLeft - pos1 + "px";
      }

      function closeDragElement() {
        if (el.offsetTop - window.top.scrollY < 0) {
          el.style.top = window.top.scrollY + 15 + "px";
        }
        if (el.offsetLeft < 320) {
          el.style.left = "320px";
        }
        document.onmouseup = null;
        document.onmousemove = null;
      }
    },
    /** uses variable from mod_form.tpl */
    updateCurrFormIndicators() {
      const formID = currCategoryID || '';
      this.currFormIndicators = this.indicators.filter(i => i.categoryID === formID);
      this.currFormIndicators.forEach(i => {
        //update tooltips for current form
        const tooltip = typeof i.conditions === 'string' && i.conditions.startsWith('[') ?
            'Edit conditions (conditions present)' : 'Edit conditions';

        let elIcon = document.getElementById(`edit_conditions_${i.indicatorID}`);
        if(elIcon !== null) {
          elIcon.title = tooltip;
        }
        //add header info to assist filtering
        if (i.parentIndicatorID !== null) {
          this.addHeaderIDs(parseInt(i.parentIndicatorID), i);
        } else {
          i.headerIndicatorID = parseInt(i.indicatorID);
        }
      });
    },
    forceUpdate() {
      this.childIndID = ifThenIndicatorID;
      if (this.childIndID === 0) {
            this.getAllIndicators();
        } else {
            this.selectNewChildIndicator();
        }
    },
    truncateText(text = "", maxTextLength = 40) {
      return text?.length > maxTextLength
        ? text.slice(0, maxTextLength) + "... "
        : text || "";
    },
    /**
     * @param {number} id
     * @returns {string}
     */
    getIndicatorName(id = 0) {
      let indicatorName = this.currFormIndicators.find(i => parseInt(i.indicatorID) === id)?.name || "";
      indicatorName = XSSHelpers.stripAllTags(this.decodeAndStripHTML(indicatorName));
      return this.truncateText(indicatorName);
    },
    /**
    * removes encoded chars by passing through div and then strips all tags
    * @param {string} content 
    * @returns {string}
    */
    decodeAndStripHTML(content = '') {
      const elDiv = document.createElement('div');
      elDiv.innerHTML = content;
      return XSSHelpers.stripAllTags(elDiv.innerText);
    },
    /**
    * @param {Object} condition
    * @returns {string}
    */
    getOperatorText(condition = {}) {
      const parFormat = condition.parentFormat.toLowerCase();
      let text = condition.selectedOp;
      switch(text) {
          case '==':
              text = this.multiOptionFormats.includes(parFormat) ? 'includes' : 'is';
              break;
          case '!=':
              text = this.multiOptionFormats.includes(parFormat) ? 'does not include' : 'is not';
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
      switch(type) {
        case 'show':
          text = 'This field will be hidden except:'
          break;
        case 'hide':
          text = 'This field will be shown except:'
          break;
        case 'prefill':
          text = 'This field will be pre-filled:'
          break;
        case 'crosswalk':
          text = 'This field has loaded dropdown(s)'
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
      const parentInd = this.selectableParents.find(
        p => parseInt(p.indicatorID) === savedParIndID
      );
      const parentIndFormat = (parentInd?.format || '')
        .toLowerCase()
        .split('\n')[0].trim();

      return savedChildFormat !== this.childFormat || savedParentFormat !== parentIndFormat;
    },
    /**
     * Creates choicejs combobox instances for multiselect format select boxes
     */
    updateChoicesJS() {
      setTimeout(() => {
        const elExistingChoicesChild = document.querySelector("#child_choices_wrapper > div.choices");
        const elSelectParent = document.getElementById("parent_compValue_entry_multi");
        const elSelectChild = document.getElementById("child_prefill_entry_multi");
        const outcome = this.conditions.selectedOutcome;

        if (
          this.multiOptionFormats.includes(this.parentFormat) &&
          elSelectParent !== null &&
          !elSelectParent.choicesjs
        ) {
          let arrValues = this.conditions?.selectedParentValue.split("\n") || [];
          arrValues = arrValues.map((v) => this.decodeAndStripHTML(v).trim());

          let options = this.selectedParentValueOptions.map((o) => ({
            value: o.trim(),
            label: o.trim(),
            selected: arrValues.includes(o.trim()),
          }));
          const choices = new Choices(elSelectParent, {
            allowHTML: false,
            removeItemButton: true,
            editItems: true,
            choices: options.filter((o) => o.value !== ""),
          });
          elSelectParent.choicesjs = choices;
        }

        if (
          outcome === "pre-fill" &&
          this.multiOptionFormats.includes(this.childFormat) &&
          elSelectChild !== null &&
          elExistingChoicesChild === null
        ) {
          let arrValues = this.conditions?.selectedChildValue.split("\n") || [];
          arrValues = arrValues.map((v) => this.decodeAndStripHTML(v).trim());

          let options = this.selectedChildValueOptions.map((o) => ({
            value: o.trim(),
            label: o.trim(),
            selected: arrValues.includes(o.trim()),
          }));
          const choices = new Choices(elSelectChild, {
            allowHTML: false,
            removeItemButton: true,
            editItems: true,
            choices: options.filter((o) => o.value !== ""),
          });
          elSelectChild.choicesjs = choices;
        }
      });
    },
    addOrgSelector() {
      if (this.selectedOutcome === 'pre-fill' && this.orgchartFormats.includes(this.childFormat)) {
        const selType = this.childFormat.slice(this.childFormat.indexOf('_') + 1);
        setTimeout(() => {
            this.initializeOrgSelector(
                selType, this.childIndID, 'ifthen_child_', this.selectedChildValue, this.setOrgSelChildValue
            );
        });
      }
    },
    initializeOrgSelector(
      selType = 'employee',
      indID = 0,
      idPrefix = '',
      initialValue = '',
      selectorCallback = null
    ) {
      selType = selType.toLowerCase();
      const inputPrefix = selType === 'group' ? 'group#' : '#';
      let orgSelector = {};
      if (selType === 'group') {
        orgSelector = new groupSelector(`${idPrefix}orgSel_${indID}`);
      } else if (selType === 'position') {
        orgSelector = new positionSelector(`${idPrefix}orgSel_${indID}`);
      } else {
        orgSelector = new employeeSelector(`${idPrefix}orgSel_${indID}`);
      }
      orgSelector.apiPath = `${this.orgchartPath}/api/`;
      orgSelector.rootPath = `${this.orgchartPath}/`;
      orgSelector.basePath = `${this.orgchartPath}/`;
      orgSelector.setSelectHandler(() => {
        const elOrgSelInput = document.querySelector(`#${orgSelector.containerID} input.${selType}SelectorInput`);
        if(elOrgSelInput !== null) {
          elOrgSelInput.value = `${inputPrefix}` + orgSelector.selection;
        }
      });
      if(typeof selectorCallback === 'function') {
        orgSelector.setResultHandler(() => selectorCallback(orgSelector));
      }
      orgSelector.initialize();
      //input initial value if there is one
      const elOrgSelInput = document.querySelector(`#${orgSelector.containerID} input.${selType}SelectorInput`);
      if (initialValue !== '' && elOrgSelInput !== null) {
        elOrgSelInput.value = `${inputPrefix}` + initialValue;
      }
    },
    setOrgSelChildValue(orgSelector = {}) {
      if(orgSelector.selection !== undefined) {
        this.orgchartSelectData = orgSelector.selectionData[orgSelector.selection];
        this.selectedChildValue = orgSelector.selection.toString();
      }
    }
  },
  computed: {
    showSetup() {
      return  !this.showRemoveModal && this.showConditionEditor &&
          (this.selectedOutcome === 'crosswalk' || this.selectableParents.length > 0);
    },
    noOptions() {
      return !['', 'crosswalk'].includes(this.selectedOutcome) && this.selectableParents.length < 1;
    },
    childIndicator() {
      const indicator = this.currFormIndicators.find(i => parseInt(i.indicatorID) === this.childIndID);
      return indicator === undefined ? {} : {...indicator};
    },
    /**
    * @returns {object} current parent selection
    */
    selectedParentIndicator() {
      const indicator = this.selectableParents.find(
          i => parseInt(i.indicatorID) === this.parentIndID
      );
      return indicator === undefined ? {} : {...indicator};
    },
    /**
    * @returns {string} lower case base format of the parent question if there is one
    */
    parentFormat() {
      const f = (this.selectedParentIndicator?.format || '').toLowerCase();
      return f.split('\n')[0].trim();
    },
    /**
     * @returns {string} lower case base format of the child question
     */
    childFormat() {
        const f = (this.childIndicator?.format || '').toLowerCase();
        return f.split('\n')[0].trim();
    },
    /**
    * @returns list of indicators that are on the same page, enabled as parents, and different than child 
    */
    selectableParents() {
      let selectable = [];
      const headerIndicatorID = this.childIndicator?.headerIndicatorID || 0;
      if (headerIndicatorID !== 0) {
        selectable = this.currFormIndicators.filter(i => {
          const parFormat = i.format?.split('\n')[0].trim().toLowerCase();
          return i.headerIndicatorID === headerIndicatorID &&
              parseInt(i.indicatorID) !== this.childIndID &&
              this.enabledParentFormats.includes(parFormat);
        });
      }
      return selectable;
    },
    /**
    * @returns list of operators and human readable text base on parent format
    */
    selectedParentOperators() {
      let operators = [];
      switch(this.parentFormat) {
        case 'multiselect':
        case 'checkboxes':
          operators = [
              {val:"==", text: "includes"},
              {val:"!=", text: "does not include"}
          ];
          break;
        case 'dropdown':
        case 'radio':
        default:
          operators = [
              {val:"==", text: "is"},
              {val:"!=", text: "is not"}
          ];
          break;
      }
      return operators;
    },
    /**
     * @returns array of indicators that meet the criteria:
     * on the same page, not the currently selected question, base format is dropdown or multiselect
     */
    crosswalkLevelTwo() {
      let levelOptions = [];
      const headerIndicatorID = this.childIndicator?.headerIndicatorID || 0;
      if(headerIndicatorID !== 0) {
        levelOptions = this.currFormIndicators.filter((i) => {
          const format = i.format?.split("\n")[0].trim().toLowerCase();
          return (
              i.headerIndicatorID === headerIndicatorID &&
              parseInt(i.indicatorID) !== this.childIndID &&
              ['dropdown', 'multiselect'].includes(format)
          );
        });
      }
      return levelOptions;
    },
    /**
    * @returns list of options for comparison based on parent indicator selection
    */
    selectedParentValueOptions() {
      const fullFormatToArray = (this.selectedParentIndicator?.format || '').split("\n");
      let options = fullFormatToArray.length > 1 ? fullFormatToArray.slice(1) : [];
      options = options.map(o => o.trim());
      return options.filter(o => o !== '');
    },
    /**
    * @returns list of options for prefill outcomes.  Does NOT combine with file loaded options.
    */
    selectedChildValueOptions() {
      const fullFormatToArray = (this.childIndicator?.format || '').split("\n");
      let options = fullFormatToArray.length > 1 ? fullFormatToArray.slice(1) : [];
      options = options.map(o => o.trim());
      return options.filter(o => o !== '');
    },
    canAddCrosswalk() {
      return (this.childFormat === 'dropdown' || this.childFormat === 'multiselect')
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
    /**
     * @returns {Object} current conditions object
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
        parentFormat: this.parentFormat,
      };
    },
    /**
     *
     * @returns {boolean} if all required fields are entered for the current condition type
     */
    conditionComplete() {
      const {
        childIndID,
        parentIndID,
        selectedOp,
        selectedParentValue,
        selectedChildValue,
        selectedOutcome,
        crosswalkFile
      } = this.conditions;

      let returnValue = false;
      if (!this.showRemoveModal) { //don't bother if showing delete view
        switch(selectedOutcome.toLowerCase()) {
          case 'pre-fill':
            returnValue = parseInt(childIndID) !== 0
                          && parseInt(parentIndID) !== 0
                          && selectedOp !== ""
                          && selectedParentValue !== ""
                          && selectedChildValue !== "";
            break;
          case 'hide':
          case 'show':
            returnValue = parseInt(childIndID) !== 0
                          && parseInt(parentIndID) !== 0
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
      return returnValue;
    },
    /**
     *
     * @returns {Array} of condition objects
     */
    savedConditions() {
      return typeof this.childIndicator.conditions === 'string' && this.childIndicator.conditions[0] === '[' ?
        JSON.parse(this.childIndicator.conditions) : [];
    },
    /**
     * @returns {Object} with arrays of conditions by type
     */
    conditionTypes() {
      return {
        show: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "show"),
        hide: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "hide"),
        prefill: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "pre-fill"),
        crosswalk: this.savedConditions.filter(i => i.selectedOutcome.toLowerCase() === "crosswalk"),
      };
    }
  },
  watch: {
    childIndID(newVal, oldVal) {
      setTimeout(() => {
        const elNew = document.querySelector('#condition_editor_inputs .btnNewCondition');
        if(+newVal > 0 && elNew !== null) {
          elNew.focus();
        }
      });
    }
  },
  template: `<div id="condition_editor_content" :style="{display: childIndID===0 ? 'none' : 'block'}">
        <div id="condition_editor_center_panel" :style="{top: windowTop > 0 ? 15+windowTop+'px' : '15px'}">

            <!-- NOTE: MAIN EDITOR TEMPLATE -->
            <div id="condition_editor_inputs">
                <button id="btn-vue-update-trigger" @click="forceUpdate" style="display:none;" aria-hidden="true"></button>
                <div id="condition_editor_center_panel_header" class="editor-card-header">
                    <h3 style="color:black;">Conditions For <span style="color: #c00;">
                    {{getIndicatorName(childIndID)}} ({{childIndID}})
                    </span></h3>
                </div>
                <div>
                    <div v-if="savedConditions.length > 0 && !showRemoveModal" id="savedConditionsLists">
                        <!-- NOTE: LISTS BY CONDITION TYPE -->
                        <template v-for="typeVal, typeKey in conditionTypes" :key="typeVal">
                            <template v-if="typeVal.length > 0">
                                <p style="margin-bottom:2px;"><b>{{ listHeaderText(typeKey) }}</b></p>
                                <ul style="margin-bottom: 1rem;">
                                    <li v-for="c in typeVal" :key="c" class="savedConditionsCard">
                                        <button type="button" @click="selectConditionFromList(c)" class="btnSavedConditions" 
                                            :class="{selectedConditionEdit: JSON.stringify(c) === selectedConditionJSON, isOrphan: isOrphan(c)}">
                                            <template v-if="!isOrphan(c)">
                                                <div v-if="c.selectedOutcome.toLowerCase() !== 'crosswalk'">
                                                    If '{{getIndicatorName(parseInt(c.parentIndID))}}' 
                                                    {{getOperatorText(c)}} <strong>{{ decodeAndStripHTML(c.selectedParentValue) }}</strong> 
                                                    then {{c.selectedOutcome}} this question.
                                                </div>
                                                <div v-else>Options for this question will be loaded from <b>{{ c.crosswalkFile }}</b></div>
                                                <div v-if="childFormatChangedSinceSave(c)" class="changesDetected">
                                                  Format changes detected.  Please review and save to update this condition.
                                                </div>
                                            </template>
                                            <div v-else>This condition is inactive because indicator {{ c.parentIndID }} has been archived, deleted or is on another page.</div>
                                        </button>
                                        <button type="button" style="width: 1.75em;" class="btn_remove_condition"
                                            @click="removeCondition({confirmDelete: false, condition: c})">X
                                        </button>
                                    </li>
                                </ul>
                            </template>
                        </template>
                    </div>
                    <button v-if="!showRemoveModal" @click="newCondition" class="btnNewCondition">+ New Condition</button>
                    <div v-if="showRemoveModal">
                        <div>Choose <b>Delete</b> to confirm removal, or <b>cancel</b> to return</div>
                        <ul style="display: flex; justify-content: space-between; margin-top: 1em">
                            <li style="width: 30%;">
                                <button class="btn_remove_condition" @click="removeCondition({confirmDelete: true, condition: {}})">Delete</button>
                            </li>
                            <li style="width: 30%;">
                                <button id="btn_cancel" @click="showRemoveModal=false">Cancel</button>
                            </li>
                        </ul>
                    </div>
                </div>
                <div v-if="!showRemoveModal && showConditionEditor" id="outcome-editor">
                    <!-- OUTCOME SELECTION -->
                    <span v-if="conditions.childIndID" class="input-info">Select an outcome</span>
                    <select v-if="conditions.childIndID" title="select outcome"
                            @change="updateSelectedOutcome($event.target.value)">
                            <option v-if="conditions.selectedOutcome===''" value="" selected>Select an outcome</option>
                            <option value="show" :selected="conditions.selectedOutcome==='show'">Hide this question except ...</option>
                            <option value="hide" :selected="conditions.selectedOutcome==='hide'">Show this question except ...</option>
                            <option v-if="!noPrefillFormats.includes(childFormat)" 
                              value="pre-fill" :selected="conditions.selectedOutcome==='pre-fill'">Pre-fill this Question
                            </option>
                            <option v-if="canAddCrosswalk"
                              value="crosswalk" :selected="conditions.selectedOutcome==='crosswalk'">Load Dropdown or Crosswalk
                            </option>
                    </select>
                    <template v-if="!noOptions && conditions.selectedOutcome === 'pre-fill'">
                      <span class="input-info" id="prefill_value_entry">Enter a pre-fill value</span>
                      <!-- NOTE: PRE-FILL ENTRY AREA -->
                      <select v-if="childFormat==='dropdown' || childFormat==='radio'"
                          id="child_prefill_entry"
                          @change="updateSelectedOptionValue($event.target, 'child')">
                          <option v-if="conditions.selectedChildValue===''" value="" selected>Select a value</option>
                          <option v-for="val in selectedChildValueOptions"
                              :value="val"
                              :key="val"
                              :selected="decodeAndStripHTML(conditions.selectedChildValue)===val">
                              {{ val }}
                          </option>
                      </select>
                      <div v-else-if="multiOptionFormats.includes(childFormat)"
                        id="child_choices_wrapper" :key="'prefill_' + selectedConditionJSON">
                        <select placeholder="select some options"
                            multiple="true"
                            id="child_prefill_entry_multi"
                            style="display: none;"
                            @change="updateSelectedOptionValue($event.target, 'child')">
                        </select>
                      </div>
                      <input v-else-if="childFormat==='text' || childFormat==='textarea'" id="child_prefill_entry"
                          @change="updateSelectedOptionValue($event.target, 'child')"
                          :value="decodeAndStripHTML(conditions.selectedChildValue)" />
                      <div v-if="orgchartFormats.includes(childFormat)" :id="'ifthen_child_orgSel_' + conditions.childIndID"
                        style="min-height:30px" aria-labelledby="prefill_value_entry">
                      </div>
                    </template>
                </div>
                <div v-if="showSetup" class="if-then-setup">
                  <template v-if="conditions.selectedOutcome!=='crosswalk'">
                    <h4 style="margin: 0;">IF</h4>
                    <!-- NOTE: PARENT CONTROLLER SELECTION -->
                    <select title="select an indicator" class="comparison" @change="updateSelectedParentIndicator(parseInt($event.target.value))">
                        <option v-if="!conditions.parentIndID" value="" selected>Select an Indicator</option>
                        <option v-for="i in selectableParents"
                        :title="i.name"
                        :value="i.indicatorID"
                        :selected="parseInt(conditions.parentIndID)===parseInt(i.indicatorID)"
                        :key="i.indicatorID">
                        {{getIndicatorName(parseInt(i.indicatorID)) }} (#{{i.indicatorID}})
                        </option>
                    </select>
                    <!-- NOTE: OPERATOR SELECTION -->
                    <select v-model="selectedOperator" class="comparison" style="width:25%;">
                        <option v-if="conditions.selectedOp===''" value="" selected>Select a condition</option>
                        <option v-for="o in selectedParentOperators"
                        :value="o.val"
                        :key="o.val"
                        :selected="conditions.selectedOp===o.val">
                        {{ o.text }}
                        </option>
                    </select>
                    <!-- NOTE: COMPARED VALUE SELECTION (active parent formats: dropdown, multiselect, radio, checkboxes) -->
                    <select v-if="parentFormat===''" aria-hidden="true" class="comparison" style="visibility: hidden;"></select>
                    <select v-else-if="parentFormat==='dropdown' || parentFormat==='radio'"
                        id="parent_compValue_entry" class="comparison"
                        @change="updateSelectedOptionValue($event.target, 'parent')">
                        <option v-if="conditions.selectedParentValue===''" value="" selected>Select a value</option>
                        <option v-for="val in selectedParentValueOptions"
                            :key="val"
                            :selected="decodeAndStripHTML(conditions.selectedParentValue)===val"> {{ val }}
                        </option>
                    </select>
                    <div v-else-if="parentFormat==='multiselect' || parentFormat==='checkboxes'"
                      id="parent_choices_wrapper" class="comparison"
                      :key="'comp_' + selectedConditionJSON">
                      <select id="parent_compValue_entry_multi" class="comparison"
                          placeholder="select some options" multiple="true"
                          style="display: none;"
                          @change="updateSelectedOptionValue($event.target, 'parent')">
                      </select>
                    </div>
                  </template>
                  <!-- LOADED DROPDOWNS AND CROSSWALKS -->
                  <div v-else style="display: flex; align-items: center; row-gap: 1rem; width: 100%; flex-wrap: wrap;">
                    <div style="width: 100%; display:flex; align-items: center;">
                      <label for="select-crosswalk-file">File</label>
                      <select v-model="crosswalkFile" style="margin: 0 1rem 0 0.25rem;" id="select-crosswalk-file">
                        <option value="">Select a file</option>
                        <option v-for="f in fileManagerFiles" :key="f" :value="f">{{f}}</option>
                      </select>
                      <label for="select-crosswalk-header">Does&nbsp;the&nbsp;file&nbsp;contain&nbsp;headers?</label>
                      <select v-model="crosswalkHasHeader" style="margin: 0 0 0 0.25rem; width:65px;" id="select-crosswalk-header">
                        <option :value="false">No</option>
                        <option :value="true">Yes</option>
                      </select>
                    </div>
                    <div style="width: 100%; display:flex; align-items: center;">
                      <label for="select-level-two">Controlled&nbsp;Dropdown</label>
                      <select v-model.number="level2IndID" style="margin: 0 0 0 0.25rem;" id="select-level-two">
                        <option :value="null">none (single dropdown)</option>
                        <option v-for="indicator in crosswalkLevelTwo"
                          :key="'level2_' + indicator.indicatorID"
                          :value="parseInt(indicator.indicatorID)">
                          {{indicator.indicatorID}}: {{getIndicatorName(parseInt(indicator.indicatorID))}}
                        </option>
                      </select>
                    </div>
                  </div>
                </div>
                <div v-if="conditionComplete">
                  <template v-if="conditions.selectedOutcome !== 'crosswalk'">
                    <h4 style="margin: 0; display:inline-block">THEN</h4> '{{getIndicatorName(childIndID)}}'
                    <span v-if="conditions.selectedOutcome==='pre-fill'">will
                    <span style="color: #00A91C; font-weight: bold;"> have the value{{childPrefillDisplay}}</span>
                    </span>
                    <span v-else>will
                        <span style="color: #00A91C; font-weight: bold;">
                        be {{conditions.selectedOutcome==="show" ? 'shown' : 'hidden'}}
                        </span>
                    </span>
                  </template>
                  <template v-else>
                    <p>Selection options will be loaded from <b>{{ conditions.crosswalkFile }}</b></p>
                  </template>
                </div>
                <div v-if="noOptions">No options are currently available for this selection</div>
            </div>

            <!--NOTE: save cancel panel  -->
            <div v-if="!showRemoveModal" id="condition_editor_actions">
                <div>
                    <ul style="display: flex; justify-content: space-between;">
                        <li style="width: 30%;">
                            <button v-if="conditionComplete" id="btn_add_condition" @click="postConditions(true)">Save</button>
                        </li>
                        <li style="width: 30%;">
                            <button id="btn_cancel" @click="clearSelections(true)">Cancel</button>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>`,
});

ConditionsEditor.mount("#LEAF_conditions_editor");
