<?php
/**
 * PDF Parser Service Client
 * Communicates with the Go-based PDF parsing microservice
 */
class PDFParserService {
    private $baseUrl = 'http://pdf-parser:9000/api';
    private $timeout = 30;
    
    /**
     * Check if the PDF parser service is healthy
     */
    public function healthCheck() {
        $ch = curl_init('http://pdf-parser:9000/health');
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 5
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        return [
            'status' => $httpCode === 200,
            'response' => json_decode($response, true)
        ];
    }
    
    /**
     * Parse PDF - extracts text, metadata, and basic info
     */
    public function parsePDF($filePath) {
        return $this->makeRequest('/parse', $filePath);
    }
    
    /**
     * Extract only text content from PDF
     */
    public function extractText($filePath) {
        return $this->makeRequest('/extract-text', $filePath);
    }
    
    /**
     * Get PDF metadata (author, title, dates, etc.)
     */
    public function getMetadata($filePath) {
        return $this->makeRequest('/metadata', $filePath);
    }
    
    /**
     * Get PDF information (pages, version, permissions, encryption)
     */
    public function getPDFInfo($filePath) {
        return $this->makeRequest('/info', $filePath);
    }
    
    /**
     * Extract form fields from fillable PDF (AcroForms)
     * Returns field names, types, values, and options
     */
    public function extractFormFields($filePath) {
        return $this->makeRequest('/extract-form-fields', $filePath);
    }
    
    /**
     * Fill PDF form with provided data
     * Returns filled PDF as binary data
     * 
     * @param string $filePath Path to PDF file
     * @param array $formData Associative array of field_name => value
     * @return array|false Binary PDF data or false on error
     */
    public function fillForm($filePath, $formData) {
        if (!file_exists($filePath)) {
            throw new Exception("File not found: $filePath");
        }
        
        $ch = curl_init($this->baseUrl . '/fill-form');
        
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => [
                'file' => new CURLFile($filePath, 'application/pdf', basename($filePath)),
                'data' => json_encode($formData)
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => $this->timeout
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
        curl_close($ch);
        
        if ($httpCode !== 200) {
            throw new Exception("PDF form filling failed: " . $response);
        }
        
        // If response is PDF, return binary data
        if (strpos($contentType, 'application/pdf') !== false) {
            return [
                'success' => true,
                'content_type' => 'application/pdf',
                'data' => $response
            ];
        }
        
        // Otherwise return JSON response
        return json_decode($response, true);
    }
    
    /**
     * Save filled PDF form to file
     */
    public function fillFormAndSave($inputPath, $outputPath, $formData) {
        $result = $this->fillForm($inputPath, $formData);
        
        if ($result['success'] && $result['content_type'] === 'application/pdf') {
            return file_put_contents($outputPath, $result['data']) !== false;
        }
        
        return false;
    }
    
    /**
     * Private helper to make requests
     */
    private function makeRequest($endpoint, $filePath) {
        if (!file_exists($filePath)) {
            throw new Exception("File not found: $filePath");
        }
        
        $ch = curl_init($this->baseUrl . $endpoint);
        
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => [
                'file' => new CURLFile($filePath, 'application/pdf', basename($filePath))
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => $this->timeout
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode !== 200) {
            throw new Exception("Request failed: " . $response);
        }
        
        return json_decode($response, true);
    }
}

// ============================================
// USAGE EXAMPLES
// ============================================

try {
    $parser = new PDFParserService();
    
    // Example 1: Check service health
    echo "=== Health Check ===\n";
    $health = $parser->healthCheck();
    print_r($health);
    echo "\n\n";
    
    // Example 2: Parse complete PDF
    echo "=== Parse PDF ===\n";
    $result = $parser->parsePDF('/path/to/document.pdf');
    echo "Filename: " . $result['data']['filename'] . "\n";
    echo "Pages: " . $result['data']['pages'] . "\n";
    echo "First page preview: " . substr($result['data']['content'][0], 0, 200) . "...\n\n";
    
    // Example 3: Extract just text
    echo "=== Extract Text ===\n";
    $textResult = $parser->extractText('/path/to/document.pdf');
    foreach ($textResult['data']['text'] as $pageNum => $text) {
        echo "Page " . ($pageNum + 1) . " length: " . strlen($text) . " chars\n";
    }
    echo "\n";
    
    // Example 4: Get metadata
    echo "=== Get Metadata ===\n";
    $metadata = $parser->getMetadata('/path/to/document.pdf');
    print_r($metadata['data']['metadata']);
    echo "\n";
    
    // Example 5: Get PDF info
    echo "=== PDF Info ===\n";
    $info = $parser->getPDFInfo('/path/to/document.pdf');
    echo "Pages: " . $info['data']['pages'] . "\n";
    echo "Version: " . $info['data']['version'] . "\n";
    echo "Encrypted: " . ($info['data']['encrypted'] ? 'Yes' : 'No') . "\n";
    print_r($info['data']['permissions']);
    echo "\n";
    
    // Example 6: Extract form fields from fillable PDF
    echo "=== Extract Form Fields ===\n";
    $formFields = $parser->extractFormFields('/path/to/fillable-form.pdf');
    
    if ($formFields['data']['has_form']) {
        echo "Found " . $formFields['data']['field_count'] . " form fields:\n";
        
        foreach ($formFields['data']['fields'] as $field) {
            echo "\nField: " . $field['name'] . "\n";
            echo "  Type: " . $field['type'] . "\n";
            echo "  Value: " . ($field['value'] ?? 'empty') . "\n";
            echo "  Required: " . ($field['required'] ? 'Yes' : 'No') . "\n";
            echo "  Read-only: " . ($field['read_only'] ? 'Yes' : 'No') . "\n";
            
            if (!empty($field['options'])) {
                echo "  Options: " . implode(', ', $field['options']) . "\n";
            }
        }
    } else {
        echo "This PDF does not contain form fields.\n";
    }
    echo "\n";
    
    // Example 7: Fill PDF form
    echo "=== Fill Form ===\n";
    $formData = [
        'firstName' => 'John',
        'lastName' => 'Doe',
        'email' => 'john.doe@example.com',
        'agreeToTerms' => true,
        'country' => 'USA'
    ];
    
    $success = $parser->fillFormAndSave(
        '/path/to/fillable-form.pdf',
        '/path/to/filled-form.pdf',
        $formData
    );
    
    if ($success) {
        echo "Form filled successfully and saved!\n";
    } else {
        echo "Failed to fill form.\n";
    }
    
    // Example 8: Fill form and return to browser
    $filledPDF = $parser->fillForm('/path/to/fillable-form.pdf', $formData);
    
    if ($filledPDF['success']) {
        // Set headers for PDF download
        header('Content-Type: application/pdf');
        header('Content-Disposition: attachment; filename="filled_form.pdf"');
        echo $filledPDF['data'];
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>