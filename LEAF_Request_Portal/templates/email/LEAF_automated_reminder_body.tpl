The last action on Request #{{$recordID}} is older than {{$daysSince}} days.
Please review this request at your earliest convenience.<br /><br />

Request title: <a href="{{$siteRoot}}?a=printview&recordID={{$recordID}}" target="_blank">
    {{$fullTitle}}</a><br />
Request status: {{$lastStatus}}<br /><br />
Request Link: <a href="{{$siteRoot}}?a=printview&recordID={{$recordID}}" target="_blank">
    {{$siteRoot}}?a=printview&recordID={{$recordID}}</a><br /><br />
<br />