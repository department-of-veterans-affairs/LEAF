<?php
require_once 'faqType.php';

class FaqQuestionList{

    private $questionList;

    private const BASE_URL = "https://leaf.va.gov/Other/DEVTICKET/LEAF_Developer_Ticket_Requests/report.php?a=faq#";

    function __construct(){
        $this->questionList = [
            new FaqQuestion(FaqQuestionList::BASE_URL."37", "What database does LEAF use?", [FaqType::TECHNICAL]),
            new FaqQuestion(FaqQuestionList::BASE_URL."38", "How do the database data types LEAF use compare to SQL Server data types?", [FaqType::TECHNICAL]),
            new FaqQuestion(FaqQuestionList::BASE_URL."39", "Can the database tables used in LEAF be modified? Or can new tables be added?", [FaqType::TECHNICAL]),
            new FaqQuestion(FaqQuestionList::BASE_URL."46", "How can I show the Initiator of a Request on the main Portal page?", [FaqType::TECHNICAL, FaqType::SITE_DISPLAY]),
            new FaqQuestion(FaqQuestionList::BASE_URL."50", "How can the min/max selectable Dates be set for the Datepicker?", [FaqType::TECHNICAL, FaqType::SITE_DISPLAY]),
            new FaqQuestion(FaqQuestionList::BASE_URL."53", "How can the date format exposed by LEAF through JSON be used in an Excel spreadsheet?", [FaqType::TECHNICAL, FaqType::OTHER]),
            new FaqQuestion(FaqQuestionList::BASE_URL."77", "Why am I getting an authentication error after getting temporary login credentials? (Windows 10)", [FaqType::USER_ACCOUNTS]),
            new FaqQuestion(FaqQuestionList::BASE_URL."85", "Why am I seeing a discrepancy between the LEAF_request_initiator_new_account utility and my report?", [FaqType::TECHNICAL, FaqType::USER_ACCOUNTS]),
            new FaqQuestion(FaqQuestionList::BASE_URL."86", "Does the administrator need Nexus and SysAdmin rights to create and edit User Access Groups?", [FaqType::USER_ACCOUNTS, FaqType::TECHNICAL])
        ];
    }

    public function getQuestionsByType($type){

        $questions = array();

        for($i = 0; $i<count($this->questionList); $i++){
            $topics = $this->questionList[$i]->topics;
            if($this->hasTopic($type, $topics)){
                array_push($questions, $this->questionList[$i]);
            }
        }

        return $questions;
    }

    public function getQuestionsByTerm($searchTerm){
        
        $questions = array();

        for($i = 0; $i < count($this->questionList); $i++){

            $toConsider = $this->questionList[$i];

            if( $this->contains($searchTerm, $toConsider->title) || 
                $this->hasTopic($searchTerm, $toConsider->topics)
            ){
                array_push($questions, $this->questionList[$i]);
            }
        }

        return $questions;
    }

    function contains($term, $toCompare){
        return strpos(strtoupper($toCompare), strtoupper($term)) !== false;
    }

    function hasTopic($term, $toCompare){
        return in_array($term, $toCompare);
    }

}

class FaqQuestion{
    public $url;
    public $question;
    public $topics;

    function __construct($url, $question, $topics){
        $this->url = $url;
        $this->title = $question;
        $this->topics = $topics;
    }
}