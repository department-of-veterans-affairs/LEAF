# PDF Parser API Documentation

A Go-based microservice for parsing and analyzing PDF files.

**Base URL:** `http://pdf-parser:9000` (Docker internal) or `http://localhost:9000` (local)

**Version:** 1.0.0

---

## Table of Contents

- [Health Check](#health-check)
- [Parse PDF](#parse-pdf)
- [Get PDF Info](#get-pdf-info)
- [Extract Text](#extract-text)
- [Extract Form Fields](#extract-form-fields)
- [Scan for SSNs](#scan-for-ssns)
- [Search Terms](#search-terms)
- [Error Handling](#error-handling)
- [PHP Examples](#php-examples)

---

## Health Check

Check if the service is running and healthy.

### Endpoint
```
GET /health
```

### Request
No parameters required.

### Response
```json
{
  "success": true,
  "message": "PDF Parser Service is healthy",
  "data": {
    "status": "up",
    "service": "pdf-parser",
    "version": "1.0.0"
  }
}
```

### Example
```bash
curl http://localhost:9000/health
```

---

## Parse PDF

Extract basic information from a PDF including page count and metadata.

### Endpoint
```
POST /api/parse
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file to parse |

### Response
```json
{
  "success": true,
  "message": "PDF parsed successfully",
  "data": {
    "filename": "document.pdf",
    "pages": 5,
    "metadata": {},
    "parsed_at": "2025-10-07T18:25:48.730570077Z"
  }
}
```

### Example
```bash
curl -X POST http://localhost:9000/api/parse \
  -F "file=@document.pdf"
```

---

## Get PDF Info

Get basic information about a PDF (page count).

### Endpoint
```
POST /api/info
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file |

### Response
```json
{
  "success": true,
  "data": {
    "filename": "document.pdf",
    "pages": 5
  }
}
```

### Example
```bash
curl -X POST http://localhost:9000/api/info \
  -F "file=@document.pdf"
```

---

## Extract Text

Extract all text content from a PDF using `pdftotext`.

### Endpoint
```
POST /api/extract-text
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file |

### Response
```json
{
  "success": true,
  "data": {
    "filename": "document.pdf",
    "text": "Full text content from the PDF...\n\nIncluding all pages..."
  }
}
```

### Example
```bash
curl -X POST http://localhost:9000/api/extract-text \
  -F "file=@document.pdf"
```

---

## Extract Form Fields

Extract form fields from fillable PDFs (AcroForms).

### Endpoint
```
POST /api/extract-form-fields
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file with form fields |

### Response
```json
{
  "success": true,
  "message": "Found 23 form fields",
  "data": {
    "result": {
      "filename": "form.pdf",
      "has_form": true,
      "field_count": 23,
      "fields": [
        {
          "name": "topmostSubform[0].Page1[0].f1_1[0]",
          "type": "Tx",
          "value": "",
          "flags": 0
        }
      ],
      "parsed_at": "2025-10-07T18:38:59.22567346Z"
    },
    "debug": {
      "acroform_found": true,
      "fields_processed": 23
    }
  }
}
```

### Field Types
- `Tx` - Text field
- `Btn` - Button/Checkbox/Radio button
- `Ch` - Choice field (dropdown/listbox)
- `Sig` - Signature field

### Example
```bash
curl -X POST http://localhost:9000/api/extract-form-fields \
  -F "file=@form.pdf"
```

### Notes
- Returns empty fields array if PDF has no form fields
- Includes debug information about form structure
- Handles nested/hierarchical form fields

---

## Scan for SSNs

Scan PDF text for Social Security Numbers in various formats.

### Endpoint
```
POST /api/scan-for-ssn
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file to scan |

### Detected Patterns
- `123-45-6789` (with dashes)
- `123 45 6789` (with spaces)
- `123456789` (9 consecutive digits)

### Response
```json
{
  "success": true,
  "data": {
    "filename": "document.pdf",
    "contains_ssn": true,
    "ssn_count": 2,
    "ssn_locations": [
      {
        "match": "123-45-6789",
        "pattern": "\\b\\d{3}-\\d{2}-\\d{4}\\b",
        "context": "...applicant's social security number 123-45-6789 as shown on..."
      }
    ]
  }
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `contains_ssn` | Boolean | True if any SSNs found |
| `ssn_count` | Integer | Number of SSNs detected |
| `ssn_locations` | Array | Array of matches with context |
| `match` | String | The matched SSN |
| `pattern` | String | Regex pattern that matched |
| `context` | String | ~50 characters before/after match |

### Example
```bash
curl -X POST http://localhost:9000/api/scan-for-ssn \
  -F "file=@document.pdf"
```

### Use Case
Flag documents containing SSNs for privacy review before storage.

---

## Search Terms

Search for specific terms in a PDF and get match statistics.

### Endpoint
```
POST /api/search-terms
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | PDF file to search |
| `terms` | String | Yes | Comma-separated search terms |

### Search Behavior
- **Case-insensitive**: "Social Security" matches "social security"
- **Spacing matters**: "john smith" won't match "johnsmith"
- **Counts all occurrences**: Each term counted separately

### Response
```json
{
  "success": true,
  "data": {
    "filename": "document.pdf",
    "total_terms": 4,
    "terms_found": 3,
    "terms_not_found": 1,
    "match_percentage": "75.00%",
    "term_breakdown": {
      "social security": 5,
      "address": 3,
      "john smith": 2,
      "date of birth": 0
    }
  }
}
```

### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `total_terms` | Integer | Total number of search terms |
| `terms_found` | Integer | How many terms were found (at least once) |
| `terms_not_found` | Integer | How many terms were not found |
| `match_percentage` | String | Percentage of terms found |
| `term_breakdown` | Object | Count of occurrences for each term |

### Example
```bash
curl -X POST http://localhost:9000/api/search-terms \
  -F "file=@document.pdf" \
  -F "terms=social security,address,john smith,date of birth"
```

### Use Cases
- Verify required information is present in documents
- Content validation for compliance
- Document classification

---

## Error Handling

All endpoints return consistent error responses.

### Error Response Format
```json
{
  "success": false,
  "error": "Error message describing what went wrong"
}
```

### HTTP Status Codes
| Code | Meaning | Common Causes |
|------|---------|---------------|
| 200 | Success | Request completed successfully |
| 400 | Bad Request | Missing file, invalid file type, missing parameters |
| 500 | Internal Server Error | PDF processing failed, service error |

### Common Errors

**No file provided:**
```json
{
  "success": false,
  "error": "no file provided"
}
```

**Invalid file type:**
```json
{
  "success": false,
  "error": "file must be a PDF"
}
```

**File too large:**
```json
{
  "success": false,
  "error": "file too large or invalid form data"
}
```

**Processing failed:**
```json
{
  "success": false,
  "error": "Failed to extract text: pdftotext failed: ..."
}
```

---

## PHP Examples

### Basic Client Class

```php
<?php
class PDFParserClient {
    private $baseUrl;
    private $timeout;
    
    public function __construct($baseUrl = 'http://pdf-parser:9000/api', $timeout = 30) {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->timeout = $timeout;
    }
    
    public function extractText($filePath) {
        return $this->makeRequest('/extract-text', ['file' => $filePath]);
    }
    
    public function scanForSSN($filePath) {
        return $this->makeRequest('/scan-for-ssn', ['file' => $filePath]);
    }
    
    public function searchTerms($filePath, $terms) {
        return $this->makeRequest('/search-terms', [
            'file' => $filePath,
            'terms' => $terms
        ]);
    }
    
    public function extractFormFields($filePath) {
        return $this->makeRequest('/extract-form-fields', ['file' => $filePath]);
    }
    
    public function getPDFInfo($filePath) {
        return $this->makeRequest('/info', ['file' => $filePath]);
    }
    
    private function makeRequest($endpoint, $params) {
        $ch = curl_init($this->baseUrl . $endpoint);
        
        $postFields = [];
        foreach ($params as $key => $value) {
            if ($key === 'file') {
                $postFields[$key] = new CURLFile($value, 'application/pdf', basename($value));
            } else {
                $postFields[$key] = $value;
            }
        }
        
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $postFields,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => $this->timeout
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode !== 200) {
            throw new Exception("API request failed: HTTP $httpCode - $response");
        }
        
        return json_decode($response, true);
    }
}
?>
```

### Usage Examples

```php
<?php
// Initialize client
$client = new PDFParserClient();

// Check for SSNs
$result = $client->scanForSSN('/path/to/document.pdf');
if ($result['data']['contains_ssn']) {
    echo "WARNING: Document contains {$result['data']['ssn_count']} SSN(s)!\n";
    // Flag for review
}

// Search for required terms
$searchResult = $client->searchTerms(
    '/path/to/document.pdf',
    'signature,date,social security number'
);
echo "Match rate: {$searchResult['data']['match_percentage']}\n";

// Extract all text
$textResult = $client->extractText('/path/to/document.pdf');
$fullText = $textResult['data']['text'];

// Get form fields
$formResult = $client->extractFormFields('/path/to/form.pdf');
if ($formResult['data']['result']['has_form']) {
    foreach ($formResult['data']['result']['fields'] as $field) {
        echo "{$field['name']}: {$field['value']}\n";
    }
}
?>
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVICE_PORT` | `9000` | Port the service listens on |
| `MAX_FILE_SIZE` | `52428800` | Max upload size in bytes (50MB) |

### Limits

- **Max file size:** 50MB
- **Timeout:** 30 seconds per request
- **Supported formats:** PDF only
- **Text extraction:** Uses `pdftotext` (poppler-utils)

---

## Technical Notes

### Dependencies
- **pdfcpu** - Pure Go PDF library
- **poppler-utils** - Provides `pdftotext` command
- Go 1.22+ (for enhanced routing)

### Performance
- Typical processing time: <1 second for most PDFs
- Concurrent request handling via Go goroutines
- No persistent storage - stateless service

### Limitations
- Form field extraction only works with AcroForms (not XFA forms)
- Flattened PDFs (print-to-PDF) have no extractable form fields
- Text extraction quality depends on PDF structure
- SSN detection uses pattern matching (may have false positives)

---

## Integration Checklist

- [ ] Service is running and accessible
- [ ] Test `/health` endpoint
- [ ] Verify file uploads work (test with small PDF)
- [ ] Test SSN detection with sample document
- [ ] Verify text extraction quality
- [ ] Test form field extraction with fillable PDF
- [ ] Implement error handling in your application
- [ ] Set appropriate timeouts for your use case
- [ ] Consider file size limits for your needs

---

## Support

For issues or questions:
1. Check service logs: `docker compose logs pdf-parser`
2. Verify service is running: `docker compose ps pdf-parser`
3. Test with curl to isolate issues
4. Check file permissions and paths

---

**Last Updated:** October 2025
**API Version:** 1.0.0