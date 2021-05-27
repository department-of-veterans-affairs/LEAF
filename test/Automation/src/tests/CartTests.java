package tests;
 
import org.junit.Test;
 
import org.junit.Assert;
import pages.CartPage;
 
public class CartTests extends BaseTest {
	
	@Test
	public void testEmptyCart() {
		CartPage cart = basePage.clickCheckoutLink();
		Assert.assertEquals("Cart should be empty", 0, cart.getNumberOfProductsInCart());
	}
}