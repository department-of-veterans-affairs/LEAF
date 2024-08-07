package test.java;

import main.java.util.CommonUtility;
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
    String formName;

    /**
     * Initialization method to set up page action instances.
     * This method runs before any test method in the class.
     */
    @BeforeClass
    public void TestInitialization() {
        adminPageActions = PageinstancesFactory.getInstance(adminPage_Actions.class); // Initialize adminPage_Actions instance
        adminPageActions.clickFormEditor(); // Navigate to the form editor page
        formEditorPageActions = PageinstancesFactory.getInstance(FormEditorPageActions.class); // Initialize FormEditorPageActions instance
        formName = "FormName_" + CommonUtility.generate_AlphaNumeric_RandomString(3);
    }

    /**
     * Test to validate the creation of a new form.
     */

    @Test(priority = 1)
    public void validateCreateForm() {

        formEditorPageActions.createForm(formName);
        Assert.assertTrue(formEditorPageActions.validateForm(formName)); // Validate the form is created
    }

    /*
     * Test to validate the creation of a new section in the form.
*/
    @Test(priority  =2)
    public void validateSectionCreated(){
        formEditorPageActions.clickAddSection(); // Click on the 'Add Section' button
        formEditorPageActions.enterSectionHeading("Section Heading"); // Enter the section heading
        formEditorPageActions.clickSave(); // Click the 'Save' button
        Assert.assertTrue(formEditorPageActions.checkSectionCreated("Section Heading")); // Validate the section is created
    }

    /**
     * Test to validate the creation of a new question in the form.
*/
    @Test(priority =3)
    public void validateQuestionCreated(){
        formEditorPageActions.clickAddQuestionToHeader(); // Click on the 'Add Question to Header' button
        formEditorPageActions.AddQuestion("Question"); // Enter the question text
        formEditorPageActions.clickSave(); // Click the 'Save' button
        Assert.assertTrue(formEditorPageActions.validateCreatedQuestion("Question")); // Validate the question is created
    }



    @Test(priority = 5)
    public void validateStapleForm() throws InterruptedException {

            formEditorPageActions.createForm(formName);
            formEditorPageActions.clickCreateFormLink();
            formEditorPageActions.createForm("staple_" + formName);
            formEditorPageActions.stapleForm(formName); // Validate stapling a form


    }

    @Test(priority = 4)
    public void validateDeleteForm() {
        formEditorPageActions.deleteForm(formName); // Validate deleting a form
        Assert.assertTrue(formEditorPageActions.checkFormDeleted(formName));

        log.info("Validating Form Deleted Successfully");


    }

    @Test(priority = 6)
    public void validateStapledFormNotDeleted() {
        formEditorPageActions.clickDeleteFormButton();

       Assert.assertTrue(formEditorPageActions.verifyDNDWarning());
    }

    @Test(priority = 7)
    public void validateAlertMessage() {
        formEditorPageActions.clickSave();
        Assert.assertTrue(formEditorPageActions.verifyAlertMessage());
    }





}
