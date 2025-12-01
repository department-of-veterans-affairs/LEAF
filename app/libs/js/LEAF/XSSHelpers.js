/**
 * Utility functions to assist in preventing XSS vulnerabilities.
 */
var XSSHelpers = function () {

    /**
     * Builds a RegExp that will match the given HTML tag. Also
     * matches even if the tag contains attributes. Can be in
     * the format "<strong>", or just "strong".
     *
     * @param string    tag     The tag to build a regex for
     *
     * @return RegExp   a Javascript RegExp object
     */
    buildTagRegex = function(tag) {
        return new RegExp('(<\\/?\\s*\\b' + tag + '\\b(.*?)\\s*>)', "gi");
    },

    /**
     * Removes the chevrons, front slash, and any white space from an
     * HTML tag. This ensures any regex operations will be working with
     * the same data without concerns of formatting (e.g., "</strong>"
     * will return "strong").
     *
     * @param string    tag     The tag to clean
     *
     * @return string   The cleaned tag
     */
    cleanTag = function(tag) {
        // remove chevrons, forward slashes, and whitespace
        return tag.replace(/<\s*\/?|>/g, "").trim();
    },

    /**
     * Checks the given text for the specified tag.
     *
     * @param text  string  The text to check for tag
     * @param tag   string  The tag to search for
     *
     * @return bool If the specified tag was found in the text
     */
    containsTag = function (text, tag) {
        return buildTagRegex(cleanTag(tag)).exec(text) !== null;
    },

    /**
     * Checks the given text for the specified tags.
     *
     * @param text  string      The text to check for tags
     * @param tags  string[]    An array of tags to search for
     * @param bool  containsAll If the given text should contain ALL
     *
     * @return bool If any/all (depends on containsAll) of the
     *              specified tags were found in the text.
     */
    containsTags = function(text, tags, containsAll) {
    	if(containsAll == undefined) {
    		containsAll = false;
    	}
        for (var i = 0; i < tags.length; i++) {
            var hasTag = containsTag(text, tags[i]);

            if (containsAll) {
                if (!hasTag) { return false; }
            } else {
                if (hasTag) { return true; }
            }
        }

        return false;
    },

    /**
     * Strips ALL HTML tags from the given text.
     *
     * @param string    text    The text to strip tags from
     *
     * @return string   The stripped text
     */
    stripAllTags = function (text) {
        return text.replace(buildTagRegex(""), "");
    },

    /**
     * Strips the given text of the specified tag.
     *
     * @param text  string  The text to strip tags from
     * @param tag   string  The tag to strip from the text
     *
     * @return string   The stripped text
     */
    stripTag = function (text, tag) {
        return text.replace(buildTagRegex(cleanTag(tag)), "");
    },

    /**
     * Strips the given text of the specified tags.
     *
     * @param text  string  The text to strip tags from
     * @param tags  string  Array of tags to strip from the text
     *
     * @return string   The stripped text
     */
    stripTags = function(text, tags) {
        for (var i = 0; i < tags.length; i++) {
            text = stripTag(text, tags[i]);
        }

        return text;
    },

    /**
     * passes str through div, rms script tags unless specified.
     *
     * @param str  string with encoded HTML
     * @param keepScriptTags whether to retain script tags for editing
     *
     * @return string with decoded html
     */
     decodeHTMLEntities = function (str, keepScriptTags = false) {
        let temp = document.createElement('div');
        temp.innerHTML = str;
        let text = temp.innerText;
        if (keepScriptTags !== true) {
            text = this.stripTags(text, ['<script>']);
        }
        return text;
    };

    /**
     * Escapes HTML special characters to prevent XSS attacks.
     * Converts characters like <, >, &, ", ' to their HTML entity equivalents.
     * Use this when inserting untrusted data (from database, API, user input)
     * into HTML content.
     *
     * @param str  string|null|undefined  The string to escape
     *
     * @return string  The escaped string safe for HTML insertion
     */
    escapeHTML = function(str) {
        if (str === null || str === undefined) {
            return '';
        }

        // Use browser's native text node escaping
        var div = document.createElement('div');
        div.textContent = String(str);
        return div.innerHTML;
    },

    /**
     * Escapes HTML attribute values to prevent XSS attacks.
     * More comprehensive than escapeHTML, as it also encodes forward slashes.
     * Use this when inserting untrusted data into HTML attribute values.
     *
     * @param str  string|null|undefined  The string to escape
     *
     * @return string  The escaped string safe for HTML attribute values
     */
    escapeHTMLAttribute = function(str) {
        if (str === null || str === undefined) {
            return '';
        }

        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#x27;')
            .replace(/\//g, '&#x2F;');
    },

    /**
     * Sanitizes database content for safe HTML display, handling both
     * already-encoded and raw data. This prevents double-encoding issues
     * while still protecting against XSS.
     *
     * Use this when you're uncertain whether database data is already encoded.
     * It will decode first (to normalize the data), then re-encode safely.
     *
     * @param str  string|null|undefined  The string to sanitize
     *
     * @return string  The sanitized string safe for HTML insertion
     */
    sanitizeForDisplay = function(str) {
        if (str === null || str === undefined) {
            return '';
        }

        // First decode any existing HTML entities to normalize the data
        var decoded = decodeHTMLEntities(String(str), false);

        // Then escape for safe display
        return escapeHTML(decoded);
    };


    return {
        buildTagRegex: buildTagRegex,
        containsTag: containsTag,
        containsTags: containsTags,
        stripAllTags: stripAllTags,
        stripTag: stripTag,
        stripTags: stripTags,
        decodeHTMLEntities: decodeHTMLEntities,
        escapeHTML: escapeHTML,
        escapeHTMLAttribute: escapeHTMLAttribute,
        sanitizeForDisplay: sanitizeForDisplay
    };
}();

if (typeof module !== 'undefined') {
    module.exports = XSSHelpers;
}