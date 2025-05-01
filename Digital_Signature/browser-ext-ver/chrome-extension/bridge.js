console.log("VA Digital Signature bridge script loaded");
// Create a global VADigSign object
window.VADigSign = {
    // Create a function to sign data
    signData: function(data) {
      return new Promise((resolve, reject) => {
        const requestId = Date.now().toString();
        
        // Set up a listener for the response
        const messageListener = function(event) {
          if (event.data.type === 'digsign-response' && 
              event.data.requestId === requestId) {
            // Clean up the listener
            window.removeEventListener('message', messageListener);
            
            if (event.data.payload.signatureCreated) {
              resolve(event.data.payload);
            } else {
              reject(event.data.payload.result);
            }
          }
        };
        
        window.addEventListener('message', messageListener);
        
        // Send the request
        window.postMessage({
          type: 'digsign',
          payload: {
            data: data,
            action: '2' // Sign data
          },
          requestId: requestId
        }, '*');
      });
    },
    
    // Create a function to verify a signature
    verifySignature: function(data, signature, certificate) {
      return new Promise((resolve, reject) => {
        const requestId = Date.now().toString();
        
        // Set up a listener for the response
        const messageListener = function(event) {
          if (event.data.type === 'digsign-response' && 
              event.data.requestId === requestId) {
            // Clean up the listener
            window.removeEventListener('message', messageListener);
            
            if (event.data.payload.signatureVerifi) {
              resolve(event.data.payload);
            } else {
              reject(event.data.payload.result);
            }
          }
        };
        
        window.addEventListener('message', messageListener);
        
        // Send the request
        window.postMessage({
          type: 'digsign',
          payload: {
            data: data,
            action: '4', // Verify with public cert
            signedHash: signature,
            cardCertPem: certificate
          },
          requestId: requestId
        }, '*');
      });
    }
  };
  
  // Dispatch an event to let the webpage know the API is ready
  document.dispatchEvent(new CustomEvent('VADigSignReady'));

  window.postMessage({ type: 'VA_DIGSIGN_READY' }, '*');