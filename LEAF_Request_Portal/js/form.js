/************************
    Form editor
*/
var form;
var formValidator = {};
var formRequired = {};
var formConditions = {};
var LeafForm = function (containerID) {
  var containerID = containerID;
  var prefixID = "LeafForm" + Math.floor(Math.random() * 1000) + "_";
  var htmlFormID = prefixID + "record";
  var dialog;
  var recordID = 0;
  var postModifyCallback;
  let rootURL = "";

  $("#" + containerID).html(
    '<div id="' +
      prefixID +
      'xhrDialog" style="display: none; background-color: white; border-style: none solid solid; border-width: 0 1px 1px; border-color: #e0e0e0; padding: 4px">\
            <form id="' +
      prefixID +
      'record" enctype="multipart/form-data" action="javascript:void(0);">\
                <div>\
                    <div id="form-xhr-cancel-save-menu" style="border-bottom: 2px solid black; height: 30px">\
                        <button id="' +
      prefixID +
      'button_cancelchange" class="buttonNorm" ><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="cancel" /> Cancel</button>\
                        <button id="' +
      prefixID +
      'button_save" class="buttonNorm"><img src="dynicons/?img=media-floppy.svg&amp;w=16" alt="save" /> Save Change</button>\
                    </div>\
                    <div id="' +
      prefixID +
      'loadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 300px; width: 460px">Loading... <img src="images/largespinner.gif" alt="loading..." /></div>\
                    <div id="' +
      prefixID +
      'xhr" style="min-width: 540px; min-height: 420px; padding: 8px; overflow: auto"></div>\
                </div>\
            </form>\
            </div>'
  );
  dialog = new dialogController(
    prefixID + "xhrDialog",
    prefixID + "xhr",
    prefixID + "loadIndicator",
    prefixID + "button_save",
    prefixID + "button_cancelchange"
  );

  function setRecordID(id) {
    recordID = id;
  }

  function setPostModifyCallback(func) {
    postModifyCallback = func;
  }

  function sanitize(input = "") {
    input = input.replace(/&/g, "&amp;");
    input = input.replace(/</g, "&lt;");
    input = input.replace(/>/g, "&gt;");
    input = input.replace(/"/g, "&quot;");
    input = input.replace(/'/g, "&#039;");
    return input;
  }

  function handleConditionalIndicators(
    formConditionsByChild = {},
    dialog = null
  ) {
    const allowedChildFormats = [
      "dropdown",
      "text",
      "multiselect",
      "radio",
      "checkboxes",
      "",
      "fileupload",
      "image",
      "textarea",
      "orgchart_employee",
      "orgchart_group",
      "orgchart_position",
    ];

    /** crosswalk variables and functions */
    let dropdownInfo = {};

    function loadRecordData() {
      return new Promise((resolve, reject)=> {
        $.ajax({
          type: 'GET',
          url: `./api/form/${recordID}/data`,
          success: (result) => {
            resolve(result)
          },
          error: (err) => {
            reject(err)
          }
        });
      });
    }

    function loadCrosswalkFile(fileName, iID) {
      return new Promise((resolve, reject)=> {
        const xhttpInds = new XMLHttpRequest();
        xhttpInds.onreadystatechange = () => {
          if (xhttpInds.readyState === 4) {
            switch(xhttpInds.status) {
              case 200:
                resolve(xhttpInds.responseText);
                break;
              case 404:
                let content = `The file for indicator ${iID} was not found at files/${fileName}.`
                content += `\nCheck the entered file name in setup and in the LEAF file manager.`
                reject(new Error(content));
                break;
              default:
                reject(new Error(xhttpInds.status));
                break;
            }
          }
        };
        xhttpInds.open("GET", `files/${fileName}`, true);
        xhttpInds.send();
      });
    }  

    function removeSelectOptions(iID) {
      let selectbox = document.getElementById(iID);
      const selectElementFound = selectbox && selectbox.nodeName === 'SELECT';
      if(!selectElementFound) {
        console.log(`-- Failed to remove options for ${iID}. Indicator was not found or is not a dropdown`);
      } else {
        while (selectbox.options.length > 0) selectbox.remove(0);
      }
      return selectElementFound;
    }

    function getSelectOptions(fileContent = "", iID, isLevel2 = false, indLevel1Val = null) {
      let uniqueList = [];
      if (isLevel2 && indLevel1Val !== null) {
        let level2_Options = [];
        let list = fileContent.split(/\n/);
        list = list.forEach(ele => {
          ele = ele.split(",");
          if (ele.length === 2 && indLevel1Val !== "") {
            let optLv1 = ele[0].trim();
            if (optLv1 === indLevel1Val || (Array.isArray(indLevel1Val) && indLevel1Val.includes(optLv1)) ) {
              level2_Options.push(ele[1]);
            }
          }
        });
        uniqueList = Array.from(new Set(level2_Options));
      } else {
        const list = fileContent.split(/\n/).map(line => line.split(",")[0]);
        uniqueList = Array.from(new Set(list));
      }

      let options = uniqueList.map(o => XSSHelpers.stripAllTags(o.trim()));

      if (!isLevel2 && options.length> 0 && dropdownInfo[iID].crosswalkHasHeader === true) {
        dropdownInfo[iID].headerName = options[0];
      }
      return options.filter(o => o !== dropdownInfo[iID].headerName && o !== "").sort().reverse();
    }

    function setSelectOptions(arrOptions = [], iID, formdata) {
      let selectbox = document.getElementById(iID);

      if (selectbox && selectbox.multiple === true) { //multiselect with choicesjs
        const formDataValue = formdata[iID]["1"].value || [];
        selectbox.choicesjs.destroy();   //choices obj is added in subindicators.tpl
        const options = arrOptions.map(o =>({
          value: o,
          label: o,
          selected: Array.isArray(formDataValue) && formDataValue.some(v => v === sanitize(o))
        }));
        const choices = new Choices(selectbox, {
          allowHTML: false,
          removeItemButton: true,
          editItems: true,
          choices: options.filter(o => o.value !== "")
        });
        selectbox.choicesjs = choices;

        let elEmptyOption = document.getElementById(`${iID}_empty_value`);
        if (elEmptyOption === null) {
            let opt = document.createElement('option');
            opt.id = `${iID}_empty_value`;
            opt.value = "";
            elEmptyOption = opt;
        }
        selectbox.appendChild(elEmptyOption);
        elEmptyOption.selected = selectbox.value === '';

      } else { //single dropdown with Chosen
        const formDataValue = formdata[iID]["1"].value || "";
        selectbox.append(`<option value=""></option>`);
        arrOptions.push("");
        arrOptions.forEach(o => {
          $('#'+iID).prepend(`<option value="${o}">${o}</option>`);
          if (sanitize(o) === formDataValue) {
            $('#'+iID).val(o);
          }
        });
        $('#'+iID).trigger("chosen:updated");
      }

      //if crosswalk (2 level dropdown)
      if (dropdownInfo[iID] !== undefined && dropdownInfo[iID].level2indID !== null) {
        const updateOptions = ()=> { //add listener to level 1
          const optionsAreRemoved = removeSelectOptions(dropdownInfo[iID].level2indID);
          if (optionsAreRemoved) {
            const options = getSelectOptions(dropdownInfo[iID].fileContents, iID, true, $('#'+iID).val());
            setSelectOptions(options, dropdownInfo[iID].level2indID, formdata);
          }
        }
        $('#'+iID).on('change', updateOptions);

        const optionsAreRemoved = removeSelectOptions(dropdownInfo[iID].level2indID);
        if (optionsAreRemoved) { //update level 2
          const options = getSelectOptions(dropdownInfo[iID].fileContents, iID, true, $('#'+iID).val());
          setSelectOptions(options, dropdownInfo[iID].level2indID, formdata);
        }
      }
    }
    /** cross walk end */

    let childRequiredValidators = {};
    const handleChildValidators = (childID) => {
      if (!childRequiredValidators[childID]) {
        childRequiredValidators[childID] = {
          validator: formRequired[`id${childID}`]?.setRequired,
        };
      }
      //reset the validator, if there is one, from the stored value
      if (
        childRequiredValidators[childID].validator !== undefined &&
        dialog !== null
      ) {
        dialog.requirements[childID] =
          childRequiredValidators[childID].validator;
      }
    };
    //validator ref for required question in a hidden state
    const hideShowValidator = function () {
      return false;
    };

    //NOTE: run only for crosswalks
    const runCrosswalk = (indID = 0, formdata = {}) => {
      //there should only be 1, and it is stored under the child id
      const allIndConditions = formConditions[`id${indID}`].conditions || [];
      const crosswalkConditions = allIndConditions.filter(
        c => c.selectedOutcome.toLowerCase() === "crosswalk"
      );
      if(crosswalkConditions.length === 1) {
        const cond = crosswalkConditions[0];
        dropdownInfo[indID] = { //defined in handleConditionalIndicators at start of crosswalk methods
          fileName: cond.crosswalkFile,
          crosswalkHasHeader: cond.crosswalkHasHeader,
          headerName: null,
          level2indID: cond.level2IndID
        }

        loadCrosswalkFile(dropdownInfo[indID].fileName, indID).then(fileContents => {
          dropdownInfo[indID].fileContents = fileContents;  //save for crosswalk listeners
          const optionsAreRemoved = removeSelectOptions(indID);
          if (optionsAreRemoved === true) {
            const options = getSelectOptions(fileContents, indID);
            setSelectOptions(options, indID, formdata);
          }
        }).catch(err => console.log('could not get file contents', err));

      } else {
        console.log('unexpected number of crosswalk conditions.  check indicator condition entry')
      }
    }

    //NOTE: run only for conditional code with parent controllers (hide, show and prefill)
    const checkConditions = (event = 0, selected = 0, parID = 0) => {
      const parentElID =
        event !== null ? parseInt(event.target.id) : parseInt(parID);

      const linkedParentConditions = getConditionsLinkedToParent(parentElID); //get all children directly controlled by this parent, and their ids
      let uniqueChildIDs = linkedParentConditions.map((c) =>
        parseInt(c.childIndID)
      );
      uniqueChildIDs = Array.from(new Set(uniqueChildIDs));

      let linkedChildConditions = [];
      uniqueChildIDs.forEach((id) => {
        linkedChildConditions.push(
          ...getConditionsLinkedToChild(id, parentElID)
        ); //get all other possible parents controlling the above children
      });

      let allConditions = [...linkedParentConditions, ...linkedChildConditions];
      let hideShowConditions = allConditions.filter((c) =>
        ["show", "hide"].includes(c.selectedOutcome.toLowerCase())
      );
      let prefillConditions = allConditions.filter(
        c => c.selectedOutcome.toLowerCase() === "pre-fill"
      );

      const hideShowCondByChild = {};
      hideShowConditions.map((c) => {
        hideShowCondByChild[c.childIndID]
          ? hideShowCondByChild[c.childIndID].push(c)
          : hideShowCondByChild[c.childIndID] = [c];
      });
      const prefillCondByChild = {};
      prefillConditions.map((c) => {
        prefillCondByChild[c.childIndID]
          ? prefillCondByChild[c.childIndID].push(c)
          : prefillCondByChild[c.childIndID] = [c];
      });
      setTimeout(() => {
        //some multiselect combobox updates don't work unless the stack is cleared
        for (let childID in hideShowCondByChild) {
          makeComparisons(childID, hideShowCondByChild[childID]);
        }
        for (let childID in prefillCondByChild) {
          makeComparisons(childID, prefillCondByChild[childID]);
        }
      });
    };
    /**
     *
     * @param {number} parentID
     * @returns array of conditions that have the given value for their parentIndID, or empty array
     */
    const getConditionsLinkedToParent = (parentID = 0) => {
      let conditionsLinkedToParent = [];
      if (parentID !== 0) {
        for (let entry in formConditionsByChild) {
          const formConditions = formConditionsByChild[entry].conditions || [];
          formConditions.forEach((c) => {
            const formatIsEnabled = allowedChildFormats.some(
              (f) => f === c.childFormat
            );
            //do not include conditions if the recorded condition format (condition.childFormat) does not
            //match the current format, as this would have unpredictable results
            if (
              formConditionsByChild[entry].format === c.childFormat &&
              formatIsEnabled &&
              parseInt(c.parentIndID) === parseInt(parentID)
            ) {
              conditionsLinkedToParent.push({ ...c });
            }
          });
        }
      }
      return conditionsLinkedToParent;
    };
    /**
     *
     * @param {number} childID id of a child condition
     * @param {number} currParentID the id of the controller that was updated
     * @returns array of all other parents that control the given child, or empty array
     */
    const getConditionsLinkedToChild = (childID = 0, currParentID = 0) => {
      let conditionsLinkedToChild = [];
      if (childID !== 0 && currParentID !== 0) {
        for (let entry in formConditionsByChild) {
          if (parseInt(entry.slice(2)) === parseInt(childID)) {
            const formConditions =
              formConditionsByChild[entry].conditions || [];
            formConditions.map((c) => {
              const formatIsEnabled = allowedChildFormats.some(
                (f) => f === c.childFormat
              );
              if (
                formConditionsByChild[entry].format === c.childFormat &&
                formatIsEnabled &&
                parseInt(currParentID) !== parseInt(c.parentIndID)
              ) {
                conditionsLinkedToChild.push({ ...c });
              }
            });
          }
        }
      }
      return conditionsLinkedToChild;
    };

    /**
     * returns true if any of the selected values are in the comparisonValues
     * @param {array} multiChoiceElements array of option elements or checkboxes
     * @param {array} comparisonValues array of values to compare against
     * @returns
     */
    const valIncludesMultiselOption = (
      multiChoiceElements = [],
      comparisonValues = []
    ) => {
      let result = false;
      //get the values associated with the selection elements
      let vals = multiChoiceElements.map((sel) => {
        if (sel?.label) {
          //multiselect option
          return sanitize(sel.label.replaceAll("\r", "").trim());
        } else {
          //checkboxes
          return sanitize(sel.value.replaceAll("\r", "").trim());
        }
      });
      vals.forEach((v) => {
        if (comparisonValues.includes(v)) {
          result = true;
        }
      });
      return result;
    };

    const clearMultiSelectChild = (element = [], childID = 0) => {
      element[0]?.choicesjs?.removeActiveItems();
      let elEmptyOption = document.getElementById(`${childID}_empty_value`);
      if (elEmptyOption === null) {
        let opt = document.createElement("option");
        opt.id = `${childID}_empty_value`;
        opt.value = "";
        element[0].appendChild(opt);
        elEmptyOption = document.getElementById(`${childID}_empty_value`);
      }
      elEmptyOption.selected = true;
    };
    /**
     * used to get the sanitized input value for radio and dropdown parents
     * @param {*} pFormat format of the parent according to conditions object
     * @param {*} pIndID id of the parent according to the conditions object
     * @returns string.
     */
    const getParentValue = (pFormat = "", pIndID = 0) => {
      let val = "";
      if (pFormat === "radio") {
        val =
          sanitize(
            document
              .querySelector(`input[id^="${pIndID}_radio"]:checked`)
              ?.value.trim()
          ) || "";
      }
      if (pFormat === "dropdown") {
        val = sanitize(document.getElementById(pIndID)?.value.trim()) || "";
      }
      return val;
    };

    const clearValues = (childFormat = "", childIndID = 0) => {
      $("#" + childIndID).val("");
      $(`input[id^="${childIndID}_"]`).prop("checked", false); //this will hit both radio and checkboxes formats
      $(`input[id^="${childIndID}_radio0"]`).prop("checked", true);
      if (childFormat === "multiselect") {
        clearMultiSelectChild($("#" + childIndID), childIndID);
      }
      if (
        childRequiredValidators[childIndID].validator !== undefined &&
        dialog !== null
      ) {
        dialog.requirements[childIndID] = hideShowValidator;
      }
    };

    /**
     *
     * @param {string} childID indicator ID of the child question, used to select associated DOM elements
     * @param {array} arrChildConditions array of conditions objects associated with the child question
     */
    const makeComparisons = (childID = "", arrChildConditions = []) => {
      const multiOptionFormats = ["multiselect", "checkboxes"];
      const orgchartFormats = ["orgchart_employee", "orgchart_group", "orgchart_position"];
      //childFormat should be the same for all, since formats that don't match the current question format are already removed.
      const childFormat = arrChildConditions[0].childFormat.toLowerCase();
      const chosenShouldUpdate = childFormat === "dropdown";

      //get child input elements
      const elChildInput = $("#" + childID); //input els for text, multiselect, dropdown and orgchart formats

      const radioEmpty = $(`input[id^="${childID}_radio0"]`); //radio format
      if (childFormat === "radio" && radioEmpty.length === 0) {
        $(`div.response.blockIndicator_${childID}`).prepend(
          `<input id="${childID}_radio0" name="${childID}" value="" style="display:none;" />`
        );
      }
      const elChildRadioBtns = $(`input[id^="${childID}_radio"]`);
      const elChildCheckboxes = $(`input[type="checkbox"][id^="${childID}"]`); //checkboxes format

      handleChildValidators(childID);

      let hideShowConditionMet = false;
      let childPrefillValue = "";

      arrChildConditions.forEach((cond) => {
        const parentFormat = cond.parentFormat.toLowerCase();
        const parent_id = cond.parentIndID;
        const parentComparisonValues = cond.selectedParentValue.trim();
        const outcome = cond.selectedOutcome.toLowerCase();

        switch (cond.selectedOp) {
          case "==":
            //these are repetitive, but potentially more confusing in a method because of their alteration of variables and comparison differences between operators
            if (multiOptionFormats.includes(parentFormat)) {
              //values from the condition to compare against. For multioption formats this will be a string of values separated with \n
              const arrCompareValues = parentComparisonValues
                .split("\n")
                .map((option) => option.replaceAll("\r", "").trim());
              //actual selected elements for multiselect and checkboxes (option or input elements)
              const selectionElements =
                parentFormat === "multiselect"
                  ? Array.from(
                      document.getElementById(parent_id)?.selectedOptions || []
                    )
                  : Array.from(
                      document.querySelectorAll(
                        `input[type="checkbox"][id^="${parent_id}"]:checked`
                      ) || []
                    );
              //hide and show should be mutually exclusive and only matter once, so don't continue if it has already become true
              if (
                ["hide", "show"].includes(outcome) &&
                !hideShowConditionMet &&
                valIncludesMultiselOption(selectionElements, arrCompareValues)
              ) {
                hideShowConditionMet = true;
              }
              //likewise if there are mult controllers for a prefill then they should have the same prefill value
              if (
                outcome === "pre-fill" &&
                childPrefillValue === "" &&
                valIncludesMultiselOption(selectionElements, arrCompareValues)
              ) {
                childPrefillValue = cond.selectedChildValue.trim();
              }
            } else {
              const parent_val = getParentValue(parentFormat, parent_id);
              if (
                ["hide", "show"].includes(outcome) &&
                !hideShowConditionMet &&
                parentComparisonValues === parent_val
              ) {
                hideShowConditionMet = true;
              }
              if (
                outcome === "pre-fill" &&
                childPrefillValue === "" &&
                parentComparisonValues === parent_val
              ) {
                childPrefillValue = cond.selectedChildValue.trim();
              }
            }
            break;
          case "!=":
            if (multiOptionFormats.includes(parentFormat)) {
              const arrCompareValues = parentComparisonValues
                .split("\n")
                .map((option) => option.replaceAll("\r", "").trim());
              const selectionElements =
                parentFormat === "multiselect"
                  ? Array.from(
                      document.getElementById(parent_id)?.selectedOptions || []
                    )
                  : Array.from(
                      document.querySelectorAll(
                        `input[type="checkbox"][id^="${parent_id}"]:checked`
                      ) || []
                    );

              if (
                ["hide", "show"].includes(outcome) &&
                !hideShowConditionMet &&
                !valIncludesMultiselOption(selectionElements, arrCompareValues)
              ) {
                hideShowConditionMet = true;
              }
              if (
                outcome === "pre-fill" &&
                childPrefillValue === "" &&
                !valIncludesMultiselOption(selectionElements, arrCompareValues)
              ) {
                childPrefillValue = cond.selectedChildValue.trim();
              }
            } else {
              const parent_val = getParentValue(parentFormat, parent_id);
              if (
                ["hide", "show"].includes(outcome) &&
                !hideShowConditionMet &&
                parentComparisonValues !== parent_val
              ) {
                hideShowConditionMet = true;
              }
              if (
                outcome === "pre-fill" &&
                childPrefillValue === "" &&
                parentComparisonValues !== parent_val
              ) {
                childPrefillValue = cond.selectedChildValue.trim();
              }
            }
            break;
          default:
            console.log(cond.selectedOp);
            break;
        }
      });

      /*There should only be hide OR show, and prefills should have only one valid comparison entry, so
      outcome checking only needs to run once per type (and there should only be one type on the outcomes array).
      Comparisons are made in two batches, hide/show, then prefills.  Crosswalks are not processed here*/
      let outcomes = [];
      if (arrChildConditions.some(c => c.selectedOutcome.toLowerCase() === "hide")) outcomes.push("hide");
      if (arrChildConditions.some(c => c.selectedOutcome.toLowerCase() === "show")) outcomes.push("show");
      if (arrChildConditions.some(c => c.selectedOutcome.toLowerCase() === "pre-fill")) outcomes.push("pre-fill");
      if (outcomes.length > 1) {
        console.log("check conditions setup for", childID);
      }

      //update child states and/or values.
      let elsChild = $(`.blockIndicator_${childID}`); //label and response divs to hide/show
      let elChildResponse = document.querySelector(`div.response.blockIndicator_${childID}`);
      const co = outcomes[0] || '';
      switch (co) {
        case "hide":
          if (hideShowConditionMet === true) {
            clearValues(childFormat, childID);
            elChildResponse.classList.add('response-hidden');
            elsChild.hide();
          } else {
            elChildResponse.classList.remove('response-hidden');
            elsChild.show();
          }
          break;
        case "show":
          if (hideShowConditionMet === true) {
            elChildResponse.classList.remove('response-hidden');
            elsChild.show();
          } else {
            clearValues(childFormat, childID);
            elChildResponse.classList.add('response-hidden');
            elsChild.hide();
          }
          break;
        case "pre-fill":
          const closestHidden = elChildResponse.closest('.response-hidden');
          if (childPrefillValue !== "" && closestHidden === null) {
            //checkboxes and multiselect items
            if (multiOptionFormats.includes(childFormat)) {
              const arrPrefills = childPrefillValue.split("\n");
              const arrChoices = arrPrefills.map((item) =>
                $("<div/>").html(item).text().trim()
              );
              $(`input[id^="${childID}_"]`).prop("checked", false); //clear out possible selections
              arrChoices.forEach((textVal) =>
                $(`input[id^="${childID}_"][value="${textVal}"]`).prop(
                  "checked",
                  true
                )
              );
              elChildCheckboxes.prop("disabled", true);

              if (childFormat === "multiselect") {
                let elSelectChoices = elChildInput[0].choicesjs;
                elSelectChoices?.removeActiveItems();
                elSelectChoices?.setChoiceByValue(arrChoices);
                elSelectChoices?.disable();
              }
              //orgchart formats
              } else if (orgchartFormats.includes(childFormat)) {
                const inputPrefix = childFormat === 'orgchart_group' ? 'group#' : '#';
                let orgSelInput = document.querySelector(`div[id$="Sel_${childID}"] input[id$="_input"]`);
                if (orgSelInput !== null) {
                  orgSelInput.value = inputPrefix + childPrefillValue;
                  orgSelInput.disabled = true;
                }
              //everything else
              } else {
                const text = $("<div/>").html(childPrefillValue).text().trim();
                elChildInput.val(text); //text, dropd
                elChildInput.attr("disabled", "disabled");
                $(`input[id^="${childID}_radio"][value="${text}"]`).prop(
                  "checked",
                  true
                ); //radio
                elChildRadioBtns.prop("disabled", true);
              }

          } else { //prefill val is empty, or the block is hidden
            elChildInput.removeAttr("disabled");
            elChildInput[0]?.choicesjs?.enable();
            elChildRadioBtns.prop("disabled", false);
            elChildCheckboxes.prop("disabled", false);
            let orgSelInput = document.querySelector(`div[id$="Sel_${childID}"] input[id$="_input"]`);
            if (orgSelInput !== null) {
              orgSelInput.disabled = false;
            }
          }
          break;
        default:
          console.log(co);
          break;
      }

      const closestHidden = elChildResponse.closest('.response-hidden');
      if (closestHidden !== null) {
        clearValues(childFormat, childID);
      }

      elChildInput.trigger("change");
      $(`input[id^="${childID}_"]`).trigger("change"); //radio and checkboxes
      if (chosenShouldUpdate) {
        elChildInput.chosen().val(elChildInput.val());
        elChildInput.chosen({ width: "100%" });
        elChildInput.trigger("chosen:updated");
      }
    };


    //confirm that the parent indicators exist on the form (in case of archive/deletion)
    let confirmedParElsByIndID = [];
    let notFoundParElsByIndID = [];
    let crosswalks = [];
    for (let entry in formConditionsByChild) {
      const formConditions = formConditionsByChild[entry].conditions || [];
      const currQuestionFormat = formConditionsByChild[entry].format.toLowerCase();

      formConditions.forEach((c) => {
        if (c.selectedOutcome.toLowerCase() === "crosswalk"
          && ["dropdown", "multiselect"].includes(currQuestionFormat)) {
          crosswalks.push(parseInt(c.childIndID));

        } else {
          let parentEl = null;
          switch (c.parentFormat.toLowerCase()) {
            case "radio": //radio buttons use indID_radio1, indID_radio2 etc
              parentEl = document.querySelector(
                `input[id^="${c.parentIndID}_radio"]`
              );
              break;
            case "checkboxes": //checkboxes use indID_0, indID_1 etc
              parentEl = document.querySelector(`input[id^="${c.parentIndID}_"]`);
              break;
            default: //multisel, dropdown, text use input id=indID.
              parentEl = document.getElementById(c.parentIndID);
              break;
          }
          if (parentEl !== null) {
            confirmedParElsByIndID.push(parseInt(c.parentIndID));
          } else {
            notFoundParElsByIndID.push(parseInt(c.parentIndID));
            console.log(`Element associated with controller ${c.parentIndID} was not found in the DOM`)
          }
        }
      });
    }
    confirmedParElsByIndID = Array.from(new Set(confirmedParElsByIndID));
    notFoundParElsByIndID = Array.from(new Set(notFoundParElsByIndID));
    crosswalks = Array.from(new Set(crosswalks));

    if (notFoundParElsByIndID.length > 0) {
      //filter out any conditions that have parent IDs of elements not found in the DOM
      for (let entry in formConditionsByChild) {
        formConditionsByChild[entry].conditions = formConditionsByChild[
          entry
        ].conditions.filter(
          (c) => !notFoundParElsByIndID.includes(parseInt(c.parentIndID))
        );
      }
    }
    confirmedParElsByIndID.forEach((id) => {
      checkConditions(null, null, id);
      //initial condition check and listeners for confirmed parents.  input depends on format. jq will not err if element is not there
      $("#" + id).on("change", checkConditions);
      $(`input[id^="${id}_"]`).on("change", checkConditions); //this should cover both radio and checkboxes
    });

    if(crosswalks.length > 0) {
      loadRecordData().then(formdata => {
        crosswalks.forEach(indID => runCrosswalk(indID, formdata));
      }).catch(err => console.log('record data did not load', err));
    }
  }

  function doModify() {
    if (recordID == 0) {
      console.log("recordID not set");
      return 0;
    }

    var hasTable = $("#" + htmlFormID).find(".tableinput").length !== 0;
    var temp = $("#" + dialog.btnSaveID).html();
    $("#" + dialog.btnSaveID)
      .empty()
      .html('<img src="images/indicator.gif" alt="saving" /> Saving...');

    $("#" + htmlFormID)
      .find(":input:disabled")
      .removeAttr("disabled");
    var data = { recordID: recordID };
    $("#" + htmlFormID)
      .serializeArray()
      .map(function (x) {
        if (x.name.includes("_multiselect")) {
          const i = x.name.indexOf("_multiselect");
          if (x.value === "") {
            //selected if no options are chosen
            data[x.name.slice(0, i)] = x.value;
          } else {
            data[x.name.slice(0, i)]
              ? data[x.name.slice(0, i)].push(x.value)
              : (data[x.name.slice(0, i)] = [x.value]);
          }
        } else data[x.name] = x.value;
      });

    if (hasTable) {
      var tables = [];

      $("#" + htmlFormID)
        .find(".tableinput > table")
        .each(function (index) {
          var gridObject = {};
          gridObject.cells = [];
          gridObject.names = [];

          // determines the order of the column values
          gridObject.columns = [];

          $("thead", this)
            .find("td")
            .slice(0, -1)
            .each(function () {
              gridObject.names.push($(this).text());
              gridObject.columns.push($("div", this).attr("id"));
            });

          $("tbody", this)
            .find("tr")
            .each(function () {
              var cellArr = [];
              $(this)
                .children("td")
                .each(function () {
                  if ($("textarea", this).length) {
                    cellArr.push($(this).find("textarea").val());
                  } else if ($("select", this).length) {
                    cellArr.push($("option:selected", this).val());
                  } else if ($("input", this).length) {
                    cellArr.push($("input", this).val());
                  }
                });
              gridObject.cells.push(cellArr);
            });
          tables[index] = {
            id: $(this).attr("id").split("_")[1],
            data: gridObject,
          };
        });

      $("#" + htmlFormID)
        .serializeArray()
        .map(function () {
          for (var i = 0; i < tables.length; i++) {
            data[tables[i].id] = tables[i].data;
          }
        });
    }

    $.ajax({
      type: "POST",
      url: rootURL + "ajaxIndex.php?a=domodify",
      data: data,
      dataType: "text",
      success: function (res) {
        if (postModifyCallback != undefined) {
          postModifyCallback();
        }
        $("#" + dialog.btnSaveID)
          .empty()
          .html(temp);
      },
      cache: false,
    });
  }

  function getForm(indicatorID, series) {
    if (recordID == 0) {
      console.log("recordID not set");
      return 0;
    }
    dialog.indicateBusy();

    dialog.setSaveHandler(function () {
      doModify();
    });

    formValidator = new Object();
    formRequired = new Object();
    formConditions = new Object();
    $.ajax({
      type: "GET",
      url:
        rootURL +
        "ajaxIndex.php?a=getindicator&recordID=" +
        recordID +
        "&indicatorID=" +
        indicatorID +
        "&series=" +
        series,
      dataType: "text",
      success: function (response) {
        dialog.setTitle("Editing #" + recordID);
        dialog.setContent(response);

        for (let i in formValidator) {
          let tID = i.slice(2);
          dialog.setValidator(tID, formValidator[i].setValidator);
          dialog.setSubmitValid(tID, formValidator[i].setSubmitValid);
          dialog.setValidatorError(tID, formValidator[i].setValidatorError);
          dialog.setValidatorOk(tID, formValidator[i].setValidatorOk);
        }

        for (let i in formRequired) {
          let tID = i.slice(2);
          dialog.setRequired(tID, formRequired[i].setRequired);
          dialog.setSubmitError(tID, formRequired[i].setSubmitError);
          dialog.setRequiredError(tID, formRequired[i].setRequiredError);
          dialog.setRequiredOk(tID, formRequired[i].setRequiredOk);
        }

        dialog.enableLiveValidation();

        handleConditionalIndicators(formConditions, dialog);
      },
      error: function (response) {
        dialog.setContent("Error: " + response);
      },
      cache: false,
    });
  }

  function initCustom(
    containerID,
    contentID,
    indicatorID,
    btnSaveID,
    btnCancelID
  ) {
    dialog = new dialogController(
      containerID,
      contentID,
      indicatorID,
      btnSaveID,
      btnCancelID
    );
    prefixID = "";
    htmlFormID = "record";
  }

  function setHtmlFormID(id) {
    htmlFormID = id;
  }

  return {
    dialog: function () {
      return dialog;
    },
    getHtmlFormID: function () {
      return htmlFormID;
    },
    serializeData: function () {
      return $("#" + htmlFormID).serialize();
    },
    setRootURL: function (url) {
      rootURL = url;
    },

    setRecordID: setRecordID,
    setPostModifyCallback: setPostModifyCallback,
    doModify: doModify,
    getForm: getForm,
    initCustom: initCustom,
    setHtmlFormID: setHtmlFormID,
  };
};
