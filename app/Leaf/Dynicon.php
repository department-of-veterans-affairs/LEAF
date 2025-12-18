<?php
/**
 * As a work of the United States government, this project is in the public domain within the United States.
 *
 * Dynicon (runtime)
 * Dynamic icons
 * Author: Michael Gao (Michael.Gao@va.gov)
 * Date: January 26, 2011
 *
 * Dynicon for Microsoft Windows
 * Dynamic icons (svg to png)
 * Author: Michael Gao (Michael.Gao@va.gov)
 * Date: January 26, 2011
*/

namespace App\Leaf;

class Dynicon
{
    private const CACHE_DIR = __DIR__ . '/../libs/dynicons/cache/';
    private const SVG_SOURCE_DIR = __DIR__ . '/../libs/dynicons/svg/';
    private const ALLOWED_EXTENSION = '.svg';
    private const FALLBACK_ICON = 'emblem-unreadable.svg';
    private $cacheDir;

    private $svgSourceDir;

    private $file = '';

    private $cachedFile = '';

    private $preferFormat = 'svg';

    private $width;

    public function __construct($file, $width)
    {
        $this->cacheDir = realpath(self::CACHE_DIR);
        $this->svgSourceDir = realpath(self::SVG_SOURCE_DIR);

        if ($this->cacheDir === false || $this->svgSourceDir === false) {
            $this->outputError('Configuration error');
            exit();
        }

        if (!is_numeric($width) || $width <= 0 || $width > 10000) {
            $this->outputError('Invalid width');
            exit();
        }

        $this->width = (int)$width;

        $sanitizedFile = $this->sanitizeFilename($file);

        if (!$this->isValidIconFile($sanitizedFile)) {
            $sanitizedFile = self::FALLBACK_ICON;
        }

        $this->file = $sanitizedFile;

        if ($this->width <= 32) {
            $this->preferFormat = 'png';
        }

        $this->cachedFile = $this->cacheDir . '/' . $this->file . $this->width . '.';

        if (file_exists($this->cachedFile . $this->preferFormat)) {
            $this->cachedFile = $this->cachedFile . $this->preferFormat;

            if (XSSHelpers::isPathSafe($this->cachedFile, $this->cacheDir)) {
                $this->output();
            } else {
                $this->outputError('Invalid file path');
            }
        } else {
            $this->preferFormat = 'svg';
            $this->cachedFile = $this->cachedFile . 'svg';
            clearstatcache();

            if (file_exists($this->cachedFile) && XSSHelpers::isPathSafe($this->cachedFile, $this->cacheDir)) {
                $this->output();
            } else {
                if ($this->convert()) {
                    if (XSSHelpers::isPathSafe($this->cachedFile, $this->cacheDir)) {
                        $this->output();
                    } else {
                        $this->outputError('Invalid cached file path');
                    }
                } else {
                    $this->outputError('conversion failed');
                }
            }
        }
    }

    /**
     * Sanitize filename to remove dangerous characters
     * @param string $filename
     * @return string
     */
    private function sanitizeFilename(string $filename): string
    {
        // Remove path separators and other dangerous characters
        $filename = preg_replace('/[\/\\\:\*\?\"\<\>\|]/', '', $filename);

        // Remove multiple consecutive dots
        $filename = preg_replace('/\.{2,}/', '.', $filename);

        // Remove leading dots
        $filename = ltrim($filename, '.');

        // Remove trailing dots
        $filename = rtrim($filename, '.');

        return $filename;
    }

    /**
     * Validate that the icon file is safe to use
     * @param string $filename
     * @return bool
     */
    private function isValidIconFile(string $filename): bool
    {
        $isValid = true;

        // Must not be empty
        if (empty($filename)) {
            $isValid = false;
        }

        // Must contain .svg extension
        if (strpos($filename, self::ALLOWED_EXTENSION) === false) {
            $isValid = false;
        }

        // Must not contain path separators
        if (strpos($filename, '/') !== false || strpos($filename, '\\') !== false) {
            $isValid = false;
        }

        // Must not contain parent directory references
        if (strpos($filename, '..') !== false) {
            $isValid = false;
        }

        // Must end with .svg
        if (substr($filename, -4) !== self::ALLOWED_EXTENSION) {
            $isValid = false;
        }

        // Only allow alphanumeric, underscores, hyphens, and dots
        if (!preg_match('/^[a-zA-Z0-9_.-]+\.svg$/', $filename)) {
            $isValid = false;
        }

        return $isValid;
    }

    /**
     * Output error message or placeholder image
     * @param string $message
     */
    private function outputError(string $message): void
    {
        // Log error for debugging
        error_log("Dynicon error: {$message} - File: {$this->file}");

        // Output a 1x1 transparent PNG as fallback
        header('Content-Type: image/png');
        header('Cache-Control: no-cache');
        echo base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    }

    private function output()
    {
        $shouldOutput = true;
        $content = null;

        if (!XSSHelpers::isPathSafe($this->cachedFile, $this->cacheDir)) {
            $this->outputError('Path validation failed');
            $shouldOutput = false;
        }

        if (!file_exists($this->cachedFile)) {
            $this->outputError('File not found');
            $shouldOutput = false;
        }

        if ($shouldOutput) {
            $time = filemtime($this->cachedFile);

            if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && $_SERVER['HTTP_IF_MODIFIED_SINCE'] == gmdate('D, d M Y H:i:s T', $time)) {
                header('Last-Modified: ' . gmdate('D, d M Y H:i:s T', $time), true, 304);
            } else {
                header('Last-Modified: ' . gmdate('D, d M Y H:i:s T', $time), true);
                header('Expires: ' . gmdate('D, d M Y H:i:s T', time() + 604800));

                if ($this->preferFormat == 'svg') {
                    header('Content-Type: image/svg+xml');
                } else {
                    header('Content-Type: image/png');
                }

                $content = file_get_contents($this->cachedFile);

                if ($content !== false) {
                    echo $content;
                } else {
                    $this->outputError('Failed to read file');
                }
            }
        }
    }

    private function convert()
    {
        $sanitizedFile = $this->sanitizeFilename($this->file);
        $sourceFile = $this->svgSourceDir . '/' . $sanitizedFile;

        if (!XSSHelpers::isPathSafe($sourceFile, $this->svgSourceDir)
            || !file_exists($sourceFile)
        ) {
            return false;
        }

        libxml_use_internal_errors(true);
        $xml = simplexml_load_file($sourceFile);
        libxml_clear_errors();

        if ($xml === false) {
            return false;
        }

        $rawWidth = trim((string) $xml->attributes()->width);
        $rawHeight = trim((string) $xml->attributes()->height);

        $unit_of_measure = 'px';

        if (is_numeric($rawWidth)) {
            $xmlWidth = $rawWidth;
        } elseif (strpos($rawWidth, 'px') !== false) {
            $xmlWidth = substr($rawWidth, 0, strpos($rawWidth, 'px'));
        } elseif (strpos($rawWidth, 'mm') !== false) {
            $xmlWidth = substr($rawWidth, 0, strpos($rawWidth, 'mm'));
            $unit_of_measure = 'mm';
        } else {
            $xmlWidth = 1;
        }

        if (is_numeric($rawHeight)) {
            $xmlHeight = $rawHeight;
        } elseif (strpos($rawHeight, 'px') !== false) {
            $xmlHeight = substr($rawHeight, 0, strpos($rawHeight, 'px'));
        } elseif (strpos($rawHeight, 'mm') !== false) {
            $xmlHeight = substr($rawHeight, 0, strpos($rawHeight, 'mm'));
            $unit_of_measure = 'mm';
        } else {
            $xmlHeight = 1;
        }

        $ratio = $this->width / $xmlWidth;
        $newHeight = $ratio * $xmlHeight;

        $xml->attributes()->width = $this->width . $unit_of_measure;
        $xml->attributes()->height = $newHeight . $unit_of_measure;
        $xml->addAttribute('viewBox', "0 0 {$xmlWidth} {$xmlHeight}");

        $outputFile = $this->cacheDir . '/' . $sanitizedFile . $this->width . '.svg';

        if (!XSSHelpers::isPathSafe($outputFile, $this->cacheDir)) {
            return false;
        }

        $result = file_put_contents($outputFile, $xml->asXML());

        if ($result === false) {
            return false;
        }

        return true;
    }
}
