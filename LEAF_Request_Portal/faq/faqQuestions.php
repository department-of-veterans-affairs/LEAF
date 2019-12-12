<?php
require_once './faqType.php';

class FaqQuestionList{

    private $questionList;

    function __construct(){
        $this->questionList = [
            new FaqQuestion("url", "title", [FaqType::USER_NOT_FOUND, FaqType::WORKFLOW_ISSUE]),
            new FaqQuestion("url", "title", [FaqType::USER_NOT_FOUND, FaqType::WORKFLOW_ISSUE])
        ];
    }

    function getQuestions($type){

        $questions = array();

        for($i = 0; $i<$this->questionList.count(); $i++){
            if(in_array($type, questionList[$i]->topics)){
                $questions.add(questionList[$i]);
            }
        }

        return $questions;
    }

}

class FaqQuestion{
    public $url;
    public $title;
    public $topics;

    function __construct($url, $title, $topics){
        $this->url = $url;
        $this->title = $title;
        $this->topics = $topics;
    }
}