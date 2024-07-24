package main.java.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class SiteSettingsPageActions extends BasePage{


    /**
     * Instantiates a new site setiings page.
     *
     * @param driver the driver
     */
    public SiteSettingsPageActions(WebDriver driver) {
        super(driver);
    }


    @FindBy(xpath ="//label[text()=\"Title of LEAF site\"]/following-sibling::input[1]")
    WebElement titleLeafSiteInput;

    @FindBy(xpath ="//label[text()=\"Facility Name\"]/following-sibling::input[1]")
    WebElement facilityNameInput;

    @FindBy(id ="btn_save")
    WebElement saveButton;

    @FindBy(xpath = "//span[@class='leaf-site-title']")
    WebElement leafTitle;

    @FindBy(id = "headerDescription")
    WebElement headerDescription;
    /**
     * Enter the "Leaf Title" in text box.
     */
    public void enterLeafTitle(String leafTitle) {
        setExplicitWaitForElementToBeVisible(titleLeafSiteInput,30);
        titleLeafSiteInput.clear();
        enterText(titleLeafSiteInput,leafTitle);
    }
    /**
     * Enter the "Facility Name" in text box.
     */
    public void enterFacilityName(String facilityName) {
        setExplicitWaitForElementToBeVisible(facilityNameInput,30);
        facilityNameInput.clear();
        enterText(facilityNameInput,facilityName);
    }

    /**
     * Clicks the "Save" button.
     */
    public void clickSaveButton() {
    if(saveButton != null) {

       scrollToView(saveButton);
    }
    else {
        System.out.println("Element not found");
    }
    setExplicitWaitForElementToBeVisible(saveButton,30);

        clickElement(saveButton);
        scrollToView(leafTitle);
        setExplicitWaitForElementToBeVisible(leafTitle,30);
    }



public boolean verifyLeafTitleAndFacility(String expLeafTitle){

        setExplicitWaitForElementToBeVisible(leafTitle,30);
    if(leafTitle != null) {

        scrollToView(leafTitle);
        setExplicitWaitForElementToBeVisible(leafTitle,30);
    }
    else {
        System.out.println("Element not found");
    }
    String actLeafTitle = leafTitle.getText();
    System.out.println("actLeafTitle : " +actLeafTitle);
    System.out.println("expLeafTitle : " +expLeafTitle);
    return actLeafTitle.equals(expLeafTitle);
}

}
