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

        if (strpos($decodedPath, '@') !== false || strpos($decodedPath, "\n") !== false) {
            error_log('LEAF: Rejected redirect containing prohibited characters: ' . $decodedPath);
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
}