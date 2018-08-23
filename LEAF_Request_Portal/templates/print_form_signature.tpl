<div class="printmainblock" id="sigstamp"></div>

<script type="text/javascript">
    const monthNamesShort = ["Jan", "Feb", "Mar", "Apr", "May", "June",
        "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
    var sigStamp = document.getElementById('sigstamp')
    $.ajax({
        type: 'GET',
        url: "./api/form/signatures/" + <!--{$recordID}-->,
        success: function (res) {
            var sigInfo = [];
            if(res.length > 0) {
                sigStamp.innerHTML =
                    '<div class="printmainlabel">\n' +
                    '        <div class="printcounter" style="cursor: pointer"><span tabindex=0 style="font-size: 14px">Signatures</span>\n' +
                    '                <div aria-hidden="true" class="printheading" style="height: 15px"></div>\n' +
                    '                <div class="printResponse" aria-hidden=false style="margin-left: -16px; display: flex; flex-direction: row; flex-basis: 45%; flex-wrap: wrap; border-collapse: collapse; width: 100%; font-weight: normal; font-family: monospace; font-size: 17px; letter-spacing: 0.01rem; color: rgba(0,0,0,0.8);" id="sigtable"></div>\n' +
                    '         </div>\n' +
                    '</div>';
                var sigTable = document.getElementById('sigtable')
            }
            for(var i = 0; i < res.length; i++) {
                if (res[i]['signature_id'] !== undefined) {

                    sigInfo[i] = new Object();
                    sigInfo[i]['signUserID'] = res[i]["userID"];
                    var signDate = new Date(res[i]["time"] * 1000);
                    sigInfo[i]['signDay'] = signDate.getDay();
                    sigInfo[i]['signMonth'] = monthNamesShort[signDate.getMonth() - 1];
                    sigInfo[i]['signYear'] = signDate.getFullYear();
                    sigInfo[i]['signHour'] = signDate.getHours();
                    sigInfo[i]['signMinute'] = signDate.getMinutes();
                    sigInfo[i]['signSecond'] = signDate.getSeconds();
                    sigInfo[i]['email'] = res[i][0]["data"];

                    sigTable.innerHTML += '<div style="border: 1px solid;"><img src="../libs/dynicons/svg/LEAF-thumbprint.svg" style="position: absolute; height: 90px; padding-top: 5px; padding-left: 65px; opacity: .25;"><div aria-hidden="false" style="text-align: left; background-repeat: no-repeat; position: relative; padding: 20px; background-position-y: 5px; background-position-x: 72px; background-size: 92px;" title="stamp" tabindex="0" id="sigdate_' + i + '"></div></div>\n'
                    document.getElementById('sigdate_' + i).innerHTML =
                        JSON.stringify(res[i][0]["firstName"]).replace(/"/g, "") + ' '
                        + JSON.stringify(res[i][0]["lastName"]).replace(/"/g, "")
                        + '<br />' + res[i][0]["data"] + '<br />' + JSON.stringify(sigInfo[i]['signDay'])
                        + ' ' + JSON.stringify(sigInfo[i]['signMonth']).replace(/"/g, "")
                        + ', ' + JSON.stringify(sigInfo[i]['signYear'])
                        + ' ' + JSON.stringify(sigInfo[i]['signHour'])
                        + ":" + JSON.stringify(sigInfo[i]['signMinute'])
                        + ":" + JSON.stringify(sigInfo[i]['signSecond']);
                }
            }
        }
    })
</script>
