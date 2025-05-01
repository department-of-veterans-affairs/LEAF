console.log("VA Digital Signature content script loaded");

// Inject bridge script
const script = document.createElement('script');
script.src = chrome.runtime.getURL('bridge.js');
document.head.appendChild(script);

// Listen for messages from the webpage
window.addEventListener('message', function(event) {
  // We only accept messages from ourselves
  if (event.source !== window) return;

  if (event.data && event.data.type === 'VA_DIGSIGN_REQUEST') {
    console.log("Content script received request from page:", event.data);
    
    // Forward the request to the background script
    chrome.runtime.sendMessage({
      action: event.data.action,
      data: event.data.data
    }, function(response) {
      console.log("Content script received response from background:", response);
      
      // Forward response back to the webpage
      window.postMessage({
        type: 'VA_DIGSIGN_RESPONSE',
        response: response
      }, '*');
    });
  }
});

// Notify the page that the extension is ready
window.postMessage({ type: 'VA_DIGSIGN_READY' }, '*');
console.log("VA Digital Signature extension ready notification sent");