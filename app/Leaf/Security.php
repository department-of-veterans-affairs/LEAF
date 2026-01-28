<?php

namespace App\Leaf;

/**
 * Security utility class for handling safe redirects and other security operations
 */
class Security
{
    /**
     * Validates and sanitizes a redirect URL to prevent open redirect vulnerabilities
     *
     * @param string $encodedUrl Base64-encoded URL to validate
     * @param string $allowedHost The allowed hostname (e.g., HTTP_HOST constant)
     * @param string $defaultRedirect Fallback redirect if validation fails
     * @param string $protocol Protocol to use (default: 'https://')
     * @return string Safe redirect URL
     */
    public static function validateRedirect(string $encodedUrl, string $allowedHost, string $defaultRedirect, string $protocol = 'https://'): string
    {
        $safeRedirect = $defaultRedirect;

        // Decode base64 with strict checking
        $decodedPath = base64_decode($encodedUrl, true);

        // If base64_decode fails, return default
        if ($decodedPath === false) {
            return $defaultRedirect;
        }

        // Normalize the path to catch URL-encoded bypasses
        // Do this BEFORE pattern checking to catch encoded malicious patterns
        $normalizedPath = urldecode($decodedPath);

        // Check for dangerous patterns in BOTH decoded and normalized versions
        // This catches both direct and URL-encoded attacks
        $dangerousPatterns = [
            // Protocol patterns (most critical)
            '/https?:\/\//i',           // HTTP/HTTPS protocols
            '/ftp:\/\//i',              // FTP protocol
            '/file:\/\//i',             // File protocol
            '/javascript:/i',           // JavaScript protocol
            '/data:/i',                 // Data protocol
            '/vbscript:/i',             // VBScript protocol
            '/about:/i',                // About protocol

            // Protocol-relative and slash-based bypasses (CRITICAL)
            '/^\/\//m',                 // Protocol-relative URLs (//evil.com)
            '/\/\//m',                  // Double slashes anywhere
            '/\\\\/',                   // Backslashes (UNC paths, Windows-style)
            '/\\\//',                   // Backslash-slash combinations
            '/\/\\/',                   // Slash-backslash combinations

            // At-sign bypass (credentials in URL)
            '/@/',                      // At-sign anywhere in path

            // HTML/XML tags
            '/<[a-z]+[^>]*>/i',        // Any HTML opening tag
            '/<\/[a-z]+>/i',           // Any HTML closing tag
            '/<br\s*\/?>/i',           // Break tags specifically
            '/<script/i',              // Script tags

            // Whitespace and control characters
            '/\r/',                     // Carriage return
            '/\n/',                     // Newline
            '/\t/',                     // Tab
            '/\x00/',                   // Null byte
            '/\x0b/',                   // Vertical tab
            '/\x0c/',                   // Form feed

            // Semicolon parameter pollution
            '/;.*https?:/i',           // Semicolon followed by protocol
            '/;.*\/\//i',              // Semicolon followed by double slash

            // Unicode/special characters that could be used for obfuscation
            '/[\x{FFF0}-\x{FFFF}]/u',  // Unicode specials
            '/[\x{200B}-\x{200D}]/u',  // Zero-width characters
            '/[\x{202A}-\x{202E}]/u',  // Bidirectional text controls
        ];

        // Check both original decoded and normalized paths
        foreach ($dangerousPatterns as $pattern) {
            if (preg_match($pattern, $decodedPath) || preg_match($pattern, $normalizedPath)) {
                error_log("Security: Blocked redirect containing dangerous pattern: " . $pattern);
                return $defaultRedirect;
            }
        }

        // Additional check: if normalization changed the path significantly, reject it
        // This catches double-encoding attacks
        if (urldecode($normalizedPath) !== $normalizedPath) {
            error_log("Security: Blocked redirect with double-encoding detected");
            return $defaultRedirect;
        }

        // Parse the URL
        $parsedUrl = parse_url($decodedPath);

        // If parse_url fails, return default
        if ($parsedUrl === false) {
            error_log("Security: parse_url failed on: " . substr($decodedPath, 0, 100));
            return $defaultRedirect;
        }

        // Check if it's a relative path (no host)
        if (empty($parsedUrl['host'])) {
            // STRICT relative path validation
            // Must start with exactly one forward slash followed by a non-slash character
            // This blocks: //evil.com, ///evil.com, /\evil.com, etc.
            if (preg_match('#^/[^/\\\\]#', $decodedPath)) {
                // Additional validation: ensure no backslashes anywhere
                if (strpos($decodedPath, '\\') !== false) {
                    error_log("Security: Blocked redirect containing backslash");
                    return $defaultRedirect;
                }

                // Additional validation: ensure no @ signs
                if (strpos($decodedPath, '@') !== false) {
                    error_log("Security: Blocked redirect containing @ sign");
                    return $defaultRedirect;
                }

                // Path is safe - construct full URL
                $safeRedirect = $protocol . $allowedHost . $decodedPath;
            } else {
                error_log("Security: Blocked redirect with invalid path format: " . substr($decodedPath, 0, 100));
                return $defaultRedirect;
            }
        }
        // Has a host - verify it matches our allowed host
        elseif ($parsedUrl['host'] === $allowedHost) {
            // Host matches - but still validate the scheme if present
            if (isset($parsedUrl['scheme']) && !in_array(strtolower($parsedUrl['scheme']), ['http', 'https'])) {
                error_log("Security: Blocked redirect with invalid scheme: " . $parsedUrl['scheme']);
                return $defaultRedirect;
            }
            $safeRedirect = $decodedPath;
        }
        // Host doesn't match - reject
        else {
            error_log("Security: Blocked redirect to different host: " . ($parsedUrl['host'] ?? 'unknown'));
            return $defaultRedirect;
        }

        return $safeRedirect;
    }

    /**
     * Get a safe redirect URL from the 'r' query parameter
     *
     * @param string $allowedHost The allowed hostname (e.g., HTTP_HOST constant)
     * @param string $defaultRedirect Fallback redirect if no valid 'r' parameter
     * @param string $protocol Protocol to use (default: 'https://')
     * @return string Safe redirect URL
     */
    public static function getSafeRedirectFromRequest(string $allowedHost, string $defaultRedirect, string $protocol = 'https://'): string
    {
        $redirect = $defaultRedirect;

        if (isset($_GET['r']) && !empty($_GET['r'])) {
            $redirect = self::validateRedirect($_GET['r'], $allowedHost, $defaultRedirect, $protocol);
        }

        return $redirect;
    }

    /**
     * Decrypt the encrypted user token from cookie
     *
     * @param string $src Encrypted user token
     * @param string $cipherKey The cipher key constant used for decryption
     * @return string Decrypted username
     */
    public static function decryptUser($src, $cipherKey)
    {
        $corrected = preg_replace("[^0-9a-fA-F]", "", $src);
        $cryptedToken = pack("H" . strlen($corrected), $corrected);

        list($cryptedToken, $encIv) = explode("::", $cryptedToken);

        $cipherMethod = 'aes-128-ctr';
        $encKey = openssl_digest($cipherKey, 'SHA256', true);
        $token = openssl_decrypt($cryptedToken, $cipherMethod, $encKey, 0, hex2bin($encIv));

        unset($cryptedToken, $cipherMethod, $encKey, $encIv);

        return $token;
    }
}