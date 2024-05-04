package main.pageActions;

import org.openqa.selenium.support.PageFactory;

import static main.Utility.Utility.driver;

public class FormEditorPageActions {

    public FormEditorPageActions() {
        PageFactory.initElements(driver, this);
    }


}
