<script>
var CSRFToken = '<!--{$CSRFToken}-->';
    var orgChartPath = '<!--{$orgchartPath}-->';
    const onSuccess = (res)=> console.log('success', res);
    const onFail = ()=> console.log('fail');
    var nexusAPI = LEAFNexusAPI();
    nexusAPI.setBaseURL(orgChartPath + '/api/?a=');
    nexusAPI.setCSRFToken(CSRFToken);
    var portalAPI = LEAFRequestPortalAPI();
    portalAPI.setBaseURL('./api/?a=');
    portalAPI.setCSRFToken(CSRFToken);
    portalAPI.Forms.getAllForms(onSuccess, onFail);
</script>
