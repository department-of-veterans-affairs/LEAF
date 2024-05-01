package main.java.pageActions;

import test.java.BaseMethods.BaseClass;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.PageFactory;

public class orgChartWorkFlow_PageObjects extends BaseClass{

    WebDriver driver;

    public orgChartWorkFlow_PageObjects(WebDriver driver){
        this.driver=driver;
        PageFactory.initElements(driver,this);
    }
}
