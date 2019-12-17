<?php

require_once 'faqType.php';
require_once 'faqQuestions.php';

class FaqCategoryListManager{

    private $categoryList;
    private $questionList;

    /*
        As this grows we should consider adding a connection to the help desks'
        DB so we can pull directly from there
    */

    function __construct(){
        $this->questionList = new FaqQuestionList();
        $this->categoryList = [
            new FaqCategory("../libs/dynicons/svg/system-users.svg",
                            "Users", 
                            FaqType::USER_ACCOUNTS),
            new FaqCategory("../libs/dynicons/svg/gnome-system-run.svg",
                            "Workflows", 
                            FaqType::WORKFLOW_ISSUE),
            new FaqCategory("../libs/dynicons/svg/document-properties.svg",
                            "Forms", 
                            FaqType::FORM_ISSUE),
            new FaqCategory("../libs/dynicons/svg/preferences-desktop-wallpaper.svg",
                            "Site Display", 
                            FaqType::SITE_DISPLAY),
            new FaqCategory("../libs/dynicons/svg/x-office-presentation.svg",
                            "Tutorials", 
                            FaqType::TUTORIALS),
            new FaqCategory("../libs/dynicons/svg/network-idle.svg",
                            "Technical", 
                            FaqType::TECHNICAL),
            new FaqCategory("../libs/dynicons/svg/help-browser.svg",
                            "Other", 
                            FaqType::OTHER)
        ];
    }

    function getCategoryList($getAll = false){

        if($getAll){
            return $this->categoryList;
        }
        // Pruning any categories that don't have Questions associated...
        $categories = array();

        for($i=0; $i< count($this->categoryList); $i++){
            
            $toConsider = $this->categoryList[$i]->faqType;
            $questionsThatMatch = $this->questionList->getQuestionsByType($toConsider);
            
            if(count($questionsThatMatch) > 0){
                array_push($categories, $this->categoryList[$i]);
            }
        }

        return $categories;

    }

}

class FaqCategory{
    public $imgUrl;
    public $title;
    public $faqType;

    function __construct($imgUrl, $title, $faqType){
        $this->imgUrl = $imgUrl;
        $this->title = $title;
        $this->faqType = $faqType;
    }
}

