(function ($) {
    jQuery.sessionTimeout = function (options) {
        var defaults = {
            message: 'Your will expire in two minutes.',
            keepAliveUrl: '/keep-alive',
            keepAliveAjaxRequestType: 'POST',
            redirUrl: '/timed-out',
            logoutUrl: '/log-out',
            warnAfter: 900000, // 15 minutes
            redirAfter: 1200000, // 20 minutes
            appendTime: true // appends time stamp to keep alive url to prevent caching
        };

        // Extend user-set options over defaults
        var o = defaults,
				dialogTimer,
				redirTimer;

        if (options) { o = $.extend(defaults, options); }

        // Create timeout warning dialog
        $('body').append('<div title="Session Timeout" id="sessionTimeout-dialog">' + o.message + '</div>');
        $('#sessionTimeout-dialog').dialog({
            autoOpen: false,
            width: 400,
            modal: true,
            closeOnEscape: false,
            open: function () { $(".ui-dialog-titlebar-close").hide(); },
            buttons: {
                // Button one - closes dialog and makes call to keep-alive URL
                "Stay Connected": function () {
                    $(this).dialog('close');

                    $.ajax({
                        type: o.keepAliveAjaxRequestType,
                        url: o.appendTime ? updateQueryStringParameter(o.keepAliveUrl, "_", new Date().getTime()) : o.keepAliveUrl
                    });

                    // Stop redirect timer and restart warning timer
                    resetTimer();
                }
            }
        });

        function controlDialogTimer(action) {
            switch (action) {
                case 'start':
                    // After warning period, show dialog and start redirect timer
                    dialogTimer = setTimeout(function () {
                        $('#sessionTimeout-dialog').dialog('open');
                        controlRedirTimer('start');
                    }, o.warnAfter);
                    break;

                case 'stop':
                    clearTimeout(dialogTimer);
                    break;
            }
        }

        function controlRedirTimer(action) {
            switch (action) {
                case 'start':
                    // Dialog has been shown, if no action taken during redir period, redirect
                    redirTimer = setTimeout(function () {
                        window.location = o.redirUrl;
                    }, o.redirAfter - o.warnAfter);
                    break;

                case 'stop':
                    clearTimeout(redirTimer);
                    break;
            }
        }

        function updateQueryStringParameter(uri, key, value) {
            var re = new RegExp("([?|&])" + key + "=.*?(&|#|$)", "i");

            if (uri.match(re)) {
                return uri.replace(re, '$1' + key + "=" + value + '$2');
            } else {
                var hash = '';

                if (uri.indexOf('#') !== -1) {
                    hash = uri.replace(/.*#/, '#');
                    uri = uri.replace(/#.*/, '');
                }

                var separator = uri.indexOf('?') !== -1 ? "&" : "?";
                return uri + separator + key + "=" + value + hash;
            }
        }

        function resetTimer() {
            controlRedirTimer('stop');
            controlDialogTimer('stop');

            setTimeout(controlDialogTimer('start'), 2000);
        }

        $(document).ajaxComplete(function () {
            if (!$('#sessionTimeout-dialog').dialog("isOpen")) {
                controlRedirTimer('stop');
                controlDialogTimer('stop');
                controlDialogTimer('start');
                $(document.body).bind('mousemove keydown click', resetTimer);
            }
        });

        // Begin warning period
        controlDialogTimer('start');
    };
})(jQuery);
