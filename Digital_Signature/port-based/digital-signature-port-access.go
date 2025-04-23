package main

import (
	"bytes"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	_ "embed"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"syscall"
	"time"
	"unsafe"

	"golang.org/x/sys/windows"
)

//go:embed cert.pem
var certPEM []byte

//go:embed key.pem
var keyPEM []byte

// Constants for general operations of apis
const (
	CERT_STORE_PROV_SYSTEM         = 10
	CERT_SYSTEM_STORE_CURRENT_USER = 0x00010000
	CERT_FIND_ANY                  = 0
	CERT_FIND_KEY_USAGE            = 0x10
	KeyUsageDigitalSignature       = 0x80
	KeyUsageContentCommitment      = 0x40
	X509_ASN_ENCODING              = 0x00000001
	PKCS_7_ASN_ENCODING            = 0x00010000
	PROV_RSA_FULL                  = 1
	CRYPT_VERIFYCONTEXT            = 0xF0000000
	PROV_RSA_AES                   = 24
	CALG_SHA_256                   = 0x0000800C
	HP_HASHVAL                     = 0x0002
	PUBLICKEYBLOB                  = 0x6
	AT_SIGNATURE                   = 2
	CRYPT_DECODE_ALLOC_FLAG        = 0x00000001
	OFN_FILEMUSTEXIST              = 0x00001000
	OFN_PATHMUSTEXIST              = 0x00000800
)

// Response.Result Constants
const (
	OPEN_KEY_STORE_ERR                                          = "Failed to open keystore.  Ensure running on Windows."
	DIGITAL_SIGNATURE_NOT_FOUND_ERR                             = "Unable to find a Digital Signature from PIV card.  Please contact AD Team."
	DIGITAL_SIGNATURE_UNABLE_TO_SIGN                            = "Unable to sign document.  Please verify correct PIV card is inserted."
	FILE_ERROR                                                  = "Problem with reading file chosen.  Please ensure location and name."
	FILE_ERROR_PROCESSING                                       = "File appears to be corrupt or empty.  Please verify contents of file."
	DATA_ERROR                                                  = "Problem with data submitted.  Please ensure it is text."
	DIGITAL_SIGNATURE_UNABLE_TO_VERIFY_SIGNATURE_INTERNAL_ERROR = "Was unable to verify the signature created.  Please contact LEAF TEAM."
	DIGITAL_SIGNATURE_UNABLE_TO_VERIFY_SIGNATURE_PIV            = "Unable to verify signature with PIV Card.  Please ensure correct one is inserted."
	DIGITAL_SIGNATURE_UNABLE_TO_VERIFY_SIGNATURE_CERT           = "Unable to verify signature with supplied public cert."
	DIGITAL_SIGNATURE_CREATED                                   = "Successfully created a digital signature for document."
	INPUT_SIGNATURE_CORRUPT                                     = "The string entered for the digital signature is incorrect or corrupt."
	INPUT_CERTIFICATE_CORRUPT                                   = "The string entered for the public certificate is incorrect or corrupt."
	VERIFY_SIGNATURE_ERROR_GENERIC                              = "Error occured with verification proccess.  Ensure running on Windows."
	VERIFY_SIGNATURE_FALSE                                      = "The signature was not able to verified for the document and public certificate provied."
	SIGNATURE_VERIFIED_WITH_PUBLIC_CERT                         = "The digital signature has been verified for the document entered with the public certificate."
	SIGNATURE_VERIFIED_WITH_PIV_CARD                            = "The digital signature has been verified for the document entered with the PIV card."
	DATA_TO_BE_SIGNED_TOO_SMALL                                 = "The data to be signed was empty."
	DATA_TO_BE_SIGNED_TOO_BIG                                   = "The data being requested to sign is over 1 Mb."
	SIGNATURE_FIELD_EMPTY                                       = "The signature field is empty."
	CARDCERT_FIELD_EMPTY                                        = "The certificate field is empty."
)

// Windows processes needed for operation of encryption and decryption
var (
	ncrypt                                = syscall.NewLazyDLL("ncrypt.dll")
	procNCryptFreeObject                  = ncrypt.NewProc("NCryptFreeObject")
	crypt32                               = syscall.NewLazyDLL("crypt32.dll")
	procCertOpenStore                     = crypt32.NewProc("CertOpenStore")
	procCertFindCertificateInStore        = crypt32.NewProc("CertFindCertificateInStore")
	procCertFreeCertificateContext        = crypt32.NewProc("CertFreeCertificateContext")
	procCryptImportPublicKeyInfo          = crypt32.NewProc("CryptImportPublicKeyInfo")
	modAdvapi32                           = windows.NewLazySystemDLL("advapi32.dll")
	procCryptCreateHash                   = modAdvapi32.NewProc("CryptCreateHash")
	procCryptHashData                     = modAdvapi32.NewProc("CryptHashData")
	procCryptDestroyHash                  = modAdvapi32.NewProc("CryptDestroyHash")
	procCryptGetHashParam                 = modAdvapi32.NewProc("CryptGetHashParam")
	procCryptSignHashW                    = modAdvapi32.NewProc("CryptSignHashW")
	procCryptAcquireContextW              = modAdvapi32.NewProc("CryptAcquireContextW")
	procCryptReleaseContext               = modAdvapi32.NewProc("CryptReleaseContext")
	procCryptDestroyKey                   = modAdvapi32.NewProc("CryptDestroyKey")
	procCryptSetHashParam                 = modAdvapi32.NewProc("CryptSetHashParam")
	procCryptVerifySignatureW             = modAdvapi32.NewProc("CryptVerifySignatureW")
	modcrypt32                            = windows.NewLazySystemDLL("crypt32.dll")
	procCertCloseStore                    = modcrypt32.NewProc("CertCloseStore")
	procCryptAcquireCertificatePrivateKey = modcrypt32.NewProc("CryptAcquireCertificatePrivateKey")
	modcomdlg32                           = windows.NewLazySystemDLL("comdlg32.dll")
	procGetOpenFileName                   = modcomdlg32.NewProc("GetOpenFileNameW")
)

type SmartCardCert struct {
	Usage       string
	SigningCert *x509.Certificate
	CardCertPem []byte
	CertContext uintptr
}

type CryptKeyProvInfo struct {
	ContainerName *uint16
	ProviderName  *uint16
	ProvType      uint32
	Flags         uint32
	ProvParam     uintptr
	KeySpec       uint32
}

type RequestData struct {
	Doc      string `json:"data"`
	Act      string `json:"action"`
	Sig      string `json:"signedHash"`
	CardCert string `json:"cardCertPem"`
}

type Response struct {
	Result       string `json:"result"`
	Signature    string `json:"signature"`
	PIVCert      string `json:"pivCertificate"`
	DateSigned   string `json:"dateSigned"`
	SignerEmail  string `json:"signerEmail"`
	ScIssuer     string `json:"scIssuer"`
	ScSerial     string `json:"scSerialNumber"`
	ScExperation string `json:"scExperiationDate"`
	SigVerifi    bool   `json:"signatureVerifi"`
	SigCreated   bool   `json:"signatureCreated"`
}

type OpenFileData struct {
	lStructSize       uint32
	hwndOwner         uintptr
	hInstance         uintptr
	lpstrFilter       *uint16
	lpstrCustomFilter *uint16
	nMaxCustFilter    uint32
	nFilterIndex      uint32
	lpstrFile         *uint16
	nMaxFile          uint32
	lpstrFileTitle    *uint16
	nMaxFileTitle     uint32
	lpstrInitialDir   *uint16
	lpstrTitle        *uint16
	Flags             uint32
	nFileOffset       uint16
	nFileExtension    uint16
	lpstrDefExt       *uint16
	lCustData         uintptr
	lpfnHook          uintptr
	lpTemplateName    *uint16
	pvReserved        unsafe.Pointer
	dwReserved        uint32
	FlagsEx           uint32
}

func digsign(request *RequestData) string {
	var response Response
	var sigByte, hashByte []byte
	var errStr string
	var verified bool

	action := request.Act
	data := request.Doc
	response.SigCreated = false
	response.SigVerifi = false
	currentTime := time.Now()
	timeString := currentTime.Format("2006-01-02 15:04:05")
	response.DateSigned = timeString

	// Allowed actions:
	// 		1:  Sign a file.  User will be prompted to select the file to be signed.
	//		2:  Sign data passed in.
	//		3:  Verifies signature for card-holder.  Takes in data and signature.
	//		4:  Verifies signature using public key.  Takes in data, signature, and public key.
	switch action {
	case "1": // Sign a file
		// Open Windows Certificate store that containes PIV card certs (MY)
		store, err := openWindowsCertStore("MY")
		if err != nil {
			response.Result = OPEN_KEY_STORE_ERR
			break
		}
		defer closeWindowsCertStore(store)

		// Retrieve PIV card information in smartcard format
		smartCard, err := getSmartCardData(store)
		if err != nil {
			response.Result = DIGITAL_SIGNATURE_NOT_FOUND_ERR
			break
		}
		sigByte, _, errStr = signFile(smartCard.SigningCert, smartCard.CertContext)
		if errStr != "" {
			response.Result = errStr
		} else {
			//  URL encode signature and public cert
			encodedSignature := base64.URLEncoding.EncodeToString(sigByte)
			encodedCardCert := base64.URLEncoding.EncodeToString(smartCard.CardCertPem)

			//  Build the Response
			response.PIVCert = encodedCardCert
			response.Signature = encodedSignature
			response.Result = DIGITAL_SIGNATURE_CREATED
			response.SigCreated = true
			response.SignerEmail = smartCard.SigningCert.EmailAddresses[0]
			response.ScSerial = fmt.Sprintf("%x", smartCard.SigningCert.SerialNumber)
			response.ScIssuer = smartCard.SigningCert.Issuer.OrganizationalUnit[0]
			response.ScExperation = smartCard.SigningCert.NotAfter.String()
		}

	case "2": //Sign a string
		//  Verify required fields.
		if len(request.Doc) < 1 {
			response.Result = DATA_TO_BE_SIGNED_TOO_SMALL
			break
		}
		if len(request.Doc) > 1048576 {
			response.Result = DATA_TO_BE_SIGNED_TOO_BIG
			break
		}

		// Open Windows Certificate store that containes PIV card certs (MY)
		store, err := openWindowsCertStore("MY")
		if err != nil {
			response.Result = OPEN_KEY_STORE_ERR
			break
		}
		defer closeWindowsCertStore(store)

		// Retrieve PIV card information in smartcard format
		smartCard, err := getSmartCardData(store)
		if err != nil {
			response.Result = DIGITAL_SIGNATURE_NOT_FOUND_ERR
			break
		}
		sigByte, _, errStr = signData(data, smartCard.SigningCert, smartCard.CertContext)
		if errStr != "" {
			response.Result = errStr
		} else {
			//  URL encode signature and public cert
			encodedSignature := base64.URLEncoding.EncodeToString(sigByte)
			encodedCardCert := base64.URLEncoding.EncodeToString(smartCard.CardCertPem)

			//  Build the Response
			response.PIVCert = encodedCardCert
			response.Signature = encodedSignature
			response.Result = DIGITAL_SIGNATURE_CREATED
			response.SigCreated = true
			response.SignerEmail = smartCard.SigningCert.EmailAddresses[0]
			response.ScSerial = fmt.Sprintf("%x", smartCard.SigningCert.SerialNumber)
			response.ScIssuer = smartCard.SigningCert.Issuer.OrganizationalUnit[0]
			response.ScExperation = smartCard.SigningCert.NotAfter.String()
		}

	case "3": //Verify signature with PIV Card
		//  Verify required fields.
		if len(request.Doc) < 1 {
			response.Result = DATA_TO_BE_SIGNED_TOO_SMALL
			break
		}

		if len(request.Doc) > 1048576 {
			response.Result = DATA_TO_BE_SIGNED_TOO_BIG
			break
		}

		if len(request.Sig) < 1 {
			response.Result = SIGNATURE_FIELD_EMPTY
			break
		}

		hashByte = []byte(request.Doc)
		signature, err := base64.URLEncoding.DecodeString(request.Sig)
		if err != nil {
			response.Result = INPUT_SIGNATURE_CORRUPT
		} else {
			// Open Windows Certificate store that containes PIV card certs (MY)
			store, err := openWindowsCertStore("MY")
			if err != nil {
				response.Result = OPEN_KEY_STORE_ERR
				break
			}
			defer closeWindowsCertStore(store)

			// Retrieve PIV card information in smartcard format
			smartCard, err := getSmartCardData(store)
			if err != nil {
				response.Result = DIGITAL_SIGNATURE_NOT_FOUND_ERR
				break
			}
			_, computedHash, _ := computeSHA256Hash(smartCard.CertContext, hashByte)
			verified = verifySignature(smartCard.SigningCert, smartCard.CertContext, computedHash, signature)
			if !verified {
				response.Result = DIGITAL_SIGNATURE_UNABLE_TO_VERIFY_SIGNATURE_PIV
			} else {
				//  Build the Response
				response.Result = SIGNATURE_VERIFIED_WITH_PIV_CARD
				response.SigVerifi = verified
				response.SignerEmail = smartCard.SigningCert.EmailAddresses[0]
				response.ScSerial = fmt.Sprintf("%x", smartCard.SigningCert.SerialNumber)
				response.ScIssuer = smartCard.SigningCert.Issuer.OrganizationalUnit[0]
				response.ScExperation = smartCard.SigningCert.NotAfter.String()
			}
		}

	case "4": //Verify signature with public cert
		//  Verify required fields.
		if len(request.Doc) < 1 {
			response.Result = DATA_TO_BE_SIGNED_TOO_SMALL
			break
		}
		if len(request.Doc) > 1048576 {
			response.Result = DATA_TO_BE_SIGNED_TOO_BIG
			break
		}
		if len(request.Sig) < 1 {
			response.Result = SIGNATURE_FIELD_EMPTY
			break
		}
		if len(request.CardCert) < 1 {
			response.Result = CARDCERT_FIELD_EMPTY
			break
		}

		//  Verify signature against public cert and data entered
		errStr, verified := verifySignatureCertPem(request.CardCert, []byte(request.Doc), request.Sig)
		if errStr != "" {
			response.Result = errStr
		} else {
			response.Result = SIGNATURE_VERIFIED_WITH_PUBLIC_CERT
			response.SigVerifi = verified
		}

	default: //  Defaulted to help file.
		response.Result = helpFile()
	}

	fmt.Println()
	fmt.Println("Response")
	jsonData, _ := json.Marshal(response)

	fmt.Println(string(jsonData))
	retval := string(jsonData)
	return retval
}

func openWindowsCertStore(storeName string) (syscall.Handle, error) {
	storeNamePtr, err := syscall.UTF16PtrFromString(storeName)
	if err != nil {
		return 0, err
	}

	r, _, err := procCertOpenStore.Call(
		CERT_STORE_PROV_SYSTEM,
		0,
		0,
		CERT_SYSTEM_STORE_CURRENT_USER,
		uintptr(unsafe.Pointer(storeNamePtr)),
	)

	if r == 0 {
		return 0, fmt.Errorf("failed to open certificate store: %v", err)
	}

	return syscall.Handle(r), nil
}

func closeWindowsCertStore(store syscall.Handle) {
	_, _, _ = procCertCloseStore.Call(uintptr(store), 0)
}

// Retrieving the required data from the PIV card
func getSmartCardData(store syscall.Handle) (*SmartCardCert, error) {
	var certContext *syscall.CertContext
	var smartCard *SmartCardCert
	keyUsage := KeyUsageDigitalSignature | KeyUsageContentCommitment
	raw, _, err := procCertFindCertificateInStore.Call(
		uintptr(store),
		syscall.X509_ASN_ENCODING|syscall.PKCS_7_ASN_ENCODING,
		0,
		CERT_FIND_KEY_USAGE, uintptr(unsafe.Pointer(&keyUsage)),
		0,
		uintptr(unsafe.Pointer(certContext)),
	)
	if raw == 0 {
		if err != nil && err != syscall.Errno(0) {
			return nil, fmt.Errorf("failed to find digital signature certificate: %v", err)
		}
	}

	//  The nolint for unsafeptr was added because this is a syscall to a Windows API.  False positive.
	// nolint:govet // unsafeptr
	certContext = (*syscall.CertContext)(unsafe.Pointer(raw))
	dupContext := windows.CertDuplicateCertificateContext((*windows.CertContext)(unsafe.Pointer(certContext)))
	if dupContext == nil {
		return nil, fmt.Errorf("failed to duplicate")
	}
	certData := (*windows.CertContext)(unsafe.Pointer(dupContext))
	certBytes := (*[1 << 20]byte)(unsafe.Pointer(certData.EncodedCert))[:certData.Length:certData.Length]

	cert, err := x509.ParseCertificate(certBytes)
	if err != nil {
		return nil, err
	}

	// Convert the certificate to PEM format
	certPem := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: cert.Raw})

	// Load SmartCard
	smartCard = &SmartCardCert{
		Usage:       describeKeyUsage(cert.KeyUsage),
		SigningCert: cert,
		CertContext: uintptr(unsafe.Pointer(dupContext)),
		CardCertPem: certPem,
	}
	_, _, _ = procCertFreeCertificateContext.Call(raw)

	return smartCard, nil
}

func describeKeyUsage(usage x509.KeyUsage) string {
	var usages []string

	if usage&x509.KeyUsageDigitalSignature != 0 {
		usages = append(usages, "Digital Signature ")
	}
	if usage&x509.KeyUsageContentCommitment != 0 {
		usages = append(usages, "Non-Repudiation")
	}
	if usage&x509.KeyUsageKeyEncipherment != 0 {
		usages = append(usages, "Key Encipherment (Encryption)")
	}
	if usage&x509.KeyUsageDataEncipherment != 0 {
		usages = append(usages, "Data Encipherment (Decryption)")
	}
	if usage&x509.KeyUsageKeyAgreement != 0 {
		usages = append(usages, "Key Agreement")
	}
	if usage&x509.KeyUsageCertSign != 0 {
		usages = append(usages, "Certificate Signing")
	}
	if usage&x509.KeyUsageCRLSign != 0 {
		usages = append(usages, "CRL Signing")
	}
	if usage&x509.KeyUsageEncipherOnly != 0 {
		usages = append(usages, "Encipher Only")
	}
	if usage&x509.KeyUsageDecipherOnly != 0 {
		usages = append(usages, "Decipher Only")

	}

	if len(usages) == 0 {
		return "Unknown"
	}
	return strings.Join(usages, ", ")
}

func signFile(cert *x509.Certificate, certContext uintptr) ([]byte, []byte, string) {
	var signature []byte
	var computedHash []byte

	// Use Windows OS to request document to sign and get the path to document
	fileBuffer := make([]uint16, syscall.MAX_PATH)
	title, _ := windows.UTF16PtrFromString("Select a file")
	ofn := OpenFileData{
		lStructSize: uint32(unsafe.Sizeof(OpenFileData{})),
		lpstrFile:   &fileBuffer[0],
		nMaxFile:    syscall.MAX_PATH,
		lpstrTitle:  title,
		Flags:       OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST,
	}

	ret, _, _ := procGetOpenFileName.Call(uintptr(unsafe.Pointer(&ofn)))
	if ret == 0 {
		return signature, computedHash, FILE_ERROR
	}

	filePath := syscall.UTF16ToString(fileBuffer)

	//Open the file to sign
	inputFile, err := os.Open(filePath)
	if err != nil {
		return signature, computedHash, FILE_ERROR
	}
	defer func() {
		err := inputFile.Close()
		if err != nil {
			log.Printf("Error closing file: %v", err)
		}
	}()

	//Load the Existing file into a Buffer
	inputBuffer := new(bytes.Buffer)
	_, err = inputBuffer.ReadFrom(inputFile)
	if err != nil {
		return signature, computedHash, FILE_ERROR
	}

	//  Hash the data in the file.
	hashHandle, computedHash, err := computeSHA256Hash(certContext, inputBuffer.Bytes())
	if err != nil {
		return signature, computedHash, FILE_ERROR_PROCESSING
	}

	//  Sign the data with PIV card.
	signature, err = signHashWithSmartCard(certContext, hashHandle)
	if err != nil {
		return signature, computedHash, DIGITAL_SIGNATURE_UNABLE_TO_SIGN
	}

	// Verify signature is computed correctly.
	if !verifySignature(cert, certContext, computedHash, signature) {
		return signature, computedHash, DIGITAL_SIGNATURE_UNABLE_TO_VERIFY_SIGNATURE_INTERNAL_ERROR
	}

	return signature, computedHash, ""
}

func signData(dataToSign string, cert *x509.Certificate, certContext uintptr) ([]byte, []byte, string) {
	var signature []byte
	var computedHash []byte
	var err error

	// Byte the data to be signed
	byteData := []byte(dataToSign)

	// Create hash from data bytes
	hashHandle, computedHash, err := computeSHA256Hash(certContext, byteData)
	if err != nil {
		return signature, computedHash, DATA_ERROR
	}

	// Sign Hash
	signature, err = signHashWithSmartCard(certContext, hashHandle)
	if err != nil {
		return signature, computedHash, DIGITAL_SIGNATURE_UNABLE_TO_SIGN
	}

	// Verify signature
	if !verifySignature(cert, certContext, computedHash, signature) {
		return signature, computedHash, DIGITAL_SIGNATURE_UNABLE_TO_VERIFY_SIGNATURE_INTERNAL_ERROR
	}

	return signature, computedHash, ""
}

func computeSHA256Hash(certContext uintptr, rawData []byte) (uintptr, []byte, error) {
	var providerHandle uintptr
	var hashHandle uintptr
	var keySpec uint32
	var mustFreeProvider bool

	// Acquire the Smart Card Provider
	ret, _, _ := procCryptAcquireCertificatePrivateKey.Call(
		certContext,
		0, 0,
		uintptr(unsafe.Pointer(&providerHandle)),
		uintptr(unsafe.Pointer(&keySpec)),
		uintptr(unsafe.Pointer(&mustFreeProvider)),
	)

	if ret == 0 || providerHandle == 0 {
		return 0, nil, fmt.Errorf("CryptAcquireCertificatePrivateKey failed (Error Code: %x)", windows.GetLastError())
	}

	//  Create a SHA-256 Hash Object
	ret, _, _ = procCryptCreateHash.Call(
		providerHandle,        //  Using a valid `HCRYPTPROV`
		uintptr(CALG_SHA_256), //  SHA-256 specified here
		0, 0,
		uintptr(unsafe.Pointer(&hashHandle)), // Store the created hash object.
	)
	if ret == 0 || hashHandle == 0 {
		return 0, nil, fmt.Errorf("CryptCreateHash failed (Error Code: %x)", windows.GetLastError())
	}

	//  Hash the Data
	ret, _, _ = procCryptHashData.Call(
		uintptr(hashHandle),
		uintptr(unsafe.Pointer(&rawData[0])),
		uintptr(len(rawData)),
		0,
	)
	if ret == 0 {
		_, _, _ = procCryptDestroyHash.Call(hashHandle)
		return 0, nil, fmt.Errorf("CryptHashData failed (Error Code: %x)", windows.GetLastError())
	}

	hash := make([]byte, 32)
	var hashLen uint32 = 32

	ret, _, _ = procCryptGetHashParam.Call(
		uintptr(hashHandle),
		uintptr(HP_HASHVAL),
		uintptr(unsafe.Pointer(&hash[0])),
		uintptr(unsafe.Pointer(&hashLen)),
		0,
	)
	if ret == 0 {
		_, _, _ = procCryptDestroyHash.Call(hashHandle)
		return 0, nil, fmt.Errorf(" CryptGetHashParam failed (Error Code: %x)", windows.GetLastError())
	}

	return hashHandle, hash, nil
}

func signHashWithSmartCard(certContext uintptr, hashHandle uintptr) ([]byte, error) {
	var keyHandle uintptr
	var keySpec uint32
	var mustFreeProvider bool

	//Acquire Smart Card Private Key Handle
	ret, _, err := procCryptAcquireCertificatePrivateKey.Call(
		certContext,
		0, 0,
		uintptr(unsafe.Pointer(&keyHandle)),
		uintptr(unsafe.Pointer(&keySpec)),
		uintptr(unsafe.Pointer(&mustFreeProvider)),
	)
	if ret == 0 || keyHandle == 0 {
		return nil, fmt.Errorf("failed to acquire Smart Card private key. %w", err)
	}
	defer func() {
		if mustFreeProvider {
			_, _, _ = procNCryptFreeObject.Call(keyHandle)
		}
	}()

	var sigLen uint32
	ret, _, err = procCryptSignHashW.Call(
		uintptr(hashHandle),
		uintptr(keySpec),
		0, 0,
		0,
		uintptr(unsafe.Pointer(&sigLen)),
	)
	if ret == 0 {
		return nil, fmt.Errorf(" CryptSignHashW failed while getting size (Error Code: %x)", err.Error())
	}

	//Generate Smart Card Signature
	signature := make([]byte, sigLen)
	ret, _, err = procCryptSignHashW.Call(
		uintptr(hashHandle),
		uintptr(keySpec),
		0, 0,
		uintptr(unsafe.Pointer(&signature[0])),
		uintptr(unsafe.Pointer(&sigLen)),
	)
	if ret == 0 {
		return nil, fmt.Errorf(" CryptSignHashW signing failed (Error Code: %x)", err.Error())
	}

	_, _, _ = procCryptDestroyHash.Call(hashHandle)

	return signature[:sigLen], nil
}

// Verify signature with PIV card
func verifySignature(cert *x509.Certificate, certContext uintptr, computedHash, signature []byte) bool {

	// Acquire CryptoAPI Context
	var hProv uintptr
	ret, _, _ := procCryptAcquireContextW.Call(
		uintptr(unsafe.Pointer(&hProv)),
		0, 0,
		PROV_RSA_AES,
		CRYPT_VERIFYCONTEXT,
	)
	if ret == 0 {
		return false
	}
	defer func() {
		_, _, err := procCryptReleaseContext.Call(hProv, 0)
		if err != syscall.Errno(0) {
			log.Printf("Error releasing crypto context: %v", err)
		}
	}()

	// Retrieve public key
	var publicKeyInfo *windows.CertPublicKeyInfo

	//  The nolint for unsafeptr was added because this is a call to a Windows API.  False positive.
	// nolint:govet // unsafeptr
	certContextStruct := (*windows.CertContext)(unsafe.Pointer(certContext))

	publicKeyInfo = &certContextStruct.CertInfo.SubjectPublicKeyInfo

	var hPublicKey uintptr
	ret, _, _ = procCryptImportPublicKeyInfo.Call(
		hProv,
		uintptr(X509_ASN_ENCODING|PKCS_7_ASN_ENCODING),
		uintptr(unsafe.Pointer(publicKeyInfo)),
		uintptr(unsafe.Pointer(&hPublicKey)),
	)
	if ret == 0 {
		return false
	}
	defer func() {
		_, _, err := procCryptDestroyKey.Call(hPublicKey)
		if err != syscall.Errno(0) {
			log.Printf("Error destroying public key: %v", err)
		}
	}()

	var hHash uintptr
	ret, _, _ = procCryptCreateHash.Call(hProv, CALG_SHA_256, 0, 0, uintptr(unsafe.Pointer(&hHash)))
	if ret == 0 {
		return false
	}
	defer func() {
		_, _, err := procCryptDestroyHash.Call(hHash)
		if err != syscall.Errno(0) {
			log.Printf("Error destroying hash: %v", err)
		}
	}()

	ret, _, _ = procCryptSetHashParam.Call(hHash, HP_HASHVAL, uintptr(unsafe.Pointer(&computedHash[0])), 0)
	if ret == 0 {
		return false
	}

	//  Verify Signature Using PIV card public key
	ret, _, _ = procCryptVerifySignatureW.Call(
		hHash,
		uintptr(unsafe.Pointer(&signature[0])),
		uintptr(len(signature)),
		hPublicKey,
		0,
		0,
	)

	return ret != 0
}

func verifySignatureCertPem(certStr string, message []byte, signatureStr string) (string, bool) {

	// Decode the string signature
	signature, err := base64.URLEncoding.DecodeString(signatureStr)
	if err != nil {
		signature, err = base64.RawURLEncoding.DecodeString(signatureStr)
		if err != nil {
			return INPUT_SIGNATURE_CORRUPT, false
		}
	}

	// Decode the string PEM public key
	certPEM, err := base64.URLEncoding.DecodeString(certStr)
	if err != nil {
		certPEM, err = base64.RawURLEncoding.DecodeString(certStr)
		if err != nil {
			return INPUT_CERTIFICATE_CORRUPT, false
		}
	}

	// Parse PEM-encoded certificate
	block, _ := pem.Decode(certPEM)
	if block == nil || block.Type != "CERTIFICATE" {
		return INPUT_CERTIFICATE_CORRUPT, false
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return INPUT_CERTIFICATE_CORRUPT, false
	}

	// Extract public key
	pubKey, ok := cert.PublicKey.(*rsa.PublicKey)
	if !ok {
		return INPUT_CERTIFICATE_CORRUPT, false
	}

	// Compute hash of the message
	hashed := sha256.Sum256(message)

	// Try verification with original signature
	err = rsa.VerifyPKCS1v15(pubKey, crypto.SHA256, hashed[:], signature)
	if err == nil {
		return SIGNATURE_VERIFIED_WITH_PUBLIC_CERT, true
	}

	// Reverse the signature bytes (Windows CryptoAPI quirk)
	reversedSignature := make([]byte, len(signature))
	for i := range signature {
		reversedSignature[len(signature)-1-i] = signature[i]
	}

	// Try verification with reversed signature
	err = rsa.VerifyPKCS1v15(pubKey, crypto.SHA256, hashed[:], reversedSignature)
	if err == nil {
		return "", true
	}

	return VERIFY_SIGNATURE_FALSE, false
}

func main() {
	http.HandleFunc("/dsign", dsignHandler)

	cert, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		log.Fatalf("Failed to load key pair: %v", err)
	}

	server := &http.Server{
		Addr: "127.0.0.1:8443",
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
			MinVersion:   tls.VersionTLS12,
		},
	}

	fmt.Println("Starting server on :8443")
	log.Fatal(server.ListenAndServeTLS("", ""))
}

// Handles the https request and response.  GET only returns help instructions.  OPTIONS tells
// the browser what can be sent, POST only accepts what is detailed in the help instructions.
func dsignHandler(write http.ResponseWriter, request *http.Request) {
	// Check if the request is coming from localhost
	host, _, err := net.SplitHostPort(request.RemoteAddr)
	if err != nil || (host != "127.0.0.1" && host != "::1" && host != "localhost") {
		http.Error(write, "Access denied: this service is only available from localhost", http.StatusForbidden)
		return
	}

	// Going to verify origin to restict it to accepted locations
	origin := request.Header.Get("Origin")

	if origin == "" || origin == "null" || strings.HasPrefix(origin, "file://") {
		write.Header().Set("Access-Control-Allow-Origin", "*")
	} else {
		// Allowed origins
		allowedOrigins := map[string]bool{
			"https://leaf.va.gov":             true,
			"https://leaf-preprod.va.gov":     true,
			"https://dev.leaf-preprod.va.gov": true,
			"https://localhost:8443":          true,
			"https://127.0.0.1:8443":          true,
		}
		if allowedOrigins[origin] {
			write.Header().Set("Access-Control-Allow-Origin", origin)
		}
	}

	write.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
	write.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	write.Header().Set("Content-Type", "application/json")

	switch request.Method {
	case http.MethodOptions:
		return
	case http.MethodGet:
		err := json.NewEncoder(write).Encode(helpFile())
		if err != nil {
			//  Note:  This section is primarily to satify the linting and to give some error back to user.
			log.Println("Help file encoding error.")
			http.Error(write, "System error", http.StatusMethodNotAllowed)
		}
		return
	case http.MethodPost:
		var req RequestData

		contentType := request.Header.Get("Content-Type")
		if strings.Contains(contentType, "application/json") {
			// Handle JSON request
			body, err := io.ReadAll(request.Body)
			if err != nil {
				response := Response{
					Result:     fmt.Sprintf("Error reading request body: %v", err),
					SigCreated: false,
					SigVerifi:  false,
				}
				err = json.NewEncoder(write).Encode(response)
				if err != nil {
					//  Note:  This section is primarily to satify the linting and to give some error back to user.
					log.Println("Json encoding error.")
					http.Error(write, "System error", http.StatusMethodNotAllowed)
				}
				return
			}

			// Validate JSON schema
			if err := validateRequestData(body); err != nil {
				response := Response{
					Result:     fmt.Sprintf("Invalid request format: %v", err),
					SigCreated: false,
					SigVerifi:  false,
				}
				err = json.NewEncoder(write).Encode(response)
				if err != nil {
					//  Note:  This section is primarily to satify the linting and to give some error back to user.
					log.Println("Response encoding error.")
					http.Error(write, "System error", http.StatusMethodNotAllowed)
				}
				return
			}

			if err := json.Unmarshal(body, &req); err != nil {
				response := Response{
					Result:     fmt.Sprintf("Error parsing JSON: %v", err),
					SigCreated: false,
					SigVerifi:  false,
				}
				err = json.NewEncoder(write).Encode(response)
				if err != nil {
					//  Note:  This section is primarily to satify the linting and to give some error back to user.
					log.Println("Unarshalling encoding error.")
					http.Error(write, "System error", http.StatusMethodNotAllowed)
				}
				return
			}
		} else {
			allowedFields := map[string]bool{
				"data":        true,
				"action":      true,
				"signedHash":  true,
				"cardCertPem": true,
			}

			for key := range request.Form {
				if !allowedFields[key] {
					response := Response{
						Result:     fmt.Sprintf("Unexpected form field: %s", key),
						SigCreated: false,
						SigVerifi:  false,
					}
					err = json.NewEncoder(write).Encode(response)
					if err != nil {
						//  Note:  This section is primarily to satify the linting and to give some error back to user.
						log.Println("Form field error.")
						http.Error(write, "System error", http.StatusMethodNotAllowed)
					}
					return
				}
			}

			req.Doc = request.FormValue("data")
			req.Act = request.FormValue("action")
			req.Sig = request.FormValue("signedHash")
			req.CardCert = request.FormValue("cardCertPem")
		}

		err = json.NewEncoder(write).Encode(digsign(&req))
		if err != nil {
			//  Note:  This section is primarily to satify the linting and to give some error back to user.
			log.Println("Final encoding error.")
			http.Error(write, "System error", http.StatusMethodNotAllowed)
		}
		return
	default:
		http.Error(write, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
}

// Returns details on using app when a GET is done to the endpoint
func helpFile() string {
	helpme := `gotta create a help html file to include:  
	type Request struct {
		Doc string 'json:"doc"'
		Act string 'json:"act"'
	}

	type Response struct {
		Result       string 'json:"result"'
		Signature    string 'json:"signature"'
		DateSigned   string 'json:"dateSigned"'
		SignerEmail  string 'json:"signerEmail"'
		ScIssuer     string 'json:"scIssuer"'
		ScSerial     string 'json:"scSerialNumber"'
		ScExperation string 'json:"scExperiationDate"'
	}`
	return helpme
}

// Validate the RequestData structure
func validateRequestData(data []byte) error {
	var request RequestData
	if err := json.Unmarshal(data, &request); err != nil {
		return fmt.Errorf("invalid JSON format: %v", err)
	}

	if request.Doc == "" {
		return fmt.Errorf("missing required field: data")
	}
	if request.Act == "" {
		return fmt.Errorf("missing required field: action")
	}

	return nil
}
