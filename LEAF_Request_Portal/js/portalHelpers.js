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
        //links must have https, they could have tags. only grab the url content here and filter based on allowlist
        let matchLinks = htmlContent.match(/(?<=https:\/\/).*?(?=\s|$|"|'|&gt;|<)/gi);
        matchLinks = Array.from(new Set(matchLinks));
        matchLinks = matchLinks.filter(url => {
            const baseurl = (url.split("/")[0] || "").toLowerCase();
            return baseurl.endsWith(".gov") || allowlist[baseurl] === 1;
        });

        matchLinks.forEach(match => {
            const linkText = match.length <= 50 ? match : match.slice(0,50) + '...';
            const oldText = `https://${match}`;
            const newText =   `<a href="https://${match}" target="_blank">https://${linkText}</a>`;
            //initial replacement
            htmlContent = htmlContent.replace(oldText, newText);

            //if user tried to add anchor tags this will replace them. link text was will be replaced by the new link text.
            const textEscaped = newText.replaceAll(".", "\\.").replaceAll("?", "\\?");
            const regStr = `(&lt;|<)a\\s+href=['"]${textEscaped}['"](>|&gt;)(.*)?(&lt;|<)/a(>|&gt;)`;
            const tagReg = new RegExp(regStr, "gi");
            if(tagReg.test(htmlContent)) {
                htmlContent = htmlContent.replace(tagReg, newText);
            }
        });
        element.innerHTML = htmlContent;
    }
}
