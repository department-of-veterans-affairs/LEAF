/************************
    Position UI element (Org Chart)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: May 18, 2012
*/

function position(positionID) {
  this.positionID = positionID;
  this.rootID = 0;
  this.parentID = 0;
  this.parentContainerID;
  this.containerHeader;
  this.x = null;
  this.y = null;

  this.prefixID = "pos" + Math.floor(Math.random() * 1000) + "_";
  this.data = new Object();
}

position.prototype.initialize = function (parentContainerID) {
  var t = this;
  this.parentContainerID = parentContainerID;

  var prefixedPID = this.prefixID + this.positionID;
  this.containerHeader = prefixedPID + "_title";
  var buffer = "";
  buffer =
    `<div id="${prefixedPID}" class="positionSmall">` +
      `<div id="${prefixedPID}_numFTE" class="fteCounter" style="margin:3px;"></div>` +
      `<div tabindex="0" role="button" id="${prefixedPID}_title" class="positionSmall_title"
        aria-expanded="false" aria-controls="${prefixedPID}_controls">
      </div>` +
      `<div id="${prefixedPID}_container" class="positionSmall_data">
        <div id="${prefixedPID}_content"></div>
        <div id="${prefixedPID}_controls" style="visibility: hidden; display: none">
          <a class="button buttonNorm" href="?a=view_position&amp;positionID=${this.positionID}">
            <img src="dynicons/?img=accessories-text-editor.svg&amp;w=32" alt="" /> View Details
          </a>
          <button type="button" class="button buttonNorm" onclick="addSubordinate(${this.positionID})">
            <img src="dynicons/?img=list-add.svg&amp;w=32" alt="" /> Add Subordinate
          </button>
        </div>
      </div>
    </div>`;
  $("#" + parentContainerID).append(buffer);

  $("#" + prefixedPID + "_title").on("click keydown mouseenter", function(ev) {
    //if they are newly focusing an open card just update the tab focus
    const isNewFocus = document.activeElement !== ev.currentTarget;
    if (ev.type === "click" && isNewFocus) {
      ev.currentTarget.focus();
      return;
    }
    const currDisplay =  $("#" + prefixedPID + "_controls").css('display');
    const isToggle =  [13, 32].includes(ev?.keyCode) || ev.type === "click";
    if(ev.type === "mouseenter" || (currDisplay === 'none' && isToggle)) {
        $("#" + prefixedPID + "_controls").css({
            visibility: "visible",
            display: "inline",
        });
        $("#" + prefixedPID).css("zIndex", "900");
        $("#" + prefixedPID + "_title").attr("aria-expanded", true);
    }
    if(currDisplay === 'inline' && isToggle) {
        t.unsetFocus();
    }
  });

  $('#' + prefixedPID + '_title').on('focus', function ( keyEnter ) {
    if (typeof moveCoordinates === 'function') {
      let position = prefixedPID.split('_');
      moveCoordinates(position[0] + '_', position[1]);
    }
  });

  document.querySelector('#' + prefixedPID + '_title').onmouseleave = function (
    mouse
  ) {
    if (!isInsideContainer(mouse, this)) {
      t.unsetFocus()
    }
  }

  function isInsideContainer(mouse, elem) {
    const elContainer = elem.parentNode;
    const containerBounding = elContainer.getBoundingClientRect();

    const mouseX = mouse.pageX;
    const mouseY = mouse.pageY;
    const roundFix = 2;
    return (
      mouseX > containerBounding.left + roundFix && mouseX < Math.floor(containerBounding.right) - roundFix &&
      mouseY > containerBounding.top + roundFix && mouseY < Math.floor(containerBounding.bottom) - roundFix
    );
  }

  $("#" + prefixedPID + "_container").on("mouseleave focusout", function (ev) {
    if(ev.type === "mouseleave") {
        t.unsetFocus();
    } else {
        const curTarget = ev.currentTarget || null;
        const newTarget = ev.relatedTarget || null;
        if(curTarget !== null && newTarget !== null) {
            const containerID = curTarget.id;
            const newTargetContainer = newTarget.closest('#' + containerID);
            if(newTargetContainer === null) {
                t.unsetFocus();
            }
        }
    }
  });

  //drag handles
  $("#" + this.containerHeader).on("mouseenter", function () {
    $("#" + this.containerHeader).addClass("positionSmall_title_drag");
  });
  $("#" + this.containerHeader).on("mouseleave", function () {
    $("#" + this.containerHeader).removeClass("positionSmall_title_drag");
  });
};

position.prototype.onLoad = function () {};

position.prototype.onDrawComplete = function () {};

position.prototype.prepContent = function (response) {
  this.data = response;
  this.setNumFTE(response[11].data);
  this.setTitle(response.title);
  var pd = response[9].data != "" ? "PD#" + response[9].data : "";
  this.setContent(
    response[2].data +
      " " +
      response[13].data +
      "-" +
      response[14].data +
      "<br />" +
      pd
  );
  if (response[15].data != "") {
    var layout = $.parseJSON(response[15].data);
    $("#" + this.prefixID + this.positionID).css("position", "absolute");
    var y = 120;
    var x = 40;
    if (layout[this.rootID] != undefined) {
      if (layout[this.rootID].y > 0) {
        y = layout[this.rootID].y;
      }
      if (layout[this.rootID].x > 0) {
        x = layout[this.rootID].x;
      }
    } else if (layout[this.parentID] != undefined) {
      if (layout[this.parentID].y > 0) {
        y = layout[this.parentID].y;
      }
      if (layout[this.parentID].x > 0) {
        x = layout[this.parentID].x;
      }
    }

    this.setDomPosition(x, y);
  }
};

position.prototype.draw = function (data) {
  var t = this;
  if (data == undefined) {
    $.ajax({
      url: "./api/position/" + this.positionID,
      data: { q: this.q },
      dataType: "json",
      success: function (data) {
        t.prepContent(data);
        t.onLoad();
        t.onDrawComplete();
      },
      cache: false,
    });
  } else {
    t.data = data;
    response = data;
    t.prepContent(response);
    t.onLoad();
    t.onDrawComplete();
  }
};

position.prototype.getDomID = function () {
  return this.prefixID + this.positionID;
};

position.prototype.setDomPosition = function (x, y) {
  this.x = x;
  this.y = y;
  $("#" + this.prefixID + this.positionID).css({
    position: "absolute",
    top: y + "px",
    left: x + "px",
  });
};

position.prototype.getPositionID = function () {
  return this.positionID;
};

position.prototype.setNumFTE = function (numFTE) {
  $("#" + this.prefixID + this.positionID + "_numFTE").html(numFTE);
};

position.prototype.setTitle = function (title) {
  if (title == "") {
    title = "";
  }
  $("#" + this.prefixID + this.positionID + "_title").html(title);
};

position.prototype.setContent = function (content) {
  $("#" + this.prefixID + this.positionID + "_content").html(content);
};

position.prototype.setRootID = function (rootID) {
  this.rootID = rootID;
};

position.prototype.setParentID = function (parentID) {
  this.parentID = parentID;
};

position.prototype.unsetFocus = function () {
  $("#" + this.prefixID + this.positionID + "_controls").css(
    "visibility",
    "hidden"
  );
  $("#" + this.prefixID + this.positionID + "_controls").css("display", "none");
  $("#" + this.prefixID + this.positionID).css("zIndex", "20");
  $("#" + this.prefixID  + this.positionID + "_title").attr("aria-expanded", false);
};

position.prototype.emptyControls = function () {
  $("#" + this.prefixID + this.positionID + "_controls").empty();
};

position.prototype.addControl = function (control) {
  $("#" + this.prefixID + this.positionID + "_controls").append(control);
};
