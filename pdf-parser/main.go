package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
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
	maxUploadSize = 50 * 1024 * 1024 // 50 MB
	uploadPath    = "/uploads"
	outputPath    = "/parsed_output"
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

	port := getEnv("SERVICE_PORT", "9000")

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
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, "File too large or invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	if filepath.Ext(header.Filename) != ".pdf" {
		respondError(w, http.StatusBadRequest, "File must be a PDF")
		return
	}

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to create temp file")
		return
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	if _, err := io.Copy(tempFile, file); err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	pageCount, err := api.PageCountFile(tempFile.Name())
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
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, "Invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to create temp file")
		return
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	if _, err := io.Copy(tempFile, file); err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	pageCount, err := api.PageCountFile(tempFile.Name())
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
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, "Invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to create temp file")
		return
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	if _, err := io.Copy(tempFile, file); err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	// Extract text from PDF
	text, err := extractTextFromPDF(tempFile.Name())
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
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, "Invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to create temp file")
		return
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	if _, err := io.Copy(tempFile, file); err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	// Read the PDF context
	ctx, err := api.ReadContextFile(tempFile.Name())
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to read PDF: %v", err))
		return
	}

	// Extract form fields with debug info
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

	// Include debug info in response
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

func extractFields(ctx *model.Context) ([]FormField, map[string]interface{}, error) {
	var fields []FormField
	debugInfo := make(map[string]interface{})

	// Check if PDF has forms
	if ctx == nil {
		debugInfo["error"] = "context is nil"
		return fields, debugInfo, nil
	}

	if ctx.XRefTable == nil {
		debugInfo["error"] = "XRefTable is nil"
		return fields, debugInfo, nil
	}

	// Try to access the AcroForm
	rootDict, err := ctx.Catalog()
	if err != nil {
		debugInfo["catalog_error"] = err.Error()
		log.Printf("Warning: Could not get catalog: %v", err)
		return fields, debugInfo, nil
	}
	debugInfo["has_catalog"] = true

	// List all keys in the catalog for debugging
	catalogKeys := []string{}
	for key := range rootDict {
		catalogKeys = append(catalogKeys, key)
	}
	debugInfo["catalog_keys"] = catalogKeys

	acroFormObj, found := rootDict.Find("AcroForm")
	if !found {
		debugInfo["acroform_found"] = false

		// Check for XFA forms
		if xfaObj, xfaFound := rootDict.Find("XFA"); xfaFound {
			debugInfo["has_xfa"] = true
			debugInfo["xfa_type"] = fmt.Sprintf("%T", xfaObj)
			debugInfo["note"] = "This PDF uses XFA forms, not AcroForms. XFA extraction not yet supported."
		}

		// Check if there are annotations on pages that might be form fields
		if pagesObj, pagesFound := rootDict.Find("Pages"); pagesFound {
			debugInfo["has_pages"] = true
			if pagesDict, err := ctx.DereferenceDict(pagesObj); err == nil {
				if kidsObj, kidsFound := pagesDict.Find("Kids"); kidsFound {
					debugInfo["has_kids"] = true
					if kidsArray, err := ctx.DereferenceArray(kidsObj); err == nil {
						debugInfo["page_count"] = len(kidsArray)

						// Check first page for annotations
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

		return fields, debugInfo, nil
	}
	if acroFormObj == nil {
		debugInfo["acroform_obj"] = "nil"
		return fields, debugInfo, nil
	}
	debugInfo["acroform_found"] = true
	debugInfo["acroform_type"] = fmt.Sprintf("%T", acroFormObj)

	// Dereference if it's an indirect reference
	acroForm, err := ctx.DereferenceDict(acroFormObj)
	if err != nil {
		debugInfo["dereference_error"] = err.Error()
		log.Printf("Warning: Could not dereference AcroForm: %v", err)
		return fields, debugInfo, nil
	}
	debugInfo["acroform_dereferenced"] = true

	// List keys in AcroForm
	acroFormKeys := []string{}
	for key := range acroForm {
		acroFormKeys = append(acroFormKeys, key)
	}
	debugInfo["acroform_keys"] = acroFormKeys

	// Get the Fields array
	fieldsObj, found := acroForm.Find("Fields")
	if !found {
		debugInfo["fields_array_found"] = false
		return fields, debugInfo, nil
	}
	if fieldsObj == nil {
		debugInfo["fields_obj"] = "nil"
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

	// Process each field recursively
	for _, fieldRef := range fieldsArray {
		processField(ctx, fieldRef, "", &fields, debugInfo, 0)
	}

	debugInfo["fields_processed"] = len(fields)
	return fields, debugInfo, nil
}

func processField(ctx *model.Context, fieldRef types.Object, parentName string, fields *[]FormField, debugInfo map[string]interface{}, depth int) {
	fieldDict, err := ctx.DereferenceDict(fieldRef)
	if err != nil {
		log.Printf("Warning: Could not dereference field at depth %d: %v", depth, err)
		return
	}

	field := FormField{}

	// Get field name - convert to string
	if nameObj, found := fieldDict.Find("T"); found && nameObj != nil {
		rawName := fmt.Sprintf("%v", nameObj)
		// Clean up common formatting
		field.Name = cleanFieldName(rawName)

		// Build full name with parent path
		if parentName != "" {
			field.Name = parentName + "." + field.Name
		}
	}

	// Get field type - convert to string
	hasFieldType := false
	if ftObj, found := fieldDict.Find("FT"); found && ftObj != nil {
		field.Type = fmt.Sprintf("%v", ftObj)
		field.Type = strings.TrimPrefix(field.Type, "/")
		hasFieldType = true
	}

	// Get field value
	if vObj, found := fieldDict.Find("V"); found && vObj != nil {
		field.Value = fmt.Sprintf("%v", vObj)
		field.Value = strings.Trim(field.Value, "()")
	}

	// Get default value
	if dvObj, found := fieldDict.Find("DV"); found && dvObj != nil {
		field.DefaultValue = fmt.Sprintf("%v", dvObj)
		field.DefaultValue = strings.Trim(field.DefaultValue, "()")
	}

	// Get field flags
	if ffObj, found := fieldDict.Find("Ff"); found && ffObj != nil {
		// Try to parse as int
		if ffStr := fmt.Sprintf("%v", ffObj); ffStr != "" {
			fmt.Sscanf(ffStr, "%d", &field.Flags)
		}
	}

	// Get options for choice fields
	if optObj, found := fieldDict.Find("Opt"); found && optObj != nil {
		if optArray, err := ctx.DereferenceArray(optObj); err == nil {
			for _, opt := range optArray {
				optStr := fmt.Sprintf("%v", opt)
				optStr = strings.Trim(optStr, "()")
				field.Options = append(field.Options, optStr)
			}
		}
	}

	// Check for child fields (Kids array)
	if kidsObj, found := fieldDict.Find("Kids"); found && kidsObj != nil {
		if kidsArray, err := ctx.DereferenceArray(kidsObj); err == nil {
			// This field has children - process them recursively
			currentName := field.Name
			if currentName == "" {
				currentName = parentName
			}

			for _, kidRef := range kidsArray {
				processField(ctx, kidRef, currentName, fields, debugInfo, depth+1)
			}

			// Don't add parent fields that only contain kids and no field type
			if !hasFieldType {
				return
			}
		}
	}

	// Only add fields with names
	if field.Name != "" {
		*fields = append(*fields, field)
	}
}

func cleanFieldName(rawName string) string {
	// Remove parentheses
	rawName = strings.Trim(rawName, "()")

	// Check if it's hex-encoded UTF-16 (starts with <FEFF)
	if strings.HasPrefix(rawName, "<FEFF") || strings.HasPrefix(rawName, "<feff") {
		// Remove angle brackets
		rawName = strings.Trim(rawName, "<>")

		// Try to decode hex UTF-16
		if decoded := decodeHexUTF16(rawName); decoded != "" {
			return decoded
		}
	}

	return rawName
}

func decodeHexUTF16(hexStr string) string {
	// Remove FEFF BOM if present
	hexStr = strings.TrimPrefix(hexStr, "FEFF")
	hexStr = strings.TrimPrefix(hexStr, "feff")

	// Decode hex pairs into UTF-16 code units
	var result strings.Builder
	for i := 0; i < len(hexStr); i += 4 {
		if i+4 > len(hexStr) {
			break
		}

		hexPair := hexStr[i : i+4]
		var codeUnit uint16
		fmt.Sscanf(hexPair, "%04x", &codeUnit)

		if codeUnit > 0 {
			result.WriteRune(rune(codeUnit))
		}
	}

	return result.String()
}

func extractTextFromPDF(filepath string) (string, error) {
	// Create temp file for output
	outputFile, err := os.CreateTemp("", "pdftext-*.txt")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %w", err)
	}
	defer os.Remove(outputFile.Name())
	outputFile.Close()

	// Run pdftotext command: pdftotext input.pdf output.txt
	cmd := exec.Command("pdftotext", filepath, outputFile.Name())

	// Capture any errors
	var stderr strings.Builder
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("pdftotext failed: %w, stderr: %s", err, stderr.String())
	}

	// Read the extracted text
	textBytes, err := os.ReadFile(outputFile.Name())
	if err != nil {
		return "", fmt.Errorf("failed to read extracted text: %w", err)
	}

	return string(textBytes), nil
}

func scanForSSN(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, "Invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to create temp file")
		return
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	if _, err := io.Copy(tempFile, file); err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	// Extract text from PDF
	text, err := extractTextFromPDF(tempFile.Name())
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to extract text: %v", err))
		return
	}

	// Scan for SSN patterns
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

func findSSNs(text string) []map[string]interface{} {
	var results []map[string]interface{}

	// SSN patterns to match:
	// 123-45-6789
	// 123 45 6789
	// 123456789
	patterns := []*regexp.Regexp{
		regexp.MustCompile(`\b\d{3}-\d{2}-\d{4}\b`),     // 123-45-6789
		regexp.MustCompile(`\b\d{3}\s+\d{2}\s+\d{4}\b`), // 123 45 6789
		regexp.MustCompile(`\b\d{9}\b`),                 // 123456789 (9 consecutive digits)
	}

	for _, pattern := range patterns {
		matches := pattern.FindAllString(text, -1)
		for _, match := range matches {
			// Find context around the match (50 chars before and after)
			index := strings.Index(text, match)
			if index == -1 {
				continue
			}

			start := index - 50
			if start < 0 {
				start = 0
			}
			end := index + len(match) + 50
			if end > len(text) {
				end = len(text)
			}

			context := text[start:end]
			context = strings.ReplaceAll(context, "\n", " ")
			context = strings.TrimSpace(context)

			results = append(results, map[string]interface{}{
				"match":   match,
				"pattern": pattern.String(),
				"context": context,
			})
		}
	}

	return results
}

func searchTerms(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		respondError(w, http.StatusBadRequest, "Invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		respondError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	// Get the comma-separated terms
	termsParam := r.FormValue("terms")
	if termsParam == "" {
		respondError(w, http.StatusBadRequest, "No terms provided")
		return
	}

	tempFile, err := os.CreateTemp("", "pdf-*.pdf")
	if err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to create temp file")
		return
	}
	defer os.Remove(tempFile.Name())
	defer tempFile.Close()

	if _, err := io.Copy(tempFile, file); err != nil {
		respondError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	// Extract text from PDF
	text, err := extractTextFromPDF(tempFile.Name())
	if err != nil {
		respondError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to extract text: %v", err))
		return
	}

	// Parse terms (split by comma and trim whitespace)
	rawTerms := strings.Split(termsParam, ",")
	terms := make([]string, 0, len(rawTerms))
	for _, term := range rawTerms {
		trimmed := strings.TrimSpace(term)
		if trimmed != "" {
			terms = append(terms, trimmed)
		}
	}

	if len(terms) == 0 {
		respondError(w, http.StatusBadRequest, "No valid terms provided")
		return
	}

	// Search for each term (case-insensitive, spacing matters)
	results := searchForTerms(text, terms)

	// Calculate statistics
	termsFound := 0
	termBreakdown := make(map[string]int)

	for _, term := range terms {
		count := results[term]
		termBreakdown[term] = count
		if count > 0 {
			termsFound++
		}
	}

	percentage := (float64(termsFound) / float64(len(terms))) * 100

	respondJSON(w, http.StatusOK, Response{
		Success: true,
		Data: map[string]interface{}{
			"filename":         header.Filename,
			"total_terms":      len(terms),
			"terms_found":      termsFound,
			"terms_not_found":  len(terms) - termsFound,
			"match_percentage": fmt.Sprintf("%.2f%%", percentage),
			"term_breakdown":   termBreakdown,
		},
	})
}

func searchForTerms(text string, terms []string) map[string]int {
	results := make(map[string]int)

	// Convert text to lowercase for case-insensitive search
	lowerText := strings.ToLower(text)

	for _, term := range terms {
		// Convert term to lowercase for comparison
		lowerTerm := strings.ToLower(term)

		// Count occurrences (spacing matters, so we search for exact term)
		count := strings.Count(lowerText, lowerTerm)
		results[term] = count
	}

	return results
}

func respondJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
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
