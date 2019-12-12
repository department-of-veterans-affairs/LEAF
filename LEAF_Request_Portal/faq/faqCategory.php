<?php

class FaqCategoryList{

    private $categoryList;

    function __construct(){
        $this->categoryList = [
            new FaqCategory("../libs/dynicons/?img=system-users.svg","Users", FaqType::USER_NOT_FOUND),
            new FaqCategory("../libs/dynicons/?img=gnome-system-run.svg","Workflows", FaqType::WORKFLOW_ISSUE),
            new FaqCategory("../libs/dynicons/?img=document-properties.svg","Forms", FaqType::FORM_ISSUE),
            new FaqCategory("../libs/dynicons/?img=preferences-desktop-wallpaper.svg","Site Display", FaqType::SITE_DISPLAY),
            new FaqCategory("../libs/dynicons/?img=x-office-presentation.svg","Tutorials", FaqType::TUTORIALS),
            new FaqCategory("../libs/dynicons/?img=help-browser.svg","Other", FaqType::OTHER)
        ];
    }

    function getCategoryList(){
        return $this->categoryList;
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

class FaqType{
    const USER_NOT_FOUND = "user_not_found";
    const WORKFLOW_ISSUE = "workflow_issue";
    const FORM_ISSUE = "form_issue";
    const SITE_DISPLAY = "site_display";
    const TUTORIALS = "tutorials";
    const OTHER = "other";
}