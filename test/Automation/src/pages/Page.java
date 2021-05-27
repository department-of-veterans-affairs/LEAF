package pages;
 
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
 
public class Page {
	
	protected static WebDriver driver;
	
	private static final String SEARCH_FIELD_CLASS = "s";
	private static final String CART_LINK_CLASS = "cart_icon";
	
	public void setWebDriver(WebDriver driver) {
		Page.driver = driver;
	}
	
	public void search(String query) {
		driver.findElement(By.className(SEARCH_FIELD_CLASS)).sendKeys(query + Keys.ENTER);
	}
	
	public CartPage clickCheckoutLink() {
		driver.findElement(By.className(CART_LINK_CLASS)).click();
		return new CartPage();
	}
}