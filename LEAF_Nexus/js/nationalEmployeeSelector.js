/************************
 Employee Selector (Org Chart)
 Date: March 2, 2012
 */

function nationalEmployeeSelector(containerID) {
  this.apiPath = "./api/?a=";
  this.rootPath = "";
  this.useJSONP = 0;
  this.selection = "";

  this.containerID = containerID;
  this.prefixID = "empSel" + Math.floor(Math.random() * 1000) + "_";
  this.timer = 0;
  this.q = "";
  this.qDomain = "";
  this.isBusy = 1;
  this.backgroundImage = "images/indicator.gif";
  this.intervalID = null;
  this.selectHandler = null;
  this.resultHandler = null;
  this.selectLink = null;
  this.selectionData = new Object();
  this.optionNoLimit = 0;
  this.currRequest = null;
  this.outputStyle = "standard"; // standard / micro
  this.emailHref = false; // create link for email

  this.numResults = 0;
}

nationalEmployeeSelector.prototype.initialize = function () {
  var t = this;
  var domains = "";
  var tDomains = [
    "aac.dva.va.gov",
    "cem.va.gov",
    "dva.va.gov",
    "r01.med.va.gov",
    "r02.med.va.gov",
    "r03.med.va.gov",
    "r04.med.va.gov",
    "vba.va.gov",
    "vha.med.va.gov",
    "VHA01",
    "VHA02",
    "VHA03",
    "VHA04",
    "VHA05",
    "VHA06",
    "VHA07",
    "VHA08",
    "VHA09",
    "VHA10",
    "VHA11",
    "VHA12",
    "VHA15",
    "VHA16",
    "VHA17",
    "VHA18",
    "VHA19",
    "VHA20",
    "VHA21",
    "VHA22",
    "VHA23",
  ];
  for (var i in tDomains) {
    domains +=
      '<option value="' + tDomains[i] + '">' + tDomains[i] + "</option>";
  }

  var id = this.containerID.split("_")[1];
  var labelText = $("[for='" + id + "']")
    .text()
    .trim();
  var arialLabelText = labelText.split("*")[0];
  $("#" + this.containerID).html(
    '<div id="' +
      this.prefixID +
      'border" class="employeeSelectorBorder">\
			<select id="' +
      this.prefixID +
      'domain" class="employeeSelectorInput" style="width: 100px; display: none">\
			<option value="">All Domains</option>\
			' +
      domains +
      '\
			</select>\
			<span style="position: absolute; width: 60%; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); border: 0;" aria-atomic="true" aria-live="polite" id="' +
      this.prefixID +
      'status" role="status"></span>\
			<img id="' +
      this.prefixID +
      'icon" src="' +
      t.rootPath +
      'dynicons/?img=search.svg&w=16" class="employeeSelectorIcon" alt="search" />\
			<img id="' +
      this.prefixID +
      'iconBusy" src="' +
      t.rootPath +
      'images/indicator.gif" style="display: none" class="employeeSelectorIcon" alt="busy" />\
			<input id="' +
      this.prefixID +
      'input" type="search" class="employeeSelectorInput" aria-label="Search for user to add as ' +
      arialLabelText +
      '"></input></div>\
			<div id="' +
      this.prefixID +
      'result" aria-label="search results"></div>'
  );

  $("#" + this.prefixID + "input").on("keydown", function (e) {
    t.showBusy();
    t.timer = 0;
    if (e.keyCode == 13) {
      // enter key
      t.search();
    }
  });

  this.showNotBusy();
  this.intervalID = setInterval(function () {
    t.search();
  }, 200);
};

nationalEmployeeSelector.prototype.showNotBusy = function () {
  if (this.isBusy == 1) {
    $("#" + this.prefixID + "icon").css("display", "inline");
    $("#" + this.prefixID + "iconBusy").css("display", "none");
    this.isBusy = 0;
  }
};

nationalEmployeeSelector.prototype.showBusy = function () {
  $("#" + this.prefixID + "icon").css("display", "none");
  $("#" + this.prefixID + "iconBusy").css("display", "inline");
  $("#" + this.prefixID + "status").text("Loading");
  this.isBusy = 1;
};

nationalEmployeeSelector.prototype.select = function (id) {
  this.selection = id;
  if (
    event != undefined &&
    typeof event.key !== "undefined" &&
    event.key.toLowerCase() !== "enter"
  )
    return; //for keypress events
  $.each(
    $("#" + this.containerID + " .employeeSelected"),
    function (key, item) {
      $("#" + item.id).removeClass("employeeSelected");
      $("#" + item.id).addClass("employeeSelector");
    }
  );

  $("#" + this.prefixID + "emp" + id).removeClass("employeeSelector");
  $("#" + this.prefixID + "emp" + id).addClass("employeeSelected");

  if (this.selectHandler != null) {
    this.selectHandler();
  }
};

nationalEmployeeSelector.prototype.setSelectHandler = function (func) {
  this.selectHandler = func;
};

nationalEmployeeSelector.prototype.setResultHandler = function (func) {
  this.resultHandler = func;
};

nationalEmployeeSelector.prototype.setSelectLink = function (link) {
  this.selectLink = link;
};

nationalEmployeeSelector.prototype.clearSearch = function () {
  $("#" + this.prefixID + "input").val("");
};

nationalEmployeeSelector.prototype.forceSearch = function (query) {
  $("#" + this.prefixID + "input").val(query.replace(/<[^>]*>/g, ""));
};

nationalEmployeeSelector.prototype.hideInput = function () {
  $("#" + this.prefixID + "border").css("display", "none");
};

nationalEmployeeSelector.prototype.showInput = function () {
  $("#" + this.prefixID + "border").css("display", "block");
};

nationalEmployeeSelector.prototype.hideResults = function () {
  $("#" + this.prefixID + "result").css("display", "none");
};

nationalEmployeeSelector.prototype.showResults = function () {
  $("#" + this.prefixID + "result").css("display", "inline");
};

nationalEmployeeSelector.prototype.getSelectorFunction = function (empUID) {
  var t = this;
  return function () {
    t.select(empUID);
  };
};

nationalEmployeeSelector.prototype.enableNoLimit = function () {
  this.optionNoLimit = 1;
};

nationalEmployeeSelector.prototype.setDomain = function (domain) {
  $("#" + this.prefixID + "domain").val(domain);
};

nationalEmployeeSelector.prototype.runSearchQuery = function (query, domain) {
  var txt = query;
  this.q = query;
  var t = this;
  if (domain == undefined) {
    domain = "";
  }
  if (this.currRequest != null) {
    this.currRequest.abort();
  }

  var apiOption = "national/employee/search";
  if (query.substr(0, 1) == "#") {
    // search local directory, since an empUID query implies that the user already exists in the local dir.
    apiOption = "employee/search";
  }
  var announceID = this.prefixID;

  var ajaxOptions = {
    url: this.apiPath + apiOption,
    dataType: "json",
    data: { q: query, noLimit: this.optionNoLimit, domain: domain },
    success: function (response) {
      t.currRequest = null;
      t.numResults = 0;
      t.selection = "";
      $("#" + t.prefixID + "result").html("");
      var buffer = "";
      if (t.outputStyle == "micro") {
        buffer =
          '<table aria-live="true" aria-atomic="true" class="employeeSelectorTable"><thead><tr><th>Name</th><th>Contact</th></tr></thead><tbody id="' +
          t.prefixID +
          'result_table"></tbody></table>';
      } else {
        buffer =
          '<table aria-live="true" aria-atomic="true" class="employeeSelectorTable"><thead><tr><th>Name</th><th>Location</th><th>Contact</th></tr></thead><tbody id="' +
          t.prefixID +
          'result_table"></tbody></table>';
      }

      $("#" + t.prefixID + "result").html(buffer);

      if (response.length == 0) {
        $("#" + t.prefixID + "result_table").append(
          '<tr id="' +
            t.prefixID +
            'emp0"><td style="font-size: 120%; background-color: white; text-align: center" colspan=3>No results for &quot;<span style="color: red">' +
            txt +
            "</span>&quot;</td></tr>"
        );
        setTimeout(function () {
          $("#" + t.prefixID + "status").text(
            "No results found for term " + txt
          );
        }, 2500);
      } else {
        setTimeout(function () {
          $("#" + t.prefixID + "status").text(
            "Search results found for term " + txt + " listed below"
          );
        }, 2500);
      }

      t.selectionData = new Object();
      for (var i in response) {
        t.selectionData[response[i].empUID] = response[i];

        var photo =
          response[i].data[1] != undefined && response[i].data[1].data != ""
            ? '<img class="employeeSelectorPhoto" src="' +
              t.rootPath +
              "image.php?categoryID=1&amp;UID=" +
              response[i].empUID +
              '&amp;indicatorID=1" alt="photo" />'
            : "";
        var positionTitle =
          response[i].positionData != undefined
            ? response[i].positionData.positionTitle
            : "";
        positionTitle =
          positionTitle == "" && response[i].data[23] !== undefined
            ? response[i].data[23].data
            : positionTitle;
        var groupTitle = "";

        if (
          response[i].serviceData != undefined &&
          response[i].serviceData[0]?.groupTitle != null
        ) {
          var counter = 0;
          var divide = "";
          for (var j in response[i].serviceData) {
            if (counter > 0) {
              divide = " - ";
            }
            groupTitle +=
              divide +
              (response[i].serviceData[j].groupAbbreviation == null
                ? response[i].serviceData[j].groupTitle
                : response[i].serviceData[j].groupAbbreviation) +
              "<br />";
            counter++;
          }
        }

        room = "";
        if (response[i].data[8] != undefined) {
          if (response[i].data[8].data != "") {
            room = response[i].data[8].data;
          }
        }
        var email = "";
        if (t.emailHref) {
          email =
            response[i].data[6] != undefined
              ? '<b>Email:</b> <a href="mailto:' +
                response[i].data[6].data +
                '" onclick="event.stopPropagation();">' +
                response[i].data[6].data +
                "</a><br />"
              : "";
        } else {
          email =
            response[i].data[6] != undefined
              ? "<b>Email:</b> " + response[i].data[6].data + "<br />"
              : "";
        }

        phone =
          response[i].data[5] != undefined
            ? "<b>Phone:</b> " + response[i].data[5].data + "<br />"
            : "";

        midName =
          response[i].middleName == ""
            ? ""
            : "&nbsp;" + response[i].middleName + ".";
        linkText =
          response[i].lastName + ", " + response[i].firstName + midName;
        if (t.selectLink != null) {
          linkText =
            '<a href="' +
            t.selectLink +
            "&empUID=" +
            response[i].empUID +
            '">' +
            linkText +
            "</a>";
        }

        if (t.outputStyle == "micro") {
          $("#" + t.prefixID + "result_table").append(
            '<tr tabindex="0" id="' +
              t.prefixID +
              "emp" +
              response[i].empUID +
              '">\
                    <td class="employeeSelectorName" title="' +
              response[i].empUID +
              " - " +
              response[i].userName +
              '">' +
              photo +
              linkText +
              '<br /><span class="employeeSelectorTitle">' +
              positionTitle +
              '</span></td>\
                    <td class="employeeSelectorContact">' +
              email +
              phone +
              "</td>\
                    </tr>"
          );
        } else {
          $("#" + t.prefixID + "result_table").append(
            '<tr tabindex="0" id="' +
              t.prefixID +
              "emp" +
              response[i].empUID +
              '">\
                    <td class="employeeSelectorName" title="' +
              response[i].empUID +
              " - " +
              response[i].userName +
              '">' +
              photo +
              linkText +
              '<br /><span class="employeeSelectorTitle">' +
              positionTitle +
              '</span></td>\
                    <td class="employeeSelectorService">' +
              groupTitle +
              "<span>" +
              room +
              '</span></td>\
                    <td class="employeeSelectorContact">' +
              email +
              phone +
              "</td>\
                    </tr>"
          );
        }

        $("#" + t.prefixID + "emp" + response[i].empUID).addClass(
          "employeeSelector"
        );

        $("#" + t.prefixID + "emp" + response[i].empUID).on(
          "click",
          t.getSelectorFunction(response[i].empUID)
        );
        $("#" + t.prefixID + "emp" + response[i].empUID).on(
          "keypress",
          t.getSelectorFunction(response[i].empUID)
        );

        $("#" + t.prefixID + "status").append(
          " " + response[i].userName + " " + positionTitle + " " + email + ","
        );
        t.numResults++;
      }

      if (t.numResults == 1) {
        t.selection = response[i].empUID;
      }

      if (t.numResults >= 5) {
        var resultColSpan = 3;
        if (t.outputStyle == "micro") {
          resultColSpan = 2;
        }

        $("#" + t.prefixID + "result_table").append(
          '<tr id="' +
            t.prefixID +
            'tip">\
                <td class="employeeSelectorName" colspan="' +
            resultColSpan +
            '" style="background-color: white; text-align: center; font-weight: normal">&#x1f4a1; Can&apos;t find someone? Trying searching their Email address</td>\
                </tr>'
        );
      }

      if (t.resultHandler != null) {
        t.resultHandler();
      }

      t.showNotBusy();
    },
    cache: false,
  };
  var t = this;
  if (this.useJSONP == 1) {
    ajaxOptions.url += "&format=jsonp";
    ajaxOptions.dataType = "jsonp";
  }
  return $.ajax(ajaxOptions);
};

nationalEmployeeSelector.prototype.search = function () {
  if (
    $("#" + this.prefixID + "input").val() == undefined ||
    $("#" + this.prefixID + "input") == null
  ) {
    clearInterval(this.intervalID);
    return false;
  }
  this.timer += this.timer > 5000 ? 0 : 200;

  if (this.timer > 300) {
    var txt = $("#" + this.prefixID + "input")
      .val()
      .replace(/<[^>]*>/g, "");
    var domain = $("#" + this.prefixID + "domain")
      .val()
      .replace(/<[^>]*>/g, "");

    if (txt != undefined && (txt != this.q || domain != this.qDomain)) {
      this.q = txt;
      this.qDomain = domain;

      if (txt != "") {
        if (this.currRequest != null) {
          this.currRequest.abort();
        }

        // search local directory, since an empUID query implies that the user already exists in the local dir.
        var apiOption = "national/employee/search";
        if (this.q.substr(0, 1) == "#") {
          apiOption = "employee/search";
        }
        var announceID = this.prefixID;

        var ajaxOptions = {
          url: this.apiPath + apiOption,
          dataType: "json",
          data: {
            q: this.q,
            noLimit: this.optionNoLimit,
            domain: domain,
            includeDisabled: true,
          },
          success: function (response) {
            t.currRequest = null;
            t.numResults = 0;
            t.selection = "";
            $("#" + t.prefixID + "result").html("");
            var buffer = "";
            if (t.outputStyle == "micro") {
              buffer =
                '<table aria-live="true" aria-atomic="true" class="employeeSelectorTable"><thead><tr><th>Name</th><th>Contact</th></tr></thead><tbody id="' +
                t.prefixID +
                'result_table"></tbody></table>';
            } else {
              buffer =
                '<table aria-live="true" aria-atomic="true" class="employeeSelectorTable"><thead><tr><th>Name</th><th>Location</th><th>Contact</th></tr></thead><tbody id="' +
                t.prefixID +
                'result_table"></tbody></table>';
            }

            $("#" + t.prefixID + "result").html(buffer);

            if (response.length == 0) {
              $("#" + t.prefixID + "result_table").append(
                '<tr id="' +
                  t.prefixID +
                  'emp0"><td style="font-size: 120%; background-color: white; text-align: center" colspan=3>No results for &quot;<span id="' +
                  t.prefixID +
                  'emp0_message" style="color: red"></span>&quot;</td></tr>'
              );
              $("#" + t.prefixID + "emp0_message").text(txt);
              setTimeout(function () {
                $("#" + t.prefixID + "status").text(
                  "No results found for term " + txt
                );
              }, 2500);
            } else {
              setTimeout(function () {
                $("#" + t.prefixID + "status").text(
                  "Search results found for term " + txt + " listed below"
                );
              }, 2500);
            }

            t.selectionData = new Object();
            for (var i in response) {
              t.selectionData[response[i].empUID] = response[i];

              var photo =
                response[i].data[1] != undefined &&
                response[i].data[1].data != ""
                  ? '<img class="employeeSelectorPhoto" src="' +
                    t.rootPath +
                    "image.php?categoryID=1&amp;UID=" +
                    response[i].empUID +
                    '&amp;indicatorID=1" alt="photo" />'
                  : "";
              var positionTitle =
                response[i].positionData != undefined
                  ? response[i].positionData.positionTitle
                  : "";
              positionTitle =
                positionTitle == "" && response[i].data[23] !== undefined
                  ? response[i].data[23].data
                  : positionTitle;
              var groupTitle = "";

              if (
                response[i].serviceData != undefined &&
                response[i].serviceData[0]?.groupTitle != null
              ) {
                var counter = 0;
                var divide = "";
                for (var j in response[i].serviceData) {
                  if (counter > 0) {
                    divide = " - ";
                  }
                  groupTitle +=
                    divide +
                    (response[i].serviceData[j].groupAbbreviation == null
                      ? response[i].serviceData[j].groupTitle
                      : response[i].serviceData[j].groupAbbreviation) +
                    "<br />";
                  counter++;
                }
              }

              room = "";
              if (response[i].data[8] != undefined) {
                if (response[i].data[8].data != "") {
                  room = response[i].data[8].data;
                }
              }
              var email = "";
              if (t.emailHref) {
                email =
                  response[i].data[6] != undefined
                    ? '<b>Email:</b> <a href="mailto:' +
                      response[i].data[6].data +
                      '" onclick="event.stopPropagation();">' +
                      response[i].data[6].data +
                      "</a><br />"
                    : "";
              } else {
                email =
                  response[i].data[6] != undefined
                    ? "<b>Email:</b> " + response[i].data[6].data + "<br />"
                    : "";
              }

              phone =
                response[i].data[5] != undefined
                  ? "<b>Phone:</b> " + response[i].data[5].data + "<br />"
                  : "";

              midName =
                response[i].middleName == ""
                  ? ""
                  : "&nbsp;" + response[i].middleName + ".";
              linkText =
                response[i].lastName + ", " + response[i].firstName + midName;
              if (t.selectLink != null) {
                linkText =
                  '<a href="' +
                  t.selectLink +
                  "&empUID=" +
                  response[i].empUID +
                  '">' +
                  linkText +
                  "</a>";
              }

              if (t.outputStyle == "micro") {
                $("#" + t.prefixID + "result_table").append(
                  '<tr tabindex="0" id="' +
                    t.prefixID +
                    "emp" +
                    response[i].empUID +
                    '">\
								<td class="employeeSelectorName" title="' +
                    response[i].empUID +
                    " - " +
                    response[i].userName +
                    '">' +
                    photo +
                    linkText +
                    '<br /><span class="employeeSelectorTitle">' +
                    positionTitle +
                    '</span></td>\
								<td class="employeeSelectorContact">' +
                    email +
                    phone +
                    "</td>\
								</tr>"
                );
              } else {
                $("#" + t.prefixID + "result_table").append(
                  '<tr tabindex="0" id="' +
                    t.prefixID +
                    "emp" +
                    response[i].empUID +
                    '">\
								<td class="employeeSelectorName" title="' +
                    response[i].empUID +
                    " - " +
                    response[i].userName +
                    '">' +
                    photo +
                    linkText +
                    '<br /><span class="employeeSelectorTitle">' +
                    positionTitle +
                    '</span></td>\
								<td class="employeeSelectorService">' +
                    groupTitle +
                    "<span>" +
                    room +
                    '</span></td>\
								<td class="employeeSelectorContact">' +
                    email +
                    phone +
                    "</td>\
								</tr>"
                );
              }

              $("#" + t.prefixID + "emp" + response[i].empUID).addClass(
                "employeeSelector"
              );
              $("#" + t.prefixID + "emp" + response[i].empUID).on(
                "click",
                t.getSelectorFunction(response[i].empUID)
              );
              $("#" + t.prefixID + "emp" + response[i].empUID).on(
                "keypress",
                t.getSelectorFunction(response[i].empUID)
              );
              $("#" + t.prefixID + "status").append(
                " " +
                  response[i].userName +
                  " " +
                  positionTitle +
                  " " +
                  email +
                  ","
              );
              t.numResults++;
            }

            if (t.numResults == 1) {
              t.selection = response[i].empUID;
            }

            if (t.numResults >= 5) {
              var resultColSpan = 3;
              if (t.outputStyle == "micro") {
                resultColSpan = 2;
              }

              $("#" + t.prefixID + "result_table").append(
                '<tr id="' +
                  t.prefixID +
                  'tip">\
							<td class="employeeSelectorName" colspan="' +
                  resultColSpan +
                  '" style="background-color: white; text-align: center; font-weight: normal">&#x1f4a1; Can&apos;t find someone? Trying searching their Email address</td>\
							</tr>'
              );
            }

            if (t.resultHandler != null) {
              t.resultHandler();
            }

            t.showNotBusy();
          },
          error: function () {
            console.log("Failed to gather users information.");
          },
          cache: false,
        };
        var t = this;
        if (this.useJSONP == 1) {
          ajaxOptions.url += "&format=jsonp";
          ajaxOptions.dataType = "jsonp";
        }
        this.currRequest = $.ajax(ajaxOptions);
      } else if (txt == "") {
        $("#" + this.prefixID + "result").html("");
        this.numResults = 0;
        this.selection = "";
        if (this.resultHandler != null) {
          this.resultHandler();
        }
        this.showNotBusy();
      }
    } else {
      this.showNotBusy();
    }
  }
};

nationalEmployeeSelector.prototype.disableSearch = function () {
  $("#" + this.containerID).css("display", "none");
  clearInterval(this.intervalID);
};
