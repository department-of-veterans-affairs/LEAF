# LEAF Testing

LEAF uses:

* [PHPUnit](https://phpunit.de/) for unit testing.
* [Phinx](https://phinx.org/) for database migrations.

## Setup

Checkout branch origin/feature/docker-unit-testing/test and edit the following:

Comment out in LEAF_Request_Portal/api/RESTfulResponse.php and LEAF_Nexus/api/RESTfulResponse.php the conditionals for POST and DELETE cases in the handler method like so.

```bash
case 'POST':
//   if($_POST['CSRFToken'] == $_SESSION['CSRFToken']) {
        $this->output($this->post($action));
//   }
//   else {
//       $this->output('Invalid Token.');
//   }
    break;
case 'DELETE':
//   if($_GET['CSRFToken'] == $_SESSION['CSRFToken']) {
        $this->output($this->delete($action));
//   }
//   else {
//       $this->output('Invalid Token.');
//   }
    break;
```

Add this to the top of the LEAF_Request_Portal/db_config.php and under the Orgchart namespace in LEAF_Nexus/config.php
```bash
$_SERVER["REMOTE_USER"] = "\\tester”;
```


<!-- Install [composer](https://getcomposer.org/).

Composer handles any PHP dependencies for the testing project. Initialize composer dependencies with:

```bash
composer install
```

Composer will install `PHPUnit` and `Phinx`, so they do not need to installed separately. Both `PHPUnit` and `Phinx` can be installed globally to avoid the `./vendor/bin/` prefix when running commands, just make sure the versions installed globally match the versions listed in [composer.json](composer.json).  -->

### Configuring Phinx

In test/LEAF_Request_Portal_Tests/phinx.yml, change the following.
```bash
environments:
    default_database: portal_testing

    portal_testing:
        host: phpunit-database
        name: portal_testing
        user: tester
        pass: 'tester'
```
In test/LEAF_Nexus_Tests/phinx.yml, change the following.
```bash
environments:
    default_database: nexus_testing

    nexus_testing:
        host: phpunit-database
        name: nexus_testing
        user: tester
        pass: 'tester'
```
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

Navigate to these inside the docker containers by doing
```bash
docker-compose exec phpunit bash
```
Then enter the directories through
```bash
cd /app/test/LEAF_Request_Portal_Tests or /app/test/LEAF_Nexus_Tests
```
Finally, run the test with
```bash
./run_tests.sh
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

The `bootstrap.php` file autoloads the classes/files in the `shared/src` directory. If
a new source file is added in the `shared/src` directory, add the file in the
`autoload/files` section of `composer.json`, then regenerate the autoload file
with:

```bash
composer dump-autoload
```

## Writing Tests

All tests should live in the `tests` directory of each projects root directory (e.g. `LEAF_Nexus_Tests`).

When deciding where to place a test that requires database interaction, it should be the project it interacts with the most. For example, [CryptoHelpersTest](LEAF_Request_Portal_Tests/tests/helpers/CryptoHelpersTest.php) actually tests [CryptoHelpers](../libs/php-commons/CryptoHelpers.php) in the [libs](../libs/php-commons) project, but the test interacts with the [Request Portal](../LEAF_Request_Portal) database, so it lives in the [LEAF_Request_Portal_Tests](LEAF_Request_Portal_Tests) directory.

### LEAFClient

For testing HTTP/API endpoints, [LEAFClient](shared/src/LEAFClient.php) is configured for LEAF and
authenticated to make API calls against both Nexus and Request Portal.

Each client create function accepts a single parameter to use as the base URL to make requests against. By default, both point to `localhost`.

```php
$defaultNexusClient = LEAFClient::createNexusClient();
$defaultPortalClient = LEAFClient::createRequestPortalClient();

// clients with different base API URLs
$nexusClient = LEAFClient::createNexusClient("https://some_url/Nexus/api/");
$portalClient = LEAFClient::createRequestPortalClient("https://some_url/Portal/api/");

$getResponse = $portalClient->get('?a=group/1/employees');
$postResponse = $nexusClient->post('?a=...', ["formField" => "fieldValue"]);
```

The `LEAFClient` can format the response. Currently the supported types are:

* JSON

```php
$jsonResponse = LEAFClient::get('/LEAF...', LEAFResponseType::JSON);
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

## TODO

* Enable `POST` requests against the API, needs `CSRF` token
