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

    /**
     * Manually parse PHP serialized data without using unserialize()
     * Only supports arrays and scalar values (no objects)
     *
     * @param string $data The serialized data
     * @return mixed The parsed data
     * @throws \InvalidArgumentException if data contains objects or is malformed
     */
    public static function parseSerializedData(string $data)
    {
        if (empty($data)) {
            throw new \InvalidArgumentException('Empty serialized data');
        }

        // Check for forbidden object patterns
        if (preg_match('/[OC]:\d+:"/', $data)) {
            throw new \InvalidArgumentException('Serialized data contains objects - not allowed');
        }

        $parser = new SerializedDataParser($data);
        return $parser->parse();
    }
}

/**
 * Internal parser class for safe deserialization
 * Only handles arrays and scalar values - no object instantiation
 * @internal
 * @psalm-internal App\Leaf
 */
final class SerializedDataParser
{
    private $data;
    private $pos = 0;
    private $length;

    public function __construct($data)
    {
        $this->data = $data;
        $this->length = strlen($data);
    }

    public function parse()
    {
        $result = $this->parseValue();

        // Ensure we consumed all the data
        if ($this->pos < $this->length) {
            throw new \InvalidArgumentException('Unexpected data after end of serialized value');
        }

        return $result;
    }

    private function parseValue()
    {
        if ($this->pos >= $this->length) {
            throw new \InvalidArgumentException('Unexpected end of data');
        }

        $type = $this->data[$this->pos];
        $this->pos++; // Move past type character

        switch ($type) {
            case 'N': // null
                return $this->parseNull();
            case 'b': // boolean
                return $this->parseBoolean();
            case 'i': // integer
                return $this->parseInteger();
            case 'd': // double/float
                return $this->parseDouble();
            case 's': // string
                return $this->parseString();
            case 'a': // array
                return $this->parseArray();
            case 'O': // object (forbidden)
            case 'C': // custom object (forbidden)
                throw new \InvalidArgumentException('Objects are not allowed');
            default:
                throw new \InvalidArgumentException("Unknown type: $type");
        }
    }

    private function parseNull()
    {
        $this->expect(';');
        return null;
    }

    private function parseBoolean()
    {
        $this->expect(':');
        $value = $this->data[$this->pos];
        $this->pos++;
        $this->expect(';');

        if ($value === '0') {
            return false;
        } elseif ($value === '1') {
            return true;
        } else {
            throw new \InvalidArgumentException('Invalid boolean value');
        }
    }

    private function parseInteger()
    {
        $this->expect(':');
        $value = $this->readUntil(';');

        if (!is_numeric($value)) {
            throw new \InvalidArgumentException('Invalid integer value');
        }

        return (int)$value;
    }

    private function parseDouble()
    {
        $this->expect(':');
        $value = $this->readUntil(';');

        if ($value === 'NAN') {
            return NAN;
        } elseif ($value === 'INF') {
            return INF;
        } elseif ($value === '-INF') {
            return -INF;
        }

        if (!is_numeric($value)) {
            throw new \InvalidArgumentException('Invalid double value');
        }

        return (float)$value;
    }

    private function parseString()
    {
        $this->expect(':');
        $length = (int)$this->readUntil(':');

        if ($length < 0) {
            throw new \InvalidArgumentException('Invalid string length');
        }

        $this->expect('"');

        // Read exactly $length bytes
        if ($this->pos + $length > $this->length) {
            throw new \InvalidArgumentException('String length exceeds data length');
        }

        $value = substr($this->data, $this->pos, $length);
        $this->pos += $length;

        $this->expect('"');
        $this->expect(';');

        return $value;
    }

    private function parseArray()
    {
        $this->expect(':');
        $count = (int)$this->readUntil(':');

        if ($count < 0) {
            throw new \InvalidArgumentException('Invalid array count');
        }

        $this->expect('{');

        $array = [];

        for ($i = 0; $i < $count; $i++) {
            // Parse key
            $key = $this->parseValue();

            // Keys must be string or integer
            if (!is_string($key) && !is_int($key)) {
                throw new \InvalidArgumentException('Array keys must be strings or integers');
            }

            // Parse value
            $value = $this->parseValue();

            $array[$key] = $value;
        }

        $this->expect('}');

        return $array;
    }

    private function expect($char)
    {
        if ($this->pos >= $this->length || $this->data[$this->pos] !== $char) {
            $found = $this->pos >= $this->length ? 'EOF' : $this->data[$this->pos];
            throw new \InvalidArgumentException("Expected '$char' but found '$found' at position {$this->pos}");
        }
        $this->pos++;
    }

    private function readUntil($delimiter)
    {
        $start = $this->pos;

        while ($this->pos < $this->length && $this->data[$this->pos] !== $delimiter) {
            $this->pos++;
        }

        if ($this->pos >= $this->length) {
            throw new \InvalidArgumentException("Unexpected end while looking for '$delimiter'");
        }

        $value = substr($this->data, $start, $this->pos - $start);
        $this->pos++; // Move past delimiter

        return $value;
    }
}