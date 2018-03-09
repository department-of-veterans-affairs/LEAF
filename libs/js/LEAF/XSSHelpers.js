/**
 * Utility functions to assist in preventing XSS vulnerabilities.
 */
var XSSHelpers = function () {

    /**
     * Checks the given text for the specified tags.
     * 
     * @param text  string      The text to check for tags
     * @param tags  string[]    An array of strings that represents the
     *                          tags to search for
     * 
     * @return bool If ANY of the specified tags were found in the text
     */
    containsTags = function (text, tags) {
        for (var i = 0; i < tags.length; i++) {
            var pattern = new RegExp(tags[i]);
            if (pattern.test(text)) {
                return true;
            }
        }

        return false;
    },
    
    /**
     * An inelegant function to strip the given text of all the specified tags.
     * 
     * @param text  string      The text to strip tags from
     * @param tags  string[]    An array of strings that represents the
     *                          tags to strip. It's only necessary to include
     *                          the opening tag (e.g. "<a>").
     * 
     * @return string   The stripped text
     */
    stripTags = function (text, tags) {
        for (var i = 0; i < tags.length; i++) {
            var openingTag = tags[i];
            var closingTag = openingTag.slice(0,1) + "/" + openingTag.slice(1); 

            // ugly, but it works
            text = text.replace(openingTag, "");
            text = text.replace(closingTag, "");
        }

        return text;
    };

    return {
        containsTags: containsTags,
        stripTags: stripTags
    };
}();