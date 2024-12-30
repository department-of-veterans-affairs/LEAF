<script>
$(function() {
    var query = new LeafFormQuery();
    query.addTerm('categoryID', '=', 'leaf_devconsole');
    query.addTerm('stepID', '!=', 'resolved');
    query.onSuccess(function(data) {
        if(Object.keys(data).length != 0) {
            $('#rob_status>iframe').attr('src', './?a=printview&iframe=1&masquerade=nonAdmin&recordID=' + data[Object.keys(data)[0]].recordID);

            $('#rob_request').slideUp();
            $('#rob_status').fadeIn();
        }
    });
    query.execute();


    $('#currentDate').html(new Date().toLocaleDateString());
    $('#print').on('click', function() {
        $('#print').css('display', 'none');
        $('#rob').css({'height': '100%',
                    'width': '100%',
                    'font-size': '0.8em',
                    'padding': '0'});
    });

    $('#startRequest').on('click', function() {
        $.ajax({
            type: 'POST',
            url: './api/form/new',
            data: {
                title: 'LEAF Developer Console Access Request',
                service: '',
                priority: 0,
                numleaf_devconsole: 1,
                CSRFToken: '<!--{$CSRFToken}-->',
                '-5': 'Accepted terms and rules of behavior'
            }
        })
        .then(function(res) {
            var recordID = parseFloat(res);
            if(!isNaN(recordID) && isFinite(recordID) && recordID != 0) {
                window.location = "index.php?a=view&recordID=" + recordID;
            }
        });
    });
    document.querySelector('#startRequest').removeAttribute('disabled');
});
</script>
<style>
    @import "<!--{$orgchartPath}-->/css/employeeSelector.css";
	p {
        font-size: 1.2em;
    }
    li {
        margin: 1em 0;
        font-size: 1.1em;
    }
</style>

<div id="rob_request">
    <div style="width: 70%; margin: auto">
        <h1 style="text-align: center">LEAF Developer Console Area</h1>
        <p>To gain access to the LEAF developer console area, please review the VA National Rules of Behavior.</p>
        <p>Upon acceptance of the terms below, you will be redirected to an electronic approval process.</p>
    </div>

    <div id="rob" style="width: 60%; margin: auto; border: 1px solid black; padding: 16px; background-color: white; height: 26em; overflow-y: auto">
        <h3>Department of Veterans Affairs (VA) National Rules of Behavior</h3>
        <p>I understand, accept, and agree to the following terms and conditions that apply to my access to, and use of, information, including VA sensitive information, or information systems of the U.S. Department of Veterans Affairs.</p>
        <ol type="1">
            <li>GENERAL RULES OF BEHAVIOR
                <ol type="a">
                    <li>I understand that when I use any Government information system, I have NO expectation of Privacy in VA records that I create or in my activities while accessing or using such information system.</li>
                    <li>I understand that authorized VA personnel may review my conduct or actions concerning VA information and information systems, and take appropriate action.  Authorized VA personnel include my supervisory chain of command as well as VA system administrators and Information Security Officers (ISOs).  Appropriate action may include monitoring, recording, copying, inspecting, restricting access, blocking, tracking, and disclosing information to authorized Office of Inspector General (OIG), VA, and law enforcement personnel.</li>
                    <li>I understand that the following actions are prohibited: unauthorized access, unauthorized uploading, unauthorized downloading, unauthorized changing, unauthorized circumventing, or unauthorized deleting information on VA systems, modifying VA systems, unauthorized denying or granting access to VA systems, using VA resources for unauthorized use on VA systems, or otherwise misusing VA systems or resources.  I also understand that attempting to engage in any of these unauthorized actions is also prohibited.</li>
                    <li>I understand that such unauthorized attempts or acts may result in disciplinary or other adverse action, as well as criminal, civil, and/or administrative penalties.  Depending on the severity of the violation, disciplinary or adverse action consequences may include: suspension of access privileges, reprimand, suspension from work, demotion, or removal.  Theft, conversion, or unauthorized disposal or destruction of Federal property or information may also result in criminal sanctions.</li>
                    <li>I understand that I have a responsibility to report suspected or identified information security incidents (security and privacy) to my Operating Unit’s Information Security Officer (ISO), Privacy Officer (PO), and my supervisor as appropriate.</li>
                    <li>I understand that I have a duty to report information about actual or possible criminal violations involving VA programs, operations, facilities, contracts or information systems to my supervisor, any management official or directly to the OIG, including reporting to the OIG Hotline.  I also understand that I have a duty to immediately report to the OIG any possible criminal matters involving felonies, including crimes involving information systems.</li>
                    <li>I understand that the VA National Rules of Behavior do not and should not be relied upon to create any other right or benefit, substantive or procedural, enforceable by law, by a party to litigation with the United States Government.</li>
                    <li>I understand that the VA National Rules of Behavior do not supersede any local policies that provide higher levels of protection to VA’s information or information systems.  The VA National Rules of Behavior provide the minimal rules with which individual users must comply.</li>
                    <li><b>I understand that if I refuse to sign this VA National Rules of Behavior as required by VA policy, I will be denied access to VA information and information systems.  Any refusal to sign the VA National Rules of Behavior may have an adverse impact on my employment with the Department.</b></li>
                </ol>
            </li>
            <li>SPECIFIC RULES OF BEHAVIOR.
                <ol type="a">
                    <li>I will follow established procedures for requesting access to any VA computer system and for notification to the VA supervisor and the ISO when the access is no longer needed.</li>
                    <li>I will follow established VA information security and privacy policies and procedures.</li>
                    <li>I will use only devices, systems, software, and data which I am authorized to use, including complying with any software licensing or copyright restrictions.  This includes downloads of software offered as free trials, shareware or public domain.</li>
                    <li>I will only use my access for authorized and official duties, and to only access data that is needed in the fulfillment of my duties except as provided for in VA Directive 6001, Limited Personal Use of Government Office Equipment Including Information Technology.  I also agree that I will not engage in any activities prohibited as stated in section 2c of VA Directive 6001.</li>
                    <li>I will secure VA sensitive information in all areas (at work and remotely) and in any form (e.g. digital, paper etc.), to include mobile media and devices that contain sensitive information, and I will follow the mandate that all VA sensitive information must be in a protected environment at all times or it must be encrypted (using FIPS 140-2 approved encryption).  If clarification is needed whether or not an environment is adequately protected, I will follow the guidance of the local Chief Information Officer (CIO).</li>
                    <li>I will properly dispose of VA sensitive information, either in hardcopy, softcopy or electronic format, in accordance with VA policy and procedures.</li>
                    <li>I will not attempt to override, circumvent or disable operational, technical, or management security controls unless expressly directed to do so in writing by authorized VA staff.</li>
                    <li>I will not attempt to alter the security configuration of government equipment unless authorized.  This includes operational, technical, or management security controls.</li>
                    <li>I will protect my verify codes and passwords from unauthorized use and disclosure and ensure I utilize only passwords that meet the VA minimum requirements for the systems that I am authorized to use and are contained in Appendix F of VA Handbook 6500.</li>
                    <li>I will not store any passwords/verify codes in any type of script file or cache on VAsystems.</li>
                    <li>I will ensure that I log off or lock any computer or console before walking away and will not allow another user to access that computer or console while I am logged on to it.</li>
                    <li>I will not misrepresent, obscure, suppress, or replace a user’s identity on the Internet or any VA electronic communication system.</li>
                    <li>I will not auto-forward e-mail messages to addresses outside the VA network.</li>
                    <li>I will comply with any directions from my supervisors, VA system administrators and information security officers concerning my access to, and use of, VA information and information systems or matters covered by these Rules.</li>
                    <li>I will ensure that any devices that I use to transmit, access, and store VA sensitive information outside of a VA protected environment will use FIPS 140-2 approved encryption (the translation of data into a form that is unintelligible without a deciphering mechanism).  This includes laptops, thumb drives, and other removable storage devices and storage media (CDs, DVDs, etc.).</li>
                    <li>I will obtain the approval of appropriate management officials before releasing VA information for public dissemination.</li>
                    <li>I will not host, set up, administer, or operate any type of Internet server on any VA network or attempt to connect any personal equipment to a VA network unless explicitly authorized in writing by my local CIO and I will ensure that all such activity is in compliance with Federal and VA policies.</li>
                    <li>I will not attempt to probe computer systems to exploit system controls or access VA sensitive data for any reason other than in the performance of official duties.  Authorized penetration testing must be approved in writing by the VA CIO.</li>
                    <li>I will protect Government property from theft, loss, destruction, or misuse.  I will follow VA policies and procedures for handling Federal Government IT equipment and will sign for items provided to me for my exclusive use and return them when no longer required for VA activities.</li>
                    <li>I will only use virus protection software, anti-spyware, and firewall/intrusion detection software authorized by the VA on VA equipment or on computer systems that are connected to any VA network.</li>
                    <li>If authorized, by waiver, to use my own personal equipment, I must use VA approved virus protection software, anti-spyware, and firewall/intrusion detection software and ensure the software is configured to meet VA configuration requirements.  My local CIO will confirm that the system meets VA configuration requirements prior to connection to VA’s network.</li>
                    <li>I will never swap or surrender VA hard drives or other storage devices to anyone other than an authorized OI&T employee at the time of system problems.</li>
                    <li>I will not disable or degrade software programs used by the VA that install security software updates to VA computer equipment, to computer equipment used to connect to VA information systems, or to create, store or use VA information.</li>
                    <li>I agree to allow examination by authorized OI&T personnel of any personal IT device [Other Equipment (OE)] that I have been granted permission to use, whether remotely or in any setting to access VA information or information systems or to create, store or use VA information.</li>
                    <li>I agree to have all equipment scanned by the appropriate facility IT Operations Service prior to connecting to the VA network if the equipment has not been connected to the VA network for a period of more than three weeks.</li>
                    <li>I will complete mandatory periodic security and privacy awareness training within designated timeframes, and complete any additional required training for the particular systems to which I require access.</li>
                    <li>I understand that if I must sign a non-VA entity’s Rules of Behavior to obtain access to information or information systems controlled by that non-VA entity, I still must comply with my responsibilities under the VA National Rules of Behavior when accessing or using VA information or information systems.  However, those Rules of Behavior apply to my access to or use of the non-VA entity’s information and information systems as a VA user.</li>
                    <li>I understand that remote access is allowed from other Federal government computers and systems to VA information systems, subject to the terms of VA and the host Federal agency’s policies.</li>
                    <li>I agree that I will directly connect to the VA network whenever possible.  If a direct connection to the VA network is not possible, then I will use VA-approved remote access software and services.  I must use VA-provided IT equipment for remote access when possible.  I may be permitted to use non–VA IT equipment [Other Equipment (OE)] only if a VA-CIO-approved waiver has been issued and the equipment is configured to follow all VA security policies and requirements.  I agree that VA OI&T officials may examine such devices, including an OE device operating under an approved waiver, at any time for proper configuration and unauthorized storage of VA sensitive information.</li>
                    <li>I agree that I will not have both a VA network connection and any kind of non-VA network connection (including a modem or phone line or wireless network card, etc.) physically connected to any computer at the same time unless the dual connection is explicitly authorized in writing by my local CIO.</li>
                    <li>I agree that I will not allow VA sensitive information to reside on non-VA systems or devices unless specifically designated and approved in advance by the appropriate VA official (supervisor), and a waiver has been issued by the VA’s CIO.  I agree that I will not access, transmit or store remotely any VA sensitive information that is not encrypted using VA approved encryption.</li>
                    <li>I will obtain my VA supervisor’s authorization, in writing, prior to transporting, transmitting, accessing, and using VA sensitive information outside of VA’s protected environment.</li>
                    <li>I will ensure that VA sensitive information, in any format, and devices, systems and/or software that contain such information or that I use to access VA sensitive information or information systems are adequately secured in remote locations, e.g., at home and during travel, and agree to periodic VA inspections of the devices, systems or software from which I conduct access from remote locations.  I agree that if I work from a remote location pursuant to an approved telework agreement with VA sensitive information that authorized OI&T personnel may periodically inspect the remote location for compliance with required security requirements.</li>
                    <li>I will protect sensitive information from unauthorized disclosure, use, modification, or destruction, including using encryption products approved and provided by the VA to protect sensitive data.</li>
                    <li>I will not store or transport any VA sensitive information on any portable storage media or device unless it is encrypted using VA approved encryption.</li>
                    <li>I will use VA-provided encryption to encrypt any e-mail, including attachments to the e-mail, that contains VA sensitive information before sending the e-mail.  I will not send any e-mail that contains VA sensitive information in an unencrypted form.  VA sensitive information includes personally identifiable information and protected health information.</li>
                    <li>I may be required to acknowledge or sign additional specific or unique rules of behavior in order to access or use specific VA systems.  I understand that those specific rules of behavior may include, but are not limited to, restrictions or prohibitions on limited personal use, special requirements for access or use of the data in that system, special requirements for the devices used to access that specific system, or special restrictions on interconnections between that system and other IT resources or systems.</li>
                </ol>
            </li>
            <li>Acknowledgement and Acceptance
                <ol type="a">
                    <li>I acknowledge that I have received a copy of these Rules of Behavior.</li>
                    <li>I understand, accept and agree to comply with all terms and conditions of these Rules of Behavior.</li>
                </ol>
            </li>
        </ol>
        <button class="buttonNorm" id="print">Expand for printing</button>
    </div>

    <div style="width: 70%; margin: auto; text-align: center; margin-top: 16px">
        <button class="buttonNorm" id="startRequest" style="font-size: 140%; padding: 8px" disabled><img src="dynicons/?img=accessories-text-editor.svg&w=32" alt="" /> I understand and accept</button>
    </div>

</div>

<div id="rob_status" style="display: none; width: 90%; margin: auto; text-align: center">
    <h1 style="text-align: center">LEAF Developer Console Area</h1>
    <iframe style="width: 99%; height: 70em; border: 1px solid black"></iframe>
</div>
