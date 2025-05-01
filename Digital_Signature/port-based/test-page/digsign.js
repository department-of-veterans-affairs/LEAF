document.getElementById('submitBtn').addEventListener('click', function() {
    const action = document.getElementById('action').value;
    const dataToSign = document.getElementById('dataToSign').value;
    const signedHash = document.getElementById('signedHash').value;
    const cardCertPem = document.getElementById('cardCertPem').value;
    const responseContainer = document.getElementById('response');

    if (action == -1) {
        fetch('https://localhost:8443/dsign')
            .then(response => response.json())
            .then(data => {
                responseContainer.value = JSON.stringify(data, null, 2);
            })
            .catch(error => {
                responseContainer.value = 'Error: ' + error;
            });
    } else {
        fetch('https://localhost:8443/dsign', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `action=${action}&data=${encodeURIComponent(dataToSign)}&signedHash=${encodeURIComponent(signedHash)}&cardCertPem=${encodeURIComponent(cardCertPem)}`
        })
        .then(response => response.json())
        .then(data => {
            responseContainer.value = JSON.stringify(data, null, 2);
        })
        .catch(error => {
            responseContainer.value = 'Error: ' + error;
        });
    }
});

