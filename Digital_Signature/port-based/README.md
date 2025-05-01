# digsig-windows
To use/test this version:

DO NOT SAVE ANY CHANGES ON THIS REPOSITORY

Additionally, if you want to compile your own executable file with your own certs, you'll need a 
computer that can run Golang.

If just running the .exe file, you want the test-page folder and files.  Download the .exe file
and test-page folder in a folder of your choice.  From Windows Explorer you can just double-click
the .exe file.  It may run in the background or it may pop up a window to show it's running.    

IMPORTANT:  If you're running it with self-generated certs (which is what the exe currently comes with)
you must first open your browser and go to: https://localhost:8443/dsign  It will pop a warning that 
the site doesn't have a signed cert.  Click "Advanced" and then "Continue to site".  This will log the 
self-signed with your browser.

Go to test-page folder and open the html file
in your browser.  Your PIV card will be necessary for the signing and "verify wiht PIV" features.  
It is not technically needed for the "verify with public cert" feature.

The signing of a file only returns a signature.  This feature may or may not be built out 
in the future if there is a demand for it.

The signing of data takes any string.  The initial focus is for json forms which would be 
stringafied first.  

Once you click sign, it will pop up a Windows prompt for your PIN.  This is OS handled; the 
script doesn't see it.  Note:  Depending on how your computer is acting, the PIN window may 
pop up behind other windows; just check your task bar for a flashing icon.

The Response on signing has the following:  
    result:  A hardcoded response signalling success or a handful of possible errors.
    signature:  A url-encoded string that is a signed blob of either the file or data entered.
    pivCertificate:  A url-encoded string that is the public cert in PEM format for the PIV card.
    dateSigned:  Pretty self-explanitory
    signerEmail:  This is pulled directly from the PIV card.
    scIssuer:  The authority for who issued the smartcard.  Future proofing.
    scSerialNumber:  The serial number of the PIV card.  Again, future proofing.
    scExperationDate:  Might be useful if one has to looked up long after someone left.
    signatureVerifi:  Boolean flag to let code requesting verification know if pass or fail.
    signatureCreated:  Boolean flag to let code requesting signature know if pass or fail.

The signature can be pasted into the Signed Hash field.  If Verfiy Signature is selected and PIV 
card is inserted, this is all that's needed.  If you want to use the public cert, just paste it 
into Card Cert.  

The Response for verification will only have the result, dateSigned (verified), and signatureVerfi 
fields set.  


If you want to compile the go to an .exe with your own key and cert, in the directory with the .go 
file run this command:

openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem

Don't change the names of the key or cert.  Then just run:

go build digital-signature-port-access.go

This will import the two files into the build of the .exe file.  At that point it's a good idea 
to get rid of them.
