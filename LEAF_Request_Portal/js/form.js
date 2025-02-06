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
  let errorCount = 0;

  $("#" + containerID).html(
    '<div id="' +
      prefixID +
      'xhrDialog" style="display: none; background-color: white; border-style: none solid solid; border-width: 0 1px 1px; border-color: #e0e0e0; padding: 4px">\
            <form id="' +
      prefixID +
      'record" enctype="multipart/form-data" action="javascript:void(0);">\
                <div>\
                    <div id="form-xhr-cancel-save-menu" style="border-bottom: 2px solid black; height: 30px">\
                        <button type="button" id="' +
      prefixID +
      'button_cancelchange" class="buttonNorm" ><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="" /> Cancel</button>\
                        <button type="button" id="' +
      prefixID +
      'button_save" class="buttonNorm"><img src="dynicons/?img=media-floppy.svg&amp;w=16" alt="" /> Save Change</button>\
                    </div>\
                    <div id="' +
      prefixID +
      'loadIndicator" aria-hidden="true" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 300px; width: 460px">Loading... <img src="images/largespinner.gif" alt="" /></div>\
                    <div id="' +
      prefixID +
      'xhr" style="min-width: 540px; min-height: 420px; padding: 8px; overflow: auto" aria-live="polite"></div>\
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

    /** CROSSWALK variables and functions */
    let dropdownInfo = {};

    function loadRecordData(indID) {
      return new Promise((resolve, reject)=> {
        $.ajax({
          type: 'GET',
          //need to know the category ID (different from main form if this is on an internal)
          url: `./api/form/${recordID}/rawIndicator/${indID}/1?x-filterData=categoryID`,
          success: (indicator) => {
            const categoryID = indicator[indID]?.categoryID || "";
            $.ajax({
              type: 'GET',
              url: `./api/form/${recordID}/_${categoryID}/data`,
              success: (result) => {
                resolve(result)
              },
              error: (err) => {
                reject(err)
              }
            });
          },
          error: (err) => {
            reject(err)
          }
        });
      });
    }

    function loadFilemanagerFile(fileName, iID) {
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
      options = options.filter(o => o !== dropdownInfo[iID].headerName && o !== "");
      options = options.sort(
          (a, b) => a.localeCompare(
            b,
            undefined,
            {
              numeric: true,
              sensitivity: 'base',
            }
          )
      );
      options = options.reverse();
      return options;
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

        loadFilemanagerFile(dropdownInfo[indID].fileName, indID).then(fileContents => {
          dropdownInfo[indID].fileContents = fileContents;  //save for crosswalk listeners
          const optionsAreRemoved = removeSelectOptions(indID);
          if (optionsAreRemoved === true) {
            const options = getSelectOptions(fileContents, indID);
            setSelectOptions(options, indID, formdata);
          }
        }).catch(err => console.log('could not get file contents', err));

      } else {
        console.log('unexpected number of crosswalk conditions.  check indicator condition entry for ', indID)
      }
    }
    /** cross walk end */

    /** HIDE/SHOW/PREFILL variables and functions */

    /**
    * Reset required validators if needed.  Based on display status.
    * @param {number|string} childID ID of the question being assessed
    **/
    const handleChildValidators = (childID = "") => {
      const elChildResponse = document.querySelector(`div.response.blockIndicator_${childID}`);
      if(elChildResponse !== null) {
        const arrSubchildren = Array.from(
          elChildResponse.querySelectorAll(`div.response[class*="blockIndicator_"]`)
        );
        const arrBlocks = [ elChildResponse, ...arrSubchildren ];
        arrBlocks.forEach(element => {
          const id = +element.className.match(/(?<=blockIndicator_)(\d+)/)?.[0];
          if(id > 0) {
            //If required validator and dialog exist, reset validator if there is not a hidden ancestor (exclude the one in the process of being assessed)
            const closestHidden = element.closest(`.response-hidden:not(.blockIndicator_${childID})`);
            const shouldSetRequired = closestHidden === null;
            const isRequired = typeof formRequired[`id${id}`]?.setRequired === "function";
            if (isRequired && dialog !== null && shouldSetRequired) {
              dialog.requirements[id] = formRequired[`id${id}`].setRequired;
            }
          }
        });
      }
    };
    //validator ref for required question in a hidden state, used to allow front end progress when the state is hidden.
    const hideShowValidator = function () {
      return false;
    };

    //NOTE: run only for conditional code with parent controllers (hide, show and prefill)
    const checkConditions = (event = 0, selected = 0, parID = 0) => {
      const parentElID =
        event !== null ? parseInt(event.target.id) : parseInt(parID);

      //!! Questions can have multiple controllers. Get ALL conditions for children if ANY of their controllers match parentElID.
      //!! Checking is separated into batches of hide/show, prefill (prefills are run after conditional display states)
      let hideShowCondByChild = {};
      let prefillCondByChild = {};
      for(let childKey in formConditions) {
        if(formConditions[childKey].conditions.some(
          cond => parseInt(cond.parentIndID) === parentElID)
        ) {
          hideShowCondByChild[childKey] = [
            ...formConditions[childKey].conditions.filter(
              cond => ['hide', 'show'].includes(cond.selectedOutcome.toLowerCase())
            )
          ]
          prefillCondByChild[childKey] = [
            ...formConditions[childKey].conditions.filter(
              cond => cond.selectedOutcome.toLowerCase() === 'pre-fill'
            )
          ]
        }
      }
      //some multiselect combobox updates don't work unless the stack is cleared
      setTimeout(() => {
        for (let childKey in hideShowCondByChild) {
          if(hideShowCondByChild[childKey].length > 0) {
            makeComparisons(hideShowCondByChild[childKey]);
          }
        }
        for (let childKey in prefillCondByChild) {
          if(prefillCondByChild[childKey].length > 0) {
            makeComparisons(prefillCondByChild[childKey]);
          }
        }
      });
    };

    /**
     * returns true if any of the selected values are in the conditionTriggerValues
     * @param {array} multiChoiceSelections array of selected option values
     * @param {array} conditionTriggerValues array of trigger values to compare against
     * @returns bool
     */
    const valIncludesMultiselOption = (multiChoiceSelections = [], conditionTriggerValues = []) => {
      let includesValue = false;
      for (let i = 0; i < multiChoiceSelections.length; i++) {
        if (conditionTriggerValues.includes(multiChoiceSelections[i])) {
          includesValue = true;
          break;
        }
      }
      return includesValue;
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
     * used to get the sanitized input value for single option parent controllers
     * @param {*} pFormat format of the parent according to conditions object
     * @param {*} pIndID id of the parent according to the conditions object
     * @returns string.
     */
    const getParentValue = (pFormat = "", pIndID = 0) => {
      let val = "";
      if (pFormat === "radio") {
        val = document.querySelector(`input[id^="${pIndID}_radio"]:checked`)?.value || "";
      }
      if (["dropdown", "currency", "number"].includes(pFormat)) {
        val = document.getElementById(pIndID)?.value || "";
      }
      return sanitize(val).trim();
    };

    /*hide the question and any subquestions. clear out potential entries and set validator for hidden questions */
    const clearValues = (childIndID = 0) => {
      const elChildResponse = document.querySelector(`div.response.blockIndicator_${childIndID}`);
      if(elChildResponse !== null) {
        const arrSubchildren = Array.from(
          elChildResponse.querySelectorAll(`div.response[class*="blockIndicator_"]`)
        );
        const arrBlocks = [ elChildResponse, ...arrSubchildren ];

        arrBlocks.forEach(element => {
          const id = +element.className.match(/(?<=blockIndicator_)(\d+)/)?.[0];
          if(id > 0) {
            //clear values for questions not already in a hidden state.
            const isHidden =  element.closest('.response-hidden') !== null;
            if(!isHidden) {
              let hasInput = false;
              let isBasicInput = false;

              if($("#" + id).val() || "" !== "") {
                hasInput = true;
                isBasicInput = true;
                $("#" + id).val(""); //basic input, single and multiselect dropdown, orgcharts
              }

              let radioAndCheckboxes = Array.from(element.querySelectorAll(`input[id^="${id}_"]:checked`));
              if (radioAndCheckboxes.length > 0) {
                hasInput = true;
                radioAndCheckboxes.forEach(box => box.checked = false);
              }

              //grids cannot be controllers so we do not need to worry about them having input for the final check below
              $(`#grid_${id}_1_input tbody td`) //grid table data
              .each(function () {
                if ($("textarea", this).length) {
                  $("textarea", this).val('');
                } else if ($("select", this).length) {
                  $("select", this).val('');
                } else if ($("input", this).length) {
                  $("input", this).val('');
                }
              });

              const isChosenDropdown = element.querySelector(`select[id="${id}"] + .chosen-container`)
              if(isChosenDropdown) {
                let elChildInput = $("#" + id);
                elChildInput.chosen().val("");
                elChildInput.chosen({ width: "100%" });
                elChildInput.trigger("chosen:updated");
              }

              const isMultiselectQuestion = element.querySelector(`select[id="${id}"][multiple]`) !== null;
              if (isMultiselectQuestion) {
                clearMultiSelectChild($("#" + id), id);
              }

              const isRadioQuestion = element.querySelector(`input[id^="${id}_radio"]`) !== null;
              if(isRadioQuestion) {
                const radioEmpty = $(`input[id^="${id}_radio0"]`); //need to add hidden empty input to clear radio
                if (radioEmpty.length === 0) {
                  $(`div.response.blockIndicator_${id}`).prepend(
                    `<input id="${id}_radio0" name="${id}" value="" style="display:none;" />`
                  );
                }
                $(`input[id^="${id}_radio0"]`).prop("checked", true);
              }

              //if another parent controller is cleared by this, recheck it.
              if(childIndID !== id && hasInput && confirmedParElsByIndID.includes(id)) {
                if (isBasicInput === true) {
                  $("#" + id).trigger("change");
                } else {
                  //radio and checkboxes. only the parent question indicatorID matters here - eq(0) to trigger only one
                  $(`input[id^="${id}_"]`).eq(0).trigger("change");
                }
              }
            }
            //use the alternate hideshow validator for all subchildren
            if (
              dialog !== null
            ) {
              dialog.requirements[id] = hideShowValidator;
            }
          }
        });
      }
    };

    /**
     * @param {array} arrChildConditions array of conditions associated with a child question
     * This method is not called unless the array contains at least one element
     */
    const makeComparisons = (arrChildConditions = []) => {
      const multiOptionFormats = ["multiselect", "checkboxes"];
      const orgchartFormats = ["orgchart_employee", "orgchart_group", "orgchart_position"];
      //childID and childFormat same for all
      const childID = arrChildConditions[0].childIndID;
      const childFormat = arrChildConditions[0].childFormat.toLowerCase();

      //get child input elements
      const elChildInput = $("#" + childID); //input els for text, multiselect, dropdown and orgchart formats
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

        //multioption formats options will be a string of values separated with \n
        const arrCompareValues = parentComparisonValues
          .split("\n")
          .map((option) => option.replaceAll("\r", "").trim());
        //actual selected elements for multiselect and checkboxes (option or input elements)
        const selectionElements = parentFormat === "multiselect" ?
          Array.from(
            document.getElementById(parent_id)?.selectedOptions || []
          ) :
          Array.from(
            document.querySelectorAll(
              `input[type="checkbox"][id^="${parent_id}"]:checked`
            ) || []
          );
        const multiSelValues = selectionElements.map((sel) => {
          return sel?.label ?   //multiselect : checkboxes
            sanitize(sel.label.replaceAll("\r", "").trim()) :
            sanitize(sel.value.replaceAll("\r", "").trim())
        });
        //selected value for a radio or single select dropdown
        const parent_val = getParentValue(parentFormat, parent_id);
        //make both arrays for consistency and filter out any empties
        let val =  multiOptionFormats.includes(parentFormat) ? multiSelValues : [parent_val];
        val = val.filter(v => v !== '');

        let comparison = null;
        const op = cond.selectedOp;
        switch (op) {
          case "==":
          case "!=":
            //define comparison for value equality checking
            comparison = multiOptionFormats.includes(parentFormat) ?
              valIncludesMultiselOption(val, arrCompareValues) :
              val[0] !== undefined && val[0] === arrCompareValues[0];
            if(op === "!=") {
              comparison = !comparison;
            }
            break;
          case 'lt':
          case 'lte':
          case 'gt':
          case 'gte':
            const arrNumVals = val
              .filter(v => !isNaN(v))
              .map(v => +v);
            const arrNumComp = arrCompareValues
              .filter(v => !isNaN(v))
              .map(v => +v);
            const useOrEqual = op.endsWith('e');
            const useGreaterThan = op.startsWith('g');
            if(arrNumComp.length > 0) {
              for (let i = 0; i < arrNumVals.length; i++) {
                const currVal = arrNumVals[i];
                if(useGreaterThan === true) {
                  //unlikely to be set up with more than one comp val, but checking just in case
                  comparison = useOrEqual === true ? currVal >= Math.max(...arrNumComp) : currVal > Math.max(...arrNumComp);
                } else {
                  comparison = useOrEqual === true ? currVal <= Math.min(...arrNumComp) : currVal < Math.min(...arrNumComp);
                }
                if(comparison === true) {
                  break;
                }
              }
            }
            break;
          default:
            console.log(op);
            break;
        }
        if (
          ["hide", "show"].includes(outcome) &&
          comparison === true
        ) {
          hideShowConditionMet = true;
        }
        if (
          outcome === "pre-fill" &&
          childPrefillValue === "" &&
          comparison === true
        ) {
          childPrefillValue = cond.selectedChildValue.trim();
        }
      });

      /* Comparisons are made in two batches, hide/show, then prefills.  Crosswalks are not processed here.
      *  There should logically only be hide OR show for a single question, and one valid prefill.
      *  This means there should only be one type on the below outcomes array.
      */
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

      const co = (outcomes[0] || '').toLowerCase();
      switch (co) {
        case "hide":
          if (hideShowConditionMet === true) {
            clearValues(childID);
            elChildResponse.classList.add('response-hidden');
            elsChild.hide();
            elsChild.attr('aria-hidden', true);
          } else {
            elChildResponse.classList.remove('response-hidden');
            elsChild.removeAttr('aria-hidden');
            elsChild.show();
          }
          break;
        case "show":
          if (hideShowConditionMet === true) {
            elChildResponse.classList.remove('response-hidden');
            elsChild.removeAttr('aria-hidden');
            elsChild.show();
          } else {
            clearValues(childID);
            elChildResponse.classList.add('response-hidden');
            elsChild.hide();
            elsChild.attr('aria-hidden', true);
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
      //clear stack again before checking for hidden elements (might be some due to the order checks run in)
      setTimeout(() => {
        const closestHidden = elChildResponse.closest('.response-hidden');
        if (closestHidden !== null) {
          clearValues(childID);
        }

        if(confirmedParElsByIndID.some(id => id === childID)) { //chain trigger if the child is also a controller
          elChildInput.trigger("change");
          //radio and checkboxes. only the parent question indicatorID matters here - eq(0) to trigger only one
          $(`input[id^="${childID}_"]`).eq(0).trigger("change");
          if (childFormat === "dropdown") {
            elChildInput.chosen().val(elChildInput.val());
            elChildInput.chosen({ width: "100%" });
            elChildInput.trigger("chosen:updated");
          }
        }
      });
    };


    //confirm that the parent indicators exist on the form (in case of archive/deletion)
    let confirmedParElsByIndID = [];
    let crosswalkIDs = [];
    for (let entry in formConditionsByChild) {
      const formConditions = formConditionsByChild[entry].conditions || [];
      const currQuestionFormat = formConditionsByChild[entry].format.toLowerCase();

      formConditions.forEach((c) => {
        if (c.selectedOutcome.toLowerCase() === "crosswalk"
          && ["dropdown", "multiselect"].includes(currQuestionFormat)) {
            crosswalkIDs.push(parseInt(c.childIndID));

        } else {
          let parentEl = null;
          switch (c.parentFormat.toLowerCase()) {
            case "radio":
              parentEl = document.querySelector(`input[id^="${c.parentIndID}_radio"]`);
              break;
            case "checkboxes":
              parentEl = document.querySelector(`input[id^="${c.parentIndID}_"]`);
              break;
            default: //multisel, dropdown, inputs
              parentEl = document.getElementById(c.parentIndID);
              break;
          }
          if (parentEl !== null) {
            confirmedParElsByIndID.push(parseInt(c.parentIndID));
          } else {
            console.log(`Element associated with controller ${c.parentIndID} was not found in the DOM`)
          }
        }
      });
    }
    confirmedParElsByIndID = Array.from(new Set(confirmedParElsByIndID));
    crosswalkIDs = Array.from(new Set(crosswalkIDs));

    /*filter:
    current format is not raw_data, current and saved child formats match,
    and the parentID is confirmed to be found in the DOM */
    for (let entry in formConditionsByChild) {
      const currentFormat = formConditionsByChild[entry].format.toLowerCase();
      formConditionsByChild[entry].conditions = formConditionsByChild[
        entry
      ].conditions.filter(c =>
        currentFormat !== 'raw_data' &&
        currentFormat === c.childFormat.toLowerCase() &&
        (c.selectedOutcome === "crosswalk" || confirmedParElsByIndID.includes(+c.parentIndID))
      );
    }
    confirmedParElsByIndID.forEach((id) => {
      checkConditions(null, null, id);
      //initial condition check and listeners for confirmed parents.  input depends on format. jq will not err if element is not there
      $("#" + id).on("change", checkConditions);
      $(`input[id^="${id}_"]`).on("change", checkConditions); //this should cover both radio and checkboxes
    });

    if(crosswalkIDs.length > 0) {
      //If there is more than one crosswalkID they will still all be on the same page.
      //The id of the first one is used to confirm the cateogryID for subsequently getting data.
      loadRecordData(crosswalkIDs[0]).then(formdata => {
        crosswalkIDs.forEach(indID => runCrosswalk(indID, formdata));
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
      .html('<img src="images/indicator.gif" alt="" /> Saving...');

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
      url: rootURL + `api/form/${data.recordID}`,
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
      error: function() {
        errorCount++;
        let errorMsg = 'Please try again, there was a problem saving the data. This issue has been automatically reported.';
        if(errorCount > 2) {
            errorMsg += "\n\nIf this message persists, please contact your administrator for additional guidance.";
        }
        alert(errorMsg);
        dialog.setSaveHandler(function () {
            doModify();
        });
        $("#" + dialog.btnSaveID)
            .html(temp);
      }
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
