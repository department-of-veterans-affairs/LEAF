/**
 * Builds a FormQuery object that will search for LEAF coaches based on the searchTerm.
 * 
 * NOTE: It's possible the categoryID and indicator IDs will need to be changed depending on
 * your LEAF configuration.
 * 
 * @param searchTerm    string  the term to search indicator data for
 */
function CoachQuery(searchTerm) {
    this.categoryID = "form_b8543";
    this.formQuery = new FormQuery();
    this.formQuery.addTerm("categoryID", "=", this.categoryID);
    this.formQuery.addTerm("deleted", "=", 0);
    this.formQuery.addDataTerm("data", "0", "LIKE", searchTerm);

    this.indicatorMap = {
        "name": "42",
        "pulse": "43",
        "phone": "44",
        "facility": "45",
        "location": "46",
        "service": "47",
        "process": "48",
        "bio": "49",
        "picture": "50"
    };

    Object.values(this.indicatorMap).forEach(function (val) {
        this.formQuery.addGetData(val);
    }, this);
}

/**
 * Build the FormQuery
 * 
 * @returns object  the FormQuery object configured for the Coach Roster
 */
CoachQuery.prototype.buildQuery = function () {
    return this.formQuery.buildQuery();
}

/**
 * Parse result object of a form query
 * 
 * @param results   object  JSON object from the form query
 * 
 * @returns array   an array of Coach objects
 */
CoachQuery.prototype.parseResults = function (results) {
    var coaches = [];
    var keys = Object.keys(results);
    keys.forEach(function (key) {
        var result = results[key];
        // only include results that have data, the "s1" key is created in the form query result
        if (typeof (result["s1"]) !== "undefined") {
            var data = result["s1"];

            var pictureData = data["id" + this.indicatorMap.picture];

            var imgSrc = (pictureData !== undefined && pictureData.length > 0)
                ? "/LEAF_Request_Portal/image.php?"
                    + "id=" + this.indicatorMap.picture 
                    + "&series=" + result.series 
                    + "&form=" + result.recordID
                    + "&file=0"
                : "../libs/dynicons/?img=system-users.svg&w=150";

            coaches.push({
                "name": data["id" + this.indicatorMap.name],
                "pulse": data["id" + this.indicatorMap.pulse],
                "phone": data["id" + this.indicatorMap.phone],
                "facility": data["id" + this.indicatorMap.facility],
                "location": data["id" + this.indicatorMap.location],
                "service": data["id" + this.indicatorMap.service],
                "process": data["id" + this.indicatorMap.process],
                "bio": data["id" + this.indicatorMap.bio],
                "picture": pictureData,
                "pictureSrc": imgSrc,
            });
        }
    }, this);

    coaches.sort(function (a,b) {
        return a.name < b.name;
    });

    return coaches;
}
