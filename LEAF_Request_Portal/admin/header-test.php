<?php
require_once '/var/www/html/app/libs/globals.php';

?>
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>LEAF Header Design Template</title>

  <link rel="stylesheet" href=<?= 'https://' . HTTP_HOST . '/app/libs/css/leaf.css'; ?>>

</head>

<section class="usa-banner bg-orange-40" aria-label="Official government website">
  <div class="usa-accordion">
    <header class="usa-banner__header">
        <div class="grid-col-fill tablet:grid-col-auto">
          <p class="usa-banner__header-text text-white">&nbsp;Do not enter PHI/PII</p>
        </div>
    </header>
</section>

<header id="header" class="usa-header site-header">
    <nav class="usa-navbar site-header-navbar">

        <div class="usa-logo site-logo" id="logo">
            <em class="usa-logo__text">
                <a href="/index.php" title="Home" aria-label="LEAF home" class="leaf-cursor-pointer">
                    <span class="leaf-logo"><img src="../images/VA_icon_small.png" /></span>
                    <span class="leaf-site-title">Site Portal Name</span>
                    <span id="headerDescription" class="leaf-header-description">Location Name</span>
                </a>
            </em>
        </div>

        <div class="leaf-header-right">
            <div class="leaf-user-menu">
                <span>Welcome, </span><a href="javascript:void(0)">Sample User</a>
            </div>
            <ul class="leaf-main-nav">

                <li class="leaf-width-7rem"><a href="javascript:void(0)">Home</a></li>

                <li class="leaf-width-10rem"><a href="javascript:void(0)">Report Builder</a></li>

                <li class="leaf-width-10rem">
                    <a href="javascript:void(0)" aria-haspopup="true">Site Links<i class="fas fa-angle-down leaf-nav-icon"></i></a>
                    <ul aria-hidden="true" aria-expanded="false" aria-label="Site Links submenu">
                        <li><a href="javascript:void(0)">Nexus: Org Charts</a></li>
                        <li><a href="javascript:void(0)">Sitemap Link One</a></li>
                        <li><a href="javascript:void(0)">Sitemap Link Two</a></li>
                        <li><a href="javascript:void(0)">Sitemap Link Three</a></li>
                    </ul>
                </li>

                <li class="leaf-width-9rem">
                    <a href="javascript:void(0)" aria-haspopup="true">Admin<i class="fas fa-angle-down leaf-nav-icon"></i></a>
                    <ul aria-hidden="true" aria-expanded="false" aria-label="Admin submenu">
                        <li><a href="javascript:void(0)">User Access<i class="fas fa-caret-left leaf-nav-icon-3"></i></a>
                            <ul>
                                <li><a href="javascript:void(0)">Template Editor</a></li>
                                <li><a href="javascript:void(0)">LEAF Programmer</a></li>
                                <li><a href="javascript:void(0)">Search Database</a></li>
                                <li><a href="javascript:void(0)">Update Database</a></li>
                                <li><a href="javascript:void(0)">File Manager</a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:void(0)">Workflow Editor<i class="leaf-nav-icon-space"></i></a></li>
                        <li><a href="javascript:void(0)">Form Editor<i class="leaf-nav-icon-space"></i></a></li>
                        <li><a href="javascript:void(0)">LEAF Library<i class="leaf-nav-icon-space"></i></a></li>
                        <li><a href="javascript:void(0)">Site Settings<i class="leaf-nav-icon-space"></i></a></li>
                        <li><a href="javascript:void(0)">Timeline Explorer<i class="leaf-nav-icon-space"></i></a></li>
                        <li><a href="javascript:void(0)">Toolbox<i class="fas fa-caret-left leaf-nav-icon-3"></i></a>
                            <ul>
                                <li><a href="javascript:void(0)">Import Spreadsheet</a></li>
                                <li><a href="javascript:void(0)">Mass Action</a></li>
                                <li><a href="javascript:void(0)">Initiator New Account</a></li>
                            </ul>
                        </li>
                        <li><a href="javascript:void(0)">Advanced Editing<i class="fas fa-caret-left leaf-nav-icon-3"></i></a>
                            <ul>
                                <li><a href="javascript:void(0)">User Access Groups</a></li>
                                <li><a href="javascript:void(0)">Service Chiefs</a></li>
                                <li><a href="javascript:void(0)">Sync Services</a></li>
                            </ul>
                        </li>
                    </ul>
                </li>

            </ul>

        </div>

    </nav>

</header>


<body>
<script type="text/javascript">

if (!Element.prototype.closest) {
    Element.prototype.closest = function(s) {
        var el = this;
        if (!document.documentElement.contains(el)) return null;
            do {
                if (el.matches(s)) return el;
                el = el.parentElement || el.parentNode;
            } while (el !== null && el.nodeType === 1);
            return null;
    };
}

/*
/ walk through all links
/ watch out whether they have an 'aria-haspopup'
/ as soon as a link has got the 'focus' (also key), then:
/ set nested UL to 'display:block;'
/ set attribute 'aria-hidden' of this UL to 'false'
/ and set attribute 'aria-expanded' to 'true'
*/

var opened;

// resets currently opened list style to CSS based value
// sets 'aria-hidden' to 'true'
// sets 'aria-expanded' to 'false'
function reset() {
    if (opened) {
        opened.style.display = '';
        opened.setAttribute('aria-hidden', 'true');
        opened.setAttribute('aria-expanded', 'false');
    }
}

// sets given list style to inline 'display: block;'
// sets 'aria-hidden' to 'false'
// sets 'aria-expanded' to 'true'
// stores the opened list for later use
function open(el) {
    el.style.display = 'block';
    el.setAttribute('aria-hidden', 'false');
    el.setAttribute('aria-expanded', 'true');
    opened = el;
}

// event delegation
// reset navigation on click outside of list
document.addEventListener('click', function(event) {
    if (!event.target.closest('[aria-hidden]')) {
        reset();
    }
});

// event delegation
document.addEventListener('focusin', function(event) {
    // reset list style on every focusin
    reset();

    // check if a[aria-haspopup="true"] got focus
    var target = event.target;
    var hasPopup = target.getAttribute('aria-haspopup') === 'true';
    if (hasPopup) {
        open(event.target.nextElementSibling);
        return;
    }

    // check if anchor inside sub menu got focus
    var popupAnchor = target.parentNode.parentNode.previousElementSibling;
    var isSubMenuAnchor = popupAnchor && popupAnchor.getAttribute('aria-haspopup') === 'true';
    if (isSubMenuAnchor) {
        open(popupAnchor.nextElementSibling);
        return;
    }
})
</script>
</body>
</html>