<style>
#coaches {
    display: inline-flex;
    flex-wrap: wrap;
}
#coaches div.coach {
    background-color: rgb(247, 247, 247);
    border: 1px solid black;
    box-shadow: 0 2px 6px #8e8e8e;

    width: 425px;

    margin: 10px 10px 0px 10px;
    padding: 13px;

    font-size: 13pt;
}
#coaches div.coach div.bio {
    font-size: 11pt;
}
#coaches div.coach div.specialties { }
#coaches div.coach div.top {
    display: inline-flex;
}
#coaches div.coach div.top div.info {
    margin: 5px 5px 5px 10px;
}
#coaches div.coach div.top div.info div.email {}
#coaches div.coach div.top div.info div.geoLocation{}
#coaches div.coach div.top div.info div.locationName{
    margin-top: 7px;
}
#coaches div.coach div.top div.info div.name {}
#coaches div.coach div.top div.info div.phone {}
#coaches div.coach div.top div.info div.pulseBioLink{
    margin-bottom: 10px;
}

#coaches div.coach div.top img.profileImage {
    margin: 5px;
    height: 150px;
    width: 150px !important;
}

#rosterHeader {
    text-align: center;
}
#rosterHeader h1 {
    font-family: 'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif;
    font-weight: 600;
}

#searchBar {
    display: inline-flex;
    padding-left: 20%;
    padding-right: 4%;
    text-align: center;
    width: 76%;
}
#searchBar input {
    height: 35px;
    width: 75%;

    font-size: large;
}
#searchBar .searchIcon {
    margin-right: 9px;
    margin-left: 9px;

    cursor: pointer;
}
</style>

<div id="rosterHeader">
    <h1>Find a LEAF Coach</h1>
</div>

<div id="searchBar">
    <input id="searchRosterInput" type="text" placeholder="Search by Name, Process, or Location" />
    <img id="searchRosterBtn" 
        class="searchIcon" 
        src="../libs/dynicons/?img=search.svg&w=25" 
        alt="search icon" />
</div>

<div id="coaches"></div>

<script src="../libs/jsapi/portal/model/FormQuery.js" type="text/javascript"></script>
<script src="../libs/jsapi/portal/LEAFPortalAPI.js" type="text/javascript"></script>

<script type="text/javascript">
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
    this.formQuery = FormQuery();
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

    this.formQuery.includeIndicator("42");
    this.formQuery.includeIndicator("43");
    this.formQuery.includeIndicator("44");
    this.formQuery.includeIndicator("45");
    this.formQuery.includeIndicator("46");
    this.formQuery.includeIndicator("47");
    this.formQuery.includeIndicator("48");
    this.formQuery.includeIndicator("49");
    this.formQuery.includeIndicator("50");
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
                ? "./image.php?"
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

function buildCoachProfile(coach) {
    // slightly faster than $("<div>")...
    var coachDiv = $(document.createElement('div')).addClass('coach');

    var topDiv = $(document.createElement('div')).addClass('top').appendTo(coachDiv);

    var imgDiv = 
        $(document.createElement('img'))
            .addClass('profileImage')
            .attr('src', coach.pictureSrc)
            .attr('alt', 'profile image')
            .appendTo(topDiv);

    var infoDiv = $(document.createElement('div')).addClass('info').appendTo(topDiv);
    var nameDiv = 
        $(document.createElement('div'))
            .addClass('name')
            .html(coach.name)
            .appendTo(infoDiv);

    var phoneDiv = $(document.createElement('div')).addClass('phone').html(coach.phone).appendTo(infoDiv);
    if (coach.pulse !== undefined && coach.pulse.length > 0) {
        var pulseDiv = $(document.createElement('div'))
            .addClass('pulseBioLink').appendTo(infoDiv);
        var anchorDiv = $(document.createElement('a'))
            .attr('href', coach.pulse).html('Pulse Bio Page').appendTo(pulseDiv);
    }

    var locationNameDiv = 
        $(document.createElement('div')).addClass('locationName').html(coach.facility).appendTo(infoDiv);
    var geoLocationDiv = 
        $(document.createElement('div')).addClass('geoLocation').html(coach.location).appendTo(infoDiv);
    
    var specialtiesDiv = $(document.createElement('div')).addClass('specialties').appendTo(coachDiv);
    $(document.createElement('ul')).html(coach.process).appendTo(specialtiesDiv);

    return coachDiv;
}

function clearCurrentRoster() {
    $('#coaches').empty();
}

function populateRoster(coaches) {
    coaches.forEach(function(coach) {
        $('#coaches').append(buildCoachProfile(coach));
    });
}

function searchForCoaches() {
    var coachQuery = new CoachQuery($('#searchRosterInput').val());

    portalAPI.Forms.query(
        coachQuery.buildQuery(),
        function(results) {
            clearCurrentRoster();
            populateRoster(coachQuery.parseResults(results));
        },
        function(err) {
            console.log(err);
        }
    );
}

this.portalAPI = LEAFRequestPortalAPI();

$(function() {
    $('#searchRosterBtn').click(function() {
        searchForCoaches();
    });

    $('#searchRosterInput').keyup(function(e) {
        // if keycode is 'Enter', uncomment the following if statement and 'return false' to disable search-as-you-type
        // if (e.which == 13) {
            searchForCoaches();
            return true;
            // return false;
        // }
    });

    searchForCoaches();
});

</script>