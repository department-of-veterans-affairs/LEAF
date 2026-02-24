<?php

namespace App\Leaf;

/**
 * Security utility class for handling safe redirects and other security operations
 */
class Security
{
    /**
     * Validates and sanitizes a redirect URL
     *
     * @param string $encodedUrl Base64-encoded URL to validate
     * @param string $allowedHost The allowed hostname (e.g., HTTP_HOST constant)
     * @param string $defaultRedirect Fallback redirect if validation fails
     * @param string $protocol Protocol to use (default: 'https://')
     * @return string Safe redirect URL
     */
    public static function validateRedirect(string $encodedUrl, string $allowedHost, string $defaultRedirect, string $protocol = 'https://'): string
    {
        $decodedPath = base64_decode($encodedUrl, true);

        if ($decodedPath === false) {
            return $defaultRedirect;
        }

        if (strpos($decodedPath, "\n") !== false) {
            error_log('LEAF: Rejected redirect containing newline: ' . $decodedPath);
            return $defaultRedirect;
        }

        // Only check for @ in the path portion (before query string).
        // The @ symbol is dangerous in paths where it redefines the URL host
        // (e.g., @evil.com/path), but is safe in query strings (e.g., ?email=user@example.com).
        $pathPortion = strtok($decodedPath, '?');
        if (strpos($pathPortion, '@') !== false) {
            error_log('LEAF: Rejected redirect containing @ in path: ' . $decodedPath);
            return $defaultRedirect;
        }

        return $protocol . $allowedHost . $decodedPath;
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
     * Returns null for empty, malformed, or object-containing data
     * (mirrors unserialize() returning false on failure)
     *
     * @param string $data The serialized data
     * @return mixed|null The parsed data, or null if data is invalid/empty/contains objects
     */
    public static function parseSerializedData(string $data)
    {
        if (empty($data)) {
            return null;
        }

        // Reject serialized objects
        if (preg_match('/[OC]:\d+:"/', $data)) {
            return null;
        }

        try {
            $parser = new SerializedDataParser($data);
            return $parser->parse();
        } catch (\InvalidArgumentException $e) {
            return null;
        }
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