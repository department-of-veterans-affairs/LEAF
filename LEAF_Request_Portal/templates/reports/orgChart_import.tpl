<link rel="stylesheet" href="<!--{$css_path}-->/leaf.css" />

<script>

    $(function() {
        // step 1
        $("#step1btn").click(function(){
            var fileInput = $('#import-fileInput').val();
            if (fileInput != '') {
                $("#importStep1").hide();
                $("#step1").removeClass('current').addClass('complete');
                $("#importStep2").show();
                $("#step2").removeClass('next').addClass('current');
                $('#input-error-message1').hide();
            }
            else {
                $('#input-error-message1').show();
            }
        });
        // step 2
        $("#step2btn").click(function(){
            $("#importStep2").hide();
            $("#step2").removeClass('current').addClass('complete');
            $("#importStep3").show();
            $("#step2").removeClass('next').addClass('complete');
            $("#step3").removeClass('next').addClass('complete');
        });
        $("#step2backBtn").click(function(){
            $("#importStep1").show();
            $("#step1").removeClass('complete').addClass('current');
            $("#importStep2").hide();
            $("#step2").removeClass('current').addClass('next');
        });

    });

</script>

<main id="main-content">

    <div class="grid-container">

        <div class="grid-row">
            <div class="grid-col-12">
                <h1>Import Organization Chart</h1>
                <div>
                    <ul class="leaf-progress-bar">
                        <li class="current" id="step1">
                            <h6>Select File</h6>
                            <span class="left"></span>
                            <span class="right"></span>
                        </li>
                        <li class="next" id="step2">
                            <h6>Org Chart Preview</h6>
                            <span class="left"></span>
                            <span class="right"></span>
                        </li>
                        <li class="next" id="step3">
                            <h6>Import Complete</h6>
                            <span class="left"></span>
                            <span class="right"></span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <div id="importStep1" class="leaf-content-show">

            <div class="grid-row">
                <div class="grid-col-12">
                    <h2>Step 1: Select Spreadsheet for Import</h2>
                    <p>Select a file to import and click Continue. The first row of the spreadsheet must contain the headers of the columns.</p>
                    <div>
                        <span class="usa-error-message leaf-content-hide" id="input-error-message1" role="alert">No file selected, select a file to continue.</span>
                    </div>
                    <div class="leaf-grey-box leaf-width50pct">
                        <input type="file" id="import-fileInput">
                    </div>
                </div>
            </div>
            <div class="grid-row leaf-buttonBar">
                <div class="leaf-displayInlineBlock leaf-width100pct">
                    <button class="usa-button usa-button--big" id="step1btn">Continue</button>
                </div>
            </div>

        </div>

        <div id="importStep2" class="leaf-content-hide">

            <div class="grid-row">
                <div class="grid-col-12">
                    <h2>Step 2: Org Chart Preview</h2>
                    <p>Select the columns from the import that map to Employee Name, Supervisor Name, and Position Title. Click Import Data to complete the import.</p>
                    <table class="usa-table">
                        <thead>
                            <tr>
                            <th scope="col">Employee Name</th>
                            <th scope="col">Supervisor Name</th>
                            <th scope="col">Position Title</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    <select class="usa-select">
                                        <option value>HR Smart Column Name 1</option>
                                        <option value>HR Smart Column Name 1 alt</option>
                                    </select>
                                </td>
                                <td>
                                    <select class="usa-select">
                                        <option value>HR Smart Column Name 2</option>
                                        <option value>HR Smart Column Name 2 alt</option>
                                    </select>
                                </td>
                                <td>
                                    <select class="usa-select">
                                        <option value>HR Smart Column Name 3</option>
                                        <option value>HR Smart Column Name 3 alt</option>
                                    </select>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="grid-row leaf-buttonBar">
                <div class="leaf-displayInlineBlock leaf-width100pct">
                    <button class="usa-button usa-button--base usa-button--big" id="step2backBtn">&lt; Back</button>
                    <button class="usa-button usa-button--big" id="step2btn">Import Data</button>
                </div>
            </div>

        </div>

        <div id="importStep3" class="leaf-content-hide">

            <div class="grid-row">
                <div class="grid-col-12">
                    <h2>Import Complete</h2>
                    <p>Import successful, 3 rows imported with 0 errors.</p>
                    <table class="usa-table">
                        <thead>
                            <tr>
                                <th scope="col">UID</th>
                                <th scope="col">Employee Name</th>
                                <th scope="col">Supervisor Name</th>
                                <th scope="col">Position Title</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>1</td>
                                <td>Jane Doe</td>
                                <td>Gina Ramirez</td>
                                <td>Physician's Assistant</td>
                            </tr>
                            <tr>
                                <td>2</td>
                                <td>Mike Benny</td>
                                <td>Fred Parks</td>
                                <td>Facilities</td>
                            </tr>
                            <tr>
                                <td>3</td>
                                <td>Karen Claypool</td>
                                <td>Jenny Abigail</td>
                                <td>Nursing Specialist</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="grid-row leaf-buttonBar">
                <div class="leaf-displayInlineBlock leaf-width100pct">
                    <button class="usa-button usa-button--big">Return to OC Admin</button>
                </div>
            </div>

        </div>

    </div>

</main>