/************************
    FormGrid editor
*/

// The options arg (type: object) is currently only used for a "read only" type of grid
const LeafFormGrid = function (containerID, options) {
  const prefixID = 'LeafFormGrid' + Math.floor(Math.random() * 1000) + '_'
  let showIndex = true
  let form
  let headers
  let currentData = []
  let currentRenderIndex = 0
  let isDataLoaded = false
  let defaultLimit = 50
  let currLimit = 50
  let dataBlob = {} // if data needs to be passed in
  let postProcessDataFunc = null
  let preRenderFunc = null
  let postRenderFunc = null
  let postSortRequestFunc = null
  let rootURL = ''
  let isRenderingVirtualHeader = true
  let isRenderingBody = false
  let renderHistory = {} // index of rendered recordIDs

  $('#' + containerID).html(
    '<div id="' +
      prefixID +
      'grid"></div><div id="' +
      prefixID +
      'form" style="display: none"></div>'
  )

  $('#' + prefixID + 'grid').html(
    '<div style="position: relative"><div id="' +
      prefixID +
      'gridToolbar" style="display: none; width: 90px; margin: 0 0 0 auto; text-align: right"></div></div><div id="' +
      prefixID +
      'table_stickyHeader" style="display: none"></div><table id="' +
      prefixID +
      'table" class="leaf_grid"><thead id="' +
      prefixID +
      'thead" aria-label="Search Results"></thead><tbody id="' +
      prefixID +
      'tbody"></tbody><tfoot id="' +
      prefixID +
      'tfoot"></tfoot></table>'
  )

  if (options === undefined) {
    form = new LeafForm(prefixID + 'form')
  }

  /**
   * Do not show UID index column
   * @memberOf LeafFormGrid
   */
  function hideIndex () {
    showIndex = false
  }

  /**
   * @param values (required) object of cells and names to generate grid
   * @param showScriptTags (default false) whether to display script tags
   * @memberOf LeafFormGrid
   * Returns copy of values with cells property html entities decoded
   */
  function decodeCellHTMLEntities (values, showScriptTags = false) {
    const gridInfo = { ...values }
    if (gridInfo?.cells) {
      const cells = gridInfo.cells.slice()
      cells.forEach((arrRowVals, ci) => {
        arrRowVals = arrRowVals.map((v) => {
          v = v.replaceAll('<', '&lt;') // handle old data values
          v = v.replaceAll('>', '&gt;')
          const elDiv = document.createElement('div')
          elDiv.innerHTML = v
          let text = elDiv.innerText
          if (showScriptTags !== true) {
            text = text.replaceAll(
              /(<script[\s\S]*?>)|(<\/script[\s\S]*?>)/gi,
              ''
            )
          }
          return text
        })
        cells[ci] = arrRowVals.slice()
      })
      gridInfo.cells = cells
    }
    return gridInfo
  }

  /**
   * @param values (required) object of cells and names to generate grid
   * @memberOf LeafFormGrid
   */
  function printTableReportBuilder (values, columnValues) {
    // remove unused columns
    values = decodeCellHTMLEntities(values)
    if (columnValues !== null && columnValues !== undefined) {
      values.format = values.format.filter(function (value) {
        return columnValues.includes(value.id)
      })
    }

    let gridBodyBuffer = ''
    let gridHeadBuffer = ''
    const rows = values.cells === undefined ? 0 : values.cells.length
    const columns = values.format.length
    const columnOrder = []
    const delim = '<span class="nodisplay">^;</span>' // invisible delimiters to help Excel users
    const delimLF = '\r\n'
    let tDelim = ''

    // finds and displays column names
    for (let i = 0; i < columns; i++) {
      tDelim = i === columns - 1 ? '' : delim
      gridHeadBuffer +=
        '<td style="width: 100px;">' + values.format[i].name + tDelim + '</td>'
      columnOrder.push(values.format[i].id)
    }

    // populates table
    for (let i = 0; i < rows; i++) {
      let gridRow = '<tr>'
      const rowBuffer = []

      // makes array of cells
      for (let j = 0; j < columns; j++) {
        rowBuffer.push('<td style="width:100px"></td>')
      }

      // for all values with matching column id, replaces cell with value
      for (let j = 0; j < values.columns.length; j++) {
        tDelim = j === values.columns.length - 1 ? '' : delim
        if (columnOrder.indexOf(values.columns[j]) !== -1) {
          const value =
            values.cells[i] === undefined || values.cells[i][j] === undefined
              ? ''
              : values.cells[i][j]
          rowBuffer.splice(
            columnOrder.indexOf(values.columns[j]),
            1,
            '<td style="width:100px">' + value + tDelim + '</td>'
          )
        }
      }

      // combines cells into html and pushes row to body buffer
      gridRow += rowBuffer.join('') + delimLF + '</tr>'
      gridBodyBuffer += gridRow
    }
    return (
      '<table class="table" style="word-wrap:break-word; max-width: 100%; padding: 20px; text-align: center; table-layout: fixed;"><thead>' +
      gridHeadBuffer +
      delimLF +
      '</thead><tbody>' +
      gridBodyBuffer +
      '</tbody></table>'
    )
  }

  /**
   * @memberOf LeafFormGrid
   */
  function getIndicator (indicatorID, series) {
    $.ajax({
      type: 'GET',
      url:
        rootURL +
        'api/form/' +
        recordID +
        '/rawIndicator/' +
        indicatorID +
        '/' +
        series,
      dataType: 'json',
      success: function (response) {
        let data =
          response[indicatorID].displayedValue !== ''
            ? response[indicatorID].displayedValue
            : response[indicatorID].value
        if (
          (response[indicatorID].format === 'checkboxes' ||
            response[indicatorID].format === 'multiselect') &&
          Array.isArray(data)
        ) {
          let tData = ''
          for (const i in data) {
            if (data[i] !== 'no') {
              tData += ', ' + data[i]
            }
          }
          data = tData.substr(2)
        }
        if (response[indicatorID].format === 'grid') {
          data = printTableReportBuilder(data)
        }
        if (response[indicatorID].format === 'date') {
          data = new Date(data).toLocaleDateString('en-US', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
          })
        }
        $('#' + prefixID + recordID + '_' + indicatorID)
          .empty()
          .html(data)
        $('#' + prefixID + recordID + '_' + indicatorID).fadeOut(
          250,
          function () {
            $('#' + prefixID + recordID + '_' + indicatorID).fadeIn(250)
          }
        )
      },
      cache: false
    })
  }

  let headerToggle = 0
  // header format: {name, indicatorID, sortable, editable, visible, [callback]}
  // callback receives {recordID, indicatorID, cellContainerID} within the scope of loadData()
  /**
   * @memberOf LeafFormGrid
   */
  function setHeaders (headersIn) {
    headers = headersIn
    let temp = '<tr id="' + prefixID + 'thead_tr' + '">'
    let virtualHeader = '<tr id="' + prefixID + 'tVirt_tr' + '">'
    if (showIndex) {
      temp +=
        '<th tabindex="0" id="' +
        prefixID +
        'header_UID" style="text-align: center">UID</th>'
      virtualHeader +=
        '<th id="Vheader_UID" style="text-align: center">UID</th>'
    }
    $('#' + prefixID + 'thead').html(temp)

    if (showIndex) {
      $('#' + prefixID + 'header_UID').css('cursor', 'pointer')
      $('#' + prefixID + 'header_UID').on('click', null, null, function (data) {
        if (headerToggle === 0) {
          sort('recordID', 'asc', postSortRequestFunc)
          headerToggle = 1
        } else {
          sort('recordID', 'desc', postSortRequestFunc)
          headerToggle = 0
        }
        renderBody(0, Infinity)
      })
    }

    for (const i in headers) {
      if (headers[i].visible === false) {
        continue
      }
      const align = headers[i].align !== undefined ? headers[i].align : 'center'
      $('#' + prefixID + 'thead_tr').append(
        '<th id="' +
          prefixID +
          'header_' +
          headers[i].indicatorID +
          '" tabindex="0"  style="text-align:' +
          align +
          '">' +
          headers[i].name +
          '<span id="' +
          prefixID +
          'header_' +
          headers[i].indicatorID +
          '_sort" class="' +
          prefixID +
          'sort"></span></th>'
      )
      virtualHeader +=
        '<th id="Vheader_' +
        headers[i].indicatorID +
        '" style="text-align:' +
        align +
        '">' +
        headers[i].name +
        '</th>'
      if (headers[i].sortable === undefined || headers[i].sortable === true) {
        $('#' + prefixID + 'header_' + headers[i].indicatorID).css(
          'cursor',
          'pointer'
        )
        $('#' + prefixID + 'header_' + headers[i].indicatorID).on(
          'click',
          null,
          headers[i].indicatorID,
          function (data) {
            if (headerToggle === 0) {
              sort(data.data, 'asc', postSortRequestFunc)
              headerToggle = 1
            } else {
              sort(data.data, 'desc', postSortRequestFunc)
              headerToggle = 0
            }
            renderBody(0, Infinity)
          }
        )
        // using enter key to sort the the table heads for 508 compliance
        $('#' + prefixID + 'header_' + headers[i].indicatorID).on(
          'keydown',
          null,
          headers[i].indicatorID,
          function (data) {
            if (data.keyCode === 13) {
              if (headerToggle === 0) {
                sort(data.data, 'asc', postSortRequestFunc)
                headerToggle = 1
              } else {
                sort(data.data, 'desc', postSortRequestFunc)
                headerToggle = 0
              }
              renderBody(0, Infinity)
            }
          }
        )
      }
    }
    $('#' + prefixID + 'thead').append('</tr>')
    virtualHeader += '</tr>'

    $('#' + prefixID + 'table>thead>tr>th').css({
      border: '1px solid black',
      padding: '4px 2px 4px 2px',
      'font-size': '12px'
    })

    // sticky headers
    let scrolled = false
    let initialTop

    $('#' + prefixID + 'table_stickyHeader').html(
      '<table><thead>' + virtualHeader + '</thead></table>'
    )
    $(window).on('resize', function () {
      renderVirtualHeader()
    })
    $(window).on('scroll', function () {
      scrolled = true
    })
    const renderRequest = []
    setInterval(function () {
      const scrollPos = $(window).scrollTop()
      const tableHeight = $('#' + prefixID + 'table').height()
      const pageHeight = $(window).height()
      if (
        scrolled &&
        $('#' + prefixID + 'thead').offset() !== undefined &&
        isRenderingVirtualHeader
      ) {
        scrolled = false
        initialTop = $('#' + prefixID + 'thead').offset().top

        if (scrollPos > initialTop && scrollPos < tableHeight + initialTop) {
          $('#' + prefixID + 'table_stickyHeader').css('display', 'inline')
          $('#' + prefixID + 'table_stickyHeader').css({
            position: 'absolute',
            top: scrollPos + 'px'
          })
        } else {
          $('#' + prefixID + 'table_stickyHeader').css('display', 'none')
        }
      }

      // render additional segment right before the user scrolls to it
      if (
        scrollPos + pageHeight * 1.2 > tableHeight &&
        isDataLoaded &&
        isRenderingBody
      ) {
        if (renderRequest[currentRenderIndex] === undefined) {
          renderRequest[currentRenderIndex] = 1
          renderBody(currentRenderIndex, defaultLimit)
        }
      }
    }, 100)
  }

  /**
   * Sort the current dataset based on rendered data in table cells
   * @param key key to sort on
   * @param order Sort order: asc/desc
   * @param callback (optional)
   * @memberOf LeafFormGrid
   */
  function sort (key, order, callback) {
    if (key !== 'recordID' && currLimit !== Infinity) {
      renderBody(0, Infinity)
    }

    $('.' + prefixID + 'sort').css('display', 'none')
    if (order.toLowerCase() === 'asc') {
      $('#' + prefixID + 'header_' + key).attr('aria-live', 'assertive')
      $('#' + prefixID + 'header_' + key).attr(
        'aria-label',
        'Sorting by ascending ' + key
      )
      $('#' + prefixID + 'header_' + key + '_sort').html(
        '<div style="position: absolute" aria-label="Sorting by ascending ' +
          key +
          '"></div>' +
          ' &#9650;'
      )
      $('#' + prefixID + 'header_' + key + '_sort').css(
        'vertical-align',
        'super'
      )
    } else {
      $('#' + prefixID + 'header_' + key).attr('aria-live', 'assertive')
      $('#' + prefixID + 'header_' + key).attr(
        'aria-label',
        'Sorting by descending ' + key
      )
      $('#' + prefixID + 'header_' + key + '_sort').html(
        '<div style="position: absolute" aria-label="Sorting by descending ' +
          key +
          '"></div>' +
          ' &#9660;'
      )
      $('#' + prefixID + 'header_' + key + '_sort').css('vertical-align', 'sub')
    }
    $('#' + prefixID + 'header_' + key + '_sort').css('display', 'inline')
    const array = []
    const isIndicatorID = $.isNumeric(key)
    let isDate = false
    let isNumeric = true
    const idKey = 'id' + key
    let tDate
    for (const i in currentData) {
      if (currentData[i][key] === undefined) {
        currentData[i][key] = $(
          '#' + prefixID + currentData[i].recordID + '_' + key
        ).html()
        currentData[i][key] =
          currentData[i][key] === undefined ? '' : currentData[i][key]
      }
      if (currentData[i].s1 === undefined) {
        currentData[i].s1 = {}
      }
      if (
        currentData[i].s1[idKey] === undefined ||
        currentData[i].s1[idKey] === ''
      ) {
        if (currentData[i].sDate === undefined) {
          currentData[i].sDate = {}
        }
        // Workaround for sorting manually created grid
        currentData[i].s1[idKey] = !isNaN(currentData[i][key])
          ? currentData[i][key]
          : ''
        currentData[i].sDate[key] = 0
      }
      if (isIndicatorID) {
        tDate = null
        if (
          isNaN(currentData[i].s1[idKey]) &&
          (currentData[i].s1[idKey].indexOf('-') !== -1 ||
            currentData[i].s1[idKey].indexOf('/') !== -1)
        ) {
          tDate = Date.parse(currentData[i].s1[idKey])
        }
        if (isDate || (tDate != null && !isNaN(tDate))) {
          isDate = true
          if (currentData[i].sDate === undefined) {
            currentData[i].sDate = {}
          }
          currentData[i].sDate[key] = 0
          currentData[i].sDate[key] = !isNaN(tDate) ? tDate : 0
        }
      } else {
        // detect date fields for other non-indicatorID columns
        tDate = null
        if (currentData[i].sDate === undefined) {
          currentData[i].sDate = {}
        }
        currentData[i].sDate[key] = 0

        if (
          isNaN(currentData[i][key]) &&
          (currentData[i][key].indexOf('-') !== -1 ||
            currentData[i][key].indexOf('/') !== -1)
        ) {
          tDate = Date.parse(currentData[i][key])
        }
        if (isDate || (tDate != null && !isNaN(tDate))) {
          isDate = true

          currentData[i].sDate[key] = !isNaN(tDate) && tDate != null ? tDate : 0
        }
      }

      if ($.isNumeric(currentData[i].s1[idKey]) & (isNumeric === true)) {
        currentData[i].s1[idKey] = parseFloat(currentData[i].s1[idKey])
      } else {
        isNumeric = false
      }

      array.push(currentData[i])
    }
    if (isDate) {
      array.sort(function (a, b) {
        if (b.sDate[key] > a.sDate[key]) {
          return 1
        }
        if (b.sDate[key] < a.sDate[key]) {
          return -1
        }
        return 0
      })
    } else if ($.isNumeric(key) || isNumeric) {
      array.sort(function (a, b) {
        if (b.s1[idKey] > a.s1[idKey]) {
          return 1
        }
        if (b.s1[idKey] < a.s1[idKey]) {
          return -1
        }
        return 0
      })
    } else if (key === 'recordID') {
      array.sort(function (a, b) {
        if (b[key] > a[key]) {
          return 1
        }
        if (b[key] < a[key]) {
          return -1
        }
        return 0
      })
    } else {
      const collator = new Intl.Collator('en', {
        numeric: true,
        sensitivity: 'base'
      })
      array.sort(function (a, b) {
        if (a[key] === undefined) {
          a[key] = ''
        }
        if (b[key] === undefined) {
          b[key] = ''
        }
        return collator.compare(b[key], a[key])
      })
    }
    if (order === 'asc') {
      array.reverse()
    }
    currentData = array

    if (callback !== undefined && typeof callback === 'function') {
      callback(key, order)
    }
  }

  /**
   * @memberOf LeafFormGrid
   */
  function renderVirtualHeader () {
    if (!isRenderingVirtualHeader) {
      return false
    }

    const virtHeaderSizes = []
    $('#' + prefixID + 'thead>tr>th').each(function () {
      virtHeaderSizes.push($(this).css('width'))
    })

    $('#' + prefixID + 'table_stickyHeader > table').css({
      width: $('#' + prefixID + 'thead').css('width'),
      height: '30px'
    })
    $('#' + prefixID + 'table_stickyHeader > table > thead > tr > th').each(
      function (idx) {
        $(this).css({
          width: virtHeaderSizes[idx],
          padding: '2px',
          'font-weight': 'normal'
        })
      }
    )

    $('#' + prefixID + 'table_stickyHeader > table').css({
      border: '1px solid black',
      'border-collapse': 'collapse',
      margin: '0 2px 0'
    })
    $('#' + prefixID + 'table_stickyHeader > table > thead > tr').css({
      'background-color': 'black',
      color: 'white'
    })
    $('#' + prefixID + 'table_stickyHeader > table > thead > tr > th').css(
      'border',
      '1px solid #e0e0e0'
    )
  }

  /**
   * @param startIdx (optional) row to start rendering on
   * @param limit (optional) number of rows to render
   * @memberOf LeafFormGrid
   */
  function renderBody (startIdx, limit) {
    isRenderingBody = true
    if (preRenderFunc != null) {
      preRenderFunc()
    }

    if (limit === undefined) {
      limit = defaultLimit
    }
    currLimit = limit

    let fullRender = false
    if (startIdx === undefined || startIdx === 0) {
      startIdx = 0
      $('#' + prefixID + 'tbody').empty()
      renderHistory = {}
      fullRender = true
    }

    let buffer = ''
    const callbackBuffer = []

    const colspan = showIndex ? headers.length + 1 : headers.length
    if (currentData.length === 0) {
      $('#' + prefixID + 'tbody').append(
        '<tr><td colspan="' +
          colspan +
          '" style="text-align: center">No Results</td></tr>'
      )
    }
    let counter = 0
    const validateHtml = document.createElement('div')
    for (let i = startIdx; i < currentData.length; i++) {
      if (counter >= limit) {
        currentRenderIndex = i
        break
      }

      // Prevent duplicate DOM IDs from being generated
      if (renderHistory[currentData[i].recordID] !== undefined) {
        continue
      }

      renderHistory[currentData[i].recordID] = 1
      buffer +=
        '<tr id="' + prefixID + 'tbody_tr' + currentData[i].recordID + '">'
      if (showIndex) {
        buffer +=
          '<td><a href="index.php?a=printview&recordID=' +
          currentData[i].recordID +
          '">' +
          currentData[i].recordID +
          '</a></td>'
      }
      for (const j in headers) {
        if (headers[j].visible === false) {
          continue
        }
        if (currentData[i] !== undefined) {
          const data = {}
          data.recordID = currentData[i].recordID
          data.indicatorID = headers[j].indicatorID
          data.cellContainerID =
            prefixID + currentData[i].recordID + '_' + headers[j].indicatorID
          data.index = i
          data.data = ''
          let editable = false

          if (
            headers[j].editable === undefined ||
            headers[j].editable !== false
          ) {
            editable = true
          }

          if ($.isNumeric(data.indicatorID)) {
            if (currentData[i].s1 === undefined) {
              currentData[i].s1 = {}
            }
            data.data =
              currentData[i].s1['id' + headers[j].indicatorID] !== undefined
                ? currentData[i].s1['id' + headers[j].indicatorID]
                : ''
            validateHtml.innerHTML = data.data
            data.data = validateHtml.innerHTML
            if (
              currentData[i].s1[
                'id' + headers[j].indicatorID + '_htmlPrint'
              ] !== undefined
            ) {
              let htmlPrint =
                '<textarea id="data_' +
                currentData[i].recordID +
                '_' +
                headers[j].indicatorID +
                '_1" style="display: none">' +
                data.data +
                '</textarea>'
              htmlPrint += currentData[i].s1[
                'id' + headers[j].indicatorID + '_htmlPrint'
              ]
                .replace(
                  /{{ iID }}/g,
                  currentData[i].recordID + '_' + headers[j].indicatorID
                )
                .replace(/{{ recordID }}/g, currentData[i].recordID)
              buffer +=
                '<td id="' +
                prefixID +
                currentData[i].recordID +
                '_' +
                headers[j].indicatorID +
                '" data-editable="' +
                editable +
                '" data-record-id="' +
                currentData[i].recordID +
                '" data-indicator-id="' +
                headers[j].indicatorID +
                '">' +
                htmlPrint +
                '</td>'
            } else {
              if (headers[j].cols !== undefined) {
                if (
                  currentData[i].s1[data.data] !== undefined &&
                  data.data.search('gridInput') &&
                  headers[j].cols.length > 0
                ) {
                  data.data = printTableReportBuilder(
                    currentData[i].s1[data.data],
                    headers[j].cols
                  )
                }
              } else {
                if (
                  currentData[i].s1[data.data] !== undefined &&
                  data.data.search('gridInput')
                ) {
                  data.data = printTableReportBuilder(
                    currentData[i].s1[data.data],
                    null
                  )
                }
              }
              buffer += `<td id="${prefixID + currentData[i].recordID}_${
                headers[j].indicatorID
              }"
                                           data-editable="${editable}"
                                           data-record-id="${
                                             currentData[i].recordID
                                           }"
                                           data-indicator-id="${
                                             headers[j].indicatorID
                                           }"
                                           data-format="${
                                             currentData[i].s1[
                                               'id' +
                                                 headers[j].indicatorID +
                                                 '_format'
                                             ]
                                           }">
                                            ${data.data}</td>`
            }
          } else if (headers[j].callback !== undefined) {
            buffer +=
              '<td id="' +
              prefixID +
              currentData[i].recordID +
              '_' +
              headers[j].indicatorID +
              '" data-clickable="' +
              editable +
              '"></td>'
          } else {
            buffer +=
              '<td id="' +
              prefixID +
              currentData[i].recordID +
              '_' +
              headers[j].indicatorID +
              '"></td>'
          }

          if (headers[j].callback !== undefined) {
            callbackBuffer.push(
              (function (funct, data) {
                return function () {
                  funct(data, dataBlob)
                }
              })(headers[j].callback, data)
            )
          }
        } else {
          buffer +=
            '<td id="' +
            prefixID +
            currentData[i].recordID +
            '_' +
            headers[j].indicatorID +
            '"></td>'
        }
      }
      buffer += '</tr>'
      counter++

      if (fullRender) {
        currentRenderIndex = i + 1
      }
    }

    if (
      currentRenderIndex + limit >= currentData.length ||
      limit === undefined
    ) {
      $('#' + prefixID + 'tfoot').html('')
    } else {
      $('#' + prefixID + 'tfoot').html(
        '<tr><td colspan=' +
          colspan +
          ' style="padding: 8px; background-color: #feffd1; font-size: 120%; font-weight: bold"><img src="' +
          rootURL +
          'images/indicator.gif" style="vertical-align: middle" alt="" /> Loading more results...</td></tr>'
      )
    }

    $('#' + prefixID + 'tbody').append(buffer)
    $('#' + prefixID + 'tbody td[data-editable=true]').addClass(
      'table_editable'
    )
    $('#' + prefixID + 'tbody td[data-clickable=true]').addClass(
      'table_editable'
    )
    $('#' + prefixID + 'tbody').unbind('click') // prevents multiple firing on same report builder element, which causes subsequent problems with icheck
    $('#' + prefixID + 'tbody').on(
      'click',
      'td[data-editable=true]',
      function (e) {
        form.setRecordID($(this).data('record-id'))
        const indicatorID = $(this).data('indicator-id')
        form.setPostModifyCallback(function () {
          getIndicator(indicatorID, 1)
          form.dialog().hide()
        })
        form.getForm(indicatorID, 1)
        form.dialog().show()
      }
    )
    for (const i in callbackBuffer) {
      callbackBuffer[i]()
    }

    $('#' + prefixID + 'table>tbody>tr>td').css({
      border: '1px solid black',
      padding: '8px'
    })
    if (postRenderFunc != null) {
      postRenderFunc()
    }
    renderVirtualHeader()
  }

  /**
   * @memberOf LeafFormGrid
   */
  function announceResults () {
    const term = $('[name="searchtxt"]').val()

    if (currentData.length === 0) {
      $('.status').text('No results found for term ' + term)
    } else {
      $('.status').text(
        'Search results found for term ' + term + ' listed below'
      )
    }
  }

  /**
   * @memberOf LeafFormGrid
   */
  function loadData (recordIDs, callback) {
    currentData = []
    const colspan = showIndex ? headers.length + 1 : headers.length
    $('#' + prefixID + 'tbody').html(
      '<tr><td colspan="' +
        colspan +
        '" style="text-align: left; padding: 8px">Building report... <img src="' +
        rootURL +
        'images/largespinner.gif" alt="" /></td></tr>'
    )

    let headerIDList = ''
    for (const i in headers) {
      if ($.isNumeric(headers[i].indicatorID)) {
        headerIDList += headers[i].indicatorID + ','
      }
    }

    $.ajax({
      type: 'POST',
      url: rootURL + 'api/form/customData',
      dataType: 'json',
      data: {
        recordList: recordIDs,
        indicatorList: headerIDList,
        CSRFToken
      },
      success: function (res) {
        isDataLoaded = true
        for (const i in res) {
          if (dataBlob[i] !== undefined) {
            for (const j in dataBlob[i]) {
              if (typeof dataBlob[i][j] === 'object') {
                // ECMA6
                // Object.assign(res[i][j], dataBlob[i][j]);
                for (const tAttr in dataBlob[i][j]) {
                  res[i][j] = res[i][j] || {}
                  res[i][j][tAttr] = dataBlob[i][j][tAttr]
                }
              } else {
                res[i][j] = dataBlob[i][j]
              }
            }
          }
          currentData.push(res[i])
        }
        if (postProcessDataFunc != null) {
          currentData = postProcessDataFunc(currentData)
        }
        sort('recordID', 'desc')
        renderBody(0, defaultLimit)

        if (callback !== undefined && typeof callback === 'function') {
          callback()
        }
      },
      cache: false
    })
  }

  /**
   * Set the working data set
   * @params array - Expects format: [{recordID}, ...]
   * @memberOf LeafFormGrid
   */
  function setData (data) {
    isDataLoaded = true
    currentData = data
  }

  /**
   * @memberOf LeafFormGrid
   */
  function setDataBlob (data) {
    dataBlob = data
  }

  /**
   * Imports LEAF Query result
   * @memberOf LeafFormGrid
   */
  function importQueryResult (res) {
    const tGridData = []
    for (const i in res) {
      tGridData.push(res[i])
    }
    setData(tGridData)
    setDataBlob(tGridData)
  }

  /**
   * @memberOf LeafFormGrid
   */
  function enableToolbar () {
    containerID = prefixID + 'gridToolbar'
    $('#' + containerID).css('display', 'block')
    $('#' + containerID).html(
      '<br/><button type="button" id="' +
        prefixID +
        'getExcel" class="buttonNorm"><img src="' +
        rootURL +
        'dynicons/?img=x-office-spreadsheet.svg&w=16" alt="" /> Export</button>'
    )

    $('#' + prefixID + 'getExcel').on('click', function () {
      if (currentRenderIndex !== currentData.length) {
        renderBody(0, Infinity)
      }
      const output = []
      const headers = []
      // removes triangle symbols so that ascii chars are not present in exported headers.
      $('#' + prefixID + 'thead>tr>th>span').each(function (idx, val) {
        $(val).html('')
      })
      $('#' + prefixID + 'thead>tr>th').each(function (idx, val) {
        headers.push($(val).text().trim())
      })
      output.push(headers) // first row will be headers

      let line = []
      let i = 0
      const numColumns = headers.length - 1
      document
        .querySelectorAll('#' + prefixID + 'tbody>tr>td')
        .forEach(function (val) {
          const foundScripts = val.querySelectorAll('script')

          for (let tIdx = 0; tIdx < foundScripts.length; tIdx++) {
            foundScripts[tIdx].parentNode.removeChild(foundScripts[tIdx])
          }

          const trimmedText = val.innerText.trim()
          line[i] = trimmedText
          // prevent some values from being interpretted as dates by excel
          const dataFormat = val.getAttribute('data-format')
          const testDateFormat = /^\d+[/-]\d+([/-]\d+)?$/
          const isNumber = /^\d+$/

          line[i] =
            (dataFormat !== null &&
              dataFormat !== 'date' &&
              testDateFormat.test(line[i])) ||
            (isNumber.test(line[i]) && line[i].length > 9)
              ? `="${line[i]}"`
              : line[i]
          if (i === 0 && headers[i] === 'UID') {
            line[i] =
              '=HYPERLINK("' +
              window.location.origin +
              window.location.pathname +
              '?a=printview&recordID=' +
              trimmedText +
              '", "' +
              trimmedText +
              '")'
          }
          i++
          if (i > numColumns) {
            output.push(line) // add new row
            line = []
            i = 0
          }
        })

      let rows = ''
      output.forEach(function (thisRow) {
        // escape double quotes
        thisRow.forEach(function (col, idx) {
          thisRow[idx] = col.replace(/"/g, '""')
        })
        // add to csv string
        rows += '"' + thisRow.join('","') + '",\r\n'
      })

      const download = document.createElement('a')
      const now = new Date().getTime()
      download.setAttribute(
        'href',
        'data:text/csv;charset=utf-8,' + encodeURIComponent(rows)
      )
      download.setAttribute('download', 'Exported_' + now + '.csv')
      download.style.display = 'none'

      document.body.appendChild(download)
      if (navigator.msSaveOrOpenBlob) {
        rows = '\uFEFF' + rows
        navigator.msSaveOrOpenBlob(
          new Blob([rows], { type: 'text/csv;charset=utf-8;' }),
          'Exported_' + now + '.csv'
        )
      } else {
        download.click()
      }
      document.body.removeChild(download)
    })
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to post process data. Returns currentData blob
   */
  function setPostProcessDataFunc (func) {
    postProcessDataFunc = func
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to run before rendering the body
   */
  function setPreRenderFunc (func) {
    preRenderFunc = func
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to run after rendering the body
   */
  function setPostRenderFunc (func) {
    postRenderFunc = func
  }

  /**
   * @memberOf LeafFormGrid
   * Set callback function to run after the user requests a sort.
   * The function takes two parameters: key, sort direction (asc/desc)
   */
  function setPostSortRequestFunc (func) {
    postSortRequestFunc = func
  }

  /**
   * @memberOf LeafFormGrid
   * Return data row from loadData() using the array's index
   */
  function getDataByIndex (index) {
    return currentData[index]
  }

  /**
   * @memberOf LeafFormGrid
   * Return data row from loadData() using recordID as the index
   */
  function getDataByRecordID (recordID) {
    for (const i in currentData) {
      if (currentData[i].recordID === recordID) {
        return currentData[i]
      }
    }
    return null
  }

  return {
    getPrefixID: function () {
      return prefixID
    },
    form: function () {
      return form
    },
    headers: function () {
      return headers
    },
    getCurrentData: function () {
      return currentData
    },
    hideIndex,
    setHeaders,
    sort,
    renderVirtualHeader,
    renderBody,
    announceResults,
    loadData,
    setData,
    setDataBlob,
    importQueryResult,
    enableToolbar,
    setPostProcessDataFunc,
    setPreRenderFunc,
    setPostRenderFunc,
    setPostSortRequestFunc,
    setDefaultLimit: function (limit) {
      defaultLimit = limit
    },
    getDefaultLimit: function () {
      return defaultLimit
    },
    getDataByIndex,
    getDataByRecordID,
    disableVirtualHeader: function () {
      isRenderingVirtualHeader = false
    },
    stop: function () {
      isRenderingBody = false
    },
    setRootURL: function (url) {
      rootURL = url
    }
  }
}
