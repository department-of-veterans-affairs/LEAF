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
        // Decode base64 with strict checking
        $decodedPath = base64_decode($encodedUrl, true);

        if ($decodedPath === false) {
            error_log("Security: Invalid base64 encoding");
            return $defaultRedirect;
        }

        // Length check
        if (strlen($decodedPath) > 2048) {
            error_log("Security: Path exceeds maximum length");
            return $defaultRedirect;
        }

        // Normalize the path to catch URL-encoded bypasses
        $normalizedPath = urldecode($decodedPath);

        // Check for double-encoding attacks
        if (urldecode($normalizedPath) !== $normalizedPath) {
            error_log("Security: Double-encoding detected");
            return $defaultRedirect;
        }

        // CRITICAL: Check dangerous patterns on BOTH original AND normalized paths
        $criticalPatterns = [
            '/https?:\/\//i',           // HTTP/HTTPS protocols
            '/ftp:\/\//i',              // FTP protocol
            '/file:\/\//i',             // File protocol
            '/javascript:/i',           // JavaScript protocol
            '/data:/i',                 // Data protocol
            '/vbscript:/i',             // VBScript protocol
            '/^\/\//m',                 // Protocol-relative URLs (//evil.com)
            '/\\\\/',                   // Backslashes
            '/@/',                      // At-sign
            '/<[a-z]+[^>]*>/i',        // HTML tags
            '/[\x00-\x1F]/',           // Control characters
            '/;.*https?:/i',           // Semicolon with protocol
        ];

        foreach ($criticalPatterns as $pattern) {
            if (preg_match($pattern, $decodedPath) || preg_match($pattern, $normalizedPath)) {
                error_log("Security: Critical pattern detected: " . $pattern);
                return $defaultRedirect;
            }
        }

        // Parse the URL (use original decoded path for parsing)
        $parsedUrl = parse_url($decodedPath);

        if ($parsedUrl === false) {
            error_log("Security: parse_url failed");
            return $defaultRedirect;
        }

        // Relative path validation (no host)
        if (empty($parsedUrl['host'])) {
            // STRICT validation: Must start with exactly one forward slash followed by non-slash
            if (!preg_match('#^/[^/\\\\]#', $decodedPath)) {
                error_log("Security: Invalid path format");
                return $defaultRedirect;
            }

            // ALLOWLIST: Only allow safe characters in the NORMALIZED path
            // This catches %2F (/) and other encoded dangerous chars
            if (!preg_match('/^\/[a-zA-Z0-9\/\-_.?=&#%+]*$/', $normalizedPath)) {
                error_log("Security: Disallowed characters in normalized path: " . $normalizedPath);
                return $defaultRedirect;
            }

            // Additional check: no backslashes in normalized path
            if (strpos($normalizedPath, '\\') !== false) {
                error_log("Security: Backslash detected in normalized path");
                return $defaultRedirect;
            }

            // Additional check: no @ signs in normalized path
            if (strpos($normalizedPath, '@') !== false) {
                error_log("Security: At-sign detected in normalized path");
                return $defaultRedirect;
            }

            return $protocol . $allowedHost . $decodedPath;
        }

        // Absolute URL - verify host matches
        if ($parsedUrl['host'] === $allowedHost) {
            // Validate scheme if present
            if (isset($parsedUrl['scheme']) && !in_array(strtolower($parsedUrl['scheme']), ['http', 'https'])) {
                error_log("Security: Invalid scheme: " . $parsedUrl['scheme']);
                return $defaultRedirect;
            }
            return $decodedPath;
        }

        // Host mismatch
        error_log("Security: Host mismatch: " . ($parsedUrl['host'] ?? 'unknown'));
        return $defaultRedirect;
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