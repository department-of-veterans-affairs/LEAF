document.addEventListener('DOMContentLoaded', function() {
    // Tab switching functionality
    const tabButtons = document.querySelectorAll('.tab-button');
    const panels = document.querySelectorAll('.panel');
    
    tabButtons.forEach(button => {
      button.addEventListener('click', () => {
        // Deactivate all tabs
        tabButtons.forEach(btn => btn.classList.remove('active'));
        panels.forEach(panel => panel.classList.remove('active'));
        
        // Activate selected tab
        button.classList.add('active');
        const panelId = button.id.replace('tab-', '') + '-panel';
        document.getElementById(panelId).classList.add('active');
      });
    });
    
    // Sign functionality
    document.getElementById('sign-btn').addEventListener('click', () => {
      const data = document.getElementById('sign-data').value.trim();
      if (!data) {
        showResult('sign-result', 'Please enter text to sign', 'error');
        return;
      }
      
      showResult('sign-result', 'Signing... Please insert your PIV card if not already inserted.', 'info');
      
      chrome.runtime.sendMessage({
        data: data,
        action: '2' // Sign data
      }, (response) => {
        if (response.signatureCreated) {
          showResult('sign-result', response.result, 'success');
          // Store signature and certificate
          localStorage.setItem('signature', response.signature);
          localStorage.setItem('certificate', response.pivCertificate);
          localStorage.setItem('signerEmail', response.signerEmail || '');
          localStorage.setItem('dateSigned', response.dateSigned || '');
          
          // Enable copy button
          document.getElementById('copy-btn').disabled = false;
        } else {
          showResult('sign-result', response.result, 'error');
        }
      });
    });
    
    // Verify functionality
    document.getElementById('verify-btn').addEventListener('click', () => {
      const data = document.getElementById('verify-data').value.trim();
      const signature = document.getElementById('verify-signature').value.trim();
      const certificate = document.getElementById('verify-cert').value.trim();
      
      if (!data) {
        showResult('verify-result', 'Please enter text to verify', 'error');
        return;
      }
      
      if (!signature) {
        showResult('verify-result', 'Please enter a signature', 'error');
        return;
      }
      
      if (!certificate) {
        showResult('verify-result', 'Please enter a certificate', 'error');
        return;
      }
      
      showResult('verify-result', 'Verifying...', 'info');
      
      chrome.runtime.sendMessage({
        data: data,
        action: '4', // Verify with public cert
        signedHash: signature,
        cardCertPem: certificate
      }, (response) => {
        if (response.signatureVerifi) {
          showResult('verify-result', response.result, 'success');
        } else {
          showResult('verify-result', response.result, 'error');
        }
      });
    });
    
    // Copy functionality
    document.getElementById('copy-btn').addEventListener('click', () => {
      const signature = localStorage.getItem('signature') || '';
      const certificate = localStorage.getItem('certificate') || '';
      const signerEmail = localStorage.getItem('signerEmail') || '';
      const dateSigned = localStorage.getItem('dateSigned') || '';
      
      const textToCopy = 
        `Signature: ${signature}\n\n` +
        `Certificate: ${certificate}\n\n` +
        `Signer: ${signerEmail}\n` +
        `Date: ${dateSigned}`;
      
      navigator.clipboard.writeText(textToCopy)
        .then(() => {
          alert('Signature information copied to clipboard');
        })
        .catch(err => {
          console.error('Failed to copy: ', err);
          alert('Failed to copy to clipboard');
        });
    });
    
    // Clear functionality
    document.getElementById('clear-btn').addEventListener('click', () => {
      document.getElementById('sign-data').value = '';
      document.getElementById('verify-data').value = '';
      document.getElementById('verify-signature').value = '';
      document.getElementById('verify-cert').value = '';
      document.getElementById('sign-result').textContent = '';
      document.getElementById('verify-result').textContent = '';
      document.getElementById('sign-result').className = 'result';
      document.getElementById('verify-result').className = 'result';
      document.getElementById('copy-btn').disabled = true;
    });
    
    // Load saved values
    const savedSignature = localStorage.getItem('signature');
    const savedCertificate = localStorage.getItem('certificate');
    if (savedSignature && savedCertificate) {
      document.getElementById('verify-signature').value = savedSignature;
      document.getElementById('verify-cert').value = savedCertificate;
      document.getElementById('copy-btn').disabled = false;
    }
    
    // Utility function to show results
    function showResult(elementId, message, type) {
      const element = document.getElementById(elementId);
      element.textContent = message;
      element.className = 'result ' + type;
    }
  });