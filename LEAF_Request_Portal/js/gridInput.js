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
  function appendOptions(elSelect = {}, arrOptions = [], selectedValues = []) {
    setTimeout(() => {
      if((elSelect?.nodeName || '').toLowerCase() === 'select') {
        arrOptions.forEach(opt => {
          const option = document.createElement('option');
          option.value = opt;
          option.innerText = opt;
          const isSelected = selectedValues.length > 0 && selectedValues.some(o => o === opt);
          if(isSelected) {
            option.setAttribute('selected', 'selected');
          }
          elSelect.appendChild(option);
        });
      }
    });
  }
  function upArrows(row, toggle) {
    if (toggle) {
      row.find('[title="Move line up"]').css("display", "inline");
    } else {
      row.find('[title="Move line up"]').css("display", "none");
    }
  }
  function downArrows(row, toggle) {
    if (toggle) {
      row.find('[title="Move line down"]').css("display", "inline");
    } else {
      row.find('[title="Move line down"]').css("display", "none");
    }
  }
  function printTableInput(values) {
    values = decodeCellHTMLEntities(values, true);
    var gridBodyElement =
      "#grid_" + indicatorID + "_" + series + "_input > tbody";
    var gridHeadElement =
      "#grid_" + indicatorID + "_" + series + "_input > thead";
    var rows =
      values.cells !== undefined && values.cells.length > 0
        ? values.cells.length
        : 0;
    var columns = gridParameters.length;
    var columnOrder = [];

    //fix for report builder
    //prevents duplicate table from being created on edit
    if ($(gridHeadElement + " > td:last").html() !== undefined) {
      return 0;
    }

    //finds and displays column names
    //gives each cell in table head unique ID from form editor
    for (let i = 0; i < columns; i++) {
      $(gridHeadElement).append(
        '<td><div style="width: 100px;" id="' +
          gridParameters[i].id +
          '">' +
          gridParameters[i].name +
          "</div></td>"
      );
      columnOrder.push(gridParameters[i].id);
    }

    //columns for row manipulation
    $(gridHeadElement).append(
      '<td style="width: 17px;">&nbsp;</td><td style="width: 17px;">&nbsp;</td>'
    );

    //populate table rows
    for (let i = 0; i < rows; i++) {
      const selectedRowValues = values?.cells[i] || [];
      $(gridBodyElement).append("<tr></tr>");
      //add td elements to each row
      for (let j = 0; j < columns; j++) {
        const name = gridParameters[j].name;
        const val = selectedRowValues[j] || '';
        const type = (gridParameters[j]?.type || '').toLowerCase();
        switch (type) {
          case "dropdown":
          case "dropdown_file":
            const isMultiple = +gridParameters[j].multiselect === 1;
            const selectedValues = isMultiple ? val.split(',') : [ val ];
            $(gridBodyElement + " > tr:last").append(
              `<td aria-label="${name}">
                <select aria-label="${name}" role="dropdown"${isMultiple ? " multiple" : ""} style="width:100%;">
                  <option value="">${isMultiple ? "Select Options" : "Select an Option"}</option>
                </select>
              </td>`
            );
            let options = [];
            if(type === 'dropdown_file') {
              const filename = gridParameters[j].file;
              const hasHeader = gridParameters[j].hasHeader;
              const loadedOptions = fileOptions[filename]?.options || [];
              const firstRow =  fileOptions[filename]?.firstRow || '';
              options = hasHeader ?
                loadedOptions.filter(o => o !== firstRow && o !== '') : loadedOptions.filter(o => o !== '');
            } else {
              options = gridParameters[j].options || []
            }
            let elSelect = document.querySelector(gridBodyElement + " > tr:last-child td:last-child select");
            appendOptions(elSelect, options, selectedValues);
            break;
          case "textarea":
            $(gridBodyElement + " > tr:last").append(
              `<td><textarea aria-label="${name}" style="overflow-y:auto; resize: none; width: fill-available; height: 50px; box-sizing:border-box;">${val}
                </textarea></td>`
            );
            break;
          case "text":
            $(gridBodyElement + " > tr:last").append(
              `<td><input aria-label="${name}" value="${val}" /></td>`
            );
            break;
          case "date":
            $(gridBodyElement + " > tr:last").append(
              `<td><input aria-label=" ${name}" data-type="grid-date" value="${val}" /></td>`
            );
            $('input[data-type="grid-date"]').datepicker();
            break;
          default:
            break;
        }
      }

      //arrow logic: if there is only one row, arrows are not necessary.  1st row only needs down, last row only needs up.
      const showUpArrow = rows !== 1 && i !== 0;
      const showDownArrow = rows !== 1 && i !== rows - 1;
      $(`${gridBodyElement} > tr:eq(${i})`).append(
        `<td>
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
        </td>`
      );
    }
  }

  function loadFilemanagerFile(fileName, iID) {
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
  function addRow() {
    const gridBodyElement = `#grid_${indicatorID}_${series}_input > tbody`;
    //makes down arrow in last row visible
    $(gridBodyElement + " > tr:last > td:last")
      .find('[title="Move line down"]')
      .css("display", "inline");

    $(gridBodyElement).append("<tr></tr>");
    for (let i = 0; i < gridParameters.length; i++) {
      const name = gridParameters[i].name;
      const type = (gridParameters[i]?.type || '').toLowerCase();
      switch (type) {
        case "dropdown":
        case "dropdown_file":
          const isMultiple = +gridParameters[i].multiselect === 1;
          //add initial select element and first option
          $(gridBodyElement + " > tr:last").append(
            `<td aria-label="${name}">
              <select aria-label="${name}" role="dropdown"${isMultiple ? " multiple" : ""} style="width:100%;">
                <option value="">${isMultiple ? "Select Options" : "Select an Option"}</option>
              </select>
            </td>`
          );
          //options need to be appended afterwards, or multiselect items won't display correctly
          let options = [];
          if(gridParameters[i].type === 'dropdown_file') {
            const filename = gridParameters[i].file;
            const hasHeader = gridParameters[i].hasHeader;
            const loadedOptions = fileOptions[filename]?.options || [];
            const firstRow =  fileOptions[filename]?.firstRow || '';
            options = hasHeader ?
              loadedOptions.filter(o => o !== firstRow && o !== '') : loadedOptions.filter(o => o !== '');
          } else {
            options = gridParameters[i].options || []
          }
          let elSelect = document.querySelector(gridBodyElement + " > tr:last-child td:last-child select");
          appendOptions(elSelect, options, []);
          break;
        case "textarea":
          $(gridBodyElement + " > tr:last").append(
            `<td><textarea aria-label="${name}" style="overflow-y:auto; resize: none; width: fill-available; height: 50px; box-sizing:border-box;">
              </textarea>
            </td>`
          );
          break;
        case "text":
          $(gridBodyElement + " > tr:last").append(
            `<td><input aria-label="${name}" value="" /></td>`
          );
          break;
        case "date":
          $(gridBodyElement + " > tr:last").append(
            `<td><input aria-label="${name}" data-type="grid-date" value="" /></td>`
          );
          $('input[data-type="grid-date"]').datepicker();
          break;
        default:
          break;
      }
    }
    const numRows = $(gridBodyElement).children().length;
    $(gridBodyElement + " > tr:last").append(
      `<td>
        <img role="button" tabindex="0"
        onkeydown="gridInput_${indicatorID}_${series}.triggerClick(event);"
        onclick="gridInput_${indicatorID}_${series}.deleteRow(event)"
        src="dynicons/?img=process-stop.svg&w=16" title="Delete line" alt="Delete line" style="cursor: pointer" />
      </td>
      <td>
        <img role="button" tabindex="0"
        onkeydown="gridInput_${indicatorID}_${series}.triggerClick(event);"
        onclick="gridInput_${indicatorID}_${series}.moveUp(event)"
        src="dynicons/?img=go-up.svg&w=16" title="Move line up" alt="Move line up" style="display: ${numRows > 1 ? 'inline' : 'none'}; cursor: pointer" />
        </br></br>
        <img role="button" tabindex="0"
        onkeydown="gridInput_${indicatorID}_${series}.triggerClick(event);"
        onclick="gridInput_${indicatorID}_${series}.moveDown(event)"
        src="dynicons/?img=go-down.svg&w=16" title="Move line down" alt="Move line down" style="display:none; cursor: pointer" />
      </td>`
    );

    $("#tableStatus").attr(
      "aria-label",
      `Row number ${numRows} added, ${numRows} total.`
    );
  }
  // click function for 508 compliance
  function triggerClick(event) {
    if (event.keyCode === 13) {
      $(event.target).trigger("click");
    }
  }
  function deleteRow(event) {
    var row = $(event.target).closest("tr");
    var tbody = $(event.target).closest("tbody");
    var rowDeleted = parseInt($(row).index()) + 1;
    var focus;
    switch (tbody.find("tr").length) {
      case 1:
        row.remove();
        setTimeout(function () {
          $("#addRowBtn").focus();
        }, 0);
      case 2:
        row.remove();
        focus = tbody.find('[title="Delete line"]');
        upArrows(tbody.find("tr"), false);
        downArrows(tbody.find("tr"), false);
        break;
      default:
        focus = row.next().find('[title="Delete line"]');
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
    if (focus !== undefined) {
      //ie11 fix
      setTimeout(function () {
        focus.focus();
      }, 0);
    }

    $("#tableStatus").attr(
      "aria-label",
      "Row " +
        rowDeleted +
        " removed, " +
        $(tbody).children().length +
        " total."
    );
  }

  function moveDown(event) {
    var row = $(event.target).closest("tr");
    var nextRowBottom =
      row.next().find('[title="Move line down"]').css("display") === "none";
    var rowTop = row.find('[title="Move line up"]').css("display") === "none";
    var focus;
    upArrows(row, true);
    if (nextRowBottom) {
      downArrows(row, false);
      downArrows(row.next(), true);
    }
    if (rowTop) {
      upArrows(row.next(), false);
    }
    row.insertAfter(row.next());
    if (nextRowBottom) {
      focus = row.find('td:last > img[title="Move line up"]');
    } else {
      focus = row.find('td:last > img[title="Move line down"]');
    }
    //ie11 fix
    setTimeout(function () {
      focus.focus();
    }, 0);
    $("#tableStatus").attr(
      "aria-label",
      "Moved down to row " +
        (parseInt($(row).index()) + 1) +
        " of " +
        $(event.target).closest("tbody").children().length
    );
  }
  function moveUp(event) {
    var row = $(event.target).closest("tr");
    var prevRowTop =
      row.prev().find('[title="Move line up"]').css("display") === "none";
    var rowBottom =
      row.find('[title="Move line down"]').css("display") === "none";
    var focus;
    downArrows(row, true);
    if (prevRowTop) {
      upArrows(row, false);
      upArrows(row.prev(), true);
    }
    if (rowBottom) {
      downArrows(row.prev(), false);
    }
    row.insertBefore(row.prev());
    if (prevRowTop) {
      focus = row.find('td:last > img[title="Move line down"]');
    } else {
      focus = row.find('td:last > img[title="Move line up"]');
    }
    //ie11 fix
    setTimeout(function () {
      focus.focus();
    }, 0);
    $("#tableStatus").attr(
      "aria-label",
      "Moved up to row " +
        (parseInt($(row).index()) + 1) +
        " of " +
        $(event.target).closest("tbody").children().length
    );
  }
  function printTableOutput(values) {
    values = decodeCellHTMLEntities(values);
    var gridBodyElement =
      "#grid_" +
      indicatorID +
      "_" +
      series +
      "_" +
      recordID +
      "_output > tbody";
    var gridHeadElement =
      "#grid_" +
      indicatorID +
      "_" +
      series +
      "_" +
      recordID +
      "_output > thead";
    var rows = values.cells === undefined ? 0 : values.cells.length;
    var columns = gridParameters.length;
    var columnOrder = [];

    //finds and displays column names
    for (var i = 0; i < columns; i++) {
      $(gridHeadElement).append(
        '<td style="width:100px">' + gridParameters[i].name + "</td>"
      );
      columnOrder.push(gridParameters[i].id);
    }

    //populates table
    for (var i = 0; i < rows; i++) {
      $(gridBodyElement).append("<tr></tr>");

      //generates row layout
      for (var j = 0; j < columns; j++) {
        $(gridBodyElement + " > tr:eq(" + i + ")").append(
          '<td style="width:100px"></td>'
        );
      }

      //assigns pre-existing values to cells based on its column
      //if its column has been deleted, the value is not assigned
      for (var j = 0; j < values.columns.length; j++) {
        if (columnOrder.indexOf(values.columns[j]) !== -1) {
          var value =
            values.cells[i] === undefined || values.cells[i][j] === undefined
              ? ""
              : values.cells[i][j];
          $(
            gridBodyElement +
              " > tr:eq(" +
              i +
              ") > td:eq(" +
              columnOrder.indexOf(values.columns[j]) +
              ")"
          ).html(value);
        }
      }
    }
  }
  function printTablePreview() {
    let previewElement = "#grid" + indicatorID + "_" + series;

    for (let i = 0; i < gridParameters.length; i++) {
      $(previewElement).append(
        '<div style="padding: 10px; vertical-align: top; display: inline-block; flex: 1; order: ' +
          (i + 1) +
          '"><b>Column #' +
          (i + 1) +
          "</b></br>Title:" +
          gridParameters[i].name +
          "</br>Type:" +
          gridParameters[i].type +
          "</br></div>"
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
