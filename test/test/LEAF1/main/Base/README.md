# LEAF Testing

LEAF uses:

* [PHPUnit](https://phpunit.de/) for unit testing.
* [Phinx](https://phinx.org/) for database migrations.

### Configuring Phinx

Each testing project has it's own Phinx configuration since the two databases are independent of each other.

Create two database tables for testing Nexus and Portal: `nexus_testing` and `portal_testing`.

Copy [LEAF_Nexus_Tests/phinx.yml.example](LEAF_Nexus_Tests/phinx.yml.example) and [LEAF_Request_Portal_Tests/phinx.yml.example](LEAF_Request_Portal_Tests/phinx.yml.example) and rename them to `phinx.yml` in their respective directories. `phinx.yml` should not be committed to the repository. 

Edit `LEAF_Nexus_Tests/phinx.yml` and `LEAF_Request_Portal_Tests/phinx.yml` and set your system specific variables.

Within each test project directory, run the migrations:

```bash
phinx migrate 
```

#### Creating Migrations

To create a new database migration, within that test project directory:

```bash
phinx create TheNewMigration
```

This creates a basic time-stamped template within the projects `db/migrations` directory for executing a database migration. 

LEAF relies on pure SQL files for migrations, so the `up()` function for each migration should read in the appropriate SQL file and execute its contents. See [this migration](LEAF_Request_Portal_Tests/db/migrations/20180301164659_init_portal.php) for an example of this.

No "tear down" SQL files exist, so the `down()` function can either be pure SQL, or use the Phinx API to accomplish the reverse of the `up()` function.

The unit tests themselves should never run migrations, only seeds.

#### Creating Seeds

Seeding the database is main purpose of Phinx within LEAF. To create a new seed, within the Nexus/Portal test project directory:

```bash
phinx seed:create SeederClassName

# run the seed
phinx seed:run -s SeederClassName
```

This creates a basic template within the projects `db/seeds` for executing a database seed. Note that, unlike migrations, the seed file is not time-stamped. Seeds can be called by name at any time and should reflect a specific task (seeding base data, setting up a specific form, etc..).

Reading and executing a pure SQL file is not required for seeding purposes (unlike migrations). The `Phinx` API can be used to seed data.

## Running Tests

All tests should be run from the project specific test directory (`LEAF_Nexus_Tests` or `LEAF_Request_Portal_Tests`), the `include` paths and `PHPUnit/Phinx` configs depend on it.

The following will run all tests in the [LEAF_Nexus_Tests/tests](LEAF_Nexus_Tests) directory if run from the `LEAF_Nexus_Tests` directory:

```bash
phpunit --bootstrap ../bootstrap.php tests
```

To run tests in a subdirectory (in this example `utils`):

```bash
phpunit --bootstrap ../bootstrap.php tests/utils 
```

To run a single test method from a test class (in this example, from [CryptoHelpersTest](LEAF_Request_Portal_Tests/tests/helpers/CryptoHelpersTest.php)):

```bash
phpunit --bootstrap ../bootstrap.php tests/helpers --filter testVerifySignature_authentic
```

These are useful when the entire suite of tests does not need to be run.

Currently, the values in:

```
LEAF_Nexus/globals.php
LEAF_Nexus/config.php
LEAF_Request_Portal/globals.php
LEAF_Request_Portal/db_config.php
```

need to be updated to the same database name/user/pass that was used when configuring the test databases (`nexus_testing`, `portal_testing`). In other words, make sure the LEAF application isn't configured to use the production/dev databases or any database tests will fail. 

The `bootstrap.php` file autoloads the classes/files in the `shared/src` directory and others, via the file list found in `test_includes.php`. If a new source file is added in the `shared/src` directory, add the file to `test_includes.php`. If you are setting up the environment for the first time or are having problems with included files try running this command from the `/tests` directory:
```bash
composer dump-autoload
```

## Writing Tests

There are currently two senarios for writing tests in LEAF:

#### New API endpoints

All tests for new API endpoints should live in the `tests` directory of each projects root directory (e.g. `LEAF_Nexus_Tests`).

When deciding where to place a test that requires database interaction, it should be the project it interacts with the most. For example, [CryptoHelpersTest](LEAF_Request_Portal_Tests/tests/helpers/CryptoHelpersTest.php) actually tests [CryptoHelpers](../libs/php-commons/CryptoHelpers.php) in the [libs](../libs/php-commons) project, but the test interacts with the [Request Portal](../LEAF_Request_Portal) database, so it lives in the [LEAF_Request_Portal_Tests](LEAF_Request_Portal_Tests) directory.

#### Functions in classes without endpoints

Due to the intricate nature of how database access is configured, any methods in classes that do not have direct endpoint access need to have endpoints written for them within the [LEAF_test_endpoints](LEAF_test_endpoints) directory for each project (e.g. [nexus](LEAF_test_endpoints), [request_portal](LEAF_test_endpoints/request_portal)). Tests should be placed according to the rules in the section above.

A controller file should be created for each class being tested, then added to the controller index file in the root folder (e.g. [nexus/index.php](LEAF_test_endpoints/nexus/index.php)). 

An endpoint can be added for each function to be tested, or a `genericFunctionCall` endpoint can be implemented. An example of the `genericFunctionCall` endpoint can be seen in [FormEditorController.php](LEAF_test_endpoints/request_portal/controllers/FormEditorController.php) and the test that calls it in [FormEditorControllerTest.php](LEAF_Request_Portal_Tests/tests/api/FormEditorControllerTest.php) (`testSetFormatGeneric()`). Just make a call to `whateverController/genericFunctionCall/[text]` where `[text]` is replaced with the name of the function, preceded by an underscore:

```
formEditor/genericFunctionCall/_setFormat
```

Then send parameters as formParams in the correct order.

### LEAFClient

For testing HTTP/API endpoints, [LEAFClient](shared/src/LEAFClient.php) is configured for LEAF and
authenticated to make API calls against both Nexus and Request Portal.

Each client create function accepts two parameters: the base URL to make requests against and the URL to authenticate against. See below for examples:

```php
$defaultNexusClient = LEAFClient::createNexusClient();
$defaultPortalClient = LEAFClient::createRequestPortalClient();
$testEndpointNexusClient = LEAFClient::createNexusClient('http://localhost/test/LEAF_test_endpoints/nexus/', '../../../LEAF_Nexus/auth_domain/');
$testEndpointPortalClient = LEAFClient::createRequestPortalClient('http://localhost/test/LEAF_test_endpoints/request_portal/', '../../../LEAF_Request_Portal/auth_domain/');

// clients with different base API URLs
$nexusClient = LEAFClient::createNexusClient("https://some_url/Nexus/api/");
$portalClient = LEAFClient::createRequestPortalClient("https://some_url/Portal/api/");

$getResponse = $portalClient->get(array('a' => 'group/1/employees', 'getKey' => 'getValue'));
$postResponse = $nexusClient->post(array('a' => '...'), array('formField' => 'fieldValue'));
```

The `LEAFClient` can format the response. Currently the supported types are:

* JSON

```php
$jsonResponse = LEAFClient::get(array('a' => '...'), array('formField' => 'fieldValue'), '', LEAFResponseType::JSON);
```
### Accessing database data

Sometimes it might be useful to access the database to test the outcome of some function calls. This can be accomplished by using the standard database access classes. Like so:

```php
private static $db;

public static function setUpBeforeClass()
{
    $db_config = new DB_Config();

    //portal DB
    self::$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

    //nexus DB
    self::$db = new DB($db_config->phonedbHost, $db_config->phonedbUser, $db_config->phonedbPass, $db_config->phonedbName);
}

public function test() : void
{
    $action = 'formEditor/setFormat';

    $queryParams = array('a' => $action);
    $formParams = array('indicatorID' => '1', 'format' => 'whatever');
    self::$testEndpointClient->post($queryParams, $formParams);

    $var = array(':indicatorID' => 1);
    $res = self::$db->prepared_query('SELECT format
                                        FROM indicators
                                        WHERE indicatorID=:indicatorID', $var);

    $this->assertFalse(empty($res));
    $this->assertEquals('whatever', $res[0]['format']);
}
```

### DatabaseTest

To write a test against the database, extend the [DatabaseTest](shared/src/DatabaseTest.php) class. It provides a few methods for seeding the database (using `Phinx`). See [GroupTest.php](LEAF_Nexus_Tests/tests/api/GroupTest.php) for an example.

#### Common Seeds

`DatabaseTest` makes use of a few "shared" seeds. These are seeds that have the same name, but are implemented for the project they reside in. This allows the test superclass to work across all test projects in a predictable way.

```php
BaseTestSeed    // populates with the bare minimum amount of data to 
                // successfully run unit tests

InitialSeed     // populates with the data was supplied when the 
                // database is created from scratch

TruncateTables  // clears all data from all tables
```

## Running Code Coverage

To run the code coverage reports, execute the following commands:

```
      cd ./docker

      docker-compose exec php /var/www/html/test/run_tests.sh
```

The report will be available at [http://localhost/test/cov/report/](http://localhost/test/cov/report/)
