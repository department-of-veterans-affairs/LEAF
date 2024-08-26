/************************
    FormGrid editor
*/

// The options arg (type: object) is currently only used for a "read only" type of grid
var LeafFormGrid = function (containerID, options) {
  var containerID = containerID;
  var prefixID = "LeafFormGrid" + Math.floor(Math.random() * 1000) + "_";
  var showIndex = true;
  var form;
  var headers;
  var currentData = [];
  var currentRenderIndex = 0;
  var isDataLoaded = false;
  var defaultLimit = 50;
  var currLimit = 50;
  var dataBlob = {}; // if data needs to be passed in
  var postProcessDataFunc = null;
  var preRenderFunc = null;
  var postRenderFunc = null;
  let postSortRequestFunc = null;
  var rootURL = "";
  var isRenderingBody = false;
  let renderHistory = {}; // index of rendered recordIDs
  let processedCallbackBuffer = false; // processed callback buffers for all records
  let renderCache = {}; // cache of rows with processed callbacks
  let disabledRenderCache = false;
  let sortDirection = {}; // map of sort direction for each key
  let rowHeight = 0;
  let stickyHeaderOffset = 0;
  let usingSetData = false; // backward compatibility

  $("#" + containerID).html(
    `<div id="${prefixID}grid"></div>
    <div id="${prefixID}form" style="display: none"></div>`
  );

  $("#" + prefixID + "grid").html(
    `<div style="position: relative">
      <div id="${prefixID}gridToolbar" style="display: none; width: 90px; margin: 0 0 0 auto; text-align: right"></div>
    </div>
    <span id="table_sorting_info" role="status" style="position:absolute;top: -40rem"
      aria-label="Search Results" aria-live="assertive">
    </span>
    <table id="${prefixID}table" class="leaf_grid">
      <thead id="${prefixID}thead" style="position: sticky; top: 0px"></thead>
      <tbody id="${prefixID}tbody"></tbody>
      <tfoot id="${prefixID}tfoot" class="leaf_grid-loading"></tfoot>
    </table>`
  );

  if (options == undefined) {
    form = new LeafForm(prefixID + "form");
  }

  function scrubHTML(input) {
    if(input == undefined) {
        return '';
    }
    let t = new DOMParser().parseFromString(input, 'text/html').body;
    while(input != t.textContent) {
      return scrubHTML(t.textContent);
    }
    return t.textContent;
  }

  /**
   * Do not show UID index column
   * @memberOf LeafFormGrid
   */
  function hideIndex() {
    showIndex = false;
  }

  /**
   * @param values (required) object of cells and names to generate grid
   * @param showScriptTags (default false) whether to display script tags
   * @memberOf LeafFormGrid
   * Returns copy of values with cells property html entities decoded
   */
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
          let scripts = elDiv.getElementsByTagName('script');
          for(let i = 0; i < scripts.length; i++) {
              let script = scripts[i];
              script.remove();
          }
          return elDiv.innerHTML;
        });
        cells[ci] = arrRowVals.slice();
      });
      gridInfo.cells = cells;
    }
    return gridInfo;
  }

  /**
   * @param values (required) object of cells and names to generate grid
   * @memberOf LeafFormGrid
   */
  function printTableReportBuilder(values, columnValues) {
    // remove unused columns
    values = decodeCellHTMLEntities(values);
    if (columnValues !== null && columnValues !== undefined) {
      values.format = values.format.filter(function (value) {
        return columnValues.includes(value.id);
      });
    }

    var gridBodyBuffer = "";
    var gridHeadBuffer = "";
    var rows = values.cells === undefined ? 0 : values.cells.length;
    var columns = values.format.length;
    var columnOrder = [];
    var delim = '<span class="nodisplay">^;</span>'; // invisible delimiters to help Excel users
    var delimLF = "\r\n";
    var tDelim = "";

    //finds and displays column names
    for (let i = 0; i < columns; i++) {
      tDelim = i === columns - 1 ? "" : delim;
      gridHeadBuffer +=
        '<td style="width: 100px;">' + values.format[i].name + tDelim + "</td>";
      columnOrder.push(values.format[i].id);
    }

    //populates table
    for (let i = 0; i < rows; i++) {
      //makes array of cells
      let rowBuffer = [];
      for (let j = 0; j < columns; j++) {
        rowBuffer.push('<td style="width:100px"></td>');
      }

      //for all values with matching column id, replaces cell with value
      for (let j = 0; j < values.columns.length; j++) {
        tDelim = j == values.columns.length - 1 ? "" : delim;
        if (columnOrder.indexOf(values.columns[j]) !== -1) {
          let value =
            values.cells[i] === undefined || values.cells[i][j] === undefined
              ? ""
              : values.cells[i][j];
          rowBuffer.splice(
            columnOrder.indexOf(values.columns[j]),
            1,
            '<td style="width:100px">' + value + tDelim + "</td>"
          );
        }
      }

      //combines cells into html and pushes row to body buffer
      const gridRow = "<tr>" + rowBuffer.join("") + delimLF + "</tr>";
      gridBodyBuffer += gridRow;
    }
    return (
      `<table class="table" style="word-wrap:break-word; max-width: 100%; padding: 20px; text-align: center; table-layout: fixed;">
        <thead>${gridHeadBuffer}${delimLF}</thead>
        <tbody>${gridBodyBuffer}</tbody>
      </table>`
    );
  }

  /** used on the formGrid header row to delegate and dispatch a click event to a hidden button to handle sorting */
  function sortHeaderFromButton(event) {
    const clickTarget = event?.target || null;
    if(clickTarget !== null && clickTarget.type !== 'button' && (event.type === "click" || event?.which === 13)) {
      const btn = clickTarget.querySelector('button');
      if(btn !== null) {
        btn.dispatchEvent(new Event("click"));
        btn.focus();
      }
    }
  }

  /**
   * @memberOf LeafFormGrid
   */
  function getIndicator(indicatorID, series) {
    $.ajax({
      type: "GET",
      url:
        rootURL +
        "api/form/" +
        recordID +
        "/rawIndicator/" +
        indicatorID +
        "/" +
        series,
      dataType: "json",
      success: function (response) {
        var data =
          response[indicatorID].displayedValue != ""
            ? response[indicatorID].displayedValue
            : response[indicatorID].value;
        if (
          (response[indicatorID].format == "checkboxes" ||
            response[indicatorID].format == "multiselect") &&
          Array.isArray(data)
        ) {
          var tData = "";
          for (let i in data) {
            if (data[i] != "no") {
              tData += ", " + data[i];
            }
          }
          data = tData.substr(2);
        }
        if (response[indicatorID].format == "grid") {
          data = printTableReportBuilder(data);
        }
        if (response[indicatorID].format == "date") {
          data = new Date(data).toLocaleDateString("en-US", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
          });
        }
        $("#" + prefixID + recordID + "_" + indicatorID)
          .empty()
          .html(data);
        $("#" + prefixID + recordID + "_" + indicatorID).fadeOut(
          250,
          function () {
            $("#" + prefixID + recordID + "_" + indicatorID).fadeIn(250);
          }
        );
      },
      cache: false,
    });
  }
  let renderRequest = 0;
  // header format: {name, indicatorID, sortable, editable, visible, [callback]}
  // callback receives {recordID, indicatorID, cellContainerID} within the scope of loadData()
  /**
   * @memberOf LeafFormGrid
   */
  function setHeaders(headersIn) {
    //hidden button styles inline to avoid custom style issues
    const btnStyles = 'style="position:absolute;left:0;top:0;width:100%;height:100%;border:0;background-color:inherit;color:inherit;z-index:-1"';
    headers = headersIn;
    let temp = `<tr id="${prefixID}thead_tr">`;
    if (showIndex) {
      const sortIcon = typeof sortPreference === 'undefined' || sortPreference?.key !== 'recordID' ?
        '' : sortPreference?.order === 'asc' ? '▲' : '▼';
      temp +=
        `<th scope="col" tabindex="0" id="${prefixID}header_UID" style="text-align: center" aria-label="sort by unique ID">UID` +
          `<span aria-hidden="true" class="sort_btn_span">${sortIcon}</span>` +
          `<button type="button" tabindex="-1" aria-label="sort by unique ID" class="btn_formgrid_sort" ${btnStyles}></button>
        </th>`;
    }
    $("#" + prefixID + "thead").html(temp);

    if (showIndex) {
      $("#" + prefixID + "header_UID, #" + prefixID + "header_UID button").css("cursor", "pointer");
      $("#" + prefixID + "header_UID > button").on("click", null, null, function (event) {
        if(sortDirection['recordID'] == undefined || sortDirection['recordID'] == 'desc') {
          sort("recordID", "asc", postSortRequestFunc);
        } else {
          sort("recordID", "desc", postSortRequestFunc);
        }
        renderRequest = 0;
        renderBody(0, virtualIndex);
        window.scrollTo(scrollX, scrollY); // compensate for browser reflow
      });
    }

    let domThead = document.querySelector(`#${prefixID}thead_tr`);
    for (let i in headers) {
      if (headers[i].visible == false) {
        continue;
      }
      const ariaLabel = scrubHTML(headers[i]?.name || '').replace(/['"]+/gu, ''); //strip out html, icons and chars that could truncate the html
      var align = headers[i].align != undefined ? headers[i].align : "center";
      domThead.insertAdjacentHTML('beforeend',
        `<th scope="col" id="${prefixID}header_${headers[i].indicatorID}" tabindex="0"  style="text-align:${align}" aria-label="Sort by ${ariaLabel}">` +
        `${headers[i].name}<span id="${prefixID}header_${headers[i].indicatorID}_sort" class="${prefixID}sort"></span>
        <button type="button" tabindex="-1" aria-label="Sort by ${ariaLabel}" class="btn_formgrid_sort" ${btnStyles}></button>
        </th>`);

      if (headers[i].sortable == undefined || headers[i].sortable == true) {
        $("#" + prefixID + "header_" + headers[i].indicatorID + ", #" + prefixID + "header_" + headers[i].indicatorID + " > button").css(
          "cursor",
          "pointer"
        );
        $("#" + prefixID + "header_" + headers[i].indicatorID + "> button").on(
          "click keydown",
          null,
          headers[i].indicatorID,
          function (event) {
            if(event.type === "click" || event?.which === 13) {
              if(sortDirection[event.data] == undefined || sortDirection[event.data] == 'desc') {
                sort(event.data, "asc", postSortRequestFunc);
              } else {
                sort(event.data, "desc", postSortRequestFunc);
              }
              renderRequest = 0;
              renderBody(0, virtualIndex);
              window.scrollTo(scrollX, scrollY); // compensate for browser reflow
            }
          }
        );
      }
    }
    $("#" + prefixID + "thead").append("</tr>");
    $("#" + prefixID + "thead_tr").on("click keydown", sortHeaderFromButton);
    $("#" + prefixID + "table>thead>tr>th").css({
      padding: "4px 2px 4px 2px",
      "font-size": "12px",
    });

    if(document.onscrollend != undefined) {
      document.onscrollend = handleScroll;
    } else {
      // safari compatibility
      let scrollTimer;
      document.onscroll = function() {
        clearTimeout(scrollTimer);
        scrollTimer = setTimeout(handleScroll, 100);
      };
    }

    let scrollX, scrollY, virtualIndex;
    function handleScroll() {
      scrollY = window.scrollY;
      scrollX = window.scrollX;

      if ($("#" + prefixID + "thead").offset() != undefined) {
        tableHeight = document.querySelector(`#${prefixID}tbody`).offsetHeight;
        let tableTop = document.querySelector(`#${prefixID}tbody`).getBoundingClientRect().top * -1;
        virtualIndex = (tableTop / rowHeight) + defaultLimit;

        // render additional segment right before the user scrolls to it
        if (
          virtualIndex > currentRenderIndex &&
          isDataLoaded &&
          isRenderingBody
        ) {
          if (renderRequest < currentRenderIndex) {
            renderBody(currentRenderIndex, virtualIndex - currentRenderIndex);
            window.scrollTo(scrollX, scrollY); // compensate for browser reflow
          }
        }
      }
    }

    // sticky header UX
    const domHeader = document.querySelector(`#${prefixID}thead`);
    const observer = new IntersectionObserver((evt) => {
      if(evt[0].boundingClientRect.y == evt[0].intersectionRect.y) {
        $("#" + prefixID + "table thead tr th").css({
          "filter": "invert(1) grayscale(1)",
          height: "1.3rem",
          "border-top": "1px solid white"
        });
        $("#" + prefixID + "table thead tr th:first-child").css({
          "border-left": "1px solid white"
        });
        $("#" + prefixID + "table thead tr th:last-child").css({
          "border-right": "1px solid white"
        });
      } else {
        $("#" + prefixID + "table thead tr th").css({
          "filter": "invert(0)",
          height: "auto",
          "border-top": "1px solid black"
        });
        $("#" + prefixID + "table thead tr th:first-child").css({
          "border-left": "1px solid black"
        });
        $("#" + prefixID + "table thead tr th:last-child").css({
          "border-right": "1px solid black"
        });
      }
    }, {
      root: document.querySelector(`#${prefixID}table`),
      rootMargin: -stickyHeaderOffset - 1 + 'px 0px 0px 0px',
      threshold: 1,
    });

    observer.observe(domHeader);
  }

  /**
   * Sort the current dataset based on rendered data in table cells
   * @param key key to sort on
   * @param order Sort order: asc/desc
   * @param callback (optional)
   * @memberOf LeafFormGrid
   */
  function sort(key, order, callback) {
    sortDirection[key] = order;
    const headerSelector = "#" + prefixID + "header_" + (key === "recordID" ? "UID" : key);
    let ariaLabel = '';
    for(let i in headers) {
      if(headers[i].indicatorID == key) {
        ariaLabel = $(headerSelector).text().replace(/[▼▲'"\n]+/gu, '');
        break;
      }
    }
    if (key != "recordID" && currLimit != Infinity) {
      renderBody(0, Infinity);
    }

    $("." + prefixID + "sort").css("display", "none");
    if (order.toLowerCase() == "asc") {
      $("#table_sorting_info").attr("aria-label", "sorted by " + (key === "recordID" ? "unique ID" : ariaLabel) + ", ascending.");
      $(headerSelector + "_sort").html('<span class="sort_icon_span" aria-hidden="true">▲</span>');
    } else {
      $("#table_sorting_info").attr("aria-label", "sorted by " + (key === "recordID" ? "unique ID" : ariaLabel) + ", descending.");
      $(headerSelector + "_sort").html('<span class="sort_icon_span" aria-hidden="true">▼</span>');
    }
    $(headerSelector + "_sort").css("display", "inline");
    var array = [];
    var isIndicatorID = $.isNumeric(key);
    var isDate = false;
    var isNumeric = true;
    var idKey = "id" + key;
    var tDate;
    for (let i in currentData) {
      if (currentData[i][key] == undefined) {
        currentData[i][key] = document.querySelector(`#${prefixID}${currentData[i].recordID}_${key}`)?.innerHTML;
        currentData[i][key] =
          currentData[i][key] == undefined ? "" : currentData[i][key];
      }
      if (currentData[i].s1 == undefined) {
        currentData[i].s1 = {};
      }
      if (
        currentData[i].s1[idKey] == undefined ||
        currentData[i].s1[idKey] == ""
      ) {
        if (currentData[i].sDate == undefined) {
          currentData[i].sDate = {};
        }
        //Workaround for sorting manually created grid
        currentData[i].s1[idKey] = !isNaN(currentData[i][key])
          ? currentData[i][key]
          : "";
        currentData[i].sDate[key] = 0;
      }
      if (isIndicatorID) {
        tDate = null;
        if (
          isNaN(currentData[i].s1[idKey]) &&
          (currentData[i].s1[idKey].indexOf("-") != -1 ||
            currentData[i].s1[idKey].indexOf("/") != -1)
        ) {
          tDate = Date.parse(currentData[i].s1[idKey]);
        }
        if (isDate || (tDate != null && !isNaN(tDate))) {
          isDate = true;
          if (currentData[i].sDate == undefined) {
            currentData[i].sDate = {};
          }
          currentData[i].sDate[key] = 0;
          currentData[i].sDate[key] = !isNaN(tDate) ? tDate : 0;
        }
      }
      // detect date fields for other non-indicatorID columns
      else {
        tDate = null;
        if (currentData[i].sDate == undefined) {
          currentData[i].sDate = {};
        }
        currentData[i].sDate[key] = 0;

        if (
          isNaN(currentData[i][key]) &&
          (currentData[i][key].indexOf("-") != -1 ||
            currentData[i][key].indexOf("/") != -1)
        ) {
          tDate = Date.parse(currentData[i][key]);
        }
        if (isDate || (tDate != null && !isNaN(tDate))) {
          isDate = true;

          currentData[i].sDate[key] =
            !isNaN(tDate) && tDate != null ? tDate : 0;
        }
      }

      if ($.isNumeric(currentData[i].s1[idKey]) & (isNumeric == true)) {
        currentData[i].s1[idKey] = parseFloat(currentData[i].s1[idKey]);
      } else {
        isNumeric = false;
      }

      array.push(currentData[i]);
    }
    if (isDate) {
      array.sort(function (a, b) {
        if (b.sDate[key] > a.sDate[key]) {
          return 1;
        }
        if (b.sDate[key] < a.sDate[key]) {
          return -1;
        }
        return 0;
      });
    } else if ($.isNumeric(key) || isNumeric) {
      array.sort(function (a, b) {
        if (b.s1[idKey] > a.s1[idKey]) {
          return 1;
        }
        if (b.s1[idKey] < a.s1[idKey]) {
          return -1;
        }
        return 0;
      });
    } else if (key == "recordID") {
      array.sort(function (a, b) {
        if (b[key] > a[key]) {
          return 1;
        }
        if (b[key] < a[key]) {
          return -1;
        }
        return 0;
      });
    } else {
      var collator = new Intl.Collator("en", {
        numeric: true,
        sensitivity: "base",
      });
      array.sort(function (a, b) {
        if (a[key] == undefined) {
          a[key] = "";
        }
        if (b[key] == undefined) {
          b[key] = "";
        }
        return collator.compare(b[key], a[key]);
      });
    }
    if (order == "asc") {
      array.reverse();
    }
    currentData = array;

    if (callback != undefined && typeof callback === "function") {
      callback(key, order);
    }
  }

  /**
   * @memberOf LeafFormGrid
   * @deprecated No-longer needed due to the end of IE7 support
   */
  function renderVirtualHeader() {
    return false;
  }

  /**
   * @param startIdx (optional) row to start rendering on
   * @param limit (optional) number of rows to render
   * @memberOf LeafFormGrid
   */
  function renderBody(startIdx, limit) {
    renderRequest = currentRenderIndex;
    isRenderingBody = true;
    if (preRenderFunc != null) {
      preRenderFunc();
    }

    if (limit == undefined) {
      limit = defaultLimit;
    }
    currLimit = limit;

    if (startIdx == undefined || startIdx == 0) {
      startIdx = 0;
      document.querySelector(`#${prefixID}tbody`).innerHTML = '';
      renderHistory = {};
      currentRenderIndex = 0;
      renderRequest = 0;
    }

    var buffer = "";
    var callbackBuffer = [];
    let outputBuffer = []; // buffer of pre-rendered rows

    var colspan = showIndex ? headers.length + 1 : headers.length;
    if (currentData.length == 0) {
      document.querySelector(`#${prefixID}tbody`).innerHTML = `<tr><td colspan="${colspan}" style="text-align: center">No Results</td></tr>`;
    }
    var counter = 0;
    var validateHtml = document.createElement("div");
    for (var i = startIdx; i < currentData.length; i++) {
      if (counter >= limit) {
        currentRenderIndex = i;
        break;
      }

      // Prevent duplicate DOM IDs from being generated
      if (renderHistory[currentData[i].recordID] != undefined) {
        continue;
      }

      renderHistory[currentData[i].recordID] = 1;

      if(renderCache[currentData[i].recordID] != undefined) {
        outputBuffer.push(renderCache[currentData[i].recordID]);
        counter++;

        currentRenderIndex = i + 1;
        continue;
      }
      buffer +=
        '<tr id="' + prefixID + "tbody_tr" + currentData[i].recordID + '">';
      if (showIndex) {
        buffer +=
          '<td><a href="index.php?a=printview&recordID=' +
          currentData[i].recordID +
          '">' +
          currentData[i].recordID +
          "</a></td>";
      }
      for (var j in headers) {
        if (headers[j].visible == false) {
          continue;
        }
        if (currentData[i] != undefined) {
          var data = {};
          data.recordID = currentData[i].recordID;
          data.indicatorID = headers[j].indicatorID;
          data.cellContainerID =
            prefixID + currentData[i].recordID + "_" + headers[j].indicatorID;
          data.index = i;
          data.data = "";
          var editable = false;

          if (
            headers[j].editable == undefined ||
            headers[j].editable != false
          ) {
            editable = true;
          }

          if ($.isNumeric(data.indicatorID)) {
            if (currentData[i].s1 == undefined) {
              currentData[i].s1 = {};
            }
            data.data = '';
            if(currentData[i].s1["id" + headers[j].indicatorID] != undefined) {
              data.data = currentData[i].s1["id" + headers[j].indicatorID];
            }
            validateHtml.innerHTML = data.data;
            data.data = validateHtml.innerHTML;
            if (currentData[i].s1[`id${headers[j].indicatorID}_htmlPrint`] != undefined) {
              let htmlPrint = `<textarea id="data_${currentData[i].recordID}_${headers[j].indicatorID}_1" style="display: none">${data.data}</textarea>`;
              htmlPrint += currentData[i].s1[`id${headers[j].indicatorID}_htmlPrint`]
                .replace(/{{ iID }}/g, currentData[i].recordID + "_" + headers[j].indicatorID)
                .replace(/{{ recordID }}/g, currentData[i].recordID);
              buffer += `<td id="${prefixID}${currentData[i].recordID}_${headers[j].indicatorID}" data-editable="${editable}" data-record-id="${currentData[i].recordID}" data-indicator-id="${headers[j].indicatorID}">${htmlPrint}</td>`;
            } else {
              if (headers[j].cols !== undefined) {
                if (
                  currentData[i].s1[data.data] !== undefined &&
                  data.data.search("gridInput") &&
                  headers[j].cols.length > 0
                ) {
                  data.data = printTableReportBuilder(
                    currentData[i].s1[data.data],
                    headers[j].cols
                  );
                }
              } else {
                if (
                  currentData[i].s1[data.data] !== undefined &&
                  data.data.search("gridInput")
                ) {
                  data.data = printTableReportBuilder(
                    currentData[i].s1[data.data],
                    null
                  );
                }
              }
              buffer += `<td id="${prefixID + currentData[i].recordID}_${headers[j].indicatorID}" data-editable="${editable}" data-record-id="${currentData[i].recordID}" data-indicator-id="${headers[j].indicatorID}">${data.data}</td>`;
            }
          } else if (headers[j].callback != undefined) {
            buffer += `<td id="${prefixID}${currentData[i].recordID}_${headers[j].indicatorID}" data-clickable="${editable}"></td>`;
          } else {
            buffer +=
              '<td id="' +
              prefixID +
              currentData[i].recordID +
              "_" +
              headers[j].indicatorID +
              '"></td>';
          }

          if (headers[j].callback != undefined && (renderCache[currentData[i].recordID] == undefined || renderCache[currentData[i].recordID][data.indicatorID] == undefined)) {
            callbackBuffer.push(
              (function (funct, data) {
                return function () {
                  funct(data, dataBlob);
                };
              })(headers[j].callback, data)
            );
          }
        } else {
          buffer +=
            '<td id="' +
            prefixID +
            currentData[i].recordID +
            "_" +
            headers[j].indicatorID +
            '"></td>';
        }
      }
      buffer += "</tr>";
      counter++;

      currentRenderIndex = i + 1;
    }

    let domTableBody = document.querySelector(`#${prefixID}tbody`);
    domTableBody.insertAdjacentHTML('beforeend', buffer);

    for (let i in outputBuffer) {
      domTableBody.appendChild(outputBuffer[i]);
    }

    if(rowHeight == 0) {
      rowHeight = domTableBody.offsetHeight / currentRenderIndex;
    }
    fillerHeight = (rowHeight * (currentData.length - currentRenderIndex));
    if (
      currentRenderIndex >= currentData.length ||
      limit == undefined
    ) {
      document.querySelector(`#${prefixID}tfoot`).innerHTML = '';
    } else {
      let tfootBuf = `<tr style="height: ${fillerHeight}px">`;
      document.querySelectorAll(`#${prefixID}thead_tr th`).forEach(el => {
        tfootBuf += `<td></td>`;
      });
      tfootBuf += `</tr>`;
      document.querySelector(`#${prefixID}tfoot`).innerHTML = tfootBuf;
    }

    document.querySelectorAll(`#${prefixID}tbody td[data-editable=true]`).forEach(el => {
      el.classList.add('table_editable');
    });
    document.querySelectorAll(`#${prefixID}tbody td[data-clickable=true]`).forEach(el => {
      el.classList.add('table_editable');
    });
    $("#" + prefixID + "tbody").unbind("click"); //prevents multiple firing on same report builder element, which causes subsequent problems with icheck
    $("#" + prefixID + "tbody").on(
      "click",
      "td[data-editable=true]",
      function (e) {
        form.setRecordID($(this).data("record-id"));
        var indicatorID = $(this).data("indicator-id");
        form.setPostModifyCallback(function () {
          getIndicator(indicatorID, 1);
          form.dialog().hide();
        });
        form.getForm(indicatorID, 1);
        form.dialog().show();
      }
    );
    for (let i in callbackBuffer) {
      callbackBuffer[i]();
    }

    if (postRenderFunc != null) {
      postRenderFunc();
    }

    //add buttons if the headers don't have them yet (this could potentially apply to checkpoint dates)
    const btnStyles = 'style="position:absolute;left:0;top:0;width:100%;height:100%;border:0;background-color:inherit;color:inherit;z-index:-1"';
    headers.forEach(h => {
      if (h.sortable == undefined || h.sortable == true) {
        setTimeout(() => {
          const elBtn = document.querySelector(`#${prefixID}header_${h.indicatorID} > button.btn_formgrid_sort`);
          if(elBtn === null) {
            const ariaLabel = 'Sort by ' + $("#" + prefixID + "header_" + h.indicatorID).text().replace(/[▼▲'"]+/gu, '');

            $("#" + prefixID + "header_" + h.indicatorID).attr('aria-label', ariaLabel);
            $("#" + prefixID + "header_" + h.indicatorID).append(
              `<span aria-hidden="true" class="sort_btn_span"></span>
              <button type="button" tabindex="-1" aria-label="${ariaLabel}" class="btn_formgrid_sort" ${btnStyles}></button>`
            );

            $("#" + prefixID + "header_" + h.indicatorID + " > button.btn_formgrid_sort").on(
              "click",
              null,
              h.indicatorID,
              function (event) {
                if(sortDirection[event.data] == undefined || sortDirection[event.data] == 'desc') {
                  sort(event.data, "asc", postSortRequestFunc);
                } else {
                  sort(event.data, "desc", postSortRequestFunc);
                }
                let currPosition = renderRequest.length; // retain scroll position
                renderRequest = [];
                renderBody(0, currPosition);
              }
            );
          }
        });
      }
    });

    // Cache rendered content
    if(limit == Infinity && !processedCallbackBuffer && !disabledRenderCache) {
      renderCache = {};
      processedCallbackBuffer = true;
      for (let i in currentData) {
        for(let j in headers) {
          let id = currentData[i].recordID;
          if (renderCache[id] == undefined) {
            renderCache[id] = document.querySelector(`#${prefixID}tbody_tr${currentData[i].recordID}`);
          }
        }
      }
    }
  }

  /**
   * @memberOf LeafFormGrid
   */
  function announceResults() {
    let term = $('[name="searchtxt"]').val();

    if (currentData.length == 0) {
      $(".status").text("No results found for term " + term);
    } else {
      $(".status").text(
        "Search results found for term " + term + " listed below"
      );
    }
  }

  /**
   * @deprecated See example.tpl for more efficient formGrid usage.
   * @memberOf LeafFormGrid
   */
  function loadData(recordIDs, callback) {
    currentData = [];
    var colspan = showIndex ? headers.length + 1 : headers.length;
    $("#" + prefixID + "tbody").html(
      '<tr><td colspan="' +
        colspan +
        '" style="text-align: left; padding: 8px">Building report... <img src="' +
        rootURL +
        'images/largespinner.gif" alt="" /></td></tr>'
    );

    var headerIDList = "";
    for (var i in headers) {
      if ($.isNumeric(headers[i].indicatorID)) {
        headerIDList += headers[i].indicatorID + ",";
      }
    }

    $.ajax({
      type: "POST",
      url: rootURL + "api/form/customData",
      dataType: "json",
      data: {
        recordList: recordIDs,
        indicatorList: headerIDList,
        CSRFToken: CSRFToken,
      },
      success: function (res) {
        isDataLoaded = true;
        for (var i in res) {
          if (dataBlob[i] != undefined) {
            for (var j in dataBlob[i]) {
              if (typeof dataBlob[i][j] == "object") {
                //ECMA6
                //Object.assign(res[i][j], dataBlob[i][j]);
                for (var tAttr in dataBlob[i][j]) {
                  res[i][j] = res[i][j] || {};
                  res[i][j][tAttr] = dataBlob[i][j][tAttr];
                }
              } else {
                res[i][j] = dataBlob[i][j];
              }
            }
          }
          currentData.push(res[i]);
        }
        if (postProcessDataFunc != null) {
          currentData = postProcessDataFunc(currentData);
        }
        document.querySelector(`#${prefixID}table`).setAttribute('aria-rowcount', currentData.length);
        sort("recordID", "desc");
        renderBody(0, defaultLimit);

        if (callback != undefined && typeof callback === "function") {
          callback();
        }
      },
      cache: false,
    });
  }

  /**
   * Set the working data set (uncommon)
   * 
   * setDataBlob() is more commonly used
   * 
   * @params array - Expects format: [{recordID}, ...]
   * @memberOf LeafFormGrid
   */
  function setData(data) {
    usingSetData = true;
    isDataLoaded = true;
    currentData = data;
    processedCallbackBuffer = false;
    document.querySelector(`#${prefixID}table`).setAttribute('aria-rowcount', currentData.length);
  }

  /**
   * Set the working data set
   * @params object - If setData() is not used, this expects {id: {recordID, ...}}
   * @memberOf LeafFormGrid
   */
  function setDataBlob(data) {
    dataBlob = data;
    if(!usingSetData) {
      if(Array.isArray(data)) {
        currentData = data;
      }
      else if(typeof data === 'object') {
        currentData = Object.keys(data).map(key => data[key]);
      }
      else {
        console.error('Invalid setDataBlob format');
        return;
      }

      isDataLoaded = true;
      processedCallbackBuffer = false;
      document.querySelector(`#${prefixID}table`).setAttribute('aria-rowcount', currentData.length);
    }
  }

  /**
   * Imports LEAF Query result
   * @memberOf LeafFormGrid
   */
  function importQueryResult(res) {
    var tGridData = [];
    for (var i in res) {
      tGridData.push(res[i]);
    }
    setData(tGridData);
    setDataBlob(tGridData);
  }

  /**
   * @memberOf LeafFormGrid
   */
  function enableToolbar() {
    containerID = prefixID + "gridToolbar";
    $("#" + containerID).css("display", "block");
    $("#" + containerID).html(
      '<br/><button type="button" id="' +
        prefixID +
        'getExcel" class="buttonNorm"><img src="' +
        rootURL +
        'dynicons/?img=x-office-spreadsheet.svg&w=16" alt="" /> Export</button>'
    );

    $("#" + prefixID + "getExcel").on("click", async function () {
      // get indicator formats in case they need special handling (e.g. dates)
      let iFormatData = await fetch(rootURL + "api/form/indicator/list?x-filterData=indicatorID,format").then(res => res.json());
      let indicatorFormats = {};
      iFormatData.forEach(i => {
        indicatorFormats[i.indicatorID] = i.format;
      });

      if (currentRenderIndex != currentData.length) {
        renderBody(0, Infinity);
      }
      let output = [];
      let headers = [];
      //removes triangle symbols so that ascii chars are not present in exported headers.
      $("#" + prefixID + "thead>tr>th>span").each(function (idx, val) {
        $(val).html("");
      });
      $("#" + prefixID + "thead>tr>th").each(function (idx, val) {
        headers.push($(val).text().trim());
      });
      output.push(headers); //first row will be headers

      let line = [];
      let i = 0;
      let numColumns = headers.length - 1;
      document
        .querySelectorAll("#" + prefixID + "tbody>tr>td")
        .forEach(function (val) {
          let foundScripts = val.querySelectorAll("script");

          for (let tIdx = 0; tIdx < foundScripts.length; tIdx++) {
            foundScripts[tIdx].parentNode.removeChild(foundScripts[tIdx]);
          }

          let trimmedText = val.innerText.trim();
          line[i] = trimmedText;
          //prevent some values from being interpreted as dates by excel
          const dataFormat = indicatorFormats[val.getAttribute("data-indicator-id")];
          const testExcelDateFormat = /^\d{1,2}[\/-]\d{1,2}([\/-]\d{2,4})?$/; // Excel thinks these are dates
          const isNumber = /^\d+$/;

          if(dataFormat == 'text') {
              if(isNumber.test(line[i]) // workaround for excel's handling of very large numbers (e.g. serial number)
                 || testExcelDateFormat.test(line[i])) {
                  line[i] = `="${line[i]}"`;
              }
          }

          if (i == 0 && headers[i] == "UID") {
            line[i] =
              '=HYPERLINK("' +
              window.location.origin +
              window.location.pathname +
              "?a=printview&recordID=" +
              trimmedText +
              '", "' +
              trimmedText +
              '")';
          }
          i++;
          if (i > numColumns) {
            output.push(line); //add new row
            line = [];
            i = 0;
          }
        });

      rows = "";
      output.forEach(function (thisRow) {
        //escape double quotes
        thisRow.forEach(function (col, idx) {
          thisRow[idx] = col.replace(/\"/g, '""');
        });
        //add to csv string
        rows += '"' + thisRow.join('","') + '",\r\n';
      });

      let download = document.createElement("a");
      let now = new Date().getTime();
      download.setAttribute(
        "href",
        "data:text/csv;charset=utf-8," + encodeURIComponent(rows)
      );
      download.setAttribute("download", "Exported_" + now + ".csv");
      download.style.display = "none";

      document.body.appendChild(download);
      if (navigator.msSaveOrOpenBlob) {
        rows = "\uFEFF" + rows;
        navigator.msSaveOrOpenBlob(
          new Blob([rows], { type: "text/csv;charset=utf-8;" }),
          "Exported_" + now + ".csv"
        );
      } else {
        download.click();
      }
      document.body.removeChild(download);
    });
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to post process data. Returns currentData blob
   */
  function setPostProcessDataFunc(func) {
    postProcessDataFunc = func;
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to run before rendering the body
   */
  function setPreRenderFunc(func) {
    preRenderFunc = func;
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to run after rendering the body
   */
  function setPostRenderFunc(func) {
    postRenderFunc = func;
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to run after the user requests a sort.
   * The function takes two parameters: key, sort direction (asc/desc)
   */
  function setPostSortRequestFunc(func) {
    postSortRequestFunc = func;
  }

  /**
   * @memberOf LeafFormGrid
   * Return data row from loadData() using the array's index
   */
  function getDataByIndex(index) {
    return currentData[index];
  }

  /**
   * @memberOf LeafFormGrid
   * Return data row from loadData() using recordID as the index
   */
  function getDataByRecordID(recordID) {
    for (var i in currentData) {
      if (currentData[i].recordID == recordID) {
        return currentData[i];
      }
    }
    return null;
  }

  /**
   * @memberOf LeafFormGrid
   * Disables the sticky header
   */
  function disableStickyHeader() {
    document.querySelector(`#${prefixID}thead`).style.position = 'static';
    document.querySelector(`#${prefixID}thead`).style.top = 'auto';
  }

  return {
    getPrefixID: function () {
      return prefixID;
    },
    form: function () {
      return form;
    },
    headers: function () {
      return headers;
    },
    getCurrentData: function () {
      return currentData;
    },
    hideIndex: hideIndex,
    setHeaders: setHeaders,
    getNumHeaders: () => {
      if(showIndex) {
        return headers.length + 1;
      } else {
        return headers.length;
      }
    },
    sort: sort,
    renderVirtualHeader: renderVirtualHeader,
    renderBody: renderBody,
    announceResults: announceResults,
    loadData: loadData,
    setData: setData,
    setDataBlob: setDataBlob,
    importQueryResult: importQueryResult,
    enableToolbar: enableToolbar,
    setPostProcessDataFunc: setPostProcessDataFunc,
    setPreRenderFunc: setPreRenderFunc,
    setPostRenderFunc: setPostRenderFunc,
    setPostSortRequestFunc: setPostSortRequestFunc,
    setDefaultLimit: function (limit) {
      defaultLimit = limit;
    },
    getDefaultLimit: function () {
      return defaultLimit;
    },
    getDataByIndex: getDataByIndex,
    getDataByRecordID: getDataByRecordID,
    disableStickyHeader: disableStickyHeader,
    disableVirtualHeader: function () { // backward compat
      disableStickyHeader();
    },
    disableRenderCache: () => disabledRenderCache = true,
    setStickyHeaderOffset: function (offset) {
      document.querySelector(`#${prefixID}thead`).style.top = offset;
      stickyHeaderOffset = Number(offset.replace('px', ''));
    },
    stop: function () {
      isRenderingBody = false;
    },
    setRootURL: function (url) {
      rootURL = url;
    },
  };
};