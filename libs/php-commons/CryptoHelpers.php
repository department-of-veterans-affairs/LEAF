<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/**
 * Suite of helper functions to assist in encrypting and signing data.
 *
 * In general, all input and output strings should be in hexadecimal
 * format, unless otherwise noted.
 */
class CryptoHelpers
{
    /**
     * Generate a hash for the given object in hexadecimal format.
     *
     * @param string    $obj    the object to hash
     *
     * @return string   the hash of the object in hexadecimal format
     */
    public static function hashObject($obj) : string
    {
        return sodium_bin2hex(sodium_crypto_generichash($obj));
    }

    /**
     * Sign a JSON object with the given key.
     *
     * The $json input usually comes from the output of json_encode().
     *
     * The returned value is a signed hash of the $json input.
     *
     * @param string    $json   the JSON object to sign
     * @param string    $hexKey the key to sign it with, in hexadecimal
     *                          string format
     *
     * @return string   the fingerprint of the JSON object signed with
     *                  the key, in hexadecimal string format
     */
    public static function signJSONObject($json, $hexKey) : string
    {
        $hashedMessage = self::hashObject($json);
        $signature = sodium_crypto_sign_detached(
            sodium_hex2bin($hashedMessage),
            sodium_hex2bin($hexKey)
        );

        return sodium_bin2hex($signature);
    }

    /**
     * Verify that the signature for the given message is authentic.
     *
     * @param string    $signature  The detached signature to authenticate,
     *                              in hexadecimal format.
     * @param string    $msg        The message to authenticate against
     * @param string    $key        The key to authenticate with, in
     *                              hexadecimal string format. Usually a
     *                              public signing key.
     *
     * @return bool If the signature is authentic for the given message
     */
    public static function verifySignature($signature, $msg, $key) : bool
    {
        $verified = sodium_crypto_sign_verify_detached(
            sodium_hex2bin($signature),
            sodium_hex2bin(self::hashObject($msg)),
            sodium_hex2bin($key)
        );

        return is_bool($verified) && $verified == true;
    }
}
