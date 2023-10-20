<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Leaf;

use App\Leaf\Db;
use App\Leaf\Model\Site as ModelSite;

class Site
{
    private $modelSite;

    private $match;

    private $portal_path;

    private $site_paths;

    public $error = false;

    /**
     * @param Db $db
     *
     * Created at: 9/5/2023, 10:56:00 AM (America/New_York)
     */
    public function __construct(ModelSite $site, GlobalSession $session, string $path, string $csrf)
    {
        $this->modelSite = $site;

        $this_session = $session->retrieveSession($csrf);
        $current_path = $this->parsePath($path);
        $original_path = $this->parsePath($path);

        if ($this_session['status']['code'] == 2 && !empty($this_session['data'])) {
            // There is a stored session, check if it matches the current path
            $session_data = json_decode($this_session['data'][0]['session'], true);

            if ($session_data['path'] == $current_path) {
                // current path and session path match get data base on session
                $this->setVariables($session_data);
            } else {
                // current path and session path do NOT match, try the supplied path
                // strip supplied path and check against session again
                $this->stripLast($current_path);

                if ($session_data['path'] == $current_path) {
                    // current path and session path match get data base on session
                    $this->setVariables($session_data);
                } else {
                    // current path and session path do NOT match, try the supplied path
                    // strip supplied path and check against session again
                    $portal_path = $this->checkPath($original_path);
                    $this->processPath($portal_path, true, $session, $csrf, $original_path, $session_data);
                }
            }
        } else {
            // there are no session variables set it up
            $portal_path = $this->checkPath($original_path);

            $this->processPath($portal_path, true, $session, $csrf, $original_path);
        }
    }

    public function getPortalPath(): string
    {
        return $this->portal_path;
    }

    public function getSitePath(): array
    {
        return $this->site_paths;
    }

    private function setVariables(array $current_session): void
    {
        $this->portal_path = $current_session['path'];
        $this->site_paths = $current_session['site_data'];
    }

    private function processPath(array $path_result, bool $first_try, GlobalSession $this_session, string $csrf, string $path, ?array $stored_session = null): void
    {
        if ($path_result['status']['code'] == 2 && !empty($path_result['data'])) {
            // this path works, assign portal and site paths, update the session
            $this->portal_path = $this->match;
            $this->site_paths = $path_result['data'][0];

            $this->setSession($this_session, $csrf);
        } elseif ($first_try) {
            // the original url does not produce a site, need to extract the end of the url and try again.
            $this->stripLast($path);
            $portal_path = $this->checkPath($path);
            $this->processPath($portal_path, false, $this_session, $csrf, $path, $stored_session);
        } elseif ($stored_session !== null) {
            $this->setVariables($stored_session);
        } else {
            $this->error = true;
        }
    }

    private function stripLast(string &$path): void
    {
        $path_array = explode('/', $path);
        array_shift($path_array);
        array_pop($path_array);

        $path = '';

        for ($i = 0; $i < count($path_array); $i++) {
            $path .= '/' . $path_array[$i];
        }
    }

    private function checkPath(string $path): array
    {
        $return_value = $this->modelSite->getSiteData($path);

        return $return_value;
    }

    private function parsePath(string $path): string
    {
        preg_match('(\/.+\/)', $path, $match);
        $this->match = rtrim(str_replace('/var/www/html', '', $match[0]), '/');
        // the only time that more than one folder gets removed is here so going to strip it here rather than wait.
        $this->match = str_replace('/sources/../mailer', '', $this->match);

        return $this->match;
    }

    private function setSession(GlobalSession $session, string $csrf): void
    {
        $data = array('path' => $this->match,
                            'site_data' => $this->site_paths);

        $session_data = json_encode($data);

        $session->storeSession($csrf, $session_data);
    }
}