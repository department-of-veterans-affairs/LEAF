const LEAF_utils = (() => ({

    //truncates string at max length and returns truncated string + appendVal, 
    truncateText: (str, maxLen = 50, appendVal = '...') => {
        return str <= maxLen ? str : `${str.slice(0,maxLen)}${appendVal}`;
    },

    //passes str through div and returns resulting text content.  
    //removes all script content and script tags unless specified not to
    unescapeHTML: (str, keepScriptContent = false, keepScriptTags = false) => {
        let temp = document.createElement('div');
        temp.innerHTML = str;
        let text = temp.innerText;
        if (keepScriptContent !== true) {
            const tagAndContentRegex = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
            text = text.replace(tagAndContentRegex, '');
        } else {
            const tagRegex =  /(<script[\s\S]*?>)|(<\/script[\s\S]*?>)/gi
            text = keepScriptTags === true ? text : text.replace(tagRegex, '');
        }
        return text;
    },

    //encodes common HTML chars <, >, &, ', "
    escapeHTML:(str) => {
        return str.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;')
    },

}))();