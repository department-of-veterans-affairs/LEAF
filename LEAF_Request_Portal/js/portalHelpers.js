'use strict';

// enableUserContentLinks adds anchor tags to all https links matching an allow-list, for the given Element.
// The list allows all *.gov domains and other specific domains.
function enableUserContentLinks(element) {
    let htmlContent = (element?.innerHTML || "").trim();
    if (htmlContent !== "") {
        const allowlist = {
            "dvagov.sharepoint.com": 1,
            "apps.gov.powerapps.us": 1
        }
        // links must have https, they could have tags. only grab the url content here and filter based on allowlist
        // exclude links within tags
        let matchLinks = htmlContent.match(/\b(?<=(?<!"|'|>)https:\/\/).*?(?=\s|$|"|'|&gt;|<)\b/gi);
        if(matchLinks == null) {
            return;
        }
        matchLinks = matchLinks.filter(url => {
            const baseurl = (url.split("/")[0] || "").toLowerCase();
            return baseurl.endsWith(".gov") || allowlist[baseurl] === 1;
        });

        let i = 0;
        let output = '';
        matchLinks.forEach(match => {
            const linkText = match.length <= 50 ? match : match.slice(0,50) + '...';
            const oldText = `https://${match}`;
            const newText =   `<a href="https://${match}" target="_blank">https://${linkText}</a>`;
            
            // parse htmlContent by segments, each containing a matching link
            let end = htmlContent.indexOf(oldText, i);
            output += htmlContent.substring(i, end + oldText.length).replace(oldText, newText);
            i = end + oldText.length;
        });
        // don't forget the last segment
        output += htmlContent.substring(i);

        element.innerHTML = output;
    }
}
