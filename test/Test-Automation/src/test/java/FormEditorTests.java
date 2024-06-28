package test.java;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import main.java.factory.PageinstancesFactory;
import main.java.pages.FormEditorPageActions;
import main.java.pages.adminPage_Actions;

/**
 * Test class for form editor functionality.
 * Extends the BaseTest class to inherit setup and teardown methods.
 */
public class FormEditorTests extends BaseTest {

    private static final Logger log = LogManager.getLogger(FormEditorTests.class);
    adminPage_Actions adminPageActions;
    FormEditorPageActions formEditorPageActions;

    /**
     * Initialization method to set up page action instances.
     * This method runs before any test method in the class.
     */
    @BeforeClass
    public void TestInitialization() {
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class); // Initialize adminPage_Actions instance
        adminPageActions.clickFormEditor(); // Navigate to the form editor page
        formEditorPageActions = PageinstancesFactory.getInstance(FormEditorPageActions.class); // Initialize FormEditorPageActions instance
    }

    /**
     * Test to validate the creation of a new form.
     */
    @Test()
    public void TC001_validateCreateForm() {
        formEditorPageActions.clickCreateForm(); // Click on the 'Create Form' button
        formEditorPageActions.enterFormName("Test-1"); // Enter the form name
        formEditorPageActions.enterDescription("Test-Description"); // Enter the form description
        formEditorPageActions.clickSave(); // Click the 'Save' button
        Assert.assertTrue(formEditorPageActions.validateForm("Test-1")); // Validate the form is created
    }

    /**
     * Test to validate the creation of a new section in the form.
     */
    @Test
    public void TC002_validateSectionCreated(){
        formEditorPageActions.clickAddSection(); // Click on the 'Add Section' button
        formEditorPageActions.enterSectionHeading("Section Heading"); // Enter the section heading
        formEditorPageActions.clickSave(); // Click the 'Save' button
        Assert.assertTrue(formEditorPageActions.checkSectionCreated("Section Heading")); // Validate the section is created
    }

    /**
     * Test to validate the creation of a new question in the form.
     */
    @Test
    public void TC003_validateQuestionCreated(){
        formEditorPageActions.clickAddQuestionToHeader(); // Click on the 'Add Question to Header' button
        formEditorPageActions.AddQuestion("Question"); // Enter the question text
        formEditorPageActions.clickSave(); // Click the 'Save' button
        Assert.assertTrue(formEditorPageActions.validateCreatedQuestion("Question")); // Validate the question is created
    }

    /*

    @Test(dependsOnMethods = {"TC001_validateCreateForm"})
    public void validateStapleForm() {
        formEditorPageActions.stapleForm("AS - Vacation Reservations"); // Validate stapling a form
    }

    @Test
    public void validateDeleteForm() {
        formEditorPageActions.deleteForm("TestForm-1"); // Validate deleting a form
    }
    */
}
