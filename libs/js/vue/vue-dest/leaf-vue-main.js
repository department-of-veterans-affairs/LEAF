/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./libs/js/vue/vue-src/layout/footer/vue-leaf-footer.js":
/*!**************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/footer/vue-leaf-footer.js ***!
  \**************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "appFooter": () => (/* binding */ appFooter)
/* harmony export */ });
var appFooter = Vue.createApp({});
appFooter.component('vue-footer', {
  props: {
    hideFooter: {
      type: String,
      //json encoded boolean (is usually null)
      "default": "null"
    },
    productName: {
      type: String
    },
    version: {
      type: String
    },
    revision: {
      type: String
    }
  },
  template: "<footer v-if=\"hideFooter !== 'true'\" id=\"footer\" class=\"usa-footer leaf-footer noprint\">\n            <a id=\"versionID\" href=\"../?a=about\">{{productName}}<br />Version {{version}} r{{revision}}</a>\n            </footer>"
});

/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/admin-nav/admin-nav.js":
/*!******************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/admin-nav/admin-nav.js ***!
  \******************************************************************/
/***/ ((module) => {

//admin view links
module.exports = {
  data: function data() {
    return {
      navItems: [{
        title: 'Home',
        link: '../'
      }, {
        title: 'Report Builder',
        link: '../?a=reports'
      }, {
        title: 'Site Links',
        link: '#',
        subLinks: [{
          title: 'Nexus: Org Charts',
          link: '../' + this.$props.orgchartPath
        }],
        subLinkOpen: false,
        isClickedOn: false
      }, {
        title: 'Admin',
        link: '#',
        subLinks: [{
          title: 'Admin Home',
          link: './'
        }, {
          title: 'User Access',
          link: '#',
          subLinks: [{
            title: 'User Access Groups',
            link: '?a=mod_groups'
          }, {
            title: 'Service Chiefs',
            link: '?a=mod_svcChief'
          }],
          subLinkOpen: false,
          isClickedOn: false
        }, {
          title: 'Workflow Editor',
          link: '?a=workflow',
          renderCondition: this.$props.siteType !== 'national_subordinate'
        }, {
          title: 'Form Editor',
          link: '?a=form',
          renderCondition: this.$props.siteType !== 'national_subordinate'
        }, {
          title: 'LEAF Library',
          link: '?a=formLibrary',
          renderCondition: this.$props.siteType !== 'national_subordinate'
        }, {
          title: 'Site Settings',
          link: '?a=mod_system'
        }, {
          title: 'Site Distribution',
          link: '../report.php?a=LEAF_National_Distribution',
          renderCondition: this.$props.siteType === 'national_primary'
        }, {
          title: 'Timeline Explorer',
          link: '../report.php?a=LEAF_Timeline_Explorer'
        }, {
          title: 'Toolbox',
          link: '#',
          subLinks: [{
            title: 'Import Spreadsheet',
            link: '../report.php?a=LEAF_import_data'
          }, {
            title: 'Mass Action',
            link: '../report.php?a=LEAF_mass_action'
          }, {
            title: 'Initiator New Account',
            link: '../report.php?a=LEAF_request_initiator_new_account'
          }, {
            title: 'Sitemap Editor',
            link: '../report.php?a=LEAF_sitemaps_template'
          }],
          subLinkOpen: false,
          isClickedOn: false
        }, {
          title: 'LEAF Developer',
          link: '#',
          subLinks: [{
            title: 'Template Editor',
            link: '?a=mod_templates'
          }, {
            title: 'Email Template Editor',
            link: '?a=mod_templates_email'
          }, {
            title: 'LEAF Programmer',
            link: '?a=mod_templates_reports'
          }, {
            title: 'File Manager',
            link: '?a=mod_file_manager'
          }, {
            title: 'Search Database',
            link: '../?a=search'
          }, {
            title: 'Sync Services',
            link: '?a=admin_sync_services'
          }, {
            title: 'Update Database',
            link: '?a=admin_update_database'
          }],
          subLinkOpen: false,
          isClickedOn: false
        }],
        subLinkOpen: false,
        isClickedOn: false
      }]
    };
  },
  props: {
    siteType: {
      type: String,
      required: true
    },
    orgchartPath: {
      type: String,
      required: true
    },
    innerWidth: {
      type: Number,
      required: true
    }
  },
  computed: {
    isSmallScreen: function isSmallScreen() {
      return this.$props.innerWidth < 600;
    }
  },
  methods: {
    toggleSubModal: function toggleSubModal(event, item) {
      if (item.subLinks) {
        event.preventDefault();
        item.isClickedOn = !item.isClickedOn;

        if (item.isClickedOn) {
          this.modalOn(item);
        } else {
          this.modalOff(item);
        }

        this.adjustIndex(event);
      }
    },
    adjustIndex: function adjustIndex(event) {
      //so that the newest submenu opened will be on top
      var elLi = Array.from(document.querySelectorAll('nav li'));
      elLi.forEach(function (ele) {
        ele.style.zIndex = 100;
      });
      event.currentTarget.parentElement.style.zIndex = 200;
    },
    modalOn: function modalOn(item) {
      if (item.subLinks) {
        item.subLinkOpen = true;
      }
    },
    modalOff: function modalOff(item) {
      if (item.subLinks && !item.isClickedOn) {
        item.subLinkOpen = false;
      }
    }
  },
  template: "<li :key=\"item.title\" \n            v-for=\"item in navItems\"\n            \n            @mouseenter=\"modalOn(item)\"\n            @mouseleave=\"modalOff(item)\">\n            <a  :href=\"item.link\" \n                @click=\"toggleSubModal($event,item)\"\n                :class=\"{ 'active': item.isClickedOn }\">{{ item.title }}\n                <i v-if=\"item.subLinks\" :style=\"{color: !item.subLinkOpen ? '' : 'white'}\" class=\"fas fa-angle-down\"></i>\n            </a>\n            \n            <template v-if=\"item.subLinks && item.subLinkOpen\">\n                <ul class=\"sublinks\"> \n                    <li :key=\"subLink.title\" \n                        v-for=\"subLink in item.subLinks\" \n                        :style=\"{display: !subLink.hasOwnProperty('renderCondition') || subLink.renderCondition === true ? 'block' : 'none'}\"\n                        @mouseleave=\"modalOff(subLink)\"\n                        @mouseenter=\"modalOn(subLink)\">\n                        <a :href=\"subLink.link\"\n                            :target=\"subLink.title==='Nexus: Org Charts' ? '_blank' : '_self'\"\n                            @click=\"toggleSubModal($event,subLink)\" \n                            :class=\"{'active' : subLink.subLinkOpen || (subLink.subLinks && isSmallScreen)}\">\n                            {{ subLink.title }} \n                            <i v-if=\"subLink.subLinks && !isSmallScreen\" :style=\"{color: !subLink.subLinkOpen ? '' : 'white'}\" class=\"fas fa-caret-right\"></i>\n                        </a>\n                        \n                        <template v-if=\"subLink.subLinks && (subLink.subLinkOpen || isSmallScreen)\">\n                            <ul class=\"inner-sublinks\"> \n                                <li :key=\"sub.title\" v-for=\"sub in subLink.subLinks\">\n                                <a :href=\"sub.link\">{{ sub.title }}</a>\n                                </li>\n                            </ul>  \n                        </template>\n                    </li>\n                </ul> \n            </template>\n        </li>"
};

/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/leaf-warning/leaf-warning.js":
/*!************************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/leaf-warning/leaf-warning.js ***!
  \************************************************************************/
/***/ ((module) => {

//warning section with triangle
module.exports = {
  data: function data() {
    return {
      leafSecure: this.$props.propSecure
    };
  },
  props: {
    propSecure: {
      type: String,
      required: true
    }
  },
  template: "<div v-if=\"leafSecure==='0'\" id=\"leaf-warning\">\n            <div>\n                <h3>Do not enter PHI/PII: this site is not yet secure</h3>\n                <p><a href=\"../report.php?a=LEAF_start_leaf_secure_certification\">Start certification process</a></p>\n            </div>\n            <div><i class=\"fas fa-exclamation-triangle fa-2x\"></i></div>\n        </div>"
};

/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/minimize-btn/minimize-btn.js":
/*!************************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/minimize-btn/minimize-btn.js ***!
  \************************************************************************/
/***/ ((module) => {

module.exports = {
  props: {
    isRetracted: {
      type: Boolean,
      required: true
    }
  },
  computed: {
    buttonTitle: function buttonTitle() {
      return this.$props.isRetracted ? 'Display full header' : 'Minimize header';
    }
  },
  template: "<li role=\"button\" id=\"header-toggle-button\" :title=\"buttonTitle\">\n                <a href=\"#\" @click.prevent=\"$emit('toggle-top-header')\"><i :class=\"[isRetracted ? 'fas fa-angle-double-down': 'fas fa-angle-double-up']\"></i></a>\n               </li>"
};

/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/scroll-warning/scroll-warning.js":
/*!****************************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/scroll-warning/scroll-warning.js ***!
  \****************************************************************************/
/***/ ((module) => {

//scrolling warning banner
module.exports = {
  data: function data() {
    return {
      leafSecure: this.$props.propSecure
    };
  },
  props: {
    propSecure: {
      type: String,
      required: true
    },
    bgColor: {
      type: String,
      required: false,
      "default": 'rgb(250,75,50)'
    },
    textColor: {
      type: String,
      required: false,
      "default": 'rgb(255,255,255)'
    }
  },
  template: "<p v-if=\"leafSecure==='0'\" id=\"scrolling-leaf-warning\" :style=\"{backgroundColor: bgColor, color: textColor}\"><slot></slot></p>"
};

/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/user-info/user-info.js":
/*!******************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/user-info/user-info.js ***!
  \******************************************************************/
/***/ ((module) => {

//user info list in nav
module.exports = {
  data: function data() {
    return {
      userItems: {
        user: this.$props.userName,
        primaryAdmin: ''
      },
      subLinkOpen: false,
      isClickedOn: false
    };
  },
  props: {
    userName: {
      type: String
    },
    innerWidth: {
      type: Number
    }
  },
  methods: {
    toggleSubModal: function toggleSubModal(event) {
      event.preventDefault();
      this.isClickedOn = !this.isClickedOn;

      if (this.isClickedOn) {
        this.modalOn();
      } else {
        this.modalOff();
      }
    },
    modalOn: function modalOn() {
      this.subLinkOpen = true;
    },
    modalOff: function modalOff() {
      if (!this.isClickedOn) {
        this.subLinkOpen = false;
      }
    }
  },
  created: function created() {
    var _this = this;

    fetch('../api/system/primaryadmin', {
      "method": "GET"
    }).then(function (res) {
      return res.json();
    }).then(function (data) {
      var emailString = data['Email'] !== '' ? " - " + data['Email'] : '';

      if (data["Fname"] !== undefined && data["Lname"] !== undefined) {
        _this.userItems.primaryAdmin = data['Fname'] + " " + data['Lname'] + emailString;
      } else {
        _this.userItems.primaryAdmin = data["userName"] !== undefined ? data["userName"] : 'Not Set';
      }
    });
  },
  template: "<li @mouseleave=\"modalOff\" @mouseenter=\"modalOn\">\n            <a href=\"#\" @click=\"toggleSubModal\">\n                <i id=\"nav-user-icon\" class='fas fa-user-circle' alt='User Account Menu'>&nbsp;</i>\n                <span>{{ this.userItems.user }}</span> \n                <i :style=\"{color: !subLinkOpen ? '' : 'white'}\" class=\"fas fa-angle-down\"></i> \n            </a>\n            <template v-if=\"subLinkOpen\">\n                <ul class=\"sublinks\">\n                    <li><a href=\"#\">Your primary Admin:<p id=\"primary-admin\" class=\"leaf-user-menu-name\">{{userItems.primaryAdmin}}</p></a></li>\n                    <li><a href=\"../?a=logout\">Sign Out</a></li>\n                </ul>\n            </template>\n        </li>"
};

/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/vue-leaf-header.js":
/*!**************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/vue-leaf-header.js ***!
  \**************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "appHeader": () => (/* binding */ appHeader)
/* harmony export */ });
/* harmony import */ var _minimize_btn_minimize_btn__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./minimize-btn/minimize-btn */ "./libs/js/vue/vue-src/layout/header/minimize-btn/minimize-btn.js");
/* harmony import */ var _minimize_btn_minimize_btn__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_minimize_btn_minimize_btn__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _leaf_warning_leaf_warning__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./leaf-warning/leaf-warning */ "./libs/js/vue/vue-src/layout/header/leaf-warning/leaf-warning.js");
/* harmony import */ var _leaf_warning_leaf_warning__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_leaf_warning_leaf_warning__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _scroll_warning_scroll_warning__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./scroll-warning/scroll-warning */ "./libs/js/vue/vue-src/layout/header/scroll-warning/scroll-warning.js");
/* harmony import */ var _scroll_warning_scroll_warning__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_scroll_warning_scroll_warning__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _admin_nav_admin_nav__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./admin-nav/admin-nav */ "./libs/js/vue/vue-src/layout/header/admin-nav/admin-nav.js");
/* harmony import */ var _admin_nav_admin_nav__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_admin_nav_admin_nav__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _user_info_user_info__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./user-info/user-info */ "./libs/js/vue/vue-src/layout/header/user-info/user-info.js");
/* harmony import */ var _user_info_user_info__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_user_info_user_info__WEBPACK_IMPORTED_MODULE_4__);
/* harmony import */ var _vue_leaf_header_scss__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./vue-leaf-header.scss */ "./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss");






var appHeader = Vue.createApp({
  data: function data() {
    return {
      windowTop: 0,
      windowInnerWidth: 800,
      topIsRetracted: false
    };
  },
  components: {
    'minimize-button': (_minimize_btn_minimize_btn__WEBPACK_IMPORTED_MODULE_0___default()),
    'leaf-warning': (_leaf_warning_leaf_warning__WEBPACK_IMPORTED_MODULE_1___default()),
    'scrolling-leaf-warning': (_scroll_warning_scroll_warning__WEBPACK_IMPORTED_MODULE_2___default()),
    'admin-leaf-nav': (_admin_nav_admin_nav__WEBPACK_IMPORTED_MODULE_3___default()),
    'leaf-user-info': (_user_info_user_info__WEBPACK_IMPORTED_MODULE_4___default())
  },
  mounted: function mounted() {
    this.windowInnerWidth = window.innerWidth;
    document.addEventListener("scroll", this.onScroll);
    window.addEventListener("resize", this.onResize);
  },
  beforeUnmount: function beforeUnmount() {
    document.removeEventListener("scroll", this.onScroll);
    window.removeEventListener("resize", this.onResize);
  },
  methods: {
    onScroll: function onScroll() {
      this.windowTop = window.top.scrollY;
    },
    onResize: function onResize() {
      this.windowInnerWidth = window.innerWidth;
    },
    toggleHeader: function toggleHeader() {
      this.topIsRetracted = !this.topIsRetracted;
    }
  }
});

/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/api.js":
/*!*****************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/api.js ***!
  \*****************************************************/
/***/ ((module) => {

"use strict";

/*
  MIT License http://www.opensource.org/licenses/mit-license.php
  Author Tobias Koppers @sokra
*/

module.exports = function (cssWithMappingToString) {
  var list = []; // return the list of modules as css string

  list.toString = function toString() {
    return this.map(function (item) {
      var content = "";
      var needLayer = typeof item[5] !== "undefined";

      if (item[4]) {
        content += "@supports (".concat(item[4], ") {");
      }

      if (item[2]) {
        content += "@media ".concat(item[2], " {");
      }

      if (needLayer) {
        content += "@layer".concat(item[5].length > 0 ? " ".concat(item[5]) : "", " {");
      }

      content += cssWithMappingToString(item);

      if (needLayer) {
        content += "}";
      }

      if (item[2]) {
        content += "}";
      }

      if (item[4]) {
        content += "}";
      }

      return content;
    }).join("");
  }; // import a list of modules into the list


  list.i = function i(modules, media, dedupe, supports, layer) {
    if (typeof modules === "string") {
      modules = [[null, modules, undefined]];
    }

    var alreadyImportedModules = {};

    if (dedupe) {
      for (var _i = 0; _i < this.length; _i++) {
        var id = this[_i][0];

        if (id != null) {
          alreadyImportedModules[id] = true;
        }
      }
    }

    for (var _i2 = 0; _i2 < modules.length; _i2++) {
      var item = [].concat(modules[_i2]);

      if (dedupe && alreadyImportedModules[item[0]]) {
        continue;
      }

      if (typeof layer !== "undefined") {
        if (typeof item[5] === "undefined") {
          item[5] = layer;
        } else {
          item[1] = "@layer".concat(item[5].length > 0 ? " ".concat(item[5]) : "", " {").concat(item[1], "}");
          item[5] = layer;
        }
      }

      if (media) {
        if (!item[2]) {
          item[2] = media;
        } else {
          item[1] = "@media ".concat(item[2], " {").concat(item[1], "}");
          item[2] = media;
        }
      }

      if (supports) {
        if (!item[4]) {
          item[4] = "".concat(supports);
        } else {
          item[1] = "@supports (".concat(item[4], ") {").concat(item[1], "}");
          item[4] = supports;
        }
      }

      list.push(item);
    }
  };

  return list;
};

/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/sourceMaps.js":
/*!************************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/sourceMaps.js ***!
  \************************************************************/
/***/ ((module) => {

"use strict";


module.exports = function (item) {
  var content = item[1];
  var cssMapping = item[3];

  if (!cssMapping) {
    return content;
  }

  if (typeof btoa === "function") {
    var base64 = btoa(unescape(encodeURIComponent(JSON.stringify(cssMapping))));
    var data = "sourceMappingURL=data:application/json;charset=utf-8;base64,".concat(base64);
    var sourceMapping = "/*# ".concat(data, " */");
    var sourceURLs = cssMapping.sources.map(function (source) {
      return "/*# sourceURL=".concat(cssMapping.sourceRoot || "").concat(source, " */");
    });
    return [content].concat(sourceURLs).concat([sourceMapping]).join("\n");
  }

  return [content].join("\n");
};

/***/ }),

/***/ "./node_modules/css-loader/dist/cjs.js!./node_modules/sass-loader/dist/cjs.js!./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss":
/*!*********************************************************************************************************************************************!*\
  !*** ./node_modules/css-loader/dist/cjs.js!./node_modules/sass-loader/dist/cjs.js!./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss ***!
  \*********************************************************************************************************************************************/
/***/ ((module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var _node_modules_css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../../../../../node_modules/css-loader/dist/runtime/sourceMaps.js */ "./node_modules/css-loader/dist/runtime/sourceMaps.js");
/* harmony import */ var _node_modules_css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_node_modules_css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../../../../../node_modules/css-loader/dist/runtime/api.js */ "./node_modules/css-loader/dist/runtime/api.js");
/* harmony import */ var _node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1__);
// Imports


var ___CSS_LOADER_EXPORT___ = _node_modules_css_loader_dist_runtime_api_js__WEBPACK_IMPORTED_MODULE_1___default()((_node_modules_css_loader_dist_runtime_sourceMaps_js__WEBPACK_IMPORTED_MODULE_0___default()));
// Module
___CSS_LOADER_EXPORT___.push([module.id, "/* changed from Figma #f56600 to meet accessibility contrast */\n#vue-leaf-header * {\n  margin: 0;\n  padding: 0;\n  box-sizing: border-box;\n}\n\n/* the div that the vue header app is mounted on */\n#vue-leaf-header {\n  margin-bottom: 0.5em;\n  width: 100%;\n  min-width: 475px;\n  box-shadow: 0 4px 5px 1px rgba(0, 0, 25, 0.25);\n}\n\n/* scrolling warning banner */\n#scrolling-leaf-warning {\n  text-align: center;\n  font-size: 0.9rem;\n  padding: 0.1em;\n  width: 100%;\n  position: fixed;\n  z-index: 1000;\n}\n\n.warn-enter-from {\n  opacity: 0;\n}\n\n.warn-enter-to {\n  opacity: 1;\n}\n\n.warn-enter-active {\n  transition: opacity 0.25s ease;\n}\n\n/* header element. wraps header-top and nav-ribon */\nheader#leaf-header {\n  display: flex;\n  flex-direction: column;\n  font-family: \"PublicSans-Regular\", sans-serif;\n}\nheader#leaf-header i {\n  margin-left: 0.3em;\n}\n\n/* container for top part of header.  inc site info and top warning */\n#header-top {\n  padding: 0.25em 0.5em;\n  height: 90px;\n  width: 100%;\n  display: flex;\n  align-items: center;\n  background-color: #252f3e;\n  /* site info in top part of header */\n  /* warning in top right of header */\n}\n#header-top #logo {\n  width: 75px;\n  min-width: 75px;\n  margin-right: 0.5em;\n  height: 75px;\n  min-height: 75px;\n  cursor: pointer;\n}\n#header-top #logo img {\n  height: 100%;\n  width: auto;\n}\n#header-top #site-info-city, #header-top #site-info-title {\n  color: white;\n  font-style: normal;\n  line-height: 1.3;\n}\n#header-top #site-info-city {\n  font-size: 16px;\n}\n#header-top #site-info-title {\n  font-size: 22px;\n}\n#header-top #leaf-warning {\n  height: 100%;\n  margin-left: auto;\n  display: flex;\n  align-items: center;\n  text-align: right;\n  color: #ff7800;\n}\n#header-top #leaf-warning h3 {\n  font-size: 16px;\n  color: #ff7800 !important;\n}\n#header-top #leaf-warning a, #header-top #leaf-warning a:hover, #header-top #leaf-warning a:focus, #header-top #leaf-warning a:visited {\n  color: white;\n  text-decoration: underline;\n  line-height: 1.2;\n}\n\n/* bottom dark navy nav ribbon.  container for links, toggle, and user info */\nnav#leaf-vue-nav {\n  display: flex;\n  justify-content: space-between;\n  align-items: center;\n  width: 100%;\n  height: 36px;\n  background-color: #162e51;\n  z-index: 50;\n  font-size: 90%;\n  /* sublinks and inner-sublinks are sublist ul elements */\n  /* toggle full / minimized nav */\n  /* user info section  */\n}\nnav#leaf-vue-nav li {\n  list-style-type: none;\n  display: inline-block;\n  white-space: nowrap;\n}\nnav#leaf-vue-nav a {\n  text-decoration: none;\n  display: inline-block;\n  width: 100%;\n  height: 100%;\n  color: #c9c9c9;\n  border-left: 2px solid transparent;\n}\nnav#leaf-vue-nav a:hover, nav#leaf-vue-nav a:focus, nav#leaf-vue-nav a:active, nav#leaf-vue-nav a.active {\n  color: #eef;\n  background-color: #005ea2;\n}\nnav#leaf-vue-nav a:focus {\n  border-left: 2px solid #f0f0ff !important;\n}\nnav#leaf-vue-nav i {\n  color: #00bde3;\n}\nnav#leaf-vue-nav > ul {\n  height: 80%;\n  display: flex;\n}\nnav#leaf-vue-nav > ul > li {\n  padding: 0 0.25em;\n  position: relative;\n  border-radius: 2px;\n  display: flex;\n  align-items: center;\n}\nnav#leaf-vue-nav > ul > li > a {\n  padding: 0.2em 0.4em;\n  border-radius: 2px;\n  display: flex;\n  align-items: center;\n}\nnav#leaf-vue-nav .sublinks {\n  padding: 0.25em;\n  min-width: 150px;\n  position: absolute;\n  top: 100%;\n  left: 0;\n  display: flex;\n  flex-direction: column;\n  background-color: #162e51;\n  border-top: 2px solid #162e51;\n  box-shadow: 0 4px 10px 1px rgba(0, 0, 20, 0.2);\n  font-size: 0.8rem;\n}\nnav#leaf-vue-nav .sublinks li {\n  position: relative;\n}\nnav#leaf-vue-nav .sublinks a {\n  color: #c9c9c9;\n  padding: 0.7em 0.4em;\n}\nnav#leaf-vue-nav .sublinks a:hover, nav#leaf-vue-nav .sublinks a:focus, nav#leaf-vue-nav .sublinks a:active, nav#leaf-vue-nav .sublinks a.active {\n  color: #fff;\n  border-left: 2px solid #00bde3;\n}\nnav#leaf-vue-nav .sublinks i {\n  float: right;\n}\nnav#leaf-vue-nav .inner-sublinks {\n  padding: 0.25em;\n  position: absolute;\n  top: -0.25em;\n  left: 100%;\n  display: flex;\n  flex-direction: column;\n  background-color: #1476bd;\n  min-width: 150px;\n  box-shadow: 0 -3px 15px 4px rgba(0, 0, 20, 0.25);\n  font-size: 0.8rem;\n  transition: all 0.1s ease;\n}\nnav#leaf-vue-nav .inner-sublinks a {\n  color: #eef;\n  background-color: #005ea2;\n  border-bottom: 1px solid #1476bd;\n}\nnav#leaf-vue-nav .inner-sublinks a:focus {\n  border-bottom: 1px solid #1476bd !important;\n}\nnav#leaf-vue-nav #header-toggle-button {\n  padding: 0;\n  width: 12px;\n  height: 100%;\n  background-color: #112;\n  flex-shrink: 0;\n  font-size: 0.6rem;\n  cursor: pointer;\n}\nnav#leaf-vue-nav #header-toggle-button a {\n  width: 100%;\n  height: 100%;\n  border: 0;\n  margin: 0;\n  padding: 0;\n  border-radius: 1px;\n  display: flex;\n  justify-content: center;\n  align-items: center;\n}\nnav#leaf-vue-nav #header-toggle-button a:hover, nav#leaf-vue-nav #header-toggle-button a:focus, nav#leaf-vue-nav #header-toggle-button a:active {\n  background-color: #1476bd;\n  border: 0 !important;\n}\nnav#leaf-vue-nav #header-toggle-button a:hover i, nav#leaf-vue-nav #header-toggle-button a:focus i, nav#leaf-vue-nav #header-toggle-button a:active i {\n  color: white;\n}\nnav#leaf-vue-nav #header-toggle-button i {\n  display: inline-block;\n  margin: 0;\n}\nnav#leaf-vue-nav ul#nav-user-info {\n  font-size: 0.8rem;\n}\nnav#leaf-vue-nav ul#nav-user-info #nav-user-icon {\n  color: white;\n  font-size: 18px;\n  margin: 0 0.25em 0 0;\n}\nnav#leaf-vue-nav ul#nav-user-info > li {\n  min-width: 150px;\n}\nnav#leaf-vue-nav ul#nav-user-info ul {\n  width: 100%;\n  font-size: 90%;\n}\nnav#leaf-vue-nav ul#nav-user-info p {\n  margin-top: 0.2em;\n}\n\n/* for screen sizes specifically */\n@media (max-width: 768px) {\n  nav#leaf-vue-nav {\n    font-size: 80%;\n    padding-left: 0;\n  }\n\n  #vue-leaf-header #header-top h1 {\n    font-size: 20px;\n  }\n\n  #vue-leaf-header #header-top h2 {\n    font-size: 14px;\n  }\n}\n@media (max-width: 600px) {\n  nav#leaf-vue-nav .inner-sublinks {\n    position: relative;\n    left: 0;\n    top: 0;\n  }\n}", "",{"version":3,"sources":["webpack://./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss"],"names":[],"mappings":"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","sourcesContent":["$headerHeight: 90px;\n$navRibbonHeight: 36px;\n$BG-DarkNavy: #162e51;\n$BG-Charcoal: #252f3e;\n$BG-VividOrange: #ff7800; /* changed from Figma #f56600 to meet accessibility contrast */\n$BG-LightGray: #dcdee0;\n$USWDS-LtGray: #c9c9c9;\n$USWDS-Cyan: #00bde3;\n$BaseNavy: #005ea2;\n$LtNavy: #1476bd;\n\n#vue-leaf-header * {\n  margin: 0;\n  padding: 0;\n  box-sizing: border-box;\n}\n\n/* the div that the vue header app is mounted on */\n#vue-leaf-header {\n  margin-bottom: 0.5em;\n  width: 100%;\n  min-width: 475px;\n  box-shadow: 0 4px 5px 1px rgba(0,0,25,0.25);\n}\n\n/* scrolling warning banner */\n#scrolling-leaf-warning {\n  text-align: center;\n  font-size: 0.9rem;\n  padding: 0.1em;\n  width: 100%;\n  position: fixed;\n  z-index: 1000;\n}\n.warn-enter-from {\n  opacity: 0;\n}\n.warn-enter-to {\n  opacity: 1;\n}\n.warn-enter-active {\n  transition: opacity 0.25s ease;\n}\n\n/* header element. wraps header-top and nav-ribon */\nheader#leaf-header {\n  display: flex;\n  flex-direction: column;\n  font-family: \"PublicSans-Regular\", sans-serif;\n\n  i {\n    margin-left: 0.3em;\n  }\n}\n\n/* container for top part of header.  inc site info and top warning */\n#header-top {\n  padding: 0.25em 0.5em;\n  height: $headerHeight;\n  width: 100%;\n  display: flex;\n  align-items: center;\n  background-color: $BG-Charcoal;\n\n  #logo {\n    width: 75px;\n    min-width: 75px;\n    margin-right: 0.5em;\n    height: 75px;\n    min-height: 75px;\n    cursor: pointer;\n\n    img {\n      height: 100%;\n      width: auto;\n    }\n  }\n  /* site info in top part of header */\n  #site-info-city, #site-info-title {\n    color: white;\n    font-style: normal;\n    line-height: 1.3;\n  }\n  #site-info-city {\n    font-size: 16px;\n  }\n  #site-info-title {\n    font-size: 22px;\n  }\n  /* warning in top right of header */\n  #leaf-warning {\n    height: 100%;\n    margin-left: auto;\n    display: flex;\n    align-items: center;\n    text-align: right;\n    color: $BG-VividOrange;\n\n    h3 {\n      font-size: 16px;\n      color: $BG-VividOrange !important;\n    }\n    a, a:hover, a:focus, a:visited {\n      color: white;\n      text-decoration: underline;\n      line-height: 1.2;\n    }\n  }\n}\n\n/* bottom dark navy nav ribbon.  container for links, toggle, and user info */\nnav#leaf-vue-nav {\n  display: flex;\n  justify-content:space-between;\n  align-items: center;\n  width: 100%;\n  height: $navRibbonHeight;\n  background-color: $BG-DarkNavy;\n  z-index: 50;\n  font-size: 90%;\n\n  li {\n    list-style-type: none;\n    display: inline-block;\n    white-space: nowrap;\n  }\n  a {\n    text-decoration: none;\n    display: inline-block;\n    width: 100%;\n    height: 100%;\n    color: $USWDS-LtGray;\n    border-left: 2px solid transparent;\n  }\n  a:hover, a:focus, a:active, a.active {\n    color: #eef;\n    background-color: $BaseNavy;\n  }\n  a:focus {\n    border-left: 2px solid #f0f0ff !important;\n  }\n  i {\n    color: $USWDS-Cyan;\n  }\n\n  > ul {\n    height: 80%;\n    display: flex;\n\n    > li {\n      padding: 0 0.25em;\n      position: relative;\n      border-radius: 2px;\n      display: flex;\n      align-items: center;\n      > a {\n        padding: 0.2em 0.4em;\n        border-radius: 2px;\n        display: flex;\n        align-items: center;\n      }\n    }\n  }\n\n  /* sublinks and inner-sublinks are sublist ul elements */\n  .sublinks {\n    padding: 0.25em;\n    min-width: 150px;\n    position: absolute;\n    top: 100%;\n    left: 0;\n    display: flex;\n    flex-direction: column;\n    background-color: $BG-DarkNavy;\n    border-top: 2px solid $BG-DarkNavy;\n    box-shadow: 0 4px 10px 1px rgba(0,0,20,0.2);\n    font-size: 0.8rem;\n\n    li {\n      position: relative;\n    }\n    a {\n      color: $USWDS-LtGray;\n      padding: 0.7em 0.4em;\n    }\n    a:hover, a:focus, a:active, a.active {\n      color: #fff;\n      border-left: 2px solid $USWDS-Cyan;\n    }\n    i {\n      float: right;\n    }\n  }\n\n  .inner-sublinks {\n    padding: 0.25em;\n    position: absolute;\n    top: -0.25em;\n    left: 100%;\n    display: flex;\n    flex-direction: column;\n    background-color: $LtNavy;\n    min-width: 150px;\n    box-shadow: 0 -3px 15px 4px rgba(0,0,20,0.25);\n    font-size: 0.8rem;\n    transition: all 0.1s ease;\n\n    a {\n      color: #eef;\n      background-color: $BaseNavy;\n      border-bottom: 1px solid $LtNavy;\n    }\n    a:focus {\n      border-bottom: 1px solid $LtNavy !important;\n    }\n  }\n\n  /* toggle full / minimized nav */\n  #header-toggle-button {\n    padding: 0;\n    width: 12px;\n    height: 100%;\n    background-color: #112;\n    flex-shrink: 0;\n    font-size: 0.6rem;\n    cursor: pointer;\n\n    a {\n      width: 100%;\n      height: 100%;\n      border: 0;\n      margin: 0;\n      padding: 0;\n      border-radius: 1px;\n      display: flex;\n      justify-content: center;\n      align-items: center;\n      &:hover, &:focus, &:active {\n        background-color: $LtNavy;\n        border: 0 !important;\n        i {\n          color: white;\n        }\n      }\n    }\n    i {\n      display: inline-block;\n      margin: 0;\n    }\n  }\n\n  /* user info section  */\n  ul#nav-user-info {\n    font-size: 0.8rem;\n\n    #nav-user-icon {\n      color: white;\n      font-size: 18px;\n      margin: 0 0.25em 0 0;\n    }\n    > li {\n      min-width: 150px;\n    }\n    ul {\n      width: 100%;\n      font-size: 90%;\n    }\n    p {\n      margin-top: 0.2em;\n    }\n  }\n}\n\n\n/* for screen sizes specifically */\n@media (max-width: 768px) {\n  nav#leaf-vue-nav {\n    font-size: 80%;\n    padding-left: 0;\n  }\n  #vue-leaf-header #header-top h1 {\n    font-size: 20px;\n  }\n  #vue-leaf-header #header-top h2 {\n    font-size: 14px;\n  }\n}\n@media (max-width: 600px) {\n  nav#leaf-vue-nav .inner-sublinks {\n    position: relative;\n    left: 0;\n    top: 0;\n  }\n}"],"sourceRoot":""}]);
// Exports
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (___CSS_LOADER_EXPORT___);


/***/ }),

/***/ "./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss":
/*!****************************************************************!*\
  !*** ./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss ***!
  \****************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var _node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! !../../../../../../node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js */ "./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js");
/* harmony import */ var _node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! !../../../../../../node_modules/style-loader/dist/runtime/styleDomAPI.js */ "./node_modules/style-loader/dist/runtime/styleDomAPI.js");
/* harmony import */ var _node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! !../../../../../../node_modules/style-loader/dist/runtime/insertBySelector.js */ "./node_modules/style-loader/dist/runtime/insertBySelector.js");
/* harmony import */ var _node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2__);
/* harmony import */ var _node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! !../../../../../../node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js */ "./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js");
/* harmony import */ var _node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! !../../../../../../node_modules/style-loader/dist/runtime/insertStyleElement.js */ "./node_modules/style-loader/dist/runtime/insertStyleElement.js");
/* harmony import */ var _node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4__);
/* harmony import */ var _node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! !../../../../../../node_modules/style-loader/dist/runtime/styleTagTransform.js */ "./node_modules/style-loader/dist/runtime/styleTagTransform.js");
/* harmony import */ var _node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5___default = /*#__PURE__*/__webpack_require__.n(_node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5__);
/* harmony import */ var _node_modules_css_loader_dist_cjs_js_node_modules_sass_loader_dist_cjs_js_vue_leaf_header_scss__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! !!../../../../../../node_modules/css-loader/dist/cjs.js!../../../../../../node_modules/sass-loader/dist/cjs.js!./vue-leaf-header.scss */ "./node_modules/css-loader/dist/cjs.js!./node_modules/sass-loader/dist/cjs.js!./libs/js/vue/vue-src/layout/header/vue-leaf-header.scss");

      
      
      
      
      
      
      
      
      

var options = {};

options.styleTagTransform = (_node_modules_style_loader_dist_runtime_styleTagTransform_js__WEBPACK_IMPORTED_MODULE_5___default());
options.setAttributes = (_node_modules_style_loader_dist_runtime_setAttributesWithoutAttributes_js__WEBPACK_IMPORTED_MODULE_3___default());

      options.insert = _node_modules_style_loader_dist_runtime_insertBySelector_js__WEBPACK_IMPORTED_MODULE_2___default().bind(null, "head");
    
options.domAPI = (_node_modules_style_loader_dist_runtime_styleDomAPI_js__WEBPACK_IMPORTED_MODULE_1___default());
options.insertStyleElement = (_node_modules_style_loader_dist_runtime_insertStyleElement_js__WEBPACK_IMPORTED_MODULE_4___default());

var update = _node_modules_style_loader_dist_runtime_injectStylesIntoStyleTag_js__WEBPACK_IMPORTED_MODULE_0___default()(_node_modules_css_loader_dist_cjs_js_node_modules_sass_loader_dist_cjs_js_vue_leaf_header_scss__WEBPACK_IMPORTED_MODULE_6__["default"], options);




       /* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (_node_modules_css_loader_dist_cjs_js_node_modules_sass_loader_dist_cjs_js_vue_leaf_header_scss__WEBPACK_IMPORTED_MODULE_6__["default"] && _node_modules_css_loader_dist_cjs_js_node_modules_sass_loader_dist_cjs_js_vue_leaf_header_scss__WEBPACK_IMPORTED_MODULE_6__["default"].locals ? _node_modules_css_loader_dist_cjs_js_node_modules_sass_loader_dist_cjs_js_vue_leaf_header_scss__WEBPACK_IMPORTED_MODULE_6__["default"].locals : undefined);


/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js":
/*!****************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js ***!
  \****************************************************************************/
/***/ ((module) => {

"use strict";


var stylesInDOM = [];

function getIndexByIdentifier(identifier) {
  var result = -1;

  for (var i = 0; i < stylesInDOM.length; i++) {
    if (stylesInDOM[i].identifier === identifier) {
      result = i;
      break;
    }
  }

  return result;
}

function modulesToDom(list, options) {
  var idCountMap = {};
  var identifiers = [];

  for (var i = 0; i < list.length; i++) {
    var item = list[i];
    var id = options.base ? item[0] + options.base : item[0];
    var count = idCountMap[id] || 0;
    var identifier = "".concat(id, " ").concat(count);
    idCountMap[id] = count + 1;
    var indexByIdentifier = getIndexByIdentifier(identifier);
    var obj = {
      css: item[1],
      media: item[2],
      sourceMap: item[3],
      supports: item[4],
      layer: item[5]
    };

    if (indexByIdentifier !== -1) {
      stylesInDOM[indexByIdentifier].references++;
      stylesInDOM[indexByIdentifier].updater(obj);
    } else {
      var updater = addElementStyle(obj, options);
      options.byIndex = i;
      stylesInDOM.splice(i, 0, {
        identifier: identifier,
        updater: updater,
        references: 1
      });
    }

    identifiers.push(identifier);
  }

  return identifiers;
}

function addElementStyle(obj, options) {
  var api = options.domAPI(options);
  api.update(obj);

  var updater = function updater(newObj) {
    if (newObj) {
      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap && newObj.supports === obj.supports && newObj.layer === obj.layer) {
        return;
      }

      api.update(obj = newObj);
    } else {
      api.remove();
    }
  };

  return updater;
}

module.exports = function (list, options) {
  options = options || {};
  list = list || [];
  var lastIdentifiers = modulesToDom(list, options);
  return function update(newList) {
    newList = newList || [];

    for (var i = 0; i < lastIdentifiers.length; i++) {
      var identifier = lastIdentifiers[i];
      var index = getIndexByIdentifier(identifier);
      stylesInDOM[index].references--;
    }

    var newLastIdentifiers = modulesToDom(newList, options);

    for (var _i = 0; _i < lastIdentifiers.length; _i++) {
      var _identifier = lastIdentifiers[_i];

      var _index = getIndexByIdentifier(_identifier);

      if (stylesInDOM[_index].references === 0) {
        stylesInDOM[_index].updater();

        stylesInDOM.splice(_index, 1);
      }
    }

    lastIdentifiers = newLastIdentifiers;
  };
};

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/insertBySelector.js":
/*!********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/insertBySelector.js ***!
  \********************************************************************/
/***/ ((module) => {

"use strict";


var memo = {};
/* istanbul ignore next  */

function getTarget(target) {
  if (typeof memo[target] === "undefined") {
    var styleTarget = document.querySelector(target); // Special case to return head of iframe instead of iframe itself

    if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {
      try {
        // This will throw an exception if access to iframe is blocked
        // due to cross-origin restrictions
        styleTarget = styleTarget.contentDocument.head;
      } catch (e) {
        // istanbul ignore next
        styleTarget = null;
      }
    }

    memo[target] = styleTarget;
  }

  return memo[target];
}
/* istanbul ignore next  */


function insertBySelector(insert, style) {
  var target = getTarget(insert);

  if (!target) {
    throw new Error("Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.");
  }

  target.appendChild(style);
}

module.exports = insertBySelector;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/insertStyleElement.js":
/*!**********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/insertStyleElement.js ***!
  \**********************************************************************/
/***/ ((module) => {

"use strict";


/* istanbul ignore next  */
function insertStyleElement(options) {
  var element = document.createElement("style");
  options.setAttributes(element, options.attributes);
  options.insert(element, options.options);
  return element;
}

module.exports = insertStyleElement;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js":
/*!**********************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/setAttributesWithoutAttributes.js ***!
  \**********************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";


/* istanbul ignore next  */
function setAttributesWithoutAttributes(styleElement) {
  var nonce =  true ? __webpack_require__.nc : 0;

  if (nonce) {
    styleElement.setAttribute("nonce", nonce);
  }
}

module.exports = setAttributesWithoutAttributes;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/styleDomAPI.js":
/*!***************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/styleDomAPI.js ***!
  \***************************************************************/
/***/ ((module) => {

"use strict";


/* istanbul ignore next  */
function apply(styleElement, options, obj) {
  var css = "";

  if (obj.supports) {
    css += "@supports (".concat(obj.supports, ") {");
  }

  if (obj.media) {
    css += "@media ".concat(obj.media, " {");
  }

  var needLayer = typeof obj.layer !== "undefined";

  if (needLayer) {
    css += "@layer".concat(obj.layer.length > 0 ? " ".concat(obj.layer) : "", " {");
  }

  css += obj.css;

  if (needLayer) {
    css += "}";
  }

  if (obj.media) {
    css += "}";
  }

  if (obj.supports) {
    css += "}";
  }

  var sourceMap = obj.sourceMap;

  if (sourceMap && typeof btoa !== "undefined") {
    css += "\n/*# sourceMappingURL=data:application/json;base64,".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), " */");
  } // For old IE

  /* istanbul ignore if  */


  options.styleTagTransform(css, styleElement, options.options);
}

function removeStyleElement(styleElement) {
  // istanbul ignore if
  if (styleElement.parentNode === null) {
    return false;
  }

  styleElement.parentNode.removeChild(styleElement);
}
/* istanbul ignore next  */


function domAPI(options) {
  var styleElement = options.insertStyleElement(options);
  return {
    update: function update(obj) {
      apply(styleElement, options, obj);
    },
    remove: function remove() {
      removeStyleElement(styleElement);
    }
  };
}

module.exports = domAPI;

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/styleTagTransform.js":
/*!*********************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/styleTagTransform.js ***!
  \*********************************************************************/
/***/ ((module) => {

"use strict";


/* istanbul ignore next  */
function styleTagTransform(css, styleElement) {
  if (styleElement.styleSheet) {
    styleElement.styleSheet.cssText = css;
  } else {
    while (styleElement.firstChild) {
      styleElement.removeChild(styleElement.firstChild);
    }

    styleElement.appendChild(document.createTextNode(css));
  }
}

module.exports = styleTagTransform;

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			id: moduleId,
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be in strict mode.
(() => {
"use strict";
/*!**************************************!*\
  !*** ./libs/js/vue/vue-src/index.js ***!
  \**************************************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _layout_header_vue_leaf_header__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./layout/header/vue-leaf-header */ "./libs/js/vue/vue-src/layout/header/vue-leaf-header.js");
/* harmony import */ var _layout_footer_vue_leaf_footer__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./layout/footer/vue-leaf-footer */ "./libs/js/vue/vue-src/layout/footer/vue-leaf-footer.js");


_layout_header_vue_leaf_header__WEBPACK_IMPORTED_MODULE_0__.appHeader.mount('#vue-leaf-header');
_layout_footer_vue_leaf_footer__WEBPACK_IMPORTED_MODULE_1__.appFooter.mount('#vue-leaf-footer');
})();

/******/ })()
;
//# sourceMappingURL=leaf-vue-main.js.map