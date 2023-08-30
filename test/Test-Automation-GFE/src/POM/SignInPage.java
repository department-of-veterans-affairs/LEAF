package POM;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;


public class SignInPage {

	private WebDriver driver;
	private By headerPageText = By.cssSelector(".hidden-small");
	private By createAccountLink = By.id("link-signup");
	private By emailTextBox = By.id("Email");
	private By passwordTextBox = By.id("Passwd");
	private By loginBtn = By.id("signIn");
	private By errorMsgTxt = By.id("errormsg_0_Passwd");

	public SignInPage(WebDriver driver) {
		this.driver=driver;
	}

	public String getSignInPageTitle() {
		String pageTitle = driver.getTitle();
		return pageTitle;
	}

	public boolean verifySignInPageTitle() {
		String expectedTitle = "Sign in - Google Accounts";
		return getSignInPageTitle().contains(expectedTitle);
	}

	public boolean verifySignInPageText() {
		WebElement element = driver.findElement(headerPageText);
		String pageText = element.getText();
		String expectedPageText = "Sign in with your Google Account";
		return pageText.contains(expectedPageText);
	}

	public CreateAccountPage clickonCreateAnAccount() {
		WebElement element=driver.findElement(createAccountLink);
		if(element.isDisplayed()||element.isEnabled())
		element.click();
		return new CreateAccountPage(driver);

		}
		public boolean verifySignIn() {
			enterUserName("test");
			enterPassword("pass");
			clickOnSignIn();

			return getErrorMessage().contains("incorrect");
		}
	
		public void enterUserName(String userName) {
			WebElement emailTxtBox = driver.findElement(emailTextBox);
			if(emailTxtBox.isDisplayed())
			emailTxtBox.sendKeys(userName);
		}


		public void enterPassword(String password) {
			WebElement passwordTxtBox = driver.findElement(passwordTextBox);
			if(passwordTxtBox.isDisplayed())
			passwordTxtBox.sendKeys(password);
		}

		public void clickOnSignIn() {
			WebElement signInBtn = driver.findElement(loginBtn);
			if(signInBtn.isDisplayed())
			signInBtn.click();
		}


		public String getErrorMessage() {
			String strErrorMsg = null;
			WebElement errorMsg = driver.findElement(errorMsgTxt);
			if(errorMsg.isDisplayed()&&errorMsg.isEnabled())
			strErrorMsg = errorMsg.getText();
			return strErrorMsg;
		}
		
}  //class
