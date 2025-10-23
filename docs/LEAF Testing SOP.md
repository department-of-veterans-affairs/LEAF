# Purpose

The Playwright Standard Operating Procedure (SOP) outlines the strategy and approach to establish a standardized process for creating, executing, and maintaining high-quality, reliable, and scalable automated tests using the Playwright framework.

# Scope

This SOP details out the Light Electronic Action Framework's overall testing approach and standards needed to be in place to support automated testing. It applies to all end-to-end (E2E) and integration tests developed using Playwright.

# Tools

## Playwright

LEAF testing utilizes Playwright as its main testing tool due to its auto-waiting capabilities, reliable locators, and cross-browser capabilities:

- Isolated Tests: Each test should be independent and not rely on the state of previous tests. Playwright\'s browser context provides a clean slate for each test, ensuring isolation and preventing cascading failures.
- Role-Based Locators: Use locators that are resilient to UI changes. Playwright\'s built-in getByRole locator is highly recommended as it interacts with elements based on their accessibility attributes, making your tests more robust.
- Auto-Waiting: Playwright automatically waits for elements to be actionable before performing actions, which eliminates the need for manual waits and significantly reduces test flakiness. Avoid using page.waitForTimeout() as it can lead to unreliable tests.
- Trace Viewer: Use the Playwright Trace Viewer to debug failed tests. It provides a visual timeline of the test execution, including screenshots, network requests, and DOM snapshots, making it easy to pinpoint the cause of a failure.
- Headless and Headed Modes: Run tests in headless mode (without a visible browser) for faster execution in CI/CD pipelines. For debugging, use headed mode (\--headed) or Playwright\'s UI Mode (\--ui) to see the browser actions in real-time.
- Parallel Execution: Configure Playwright to run tests in parallel to speed up execution time, especially in a CI/CD environment.

## Git

Git helps organize changes across branches, environments, and contributors.

### Git Branch Naming Convention

To customize the Git branch naming conventions for use with Playwright, especially for testing coordination, we tailor the structure to reflect the type of test, the scope of the feature, and the environment.

| Branch Type | Purpose                                          | Example                       |
| ----------- | ------------------------------------------------ | ----------------------------- |
| e2e/        | End-to-end test development                      | e2e/checkout-flow             |
| test/       | General test-related work                        | test/login-page-validation    |
| playwright/ | Playwright config or setup changes               | playwright/setup-browserstack |
| mock/       | Mocking data or APIs for Playwright              | mock/user-profile-api         |
| hotfix/     | Address critical bugs in production environment. | Hotfix/ hotfix-1.2.1          |

This naming convention will be implemented moving forward -- current branching will not be renamed.

### Coordinate Testing

Coordinating Playwright-based testing via Git involves setting up a workflow where test development, execution, and review are tightly integrated with our Git branching strategy and CI/CD pipeline.

**Define Testing Strategy**

Decide what types of testing will be performed and coordinated:

- API Testing: Test individual API calls
- End-to-End Testing: Simulate scenarios
- Manual QA: For UI/UX or exploratory tests

**Isolate Tests via Branching**

Isolating work using Git using the following branches:

- Feature Branches: Developers work on features independently.
- (future) Testing Branches: Create branches like *qa*, *staging*, or *test-env*

  - Tests are run here before merging to main.
- Hotfix Branches: For urgent bug fixes.

> *NOTE: Testing branches will be introduced to our testing approach later on.*

**Automate Git Testing**

Our team uses the following tools to create the CI/CD pipeline

- GitHub Actions -- used to automate, build, test, and deploy from Github
- Quay -- Secure Code Analysis

The CI/CD pipeline performs automated tests anytime the following triggers occur:

- Code is pushed
- A pull request is opened
- A branch is merged

```yaml
name: Run Tests
on: \[push, pull_request\]
jobs:
  test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm
```

**Pull Requests -- Coordinate Testing and Review Tests**

Using pull requests, LEAF will coordinate testing via git:

- Developers push test branches (e.g., e2e/login-flow) and open PRs to qa or main.
- CI runs Playwright tests automatically.
- Reviewers check test results and approve merges

Before merging, code **must** pass all tests. If needed reviewer will manually test or approve test results, making sure to add labels to the code:

- Prerequisite: PR Merge (on app side)
- Release Ready
- Hold for Deploy
- TL-Approved (this means the tech lead has reviewed it)

**Testing Protocols**

As the team matures the LEAF testing framework, the released code will include a TESTING.md file which will provide a summary of locally run tests and any environment variables that were passed on to configure tests dynamically.

## Playwright inspector

Inspect page, generate selectors, step through the test execution, see click points and explore execution logs.

## Trace Viewer

Capture all the information to investigate the test failure. Playwright trace contains test execution screencast, live DOM snapshots, action explorer, test source and many more.

## eslint-plugin-playwright

Purpose: Keep test suite reliable and maintainable.

This plugin analyzes Playwright code and automatically flags issues such as those found in table below. It works with ESLint to automatically check test code for common issues and enforce best practices through automating quality check.

| Issue                       | Description                                                | Example                                                      |
| --------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| Missing await               | Catches when you forget to await a Playwright command      |                                                              |
| Inefficient Selectors       | Recommends using user-facing locators                      | getByRole() instead of less reliable CSS or XPath selectors |
| Improper Assertions         | Ensures use of Playwright's web-first assertions correctly | await expect(...)                                            |
| Bad Practices               | Warns against using anti-patterns                          | page.waitForTimeout(                                         |
| [expand table as we config] |                                                            |                                                              |

This linter would be configured initially to for handling known issues such as flaky tests (e.g., using test.skip for temporary disablement). In conjunction with AI, tests would be confirmed to test only what is controlled within the application, avoiding external dependencies. (See Test Isolation for more details.)

# Testing Approach

The LEAF testing approach is a multi-layered testing strategy, leveraging Playwright to build a robust and reliable test suit to combine scenario, component, and unit testing -- a summary of the purpose of the tests and Playwright's role is summarized below with more details provided after.

| **Test Type**                                                  | **Playwright's Role**                                                                                             | **Playwright Features**                                                                        |
| -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Scenario/E2E - Verify complete user journeys and system integration | Primary tool for simulating user interactions and flows in real browsers.                                              | page object, locator API, auto-waiting, cross-browser support, Tracing, UI Mode, parallel execution |
| Component - Test individual UI components in isolation.             | Mounts and tests components in a real browser, enabling visual and behavioral testing.                                 | mount fixture, toHaveScreenshot, toHaveText, interaction methods like click.                        |
| Unit Test - Test individual functions or logic in isolation         | Can be used as the test runner for Node.js-based unit tests, but a dedicated unit testing framework is often preferred | test and expect from @playwright/test can be used to write assertions                               |

By combining these three levels of testing, we create a comprehensive and effective automated testing strategy with Playwright, ensuring both the functionality and user experience of the LEAF application are of high quality. Once these are in place, viability of an automated test suite becomes a matter of "the next step" in the maturation of LEAF testing since the foundation will provide for auditable test cases, repeatable test results, and improved reliability overall,

## Scenario Testing (End-to-End Testing)

Scenario testing, also known as end-to-end (E2E) testing, focuses on verifying complete user flows in your application, from a user\'s perspective. It ensures that all parts of your system---the frontend, backend, and any external services---work together as expected.

## Component Testing

Component testing focuses on testing individual UI components in isolation, without the need for a full application to be running. Playwright provides an experimental feature for component testing that allows you to mount and test your components in a real browser, which is a significant advantage over testing them in a simulated environment.

Component tests should be focused, fast, and isolated. They verify that a single UI component functions correctly in various states and scenarios. Tests should mock API calls and other external dependencies to ensure isolation.

- Directory Structure: Store component tests in a dedicated tests/components directory.
- Naming Convention: Follow the format \[ComponentName\].spec.ts.

Key Concepts and Best Practices:

- Isolation: Test each component in isolation, mocking dependencies like API calls or global state to ensure the test is focused on the component\'s functionality.
- Mounting: Use Playwright\'s mount fixture to render your component within a real browser page. This gives you a true representation of how the component will behave in a live environment.
- Visual Regression Testing: Take screenshots of your components to detect unintended visual changes. Playwright\'s toMatchSnapshot assertion is perfect for this, as it compares a new screenshot against a baseline.
- Event Handling: Test how components react to user interactions and emit events. Verify that the correct callbacks or state changes occur.

## Regression Testing

Regression tests are designed to ensure that new code changes or feature additions do not break existing, previously working functionality of a component. Regression tests are a comprehensive suite of tests to ensure that new code changes have not introduced new bugs or broken existing functionality. These tests are more detailed than smoke tests and cover all previously identified bugs and critical features.

Procedure:

1. Identify the component\'s core functionality that has been stable and should not change.
2. Develop tests that cover these known-good behaviors.
3. Run these tests frequently to catch regressions early.

# Naming Conventions

Consistent and clear naming is crucial for a maintainable test suite. Following these conventions will make your tests easier to find, understand, and debug.

## Test File Names

- Use a descriptive name that reflects the functionality being tested.
- The name should end with .spec.ts (for TypeScript). This is a standard convention that Playwright and many other test runners recognize.
- Use Camel Case for filenames
- Example: login-page.spec.ts, shopping-cart-checkout.spec.ts

## Test Suite and Test Names

- Use describe() to group related tests. The string argument for describe() should be a high-level description of the feature or component being tested.
- Use test() for individual tests. The string argument for test() should describe the specific behavior or scenario being validated.
- The test name should be a complete sentence that clearly states the action and the expected outcome.
- Avoid vague names like \"test 1\" or \"login\".

# Test Structure

## Arrange-Act-Assert (AAA) Pattern

A well-structured test is easy to read and follow. The Arrange-Act-Assert pattern is a widely adopted standard for organizing tests.

### Arrange (Setup)

This is the setup phase. It\'s where you prepare the state of your application for the test.

- Navigate to the correct URL (page.goto(\...)).
- Set up any necessary data (e.g., mock API responses).
- Define locators for elements you will interact with.

### Act (Action)

This is the action phase. It\'s where you perform the user\'s interaction with the application.

- Click buttons (locator.click()).
- Type into input fields (locator.fill()).
- Interact with the page in the way a user would.

### Assert (Verification)

This is the verification phase. It\'s where we check if the application\'s state or behavior is what you expect.

- Use Playwright\'s expect assertions to verify elements are visible, text is correct, or the URL has changed.
- Examples: expect(locator).toBeVisible(), expect(locator).toHaveText(\...), expect(page).toHaveURL(\...).

Example Test Script with A-A-A Pattern

```javascript
import { test, expect } from '@playwright/test';

test('should successfully add an item to the cart', async ({ page }) => {
  // Arrange: Set up the test environment and data
  await page.goto('https://www.demoblaze.com/'); // Navigate to the application
  await page.click('text="Laptops"'); // Filter by laptops
  await page.click('text="MacBook Air"'); // Select a specific product

  // Act: Perform the action being tested
  await page.click('text="Add to cart"'); // Add the item to the cart
  page.on('dialog', async dialog => {
    await dialog.accept(); // Handle the alert dialog
  });

  // Assert: Verify the expected outcome
  await page.click('text="Cart"'); // Navigate to the cart page
  await expect(page.locator('.success')).toContainText('MacBook Air'); // Verify the item is in the cart
});
```

# Test Design

## Single Responsibility Principle

Each test case should verify a single piece of functionality or a single user behavior. Avoid creating long, complex tests that check multiple unrelated things. This makes debugging easier and test results clearer.

Example: Consider a login flow in a web application. Instead of having one large `LoginPage` class that handles all interactions, validations, and even data management, we can apply SRP by breaking down these responsibilities.

1. `LoginPage` (UI Interaction): This class focuses solely on interacting with the login page elements.

```typescript
// pages/LoginPage.ts
import { Page } from '@playwright/test';export class LoginPage {
  private readonly page: Page;
  private readonly usernameInput = '#username';
  private readonly passwordInput = '#password';
  private readonly loginButton = '#loginButton';  constructor(page: Page) {
    this.page = page;
  }  async navigateToLoginPage() {
    await this.page.goto('/login');
  }  async enterUsername(username: string) {
    await this.page.fill(this.usernameInput, username);
  }  async enterPassword(password: string) {
    await this.page.fill(this.passwordInput, password);
  }  async clickLoginButton() {
    await this.page.click(this.loginButton);
  }
}
```

2. `LoginValidator` (Validation Logic): This class handles all assertions and validations related to the login process.

```typescript
// validators/LoginValidator.ts
import { Page, expect } from '@playwright/test';

export class LoginValidator {
  private readonly page: Page;
  private readonly errorMessage = '.error-message';
  private readonly successMessage = '.success-message';

  constructor(page: Page) {
    this.page = page;
  }

  async expectLoginSuccess() {
    await expect(this.page.locator(this.successMessage)).toBeVisible();
  }

  async expectLoginFailure(expectedMessage: string) {
    await expect(this.page.locator(this.errorMessage)).toBeVisible();
    await expect(this.page.locator(this.errorMessage)).toHaveText(expectedMessage);
  }
}
```

3. `Test File` (Orchestration): The test file orchestrates the actions and validations, bringing together the different components.

```typescript
// tests/login.spec.ts
import { test } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { LoginValidator } from '../validators/LoginValidator';

test.describe('Login Functionality', () => {
  let loginPage: LoginPage;
  let loginValidator: LoginValidator;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    loginValidator = new LoginValidator(page);
    await loginPage.navigateToLoginPage();
  });

  test('should allow successful login with valid credentials', async () => {
    await loginPage.enterUsername('validUser');
    await loginPage.enterPassword('validPassword');
    await loginPage.clickLoginButton();
    await loginValidator.expectLoginSuccess();
  });

  test('should prevent login with invalid credentials', async () => {
    await loginPage.enterUsername('invalidUser');
    await loginPage.enterPassword('invalidPassword');
    await loginPage.clickLoginButton();
    await loginValidator.expectLoginFailure('Invalid username or password.');
  });
});
```

By separating the concerns into distinct classes, each with a single responsibility, the code becomes more organized, easier to understand, and simpler to modify or extend. For instance, if the error message locator changes, only `LoginValidator` needs modification, not the `LoginPage` or the test file itself.

## Structure Tests for Clarity

**Problem:** The second test includes cleanup logic (deleting the form) at the end of the test block. If an assertion fails midway through the test, this cleanup code will never run, leaving test data in the system.

**Improvement:** Use test.describe to group related tests and move the cleanup logic into an afterEach hook. This ensures the cleanup runs regardless of whether the test passes or fails.

```javascript
import { test, expect } from '@playwright/test';

// Define a describe block for login functionality tests
test.describe('Login Functionality', () => {
  // Test case for successful login
  test('should allow a user to log in with valid credentials', async ({ page }) => {
    await page.goto('https://example.com/login');
    await page.fill('input[name="username"]', 'validUser');
    await page.fill('input[name="password"]', 'validPassword');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('https://example.com/dashboard');
    await expect(page.locator('.welcome-message')).toContainText('Welcome, validUser!');
  });

  // Test case for failed login with invalid credentials
  test('should show an error message with invalid credentials', async ({ page }) => {
    await page.goto('https://example.com/login');
    await page.fill('input[name="username"]', 'invalidUser');
    await page.fill('input[name="password"]', 'invalidPassword');
    await page.click('button[type="submit"]');
    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page.locator('.error-message')).toContainText('Invalid username or password.');
  });

  // Test case for missing credentials
  test('should prevent login with empty credentials', async ({ page }) => {
    await page.goto('https://example.com/login');
    await page.click('button[type="submit"]'); // Attempt to submit with empty fields
    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page.locator('.error-message')).toContainText('Please enter your username and password.');
  });
});

// Another describe block for a different feature
test.describe('Product Page Functionality', () => {
  test('should display product details correctly', async ({ page }) => {
    await page.goto('https://example.com/products/item1');
    await expect(page.locator('.product-title')).toContainText('Product One');
    await expect(page.locator('.product-price')).toContainText('$19.99');
  });
});
```

## Resilient/No flaky tests

### Auto-wait

Playwright waits for elements to be actionable prior to performing actions. It also has a rich set of introspection events. The combination of the two eliminates the need for artificial timeouts - a primary cause of flaky tests.

### Web-first assertions.

Playwright assertions are created specifically for the dynamic web. Checks are automatically retried until the necessary conditions are met.

### Tracing

Configure test retry strategy, capture execution trace, videos and screenshots to eliminate flakes.

Here\'s a breakdown of Playwright\'s test hooks, along with best practices on when to use each one.

## Playwright Test Hooks

Playwright provides four primary hooks for managing test setup and teardown: beforeAll, beforeEach, afterAll, and afterEach. Understanding when to use each is key to writing efficient and reliable tests. A summary table is below, followed up by more details on each hook.

| Hook       | When to Use                                 | Typical Tasks                                          |
| ---------- | ------------------------------------------- | ------------------------------------------------------ |
| beforeAll  | One-time setup before all tests in a file.  | Database connection, creating a shared user account.   |
| beforeEach | Setup before each individual test.          | Navigating to a URL, logging in, resetting state.      |
| afterEach  | Cleanup after each individual test.         | Logging out, clearing local storage.                   |
| afterAll   | One-time cleanup after all tests in a file. | Disconnecting from a database, deleting a shared user. |

### beforeAll

Use beforeAll to set up resources or state **once** before all the tests in a file run. This is ideal for tasks that are expensive to perform and can be shared across multiple tests.

Best Practices:

- Database Connections: Establish a connection to a test database or start a mock server.
- Fixture Initialization: Create and load data that will be used by all tests in the file, like setting up a user account.
- Browser/Context Setup: Although Playwright manages browser context for you, you can use beforeAll for more complex, one-time browser setup if needed.

### beforeEach

Use beforeEach to set up a clean, isolated state **before each individual test** runs. This ensures that each test starts from a known, predictable state and doesn\'t depend on the outcome of previous tests.

Best Practices:

- Page Navigation: Navigate to a specific page or URL for each test.
- Login/Authentication: Log in as a user for each test, ensuring a clean session.
- Mocking APIs: Reset or configure mock API responses to prevent tests from interfering with each other.

### afterEach

Use afterEach to clean up resources or state **after each individual test** has finished. This is the counterpart to beforeEach and is crucial for leaving a clean slate for the next test.

Best Practices:

- Log Out: Log out of the application to ensure the next test starts with a fresh session.
- State Reset: Reset form fields, local storage, or other application state modified by the test.
- Screenshot/Artifact Cleanup: Delete any screenshots or test artifacts generated during the test run.

### afterAll

Use afterAll to tear down resources **once** after all tests in a file have completed. This is the counterpart to beforeAll and is essential for releasing shared resources.

Best Practices:

- Database Cleanup: Disconnect from the database, close a mock server, or delete a shared test user created in beforeAll.
- File/Directory Deletion: Remove temporary files or directories created during the test run.

## Full isolation/Fast execution

> *\[NOTE: The Team is working towards maturing the framework to support full isolation.\]*

### Browser contexts

Playwright creates a browser context for each test. Browser context is equivalent to a brand new browser profile. This delivers full test isolation with zero overhead. Creating a new browser context only takes a handful of milliseconds.

### Log in once

Save the authentication state of the context and reuse it in all the tests. This bypasses repetitive log-in operations in each test, yet delivers full isolation of independent tests.

## Assertions and Synchronization

### Use Web-First Assertions

Always use Playwright\'s built-in expect for assertions. It has auto-waiting capabilities, which means it will wait for a condition to be met before failing, making tests more stable.

- Correct: await expect(locator).toBeVisible();
- Incorrect: const isVisible = await locator.isVisible(); expect(isVisible).toBe(true);

### Avoid Manual Waits

Do not use fixed timeouts like page.waitForTimeout(5000). Playwright\'s auto-waiting handles most synchronization issues. If you need to wait for a specific condition that isn\'t covered by an assertion, use an explicit wait function like page.waitForFunction() or page.waitForSelector().

## Selector Strategy

To build resilient tests that don\'t break with minor UI changes, follow this prioritized order for selecting elements. Avoid brittle selectors like complex XPath or dynamic class names.

1. User-Facing Locators: Prioritize selectors that a user would see.
   * page.getByRole(): For accessibility roles (e.g., button, link, checkbox).
   * page.getByText(): For elements with specific text content.
   * page.getByLabel(): For form controls associated with a label.
   * page.getByPlaceholder(): For inputs with placeholder text.
2. Test IDs: For elements that lack clear user-facing attributes, use a dedicated test ID.
   * Attribute: Use data-testid. Example: `<button data-testid="submit-button">`Submit `</button>`.
   * Selector: page.getByTestId('submit-button').
3. CSS Selectors: Use as a last resort. Keep them simple and tied to stable attributes like id.

### Example of Using Robust, Non-Fragile Selectors

#### Issue: Calculating Selectors from UI Text

The logic to determine questionId and editIdData is extremely fragile. It relies on parsing UI text like \"Add sub-question to Section 2\". If this text ever changes (e.g., a word is added or the number is removed), the test will break completely.

```typescript
// From the original script - VERY FRAGILE
let questionId = await page.textContent(\'#leaf_dialog_content_drag_handle\');
let str2 = questionId;
let seperateStr = str2.split(\"to\", 2);

// \... more logic to calculate a number \...
let editIdData = \`#edit_conditions\_\${questionIdnum}\`;
await page.locator(editIdData).click();
```

**Improvement:** Use relationship-based locators. Locate elements based on their position relative to stable text. This is far more resilient to change.

```typescript
// A more robust way to locate the button
const questionTwo = \"Where do you go to school?\";
const questionContainer = page.locator(\'.question-container\', { hasText: questionTwo });
await questionContainer.getByRole(\'button\', { name: \'Edit Conditions\' }).click();
```

#### Issue 2: Using Index-Based Selectors

In the first test, locator(\'#format_label_3\') relies on a \"magic number\" (3). If other fields are added or the order changes, this selector will fail or target the wrong element.

**Improvement:** Locate the element by the unique text you just created.

```typescript
// Instead of this:
await expect(page.locator(\'#format_label_3\')).toContainText(uniqueText);
```

```typescript
// Use this:
await expect(page.getByRole(\'heading\', { name: uniqueText })).toBeVisible();
```

### Example of Simplifying Actions and Relying on Auto-Waiting

#### Issue -- Repetitive use of click() before fill()

Repetitive using .click() before .fill(), which is redundant as fill() first clicks the element. It also uses waitForLoadState(\'domcontentloaded\') multiple times, which is often unnecessary because Playwright\'s auto-waiting mechanism waits for elements to be actionable before interacting with them.

**Improvement:** Simplify the actions and remove unnecessary waits. Trust Playwright's auto-waiting.

```typescript
// Instead of this:
await page.getByRole(\'textbox\', { name: \'Section Heading\' }).click()
await page.getByRole(\'textbox\', { name: \'Section Heading\' }).fill(sectionHeading);
await page.waitForLoadState(\'domcontentloaded\');
```

```typescript
// Use this:
await page.getByRole(\'textbox\', { name: \'Section Heading\' }).fill(sectionHeading);
```

# Test Data

## Isolate Test Data

Never hardcode test data (URLs, credentials, user details) directly in the test files. Test data is stored in separate files (.json, .ts) or environment variables.

- Static Data: Use JSON files for data like user credentials. Import them into your tests.
- Dynamic Data: Use libraries like Faker.js to generate realistic data on the fly.

To ensure test consistency and reusability, all test data will be managed from a centralized source. This approach simplifies maintenance and allows test cases to programmatically create their required data sets before execution.

Procedure:

1. Create a dedicated directory for test data (e.g., tests/data).
2. Within this directory, module (e.g., tests/data/test_data.js) will export reusable data sets. This can be a simple JSON object or a function that returns data.
3. Each test case will import and use this data source to populate its specific test data set, as shown in the examples below.

## State Management

For tests that require an authenticated state, use storageState feature:

- Create a setup test that logs in once and saves the session state (cookies, local storage) to a file.
- Subsequent tests can then reuse this state, making them much faster.

Example: playwright.config.ts:

```typescript
import { defineConfig } from \'@playwright/test\';

export default defineConfig({
    projects: \[
        {
            name: \'setup\',
testMatch: /.\*\\.setup\\.ts /,
},
    {
        name: \'chromium\',
use: {
    storageState: \'playwright/.auth/user.json\',
},
    dependencies: \[\'setup\'\],
},
    \],
});
```

# Code Review and Maintenance

## Mandatory Peer Review

All new and modified test code must be reviewed by at least one other team member before being merged. The review should focus on:

- Adherence to this SOP.
- Clarity, readability, and maintainability.
- Correctness and robustness of selectors and assertions.

## Regular Maintenance

- Regularly review the test suite to refactor flaky tests.
- A test that fails intermittently should be investigated, fixed, or quarantined immediately to ensure the build remains reliable.
- Update tests promptly to reflect changes in the application\'s UI or functionality.

# Execution and Reporting

## CI/CD Integration\*

All tests should integrated into the CI/CD pipeline to run on every pull request or merge to the main branch. This ensures immediate feedback on code changes and will direfctly supports automated text execution.

A core principle of this SOP is that successful component-level testing is a prerequisite for end-to-end (E2E) testing. After a component passes all of its smoke and regression tests, it is considered stable and is a candidate to be used within the broader E2E test suite.

Procedure

- E2E Test Run: The test suite is executed as part of the CI/CD pipeline\'s build stage.
- Pass/Fail Status: The pipeline checks the exit code of the Playwright test run. A successful run (exit code 0) indicates all component tests passed.

  - Report is stored in GitHub
- Handoff: If the component tests are successful, the CI/CD pipeline proceeds to the next stage, which involves deploying the built application to a staging environment and running the full E2E test suite. This ensures that the component, in combination with other components, functions correctly within the complete application.

## Parallel Execution

Enable test parallelization in playwright.config.ts to significantly reduce execution time.

> *NOTE: Playwright handles this automatically by running tests in separate worker processes.*

## Retry Strategy

Configure retries for failed tests in the CI environment to handle occasional flakiness (e.g., due to network hiccups).

NOTE: A common practice is to allow 1 or 2 retries on CI.

```typescript
// In playwright.config.ts
retries: process.env.CI ? 2 : 0,
```

## Reporting

Use the built-in HTML reporter for a detailed overview of test run to analyze test results and identify failures. This report includes traces, screenshots, and videos for failed tests, which is essential for debugging.
