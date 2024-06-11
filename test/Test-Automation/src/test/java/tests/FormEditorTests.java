package test.java.tests;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import test.java.factory.PageinstancesFactory;
import test.java.pages.FormEditorPageActions;
import test.java.pages.adminPage_Actions;

public class FormEditorTests extends BaseTest {

    private static final Logger log = LogManager.getLogger(FormEditorTests.class);
    adminPage_Actions adminPageActions ;
    FormEditorPageActions formEditorPageActions;


    @BeforeClass
    public void TestInitialization() {
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class);
        adminPageActions.clickFormEditor();
        formEditorPageActions = PageinstancesFactory.getInstance(FormEditorPageActions.class);
    }


    @Test()
    public void validateCreateForm() {
        formEditorPageActions.createForm("TestForm-1", "TestFormDescription-1");
    }

    @Test(dependsOnMethods = {"validateCreateForm"})
    public void validateStapleForm() {
        formEditorPageActions.stapleForm("AS - Vacation Reservations");
    }

    @Test()
    public void validateDeleteForm() {
        formEditorPageActions.deleteForm("TestForm-1");
    }


}
