package Execution;

import org.openqa.selenium.WebDriver;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import com.pack.base.TestBaseSetup;
import come.pack.common.pageobjects.BasePage;
import come.pack.common.pageobjects.SignInPage;

public class SignInPageTest extends TestBaseSetup {

	private WebDriver driver;
	private SignInPage signInPage;
	private BasePage basePage;

	@BeforeClass
	public void setUp() {

	driver=getDriver();

	}

	@Test

	public void verifySignInFunction() {

	System.out.println("Sign In functionality details...");

	basePage = new BasePage(driver);

	signInPage = basePage.clickSignInBtn();

	Assert.assertTrue(signInPage.verifySignInPageTitle(), "Sign In page title doesn't match");

	Assert.assertTrue(signInPage.verifySignInPageText(), "Page text not matching");

	Assert.assertTrue(signInPage.verifySignIn(), "Unable to sign in");

	}


	}

	Now the create test 'CreateAnAccountTest'. Now we should be able to understand the verification that we are doing in the below test.

	package com.pack.common.tests;

	import org.openqa.selenium.WebDriver;

	import org.testng.Assert;

	import org.testng.annotations.BeforeClass;

	import org.testng.annotations.Test;
	import com.pack.base.TestBaseSetup;
	import come.pack.common.pageobjects.BasePage;

	import come.pack.common.pageobjects.CreateAccountPage;

	import come.pack.common.pageobjects.SignInPage;

	public class CreateAnAccounTest extends TestBaseSetup {

	private WebDriver driver;

	private SignInPage signInPage;

	private BasePage basePage;

	private CreateAccountPage createAccountPage;



	@BeforeClass

	public void setUp() {

	driver=getDriver();

	}



	@Test

	public void verifyCreateAnAccounPage() {

	System.out.println("Create An Account page test...");

	basePage = new BasePage(driver);

	signInPage = basePage.clickSignInBtn();

	createAccountPage = signInPage.clickonCreateAnAccount();

	Assert.assertTrue(createAccountPage.verifyPageTitle(), "Page title not matching");

	Assert.assertTrue(createAccountPage.verifyCreateAccountPageText(), "Page text not matching");

	}
	public void verifySignInFunction() {

	}

	
	
	
}  //class
