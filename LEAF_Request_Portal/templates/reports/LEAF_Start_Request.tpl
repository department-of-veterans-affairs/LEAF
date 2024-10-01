<style>
#content {
    margin: 1rem;
}
p, .card {
    font-size: 1rem;
}
.card {
    padding: 1rem;
    margin-bottom: 1rem;
}
</style>
<script>
function scrubHTML(input) {
    if(input == undefined) {
        return '';
    }
    let t = new DOMParser().parseFromString(input, 'text/html').body;
    while(input != t.textContent) {
        return scrubHTML(t.textContent);
    }
    return t.textContent;
}

// findIncompleteRequest returns the record ID (int) of the current user's incomplete request, or 0 if none
async function findIncompleteRequest(categoryID, requestTitle) {
    let query = new LeafFormQuery();
    query.addTerm('userID', '=', `<!--{$userID|escape:'quotes'}-->`);
    query.addTerm('categoryID', '=', categoryID);
    query.addTerm('title', '=', requestTitle);
    query.addTerm('submitted', '=', 0);
    query.addTerm('deleted', '=', 0);

    let res = await query.execute();
    if(Object.keys(res).length > 0) {
        return Object.keys(res)[0];
    }
    else {
        return 0;
    }
}

async function startNewRequest(categoryID, requestTitle) {
    let formData = new FormData();
    formData.append('CSRFToken', '<!--{$CSRFToken}-->');
    formData.append(`num${categoryID}`, 1);
    formData.append('title', requestTitle);
    let recordID = await fetch('api/form/new', {
        method: 'POST',
        body: formData
    }).then(res => res.json());
    if(!isNaN(recordID) && isFinite(recordID) && recordID != 0) {
        window.location = 'index.php?a=view&recordID=' + recordID;
    }
    else {
        alert(recordID + '\n\nPlease contact your system administrator.');
    }
}

async function showSetup() {
    document.querySelector('#setup').style.display = 'block';

    let forms = await fetch('api/formStack/categoryList').then(res => res.json());
    let buf = '';
    for(let i in forms) {
        buf += `<option value="${forms[i].categoryID}">${scrubHTML(forms[i].categoryName)}</option>`;
    }

    document.querySelector('#forms').innerHTML = buf;
    document.querySelector('#forms').addEventListener('change', () => {
        document.querySelector('#link').value = '';
    });
    document.querySelector('#create').addEventListener('click', () => {
        let formID = document.querySelector('#forms').value;
        let url = window.location.href;
        
        url += `&id=${formID}`;

        document.querySelector('#link').value = url;
    });

    document.querySelector('#link').addEventListener('click', () => {
        document.execCommand("selectAll", false, null);
    });
}

async function main() {
    document.querySelector('title').innerText = 'Start Request';

    const urlParams = new URLSearchParams(window.location.search);
    let categoryID = urlParams.get('id');
    let requestTitle = urlParams.get('title');
    requestTitle = scrubHTML(requestTitle);
    if(requestTitle == '') {
        requestTitle = 'Record';
    }

    if(categoryID != null) {
        let incompleteRequestID = await findIncompleteRequest(categoryID, requestTitle);
        if(incompleteRequestID > 0) {
            window.location = 'index.php?a=view&recordID=' + incompleteRequestID;
        }
        else {
            startNewRequest(categoryID, requestTitle);
        }
    }
    else {
        showSetup();
    }
}

document.addEventListener('DOMContentLoaded', main);
</script>
<div id="setup" style="display: none">
    <h1>Setup Quickstart Link</h1>
    <p>A Quickstart Link creates a shortcut that starts a new request. This can help streamline intake processes by reducing total number of clicks.</p>

    <br /><br />
    <div class="card">
        Select a form: <select id="forms"><option>Loading...</option></select>
        <br /><br />

        <button id="create" class="buttonNorm">Create Quickstart Link</button>
        <br /><br />
    </div>

    <div class="card">
        Quickstart Link: <input id="link" type="text" style="width: 50vw" />
    </div>
</div>
