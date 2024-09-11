/************************
    Position Selector (Org Chart)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: March 2, 2012
*/

function positionSelector(containerID) {
  this.apiPath = "./api/?a=";
  this.rootPath = "";
  this.selection = "";

  this.containerID = containerID;
  this.prefixID = this.makePrefixID();
  this.timer = 0;
  this.q = "";
  this.isBusy = 1;
  this.backgroundImage = "images/indicator.gif";
  this.intervalID = null;
  this.selectHandler = null;
  this.resultHandler = null;
  this.selectLink = null;
  this.selectionData = new Object();
  this.optionEmployeeSearch = 0;
  this.optionNoLimit = 0;
  this.currRequest = null;

  this.numResults = 0;
}

positionSelector.prototype.makePrefixID = function () {
  const id = "posSel" + Math.floor(Math.random() * 1000) + "_";
  const el = document.getElementById(id + 'result');
  return (el !== null) ? this.makePrefixID() : id;
}

positionSelector.prototype.initialize = function () {
  var t = this;
  const id = this.containerID.split("_")[1];
  const labelText = $("[for='" + id + "']")
    .text()
    .trim();
  const arialLabelText = labelText.split("*")[0];
  $("#" + this.containerID).html(
    '<div id="' +
      this.prefixID +
      'border" class="positionSelectorBorder">\
			<div style="float: left"><img id="' +
      this.prefixID +
      'icon" src="' +
      t.rootPath +
      'dynicons/?img=search.svg&w=16" class="positionSelectorIcon" alt="" />\
			<span style="position: absolute; width: 60%; height: 1px; margin: -1px; padding: 0; overflow: hidden; clip: rect(0,0,0,0); border: 0;" aria-atomic="true" aria-live="polite" id="' +
      this.prefixID +
      'status" role="status"></span>\
			<img id="' +
      this.prefixID +
      'iconBusy" src="' +
      t.rootPath +
      'images/indicator.gif" style="display: none" class="positionSelectorIcon" alt="" /></div>\
			<input id="' +
      this.prefixID +
      'input" type="search" class="positionSelectorInput" aria-label="Search for user to add as ' +
      arialLabelText +
      '"/></div>\
			<div tabindex="0" id="' +
      this.prefixID +
      'result"></div>'
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

positionSelector.prototype.showNotBusy = function () {
  if (this.isBusy == 1) {
    $("#" + this.prefixID + "icon").css("display", "inline");
    $("#" + this.prefixID + "iconBusy").css("display", "none");
    this.isBusy = 0;
  }
};

positionSelector.prototype.showBusy = function () {
  $("#" + this.prefixID + "icon").css("display", "none");
  $("#" + this.prefixID + "iconBusy").css("display", "inline");
  $("#" + this.prefixID + "status").text("Loading");

  this.isBusy = 1;
};

positionSelector.prototype.select = function (id) {
  this.selection = id;
  if (
    event != undefined &&
    typeof event.key !== "undefined" &&
    event.key.toLowerCase() !== "enter"
  )
    return;
  $.each(
    $("#" + this.containerID + " .positionSelected"),
    function (key, item) {
      $("#" + item.id).removeClass("positionSelected");
      $("#" + item.id).addClass("positionSelector");
    }
  );

  $("#" + this.prefixID + "pos" + id).removeClass("positionSelector");
  $("#" + this.prefixID + "pos" + id).addClass("positionSelected");

  if (this.selectHandler != null) {
    this.selectHandler();
  }
};

positionSelector.prototype.setSelectHandler = function (func) {
  this.selectHandler = func;
};

positionSelector.prototype.setResultHandler = function (func) {
  this.resultHandler = func;
};

positionSelector.prototype.setSelectLink = function (link) {
  this.selectLink = link;
};

positionSelector.prototype.forceSearch = function (query) {
  $("#" + this.prefixID + "input").val(query.replace(/<[^>]*>/g, ""));
};

positionSelector.prototype.hideInput = function () {
  $("#" + this.prefixID + "border").css("display", "none");
};

positionSelector.prototype.showInput = function () {
  $("#" + this.prefixID + "border").css("display", "block");
};

positionSelector.prototype.hideResults = function () {
  $("#" + this.prefixID + "result").css("display", "none");
};

positionSelector.prototype.showResults = function () {
  $("#" + this.prefixID + "result").css("display", "inline");
};

positionSelector.prototype.enableEmployeeSearch = function () {
  this.optionEmployeeSearch = 1;
};

positionSelector.prototype.enableNoLimit = function () {
  this.optionNoLimit = 1;
};

positionSelector.prototype.search = function () {
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

    if (txt != "" && txt != this.q) {
      this.q = txt;

      if (this.currRequest != null) {
        this.currRequest.abort();
      }

      var t = this;
      this.currRequest = $.ajax({
        url: this.apiPath + "position/search",
        dataType: "json",
        data: {
          q: this.q,
          employeeSearch: this.optionEmployeeSearch,
          noLimit: this.optionNoLimit,
        },
        success: function (response, args) {
          t.currRequest = null;
          t.selection = "";
          t.numResults = 0;
          $("#" + t.prefixID + "result").html("");
          var buffer =
            '<table class="positionSelectorTable"><tr><th>Title</th><th>Incumbent(s)</th></tr><tbody id="' +
            t.prefixID +
            'result_table"></tbody></table>';
          $("#" + t.prefixID + "result").html(buffer);

          if (response.length == 0) {
            $("#" + t.prefixID + "result_table").append(
              '<tr id="' +
                t.prefixID +
                'emp0"><td style="font-size: 120%; background-color: white; text-align: center" colspan=2>No results for &quot;<span id="' +
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
          $.each(response, function (key, item) {
            t.selectionData[item.positionID] = item;

            service = "";
            if (item.services != undefined) {
              var counter = 0;
              var divide = "";
              for (var i in item.services) {
                if (counter > 0) {
                  divide = " - ";
                }
                if (item.services[i].groupAbbreviation != null) {
                  service += divide + item.services[i].groupAbbreviation;
                } else {
                  service += divide + item.services[i].groupTitle;
                }
                counter++;
              }
            }

            employees = "";
            if (item.employeeList[0] != undefined) {
              for (var id in item.employeeList) {
                if (item.employeeList[id].firstName != null) {
                  employees +=
                    item.employeeList[id].firstName +
                    " " +
                    item.employeeList[id].lastName +
                    ", ";
                }
              }
              employees = employees.replace(/, $/, "");
            }
            var payGrade = "";
            if (item.positionData[2].data != "") {
              payGrade =
                ' <span style="font-weight: normal">(' +
                item.positionData[2].data +
                " " +
                item.positionData[14].data +
                ")</span>";
            }

            linkText = item.positionTitle + payGrade;
            if (t.selectLink != null) {
              linkText =
                '<a href="' +
                t.selectLink +
                "&positionID=" +
                item.positionID +
                '">' +
                linkText +
                "</a>";
            }

            $("#" + t.prefixID + "result_table").append(
              '<tr tabindex="0" id="' +
                t.prefixID +
                "pos" +
                item.positionID +
                '">\
	                			<td class="positionSelectorTitle" title="PositionID: ' +
                item.positionID +
                '">' +
                linkText +
                '<br /><span class="positionSelectorService">' +
                service +
                '</span></td>\
                    			<td class="positionSelectorIncumbents">' +
                employees +
                "</td></tr>"
            );

            $("#" + t.prefixID + "pos" + item.positionID).addClass(
              "positionSelector"
            );

            $("#" + t.prefixID + "pos" + item.positionID).on(
              "click",
              function () {
                t.select(item.positionID);
              }
            );
            $("#" + t.prefixID + "pos" + item.positionID).on(
              "keypress",
              function () {
                t.select(item.positionID);
              }
            );
            $("#" + t.prefixID + "status").append(" " + linkText + ",");
            t.numResults++;
          });

          if (t.numResults == 1) {
            t.selection = response[0].positionID;
          }

          if (t.resultHandler != null) {
            t.resultHandler();
          }

          t.showNotBusy();
          return response;
        },
        preventCache: true,
      });
    } else if (txt == "") {
      this.q = txt;
      $("#" + this.prefixID + "result").html("");
      this.numResults = 0;
      this.selection = "";
      if (this.resultHandler != null) {
        this.resultHandler();
      }
      this.showNotBusy();
    } else {
      this.showNotBusy();
    }
  }
};

positionSelector.prototype.disableSearch = function () {
  $("#" + this.containerID).css("display", "none");
  clearInterval(this.intervalID);
};
