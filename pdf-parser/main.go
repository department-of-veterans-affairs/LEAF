package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/pdfcpu/pdfcpu/pkg/api"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu/model"
	"github.com/pdfcpu/pdfcpu/pkg/pdfcpu/types"
)

const (
	maxUploadSize      = 50 * 1024 * 1024 // 50 MB
	uploadPath         = "/uploads"
	outputPath         = "/parsed_output"
	pdfExtension       = ".pdf"
	contentTypeJSON    = "application/json"
	contentTypePDF     = "application/pdf"
	pdftotextTimeout   = 30 * time.Second
	hexUTF16ChunkSize  = 4
	contextBufferSize  = 50
	defaultServicePort = "9000"
)

var (
	// SSN patterns
	ssnPatterns = []*regexp.Regexp{
		regexp.MustCompile(`\b\d{3}-\d{2}-\d{4}\b`),     // 123-45-6789
		regexp.MustCompile(`\b\d{3}\s+\d{2}\s+\d{4}\b`), // 123 45 6789
		regexp.MustCompile(`\b\d{9}\b`),                 // 123456789
	}

	// Error messages
	errFileTooLarge     = errors.New("file too large or invalid form data")
	errNoFile           = errors.New("no file provided")
	errInvalidFileType  = errors.New("file must be a PDF")
	errTempFileCreation = errors.New("failed to create temp file")
	errFileSave         = errors.New("failed to save file")
	errNoTerms          = errors.New("no terms provided")
	errNoValidTerms     = errors.New("no valid terms provided")
)

type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

type ParseResult struct {
	Filename string            `json:"filename"`
	Pages    int               `json:"pages"`
	Metadata map[string]string `json:"metadata"`
	ParsedAt time.Time         `json:"parsed_at"`
}

type FormField struct {
	Name         string   `json:"name"`
	Type         string   `json:"type"`
	Value        string   `json:"value,omitempty"`
	DefaultValue string   `json:"default_value,omitempty"`
	Options      []string `json:"options,omitempty"`
	Flags        int      `json:"flags,omitempty"`
}

type FormFieldsResult struct {
	Filename   string      `json:"filename"`
	HasForm    bool        `json:"has_form"`
	FieldCount int         `json:"field_count"`
	Fields     []FormField `json:"fields"`
	ParsedAt   time.Time   `json:"parsed_at"`
}

type SSNMatch struct {
	Match   string `json:"match"`
	Pattern string `json:"pattern"`
	Context string `json:"context"`
}

type TermSearchResult struct {
	Filename        string         `json:"filename"`
	TotalTerms      int            `json:"total_terms"`
	TermsFound      int            `json:"terms_found"`
	TermsNotFound   int            `json:"terms_not_found"`
	MatchPercentage string         `json:"match_percentage"`
	TermBreakdown   map[string]int `json:"term_breakdown"`
}

func main() {
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("/health", healthCheck)

	// PDF operations
	mux.HandleFunc("/api/parse", parsePDF)
	mux.HandleFunc("/api/info", getPDFInfo)
	mux.HandleFunc("/api/extract-text", extractText)
	mux.HandleFunc("/api/extract-form-fields", extractFormFields)
	mux.HandleFunc("/api/scan-for-ssn", scanForSSN)
	mux.HandleFunc("/api/search-terms", searchTerms)

	port := getEnv("SERVICE_PORT", defaultServicePort)

	log.Printf("PDF Parser Service starting on port %s", port)
	log.Printf("Max upload size: %d bytes", maxUploadSize)

	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatal(err)
	}
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Message: "PDF Parser Service is healthy",
		Data: map[string]string{
			"status":  "up",
			"service": "pdf-parser",
			"version": "1.0.0",
		},
	})
}

func parsePDF(w http.ResponseWriter, r *http.Request) {
	tempFile, header, cleanup, err := handleFileUpload(w, r)
	if err != nil {
		return // Error already sent to client
	}
	defer cleanup()

	pageCount, err := api.PageCountFile(tempFile)
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to parse PDF: %v", err))
		return
	}

	result := ParseResult{
		Filename: header.Filename,
		Pages:    pageCount,
		Metadata: make(map[string]string),
		ParsedAt: time.Now(),
	}

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Message: "PDF parsed successfully",
		Data:    result,
	})
}

func getPDFInfo(w http.ResponseWriter, r *http.Request) {
	tempFile, header, cleanup, err := handleFileUpload(w, r)
	if err != nil {
		return // Error already sent to client
	}
	defer cleanup()

	pageCount, err := api.PageCountFile(tempFile)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to read PDF")
		return
	}

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Data: map[string]interface{}{
			"filename": header.Filename,
			"pages":    pageCount,
		},
	})
}

func extractText(w http.ResponseWriter, r *http.Request) {
	tempFile, header, cleanup, err := handleFileUpload(w, r)
	if err != nil {
		return // Error already sent to client
	}
	defer cleanup()

	text, err := extractTextFromPDF(tempFile)
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to extract text: %v", err))
		return
	}

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Data: map[string]interface{}{
			"filename": header.Filename,
			"text":     text,
		},
	})
}

func extractFormFields(w http.ResponseWriter, r *http.Request) {
	tempFile, header, cleanup, err := handleFileUpload(w, r)
	if err != nil {
		return // Error already sent to client
	}
	defer cleanup()

	ctx, err := api.ReadContextFile(tempFile)
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to read PDF: %v", err))
		return
	}

	fields, debugInfo, err := extractFields(ctx)
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to extract form fields: %v", err))
		return
	}

	result := FormFieldsResult{
		Filename:   header.Filename,
		HasForm:    len(fields) > 0,
		FieldCount: len(fields),
		Fields:     fields,
		ParsedAt:   time.Now(),
	}

	responseData := map[string]interface{}{
		"result": result,
		"debug":  debugInfo,
	}

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Message: fmt.Sprintf("Found %d form fields", len(fields)),
		Data:    responseData,
	})
}

func scanForSSN(w http.ResponseWriter, r *http.Request) {
	tempFile, header, cleanup, err := handleFileUpload(w, r)
	if err != nil {
		return // Error already sent to client
	}
	defer cleanup()

	text, err := extractTextFromPDF(tempFile)
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to extract text: %v", err))
		return
	}

	ssns := findSSNs(text)

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Data: map[string]interface{}{
			"filename":      header.Filename,
			"contains_ssn":  len(ssns) > 0,
			"ssn_count":     len(ssns),
			"ssn_locations": ssns,
		},
	})
}

func searchTerms(w http.ResponseWriter, r *http.Request) {
	tempFile, header, cleanup, err := handleFileUpload(w, r)
	if err != nil {
		return // Error already sent to client
	}
	defer cleanup()

	termsParam := r.FormValue("terms")
	if termsParam == "" {
		respondError(w, http.StatusBadRequest, errNoTerms.Error())
		return
	}

	text, err := extractTextFromPDF(tempFile)
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to extract text: %v", err))
		return
	}

	terms := parseTerms(termsParam)
	if len(terms) == 0 {
		respondError(w, http.StatusBadRequest, errNoValidTerms.Error())
		return
	}

	result := performTermSearch(text, terms, header.Filename)

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Data:    result,
	})
}

// handleFileUpload consolidates file upload handling
// Returns: tempFilePath, header, cleanup function, error
func handleFileUpload(w http.ResponseWriter, r *http.Request) (string, *multipart.FileHeader, func(), error) {
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, errFileTooLarge.Error())
		return "", nil, nil, errFileTooLarge
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, errNoFile.Error())
		return "", nil, nil, errNoFile
	}

	if filepath.Ext(header.Filename) != pdfExtension {
		file.Close()
		respondError(w, http.StatusBadRequest, errInvalidFileType.Error())
		return "", nil, nil, errInvalidFileType
	}

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		file.Close()
		respondError(w, http.StatusInternalServerError, errTempFileCreation.Error())
		return "", nil, nil, errTempFileCreation
	}

	tempPath := tempFile.Name()

	// Copy file content
	if _, err := io.Copy(tempFile, file); err != nil {
		file.Close()
		tempFile.Close()
		os.Remove(tempPath)
		respondError(w, http.StatusInternalServerError, errFileSave.Error())
		return "", nil, nil, errFileSave
	}

	file.Close()
	tempFile.Close()

	// Cleanup function
	cleanup := func() {
		os.Remove(tempPath)
	}

	return tempPath, header, cleanup, nil
}

func extractFields(ctx *model.Context) ([]FormField, map[string]interface{}, error) {
	var fields []FormField
	debugInfo := make(map[string]interface{})

	if ctx == nil {
		debugInfo["error"] = "context is nil"
		return fields, debugInfo, nil
	}

	if ctx.XRefTable == nil {
		debugInfo["error"] = "XRefTable is nil"
		return fields, debugInfo, nil
	}

	rootDict, err := ctx.Catalog()
	if err != nil {
		debugInfo["catalog_error"] = err.Error()
		log.Printf("Warning: Could not get catalog: %v", err)
		return fields, debugInfo, nil
	}
	debugInfo["has_catalog"] = true

	catalogKeys := make([]string, 0, len(rootDict))
	for key := range rootDict {
		catalogKeys = append(catalogKeys, key)
	}
	debugInfo["catalog_keys"] = catalogKeys

	acroFormObj, found := rootDict.Find("AcroForm")
	if !found {
		debugInfo["acroform_found"] = false
		checkAlternativeFormStructures(rootDict, ctx, debugInfo)
		return fields, debugInfo, nil
	}

	if acroFormObj == nil {
		debugInfo["acroform_obj"] = "nil"
		return fields, debugInfo, nil
	}

	debugInfo["acroform_found"] = true
	debugInfo["acroform_type"] = fmt.Sprintf("%T", acroFormObj)

	acroForm, err := ctx.DereferenceDict(acroFormObj)
	if err != nil {
		debugInfo["dereference_error"] = err.Error()
		log.Printf("Warning: Could not dereference AcroForm: %v", err)
		return fields, debugInfo, nil
	}
	debugInfo["acroform_dereferenced"] = true

	acroFormKeys := make([]string, 0, len(acroForm))
	for key := range acroForm {
		acroFormKeys = append(acroFormKeys, key)
	}
	debugInfo["acroform_keys"] = acroFormKeys

	fieldsObj, found := acroForm.Find("Fields")
	if !found || fieldsObj == nil {
		debugInfo["fields_array_found"] = false
		return fields, debugInfo, nil
	}

	debugInfo["fields_array_found"] = true
	debugInfo["fields_obj_type"] = fmt.Sprintf("%T", fieldsObj)

	fieldsArray, err := ctx.DereferenceArray(fieldsObj)
	if err != nil {
		debugInfo["fields_array_deref_error"] = err.Error()
		log.Printf("Warning: Could not dereference Fields array: %v", err)
		return fields, debugInfo, nil
	}
	debugInfo["fields_array_length"] = len(fieldsArray)

	for _, fieldRef := range fieldsArray {
		processField(ctx, fieldRef, "", &fields, debugInfo, 0)
	}

	debugInfo["fields_processed"] = len(fields)
	return fields, debugInfo, nil
}

func checkAlternativeFormStructures(rootDict types.Dict, ctx *model.Context, debugInfo map[string]interface{}) {
	// Check for XFA forms
	if xfaObj, xfaFound := rootDict.Find("XFA"); xfaFound {
		debugInfo["has_xfa"] = true
		debugInfo["xfa_type"] = fmt.Sprintf("%T", xfaObj)
		debugInfo["note"] = "This PDF uses XFA forms, not AcroForms. XFA extraction not yet supported."
	}

	// Check for page annotations
	if pagesObj, pagesFound := rootDict.Find("Pages"); pagesFound {
		debugInfo["has_pages"] = true
		if pagesDict, err := ctx.DereferenceDict(pagesObj); err == nil {
			if kidsObj, kidsFound := pagesDict.Find("Kids"); kidsFound {
				debugInfo["has_kids"] = true
				if kidsArray, err := ctx.DereferenceArray(kidsObj); err == nil {
					debugInfo["page_count"] = len(kidsArray)

					if len(kidsArray) > 0 {
						if pageDict, err := ctx.DereferenceDict(kidsArray[0]); err == nil {
							if annotsObj, annotsFound := pageDict.Find("Annots"); annotsFound {
								debugInfo["first_page_has_annots"] = true
								if annotsArray, err := ctx.DereferenceArray(annotsObj); err == nil {
									debugInfo["first_page_annot_count"] = len(annotsArray)
								}
							} else {
								debugInfo["first_page_has_annots"] = false
							}
						}
					}
				}
			}
		}
	}
}

func processField(ctx *model.Context, fieldRef types.Object, parentName string, fields *[]FormField, debugInfo map[string]interface{}, depth int) {
	fieldDict, err := ctx.DereferenceDict(fieldRef)
	if err != nil {
		log.Printf("Warning: Could not dereference field at depth %d: %v", depth, err)
		return
	}

	field := FormField{}

	if nameObj, found := fieldDict.Find("T"); found && nameObj != nil {
		rawName := fmt.Sprintf("%v", nameObj)
		field.Name = cleanFieldName(rawName)

		if parentName != "" {
			field.Name = parentName + "." + field.Name
		}
	}

	hasFieldType := false
	if ftObj, found := fieldDict.Find("FT"); found && ftObj != nil {
		field.Type = fmt.Sprintf("%v", ftObj)
		field.Type = strings.TrimPrefix(field.Type, "/")
		hasFieldType = true
	}

	if vObj, found := fieldDict.Find("V"); found && vObj != nil {
		field.Value = strings.Trim(fmt.Sprintf("%v", vObj), "()")
	}

	if dvObj, found := fieldDict.Find("DV"); found && dvObj != nil {
		field.DefaultValue = strings.Trim(fmt.Sprintf("%v", dvObj), "()")
	}

	if ffObj, found := fieldDict.Find("Ff"); found && ffObj != nil {
		fmt.Sscanf(fmt.Sprintf("%v", ffObj), "%d", &field.Flags)
	}

	if optObj, found := fieldDict.Find("Opt"); found && optObj != nil {
		if optArray, err := ctx.DereferenceArray(optObj); err == nil {
			field.Options = make([]string, 0, len(optArray))
			for _, opt := range optArray {
				optStr := strings.Trim(fmt.Sprintf("%v", opt), "()")
				field.Options = append(field.Options, optStr)
			}
		}
	}

	if kidsObj, found := fieldDict.Find("Kids"); found && kidsObj != nil {
		if kidsArray, err := ctx.DereferenceArray(kidsObj); err == nil {
			currentName := field.Name
			if currentName == "" {
				currentName = parentName
			}

			for _, kidRef := range kidsArray {
				processField(ctx, kidRef, currentName, fields, debugInfo, depth+1)
			}

			if !hasFieldType {
				return
			}
		}
	}

	if field.Name != "" {
		*fields = append(*fields, field)
	}
}

func cleanFieldName(rawName string) string {
	rawName = strings.Trim(rawName, "()")

	if strings.HasPrefix(rawName, "<FEFF") || strings.HasPrefix(rawName, "<feff") {
		rawName = strings.Trim(rawName, "<>")
		if decoded := decodeHexUTF16(rawName); decoded != "" {
			return decoded
		}
	}

	return rawName
}

func decodeHexUTF16(hexStr string) string {
	hexStr = strings.TrimPrefix(hexStr, "FEFF")
	hexStr = strings.TrimPrefix(hexStr, "feff")

	if len(hexStr)%hexUTF16ChunkSize != 0 {
		return ""
	}

	var result strings.Builder
	result.Grow(len(hexStr) / hexUTF16ChunkSize)

	for i := 0; i < len(hexStr); i += hexUTF16ChunkSize {
		if i+hexUTF16ChunkSize > len(hexStr) {
			break
		}

		hexPair := hexStr[i : i+hexUTF16ChunkSize]
		var codeUnit uint16
		if n, err := fmt.Sscanf(hexPair, "%04x", &codeUnit); err != nil || n != 1 {
			continue
		}

		if codeUnit > 0 {
			result.WriteRune(rune(codeUnit))
		}
	}

	return result.String()
}

func extractTextFromPDF(filepath string) (string, error) {
	outputFile, err := os.CreateTemp("", "pdftext-*.txt")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %w", err)
	}
	outputPath := outputFile.Name()
	outputFile.Close()
	defer os.Remove(outputPath)

	ctx, cancel := context.WithTimeout(context.Background(), pdftotextTimeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, "pdftotext", filepath, outputPath)

	var stderr strings.Builder
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		if ctx.Err() == context.DeadlineExceeded {
			return "", fmt.Errorf("pdftotext timed out after %v", pdftotextTimeout)
		}
		return "", fmt.Errorf("pdftotext failed: %w, stderr: %s", err, stderr.String())
	}

	textBytes, err := os.ReadFile(outputPath)
	if err != nil {
		return "", fmt.Errorf("failed to read extracted text: %w", err)
	}

	return string(textBytes), nil
}

func findSSNs(text string) []SSNMatch {
	results := make([]SSNMatch, 0)
	seen := make(map[string]bool)

	for _, pattern := range ssnPatterns {
		matches := pattern.FindAllString(text, -1)
		for _, match := range matches {
			// Avoid duplicate matches
			if seen[match] {
				continue
			}
			seen[match] = true

			index := strings.Index(text, match)
			if index == -1 {
				continue
			}

			start := index - contextBufferSize
			if start < 0 {
				start = 0
			}
			end := index + len(match) + contextBufferSize
			if end > len(text) {
				end = len(text)
			}

			context := text[start:end]
			context = strings.ReplaceAll(context, "\n", " ")
			context = strings.TrimSpace(context)

			results = append(results, SSNMatch{
				Match:   match,
				Pattern: pattern.String(),
				Context: context,
			})
		}
	}

	return results
}

func parseTerms(termsParam string) []string {
	rawTerms := strings.Split(termsParam, ",")
	terms := make([]string, 0, len(rawTerms))

	for _, term := range rawTerms {
		trimmed := strings.TrimSpace(term)
		if trimmed != "" {
			terms = append(terms, trimmed)
		}
	}

	return terms
}

func performTermSearch(text string, terms []string, filename string) TermSearchResult {
	lowerText := strings.ToLower(text)
	termBreakdown := make(map[string]int, len(terms))
	termsFound := 0

	for _, term := range terms {
		lowerTerm := strings.ToLower(term)
		count := strings.Count(lowerText, lowerTerm)
		termBreakdown[term] = count

		if count > 0 {
			termsFound++
		}
	}

	percentage := 0.0
	if len(terms) > 0 {
		percentage = (float64(termsFound) / float64(len(terms))) * 100
	}

	return TermSearchResult{
		Filename:        filename,
		TotalTerms:      len(terms),
		TermsFound:      termsFound,
		TermsNotFound:   len(terms) - termsFound,
		MatchPercentage: fmt.Sprintf("%.2f%%", percentage),
		TermBreakdown:   termBreakdown,
	}
}

func respondJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", contentTypeJSON)
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("Error encoding JSON response: %v", err)
	}
}

func respondError(w http.ResponseWriter, status int, message string) {
	respondJSON(w, status, Response{
		Success: false,
		Error:   message,
	})
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
