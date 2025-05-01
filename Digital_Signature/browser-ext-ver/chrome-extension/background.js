console.log("VA Digital Signature background script loaded");

// Initialize connection to native messaging host
let nativePort = null;

// Connect to native messaging host
function connectToNativeHost() {
  console.log("Connecting to native messaging host");
  try {
    nativePort = chrome.runtime.connectNative('gov.va.leaf.digsign');
    
    // Handle disconnection
    nativePort.onDisconnect.addListener(() => {
      console.error('Disconnected from native host:', chrome.runtime.lastError);
      nativePort = null;
    });
    
    console.log("Connected to native messaging host");
    return true;
  } catch (error) {
    console.error("Failed to connect to native host:", error);
    return false;
  }
}

// Listen for messages from content script
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log("Background received message:", message);
  
  // Connect to native host if not already connected
  if (!nativePort && !connectToNativeHost()) {
    sendResponse({
      result: "Failed to connect to the native messaging host. Is it installed correctly?",
      signatureCreated: false
    });
    return false;
  }
  
  // Set up one-time response handler
  const responseHandler = function(response) {
    console.log("Background received response from native host:", response);
    sendResponse(response);
    nativePort.onMessage.removeListener(responseHandler);
  };
  
  nativePort.onMessage.addListener(responseHandler);
  
  // Send message to native host
  try {
    nativePort.postMessage(message);
    console.log("Message sent to native host");
  } catch (error) {
    console.error("Error sending message to native host:", error);
    sendResponse({
      result: "Error sending message to native host: " + error.message,
      signatureCreated: false
    });
    return false;
  }
  
  // Return true to indicate that sendResponse will be called asynchronously
  return true;
});

console.log("VA Digital Signature background script ready");