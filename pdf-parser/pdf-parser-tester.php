<?php
/**
 * PDF Analyzer Test Page
 * Tests the PDF Parser Service endpoints
 */

$pdfParserUrl = 'http://pdf-parser:9000/api';
$results = null;
$error = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['pdf_file'])) {
    $pdfFile = $_FILES['pdf_file'];
    $searchTerms = $_POST['search_terms'] ?? '';
    
    // Validate file
    if ($pdfFile['error'] !== UPLOAD_ERR_OK) {
        $error = "File upload error: " . $pdfFile['error'];
    } elseif ($pdfFile['type'] !== 'application/pdf' && !str_ends_with($pdfFile['name'], '.pdf')) {
        $error = "Please upload a PDF file";
    } else {
        try {
            // Call all three endpoints
            $results = [
                'ssn' => checkForSSN($pdfParserUrl, $pdfFile['tmp_name']),
                'search' => searchTerms($pdfParserUrl, $pdfFile['tmp_name'], $searchTerms),
                'text' => extractText($pdfParserUrl, $pdfFile['tmp_name']),
                'filename' => htmlspecialchars($pdfFile['name'])
            ];
        } catch (Exception $e) {
            $error = "Error: " . $e->getMessage();
        }
    }
}

function checkForSSN($baseUrl, $filePath) {
    $ch = curl_init($baseUrl . '/scan-for-ssn');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => [
            'file' => new CURLFile($filePath, 'application/pdf', 'upload.pdf')
        ],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode !== 200) {
        throw new Exception("SSN scan failed: HTTP $httpCode");
    }
    
    return json_decode($response, true);
}

function searchTerms($baseUrl, $filePath, $terms) {
    if (empty(trim($terms))) {
        return null; // Skip if no terms provided
    }
    
    $ch = curl_init($baseUrl . '/search-terms');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => [
            'file' => new CURLFile($filePath, 'application/pdf', 'upload.pdf'),
            'terms' => $terms
        ],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode !== 200) {
        throw new Exception("Term search failed: HTTP $httpCode");
    }
    
    return json_decode($response, true);
}

function extractText($baseUrl, $filePath) {
    $ch = curl_init($baseUrl . '/extract-text');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => [
            'file' => new CURLFile($filePath, 'application/pdf', 'upload.pdf')
        ],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode !== 200) {
        throw new Exception("Text extraction failed: HTTP $httpCode");
    }
    
    return json_decode($response, true);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PDF Analyzer - Test Tool</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        h1 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #666;
            margin-bottom: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #333;
        }
        
        input[type="file"],
        input[type="text"] {
            width: 100%;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        input[type="file"]:focus,
        input[type="text"]:focus {
            outline: none;
            border-color: #4CAF50;
        }
        
        .help-text {
            font-size: 13px;
            color: #666;
            margin-top: 5px;
        }
        
        button {
            background: #4CAF50;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        button:hover {
            background: #45a049;
        }
        
        .error {
            background: #f44336;
            color: white;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .results {
            margin-top: 30px;
        }
        
        .result-section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background: #fafafa;
        }
        
        .result-section h2 {
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #4CAF50;
        }
        
        .alert {
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 15px;
        }
        
        .alert-danger {
            background: #ffebee;
            color: #c62828;
            border-left: 4px solid #c62828;
        }
        
        .alert-success {
            background: #e8f5e9;
            color: #2e7d32;
            border-left: 4px solid #2e7d32;
        }
        
        .ssn-match {
            background: white;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 4px;
            border-left: 4px solid #f44336;
        }
        
        .ssn-match strong {
            color: #f44336;
        }
        
        .context {
            font-family: monospace;
            font-size: 13px;
            background: #f5f5f5;
            padding: 10px;
            margin-top: 8px;
            border-radius: 3px;
            overflow-x: auto;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: white;
            padding: 15px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        
        .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: #4CAF50;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .term-item {
            display: flex;
            justify-content: space-between;
            padding: 10px;
            background: white;
            margin-bottom: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        
        .term-name {
            font-weight: 600;
        }
        
        .term-count {
            color: #4CAF50;
            font-weight: bold;
        }
        
        .term-count.zero {
            color: #999;
        }
        
        .text-content {
            background: white;
            padding: 20px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 13px;
            line-height: 1.8;
            white-space: pre-wrap;
            max-height: 500px;
            overflow-y: auto;
            border: 1px solid #ddd;
        }
        
        .filename {
            background: #e3f2fd;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📄 PDF Analyzer</h1>
        <p class="subtitle">Upload a PDF to scan for SSNs, search for terms, and extract text</p>
        
        <?php if ($error): ?>
            <div class="error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>
        
        <form method="POST" enctype="multipart/form-data">
            <div class="form-group">
                <label for="pdf_file">PDF File</label>
                <input type="file" name="pdf_file" id="pdf_file" accept=".pdf,application/pdf" required>
                <div class="help-text">Select a PDF file to analyze (max 50MB)</div>
            </div>
            
            <div class="form-group">
                <label for="search_terms">Search Terms (optional)</label>
                <input type="text" name="search_terms" id="search_terms" placeholder="e.g. social security, john smith, address">
                <div class="help-text">Enter comma-separated words or phrases to search for (case-insensitive)</div>
            </div>
            
            <button type="submit">Analyze PDF</button>
        </form>
        
        <?php if ($results): ?>
            <div class="results">
                <div class="filename">
                    📁 Analyzing: <?= $results['filename'] ?>
                </div>
                
                <!-- SSN Results -->
                <div class="result-section">
                    <h2>🔒 SSN Detection</h2>
                    <?php if ($results['ssn']['success']): ?>
                        <?php if ($results['ssn']['data']['contains_ssn']): ?>
                            <div class="alert alert-danger">
                                <strong>⚠️ WARNING:</strong> Found <?= $results['ssn']['data']['ssn_count'] ?> potential SSN(s) in this document!
                            </div>
                            
                            <?php foreach ($results['ssn']['data']['ssn_locations'] as $match): ?>
                                <div class="ssn-match">
                                    <strong>Match:</strong> <?= htmlspecialchars($match['match']) ?>
                                    <div class="context"><?= htmlspecialchars($match['context']) ?></div>
                                </div>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <div class="alert alert-success">
                                ✅ No SSNs detected in this document
                            </div>
                        <?php endif; ?>
                    <?php else: ?>
                        <div class="alert alert-danger">Error scanning for SSNs</div>
                    <?php endif; ?>
                </div>
                
                <!-- Search Results -->
                <?php if ($results['search']): ?>
                    <div class="result-section">
                        <h2>🔍 Term Search Results</h2>
                        <?php if ($results['search']['success']): ?>
                            <div class="stats">
                                <div class="stat-card">
                                    <div class="stat-value"><?= $results['search']['data']['match_percentage'] ?></div>
                                    <div class="stat-label">Match Rate</div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-value"><?= $results['search']['data']['terms_found'] ?></div>
                                    <div class="stat-label">Terms Found</div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-value"><?= $results['search']['data']['total_terms'] ?></div>
                                    <div class="stat-label">Total Terms</div>
                                </div>
                            </div>
                            
                            <h3 style="margin-bottom: 10px;">Term Breakdown:</h3>
                            <?php foreach ($results['search']['data']['term_breakdown'] as $term => $count): ?>
                                <div class="term-item">
                                    <span class="term-name"><?= htmlspecialchars($term) ?></span>
                                    <span class="term-count <?= $count === 0 ? 'zero' : '' ?>">
                                        <?= $count ?> occurrence<?= $count !== 1 ? 's' : '' ?>
                                    </span>
                                </div>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <div class="alert alert-danger">Error performing term search</div>
                        <?php endif; ?>
                    </div>
                <?php endif; ?>
                
                <!-- Full Text -->
                <div class="result-section">
                    <h2>📝 Extracted Text</h2>
                    <?php if ($results['text']['success']): ?>
                        <div class="text-content"><?= htmlspecialchars($results['text']['data']['text']) ?></div>
                    <?php else: ?>
                        <div class="alert alert-danger">Error extracting text</div>
                    <?php endif; ?>
                </div>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>