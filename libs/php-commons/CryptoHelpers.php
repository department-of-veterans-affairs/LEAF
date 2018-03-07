<?php

/**
 * Suite of helper functions to assist in encrypting and signing data.
 */
class CryptoHelpers
{
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
        $hashedMessage = sodium_crypto_generichash($json, sodium_hex2bin($hexKey));

        return sodium_bin2hex($hashedMessage);
    }
}
