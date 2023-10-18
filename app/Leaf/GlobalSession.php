<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Leaf;

use App\Leaf\Model\GlobalSession as ModelSession;

class GlobalSession
{
    protected $modelSession;

    public function __construct(ModelSession $modelSession)
    {
        $this->modelSession = $modelSession;
    }

    /**
     * storeSession - stores the current session,
     * this method also updates the session should the user change portals
     * It is the responsibility of the caller to make sure that this needs
     * to be updated.
     *
     * @param string $csrf
     * @param string $session
     *
     * @return void
     *
     * Created at: 10/18/2023, 7:14:31 AM (America/New_York)
     */
    public function storeSession(string $csrf, string $session): void
    {
        $this->modelSession->postSession($csrf, $session);
    }

    /**
     * retrieveSession gets the current session data for a specific user
     *
     * @param string $csrf
     *
     * @return array
     *
     * Created at: 10/18/2023, 7:14:01 AM (America/New_York)
     */
    public function retrieveSession(string $csrf): array
    {
        return $this->modelSession->getSession($csrf);
    }
}