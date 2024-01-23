var gridInput = function (gridParameters, indicatorID, series, recordID) {
  let fileOptions = {};
  function decodeCellHTMLEntities(values, showScriptTags = false) {
    let gridInfo = { ...values };
    if (gridInfo?.cells) {
      let cells = gridInfo.cells.slice();
      cells.forEach((arrRowVals, ci) => {
        arrRowVals = arrRowVals.map((v) => {
          v = v.replaceAll("<", "&lt;"); //handle old data values
          v = v.replaceAll(">", "&gt;");
          let elDiv = document.createElement("div");
          elDiv.innerHTML = v;
          let text = elDiv.innerText;
          if (showScriptTags !== true)
            text = text.replaceAll(
              /(<script[\s\S]*?>)|(<\/script[\s\S]*?>)/gi,
              ""
            );
          return text;
        });
        cells[ci] = arrRowVals.slice();
      });
      gridInfo.cells = cells;
    }
    return gridInfo;
  }

  function upArrows(row, toggle) {
    row.find('[title="Move line up"]').css("display", `${toggle ? 'inline' : 'none'}`);
  }
  function downArrows(row, toggle) {
    row.find('[title="Move line down"]').css("display", `${toggle ? 'inline' : 'none'}`);
  }
  /** adds remove row icon and up/down arrow row controls */
  function makeControlColumnTemplate(indicatorID = 0, series = 1, showUpArrow = false, showDownArrow = false) {
    return `<td>
      <img role="button" tabindex="0"
      onkeydown="gridInput_${indicatorID}_${series}.triggerClick(event);"
      onclick="gridInput_${indicatorID}_${series}.deleteRow(event)"
      src="dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" />
    </td>
    <td>
      <img role="button" tabindex="0"
      onkeydown="gridInput_${indicatorID}_${series}.triggerClick(event);"
      onclick="gridInput_${indicatorID}_${series}.moveUp(event)"
      src="dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: ${showUpArrow ? 'inline' : 'none'}; cursor: pointer" />
      </br></br>
      <img role="button" tabindex="0"
      onkeydown="gridInput_${indicatorID}_${series}.triggerClick(event);"
      onclick="gridInput_${indicatorID}_${series}.moveDown(event)"
      src="dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display: ${showDownArrow ? 'inline' : 'none'}; cursor: pointer" />
    </td>`;
  }
  /**
   * Used when displaying cells that could have saved values because cell positions can change.
   * The cell id of an element from the indicators.format array is searched for in the data field's 'columns' array.
   * If found, the corresponding value of the data field's cells array is returned. Otherwise, an empty string is returned.
   * @param {string} cellID identifying the current table column being rendered.
   * @param {array} dataColumnIDs array of cell IDs saved in the data field.
   * @param {array} dataRowValues array of cell data saved in the data field.
   * @returns string
   */
  function getDataValueByCellID(cellID = '', dataColumnIDs = [], dataRowValues = []) {
    let val = '';
    if (dataColumnIDs.includes(cellID)) {
      const index = dataColumnIDs.indexOf(cellID);
      val = dataRowValues[index];
    }
    return val;
  }

  /* data entry display (form view and data entry modals) */
  function printTableInput(values) {
    values = decodeCellHTMLEntities(values, true);
    const gridBodyElement =`#grid_${indicatorID}_${series}_input > tbody`;
    const gridHeadElement = `#grid_${indicatorID}_${series}_input > thead`;

    const numCols = gridParameters.length;
    const dataColumnIDs = values?.columns || [];
    const numRows = values?.cells?.length || 0;

    //fix for report builder to prevent duplicate tables from being created on edit
    if ($(gridHeadElement + " > td:last").html() !== undefined) {
      return 0;
    }
    //column names/table headers, with unique ID from form editor
    for (let i = 0; i < numCols; i++) {
      $(gridHeadElement).append(
        `<td><div style="width: 100px;" id="${gridParameters[i].id}">${gridParameters[i].name}</div></td>`
      );
    }
    //columns for row manipulation
    $(gridHeadElement).append(
      '<td style="width: 17px;">&nbsp;</td><td style="width: 17px;">&nbsp;</td>'
    );
    //table rows
    for (let i = 0; i < numRows; i++) {
      const selectedRowDataValues = values?.cells[i] || [];
      $(gridBodyElement).append("<tr></tr>");
      //td elements for each row
      for (let j = 0; j < numCols; j++) {
        addTableData(gridBodyElement, gridParameters[j], dataColumnIDs, selectedRowDataValues);
      }
      //arrow controls: no arrows if there is only one row. 1st row only needs down, last row only needs up.
      const showUpArrow = numRows !== 1 && i !== 0;
      const showDownArrow = numRows !== 1 && i !== numRows - 1;
      $(gridBodyElement + " > tr:last").append(
        makeControlColumnTemplate(indicatorID, series, showUpArrow, showDownArrow)
      );
    }
  }

  function loadFilemanagerFile(fileName = '', iID = '') {
    return new Promise((resolve, reject)=> {
      const xhttpInds = new XMLHttpRequest();
      xhttpInds.onreadystatechange = () => {
        let errContent = `The file '${fileName}' for indicator ${iID} was not found.`
        errContent += `\nCheck the file in the LEAF file manager or notify an admin.`
        if (xhttpInds.readyState === 4) {
          switch(xhttpInds.status) {
            case 200:
              if (xhttpInds.responseText !== null && xhttpInds.responseText !== '') {
                resolve(xhttpInds.responseText);
              } else {
                reject(new Error(errContent));
              }
              break;
            case 404:
              reject(new Error(errContent));
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
  /**
   * If grid does not have a 'dropdown_file' cell type, or if the filename already exists as a property of
   * the instance-scoped variable 'fileOptions', loading is skipped and promise is immediately resolved.
   * Options are otherwise added to 'fileOptions' under their filename as they are loaded.
   * @returns {Promise}
   */
  function checkForFileOptions() {
    return new Promise((resolve, reject) => {
      const loadedDropdowns = gridParameters.filter(p => p.type === 'dropdown_file');
      const uniqueFiles = Array.from(new Set(loadedDropdowns.map(d => d.file)));
      if (uniqueFiles.length === 0) {
        resolve();
      } else {
        let count = 0;
        uniqueFiles.forEach(filename => {
          if (fileOptions[filename] === undefined) {
            loadFilemanagerFile(filename, indicatorID)
            .then(fileContent => {
              let list = fileContent.split(/\n/).map(line => line.split(",")[0]) || [];
              list = list.map(o => XSSHelpers.stripAllTags(o.trim()));
              const firstRow = list[0] || '';
              list = Array.from(new Set(list)).sort();
              fileOptions[filename] = {
                firstRow,
                options: list
              };
              count += 1;
              if (count === uniqueFiles.length) {
                resolve();
              }
            }).catch(err => reject(err))
          }
        })
      }
    });
  }
  /**
   * @param {String} gridBodySelector targetting table body
   * @param {Object} cellParameters information about the current cell
   * @param {Array} dataColumnIDs list of column ids from data field (if there are saved values)
   * @param {Array} selectedRowDataValues list of data from data field (if there are saved values)
   */
  function addTableData(gridBodySelector = '', cellParameters = {}, dataColumnIDs = [], selectedRowDataValues = []) {
    const colID = cellParameters.id;
    const name = cellParameters.name;
    const val = getDataValueByCellID(colID, dataColumnIDs, selectedRowDataValues);

    const type = (cellParameters?.type || '').toLowerCase();
    switch (type) {
      case "dropdown":
      case "dropdown_file":
        const isMultiple = false;  //NOTE: not implemented, set to false for now.
        const selectedValues = isMultiple ? val.split(',') : [ val ];

        let options = [];
        if(type === 'dropdown_file') {
          const filename = cellParameters.file;
          const hasHeader = cellParameters.hasHeader;
          const loadedOptions = fileOptions[filename]?.options || [];
          const firstRow =  fileOptions[filename]?.firstRow || '';
          options = hasHeader ?
            loadedOptions.filter(o => o !== firstRow && o !== '') : loadedOptions.filter(o => o !== '');
        } else {
          options = cellParameters.options || [];
        }
        const optTemplate = options.map(o => {
          const attrSelected = selectedValues.some(v => v === o) ? " selected" : "";
          const optVal = o.replaceAll('\"', '&quot;');
          return `<option value="${optVal}"${attrSelected}>${o}</option>`;
        }).join('');

        $(gridBodySelector + " > tr:last").append(
          `<td aria-label="${name}">
            <select aria-label="${name}" ${isMultiple ? " multiple" : ""} style="width: fill-available;">
              <option value="">${isMultiple ? "Select Options" : "Select an Option"}</option>
              ${optTemplate}
            </select>
          </td>`
        );
        break;
      case "textarea":
        $(gridBodySelector + " > tr:last").append(
          `<td>
            <textarea aria-label="${name}" style="overflow-y:auto; resize: none; width: fill-available; height: 50px; box-sizing:border-box;">${val}</textarea>
          </td>`
        );
        break;
      case "text":
        $(gridBodySelector + " > tr:last").append(`<td><input aria-label="${name}" value="${val.replaceAll('\"', '&quot;')}" /></td>`);
        break;
      case "date":
        $(gridBodySelector + " > tr:last").append(`<td><input aria-label=" ${name}" data-type="grid-date" value="${val}" /></td>`);
        $('input[data-type="grid-date"]').datepicker();
        break;
      default:
        break;
    }
  }

  function addRow() {
    const gridBodyElement = `#grid_${indicatorID}_${series}_input > tbody`;
    //makes down arrow in last row visible
    $(gridBodyElement + " > tr:last > td:last")
      .find('[title="Move line down"]')
      .css("display", "inline");

    $(gridBodyElement).append("<tr></tr>");
    for (let i = 0; i < gridParameters.length; i++) {
      addTableData(gridBodyElement, gridParameters[i]);
    }

    const numRows = $(gridBodyElement).children().length;
    $(gridBodyElement + " > tr:last").append(
      makeControlColumnTemplate(indicatorID, series, numRows > 1 , false)
    );
    $("#tableStatus").attr("aria-label", `Row number ${numRows} added, ${numRows} total.`);
  }

  function triggerClick(event) {
    if (event.keyCode === 13) {
      $(event.target).trigger("click");
    }
  }
  function deleteRow(event) {
    let row = $(event.target).closest("tr");
    const rowDeleted = parseInt($(row).index()) + 1;
    const tbody = $(event.target).closest("tbody");

    let focus = row.next().find('[title="Delete line"]');
    const currLength = tbody.find("tr").length;
    switch(currLength) {
      case 1:
        row.remove();
        focus = $("#addRowBtn_" + indicatorID);
        break;
      case 2:
        row.remove();
        focus = tbody.find('[title="Delete line"]');
        upArrows(tbody.find("tr"), false);
        downArrows(tbody.find("tr"), false);
        break;
      default:
        if (row.find('[title="Move line down"]').css("display") === "none") {
          downArrows(row.prev(), false);
          upArrows(row.prev(), true);
          focus = row.prev().find('[title="Delete line"]');
        }
        if (row.find('[title="Move line up"]').css("display") === "none") {
          upArrows(row.next(), false);
          downArrows(row.next(), true);
        }
        row.remove();
        break;
    }
    if (focus?.length === 1) {
      //clear stack
      setTimeout(function () {
        focus.focus();
      });
    }

    $("#tableStatus").attr(
      "aria-label",
      `Row ${rowDeleted} removed, ${$(tbody).children().length} total.`
    );
  }

  function moveDown(event) {
    let row = $(event.target).closest("tr");
    const nextRowBottom = row.next().find('[title="Move line down"]').css("display") === "none";
    const rowTop = row.find('[title="Move line up"]').css("display") === "none";
    upArrows(row, true);

    if (nextRowBottom) {
      downArrows(row, false);
      downArrows(row.next(), true);
    }
    if (rowTop) {
      upArrows(row.next(), false);
    }
    row.insertAfter(row.next());

    const focus = row.find(`td:last > img[title="Move line ${nextRowBottom ? 'up' : 'down'}"]`);
    setTimeout(function () {
      focus.focus();
    });

    $("#tableStatus").attr(
      "aria-label",
      `Moved down to row ${(parseInt($(row).index()) + 1)} of ` +
      $(event.target).closest("tbody").children().length
    );
  }
  function moveUp(event) {
    let row = $(event.target).closest("tr");
    const prevRowTop = row.prev().find('[title="Move line up"]').css("display") === "none";
    const rowBottom = row.find('[title="Move line down"]').css("display") === "none";
    downArrows(row, true);

    if (prevRowTop) {
      upArrows(row, false);
      upArrows(row.prev(), true);
    }
    if (rowBottom) {
      downArrows(row.prev(), false);
    }
    row.insertBefore(row.prev());

    const focus = row.find(`td:last > img[title="Move line ${prevRowTop ? 'down' : 'up'}"]`);
    setTimeout(function () {
      focus.focus();
    });

    $("#tableStatus").attr(
      "aria-label",
      `Moved up to row ${(parseInt($(row).index()) + 1)} of ` +
      $(event.target).closest("tbody").children().length
    );
  }
  /* form entry review page / print view before submit */
  function printTableOutput(values) {
    values = decodeCellHTMLEntities(values);
    const gridBodyElement =`#grid_${indicatorID}_${series}_${recordID}_output > tbody`;
    const gridHeadElement = `#grid_${indicatorID}_${series}_${recordID}_output > thead`;

    const numCols = gridParameters.length;
    //display the current column names
    for (let i = 0; i < numCols; i++) {
      $(gridHeadElement).append(`<td style="width:100px">${gridParameters[i].name}</td>`);
    }
    //populate table
    const dataColumnIDs = values?.columns || [];
    const numRows = values?.cells?.length || 0;
    for (let i = 0; i < numRows; i++) {
      const selectedRowDataValues = values?.cells[i] || [];
      $(gridBodyElement).append("<tr></tr>");
      //row td elements for each column
      for (let j = 0; j < numCols; j++) {
        const colID = gridParameters[j].id;
        const val = getDataValueByCellID(colID, dataColumnIDs, selectedRowDataValues);
        $(gridBodyElement + " > tr:last").append(`<td style="width:100px">${val}</td>`);
      }
    }
  }
  /* admin Form Editor view indicator display preview */
  function printTablePreview() {
    const previewElement = `#grid${indicatorID}_${series}`;
    for (let i = 0; i < gridParameters.length; i++) {
      $(previewElement).append(
        `<div style="padding: 10px; vertical-align: top; display: inline-block; flex: 1; order: ${i + 1};">
          <b>Column #${i + 1}</b></br>
          Title:${gridParameters[i].name}</br>
          Type:${gridParameters[i].type}</br>
        </div>`
      );
      if (gridParameters[i].type === "dropdown") {
        $(previewElement + "> div:eq(" + i + ")").append(
          "Options:</br><li>" +
            gridParameters[i].options.toString().replace(/,/g, "</li><li>") +
            "</li></br>"
        );
      }
      if (gridParameters[i].type === "dropdown_file" && gridParameters[i].file !== "") {
        $(previewElement + "> div:eq(" + i + ")").append(
          `Options loaded from:</br><b>${gridParameters[i].file}</b></br>`
        );
      }
    }
  }
  return {
    addRow: addRow,
    preview: printTablePreview,
    output: printTableOutput,
    input: printTableInput,
    deleteRow: deleteRow,
    moveUp: moveUp,
    moveDown: moveDown,
    triggerClick: triggerClick,
    checkForFileOptions: checkForFileOptions
  };
};