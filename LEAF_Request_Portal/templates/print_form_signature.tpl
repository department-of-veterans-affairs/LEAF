<div class="printmainblock" id="sigstamp"></div>

<script type="text/javascript">
    const monthNamesShort = ["Jan", "Feb", "Mar", "Apr", "May", "June",
        "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
    var sigStamp = document.getElementById('sigstamp')
    $.ajax({
        type: 'GET',
        url: "./api/?a=signature/" + <!--{$recordID}--> +"/history",
        success: function (res) {
            var sigInfo = []
            for(var i = 0; i < res.length; i++) {
                if (res[i]['signature_id'] !== undefined) {

                    sigInfo[i] = new Object()
                    sigInfo[i]['signUserID'] = res[i]["userID"]
                    var signDate = new Date(res[i]["time"] * 1000)
                    sigInfo[i]['signDay'] = signDate.getDay()
                    sigInfo[i]['signMonth'] = monthNamesShort[signDate.getMonth() - 1]
                    sigInfo[i]['signYear'] = signDate.getFullYear()
                    sigInfo[i]['signHour'] = signDate.getHours()
                    sigInfo[i]['signMinute'] = signDate.getMinutes()
                    sigInfo[i]['signSecond'] = signDate.getSeconds()
                    employeeSearch(i, sigInfo, signDate)
                }
            }
        }
    })

    function employeeSearch(i, sigInfo, signDate) {
        $.ajax({
            type: 'GET',
            url: "<!--{$orgchartPath}-->/api/employee/search/userName/_" + JSON.stringify(sigInfo[i]['signUserID']).replace(/"/g, ""),
            success: function (res2) {
                sigStamp.innerHTML =
                    '<div class="printmainlabel">\n' +
                    '        <div class="printcounter" style="cursor: pointer"><span tabindex=0 style="font-size: 14px">Signatures</span>\n' +
                    '                <div aria-hidden="true" class="printheading" style="height: 15px"></div>\n' +
                    '                <div class="printResponse" aria-hidden=false style="margin-left: -16px; display: flex; flex-direction: row; flex-basis: 45%; flex-wrap: wrap; border-collapse: collapse; width: 100%; font-weight: normal; font-family: monospace; font-size: 17px; letter-spacing: 0.01rem; color: rgba(0,0,0,0.8);" id="sigtable"></div>\n' +
                    '         </div>\n' +
                    '</div>'
                getEmployeeEmail(i, sigInfo, res2, signDate)
            }
        })
    }

    function getEmployeeEmail(i, sigInfo, res2, signDate) {
        $.ajax({
            type: 'GET',
            url: "<!--{$orgchartPath}-->/api/employee/" + JSON.stringify(res2[0]["empUID"]).replace(/"/g, ""),
            success: function (res3) {
                var sigEmail = ''
                if (res3['employee']['data']['6']['data'] !== undefined) {
                    sigEmail = JSON.stringify(res3['employee']['data']['6']['data']).replace(/"/g, "")
                }
                var sigTable = document.getElementById('sigtable')
                sigTable.innerHTML += '<div aria-hidden="false" style="text-align: left; background-image: url(../libs/dynicons/svg/application-certificate.svg); background-repeat: no-repeat; position: relative; border: 1px solid; padding-left: 61px; background-position-y: 8px; background-position-x: 8px;" title="stamp" tabindex="0" id="sigdate_' + i + '"></div>\n'

                if(sigEmail !== '') {
                    document.getElementById('sigdate_' + i).innerHTML =
                        JSON.stringify(res2[0]["firstName"]).replace(/"/g, "") + ' '
                        + JSON.stringify(res2[0]["lastName"]).replace(/"/g, "")
                        + '<br />' + sigEmail + '<br />' + JSON.stringify(sigInfo[i]['signDay']).replace(/"/g, "")
                        + ' ' + JSON.stringify(sigInfo[i]['signMonth']).replace(/"/g, "")
                        + ', ' + JSON.stringify(sigInfo[i]['signYear']).replace(/"/g, "")
                        + ' ' + JSON.stringify(sigInfo[i]['signHour']).replace(/"/g, "")
                        + ":" + JSON.stringify(sigInfo[i]['signMinute']).replace(/"/g, "")
                        + ":" + JSON.stringify(sigInfo[i]['signSecond']).replace(/"/g, "")
                } else {
                    document.getElementById('sigdate_' + i).innerHTML =
                        JSON.stringify(JSON.stringify(res2[0]["firstName"]).replace(/"/g, "") + ' '
                        + JSON.stringify(res2[0]["lastName"]).replace(/"/g, "")).replace(/"/g, "")
                        + '<br />' + JSON.stringify(sigInfo[i]['signDay']).replace(/"/g, "")
                        + ' ' + JSON.stringify(sigInfo[i]['signMonth']).replace(/"/g, "")
                        + ', ' + JSON.stringify(sigInfo[i]['signYear']).replace(/"/g, "")
                        + ' ' + JSON.stringify(sigInfo[i]['signHour']).replace(/"/g, "")
                        + ":" + JSON.stringify(sigInfo[i]['signMinute']).replace(/"/g, "")
                        + ":" + JSON.stringify(sigInfo[i]['signSecond']).replace(/"/g, "")
                }
            }
        })
    }
</script>