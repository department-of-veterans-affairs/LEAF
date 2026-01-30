/************************
    Form editor (Org Chart)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: March 6, 2012
*/
import { xscrub } from "../../libs/js/LEAF/XSSHelpers";

function orgchartForm(containerID) {
  this.containerID = containerID;
  this.prefixID = "orgForm" + Math.floor(Math.random() * 1000) + "_";
  this.dialog = null;
  this.updateEvents = new Object();
  this.currUID = null;
}

orgchartForm.prototype.initialize = function () {
  $("#" + this.containerID).html(
    '<div id="' +
      this.prefixID +
      'xhrDialog" style="visibility: hidden">\
				<form id="' +
      this.prefixID +
      'record" enctype="multipart/form-data" action="javascript:void(0);">\
				    <div>\
				        <button id="' +
      this.prefixID +
      'button_cancelchange" class="buttonNorm" style="position: absolute; left: 10px"><img src="dynicons/?img=process-stop.svg&amp;w=16" alt="" /> Cancel</button>\
				        <button id="' +
      this.prefixID +
      'button_save" class="buttonNorm" style="position: absolute; right: 10px"><img src="dynicons/?img=media-floppy.svg&amp;w=16" alt="" /> Save Change</button>\
				        <div style="border-bottom: 2px solid black; line-height: 30px"><br /></div>\
				        <div id="' +
      this.prefixID +
      'loadIndicator" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 300px; width: 460px">Loading... <img src="images/largespinner.gif" alt="" /></div>\
				        <div id="' +
      this.prefixID +
      'xhr" style="width: 500px; height: 400px; overflow: auto"></div>\
				    </div>\
				</form>\
				</div>'
  );
  this.dialog = new dialogController(
    this.prefixID + "xhrDialog",
    this.prefixID + "xhr",
    this.prefixID + "loadIndicator",
    this.prefixID + "button_save",
    this.prefixID + "button_cancelchange"
  );
};

orgchartForm.prototype.getForm = function (UID, categoryID, indicatorID) {
  this.currUID = UID;
  this.dialog.clearDialog();
  var dialog = this.dialog;
  var t = this;
  switch (categoryID) {
    case 1: // employee
      $.ajax({
        url:
          "ajaxEmployee.php?a=getindicator&empUID=" +
          UID +
          "&indicatorID=" +
          indicatorID,
        success: function (response) {
          dialog.setContent(response);
          $("input:visible:first, select:visible:first").focus();
          $("input:visible:first, select:visible:first").on("keydown", function (
            event
          ) {
            if (event.which == 13) {
              $("#" + dialog.btnSaveID).trigger("click");
            }
          });
        },
        error: function (jqXHR, status, error) {
          dialog.setContent("Error: " + error);
        },
        cache: false,
      });
      this.dialog.setSaveHandler(function () {
        $.ajax({
          type: "POST",
          url: "./api/employee/" + UID,
          data: $("#" + t.prefixID + "record").serialize(),
          success: function (res, args) {
            dialog.hide();
            t.updateFormDisplay(UID, categoryID, indicatorID);
          },
          cache: false,
        });
      });
      this.dialog.show();
      break;
    case 2: // position
      $.ajax({
        url:
          "ajaxPosition.php?a=getindicator&pID=" +
          UID +
          "&indicatorID=" +
          indicatorID,
        success: function (response) {
          dialog.setContent(response);
          $("input:visible:first, select:visible:first").focus();
          $("input:visible:first, select:visible:first").on("keydown", function (
            event
          ) {
            if (event.which == 13) {
              let elChosenDrop = null;
              if(event.target.classList.contains('chosen-search-input')) {
                elChosenDrop = document.querySelector('.chosen-with-drop');
              }
              if(elChosenDrop === null) { //if a chosen dropdown box is still open, the first enter will just close it.
                $("#" + dialog.btnSaveID).trigger("click");
              }
            }
          });
        },
        error: function (jqXHR, status, error) {
          dialog.setContent("Error: " + error);
        },
        cache: false,
      });
      this.dialog.setSaveHandler(function () {
        $.ajax({
          type: "POST",
          url: "./api/position/" + UID,
          data: $("#" + t.prefixID + "record").serialize(),
          success: function (res) {
            dialog.hide();
            t.updateFormDisplay(UID, categoryID, indicatorID);
          },
          cache: false,
        });
      });
      this.dialog.show();
      break;
    case 3: // group
      $.ajax({
        url:
          "ajaxGroup.php?a=getindicator&groupID=" +
          UID +
          "&indicatorID=" +
          indicatorID,
        success: function (response) {
          dialog.setContent(response);
          $("input:visible:first, select:visible:first").focus();
          $("input:visible:first, select:visible:first").on("keydown", function (
            event
          ) {
            if (event.which == 13) {
              $("#" + dialog.btnSaveID).trigger("click");
            }
          });
        },
        error: function (jqXHR, status, error) {
          dialog.setContent("Error: " + error);
        },
        cache: false,
      });
      this.dialog.setSaveHandler(function () {
        $.ajax({
          type: "POST",
          url: "./api/group/" + UID,
          data: $("#" + t.prefixID + "record").serialize(),
          success: function (res, args) {
            dialog.hide();
            t.updateFormDisplay(UID, categoryID, indicatorID);
          },
          cache: false,
        });
      });
      this.dialog.show();
      break;
    default:
      alert("default");
      break;
  }
};

orgchartForm.prototype.updateFormDisplay = function (
  UID,
  categoryID,
  indicatorID
) {
  var t = this;
  //No scrubbing here because the response is directly injected into the DOM and the HTML is needed as-is.
  switch (categoryID) {
    case 1: // employee
      $.ajax({
        url:
          "ajaxEmployee.php?a=getFormContent&indicatorID=" +
          indicatorID +
          "&empUID=" +
          UID,
        success: function (response) {
          $(
            "#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID
          ).empty();
          $("#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID).html(
            response
          );
          $("#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID)
            .fadeOut(250)
            .fadeIn(250);
          t.handleUpdateEvents(response, indicatorID);
        },
        cache: false,
      });
      break;
    case 2: // position
      $.ajax({
        url:
          "ajaxPosition.php?a=getFormContent&indicatorID=" +
          indicatorID +
          "&pID=" +
          UID,
        success: function (response) {
          $(
            "#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID
          ).empty();
          $("#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID).html(
            response
          );
          $("#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID)
            .fadeOut(250)
            .fadeIn(250);
          t.handleUpdateEvents(response, indicatorID);
        },
        cache: false,
      });
      break;
    case 3: // group
      $.ajax({
        url:
          "ajaxGroup.php?a=getFormContent&indicatorID=" +
          indicatorID +
          "&groupID=" +
          UID,
        success: function (response) {
          $(
            "#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID
          ).empty();
          $("#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID).html(
            response
          );
          $("#xhrIndicator_" + indicatorID + "_" + categoryID + "_" + UID)
            .fadeOut(250)
            .fadeIn(250);
          t.handleUpdateEvents(response, indicatorID);
        },
        cache: false,
      });
      break;
    default:
      alert("Unhandled categoryID");
      break;
  }
};

orgchartForm.prototype.addUpdateEvent = function (id, func) {
  this.updateEvents[id] = func;
};

orgchartForm.prototype.handleUpdateEvents = function (response, id) {
  if (this.updateEvents[id]) {
    this.updateEvents[id](response);
  }
};
