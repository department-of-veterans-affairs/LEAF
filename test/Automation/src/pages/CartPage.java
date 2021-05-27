package pages;
 
import org.openqa.selenium.By;
 
public class CartPage extends Page {
 
	private static final String PRODUCT_TABLE = "//table[@class='checkout_cart']";
	private static final String PRODUCT_TABLE_ROWS = PRODUCT_TABLE + "/tbody/tr[contains(@class, 'product_row')]";
	
	public int getNumberOfProductsInCart() {
		return driver.findElements(By.xpath(PRODUCT_TABLE_ROWS)).size();
	}
}