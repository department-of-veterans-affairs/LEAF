
Open Chrome and go to chrome://extensions/
Enable "Developer mode" (toggle in the top-right corner)
Click "Load unpacked" and select the chrome-extension folder
Copy your extension ID which appears on the extension card

Open a terminal and go to the browser-ext-ver.  
run install.bat <extension ID>
Verify no errors.  This will be loading the middleware and the extension manifest into 
    the correct folders (creating them if necessary), and adding a row in the user-level 
    registry to tell Chrome where to look for the manifest.

