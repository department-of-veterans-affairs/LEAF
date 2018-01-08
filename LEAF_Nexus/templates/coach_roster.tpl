<div id="rosterHeader">
    <h1>Meet Our Change Agents</h1>
</div>

<div id="searchBar">
    <input id="searchRosterInput" type="text" placeholder="Search by name" />
    <img id="searchRosterBtn" 
        class="searchIcon" 
        src="../libs/dynicons/?img=search.svg&w=25" 
        alt="search icon" />
</div>

<div id="coaches"></div>

<script type="text/javascript">
/* <![CDATA[ */

function buildCoachProfile(coach) {
    // slightly faster than $("<div>")...
    var coachDiv = $(document.createElement('div')).addClass('coach');

    var topDiv = $(document.createElement('div')).addClass('top').appendTo(coachDiv);

    var imgSrc = coach['data'][1]['data'].length > 0 
        ? "image.php?categoryID=1&UID=" + coach['empUID'] + "&indicatorID=1"
        : "../libs/dynicons/?img=system-users.svg&w=150";
    var imgDiv = 
        $(document.createElement('img'))
            .addClass('profileImage')
            .attr('src', imgSrc)
            .attr('alt', 'profile image')
            .appendTo(topDiv);

    var infoDiv = $(document.createElement('div')).addClass('info').appendTo(topDiv);
    var nameDiv = 
        $(document.createElement('div'))
            .addClass('name')
            .html(coach['firstName'] + ' ' + coach['lastName'])
            .appendTo(infoDiv);
    var emailDiv = $(document.createElement('div')).addClass('email').html(coach['data'][6]['data']).appendTo(infoDiv);
    var phoneDiv = $(document.createElement('div')).addClass('phone').html(coach['data'][5]['data']).appendTo(infoDiv);
    var pulseDiv = $(document.createElement('div')).addClass('pulseBioLink').appendTo(infoDiv);
    var anchorDiv = $(document.createElement('a')).attr('href', '#').html('Pulse Bio Page').appendTo(pulseDiv);

    var location = coach['data'][25] !== undefined ? coach['data'][25]['data'] : '';
    var locationNameDiv = 
        $(document.createElement('div')).addClass('locationName').html(location).appendTo(infoDiv);
    var geoLocationDiv = 
        $(document.createElement('div')).addClass('geoLocation').html(coach['data'][8]['data']).appendTo(infoDiv);
    

    var specialtiesDiv = $(document.createElement('div')).addClass('specialties').appendTo(coachDiv);
    var specialtyList = $(document.createElement('ul')).appendTo(specialtiesDiv);
    $(document.createElement('li')).html('Travel').appendTo(specialtyList);
    $(document.createElement('li')).html('Resource Requests').appendTo(specialtyList);
    $(document.createElement('li')).html('Funding Requests').appendTo(specialtyList);

    var bioDiv = 
        $(document.createElement('div'))
            .addClass('bio')
            .html('Air Force Veteran, loves traveling across the US and spending time with his seventeen nieces and nephews')
            .appendTo(coachDiv);
    
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
    nexusAPI.Groups.searchGroup(
        1,
        $('#searchRosterInput').val(),
        -1,
        0,
        (results) => {
            clearCurrentRoster();
            populateRoster(results['users']);
        },
        (err) => {
            console.log(err);
        }
    );
}

this.nexusAPI = new LEAFNexusAPI();

$(function() {
    $('#searchRosterBtn').click(function() {
        searchForCoaches();
    });

    $('#searchRosterInput').keypress(function(e) {
        // if keycode is 'Enter'
        if (e.which == 13) {
            searchForCoaches();
            return false;
        }
    });

    searchForCoaches();
});

/* ]]> */
</script>