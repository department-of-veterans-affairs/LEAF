# LEAF Testing

LEAF uses:

* [PHPUnit](https://phpunit.de/) for unit testing.
* [Phinx](https://phinx.org/) for database migrations.

## Setup

Install [composer](https://getcomposer.org/).

Composer handles any PHP dependencies for the testing project. Initialize composer dependencies with:

```bash
composer install
```

Composer will install `PHPUnit` and `Phinx`, so they do not need to installed separately. Both `PHPUnit` and `Phinx` can be installed globally to avoid the `./vendor/bin/` prefix when running commands, just make sure the versions installed globally match the versions listed in [composer.json](composer.json). 

### Configuring Phinx

Each testing project has it's own Phinx configuration since the two databases are independent of each other.

Create two database tables for testing Nexus and Portal: `nexus_testing` and `portal_testing`.

Edit [LEAF_Nexus_Tests/phinx.yml](LEAF_Nexus_Tests/phinx.yml) and [LEAF_Request_Portal_Tests/phinx.yml](LEAF_Request_Portal_Tests/phinx.yml) and set your system specific variables.

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
```

This creates a basic template within the projects `db/migrations` for executing a database seed. Note that, unlike migrations, the seed file is not time-stamped.

Reading and executing a pure SQL file is not required for seeding purposes (unlike migrations). The `Phinx` API can be used to seed data.

## Running Tests

All tests should be run from the project specific test directory (`LEAF_Nexus_Tests` or `LEAF_Request_Portal_Tests`), the `include` paths and `PHPUnit/Phinx` configs depend on it.

The following will run all tests in the [LEAF_Nexus_Tests/tests](LEAF_Nexus_Tests) directory if run from the `LEAF_Nexus_Tests` directory:

```bash
phpunit --bootstrap ../bootstrap.php tests
```

To run tests in a subdirectory (in this case `utils`):

```bash
phpunit --bootstrap ../bootstrap.php tests/utils 
```

This is useful when the entire suite of tests does not need to be run.

The `bootstrap.php` file autoloads the classes/files in the `shared/src` directory. If
a new source file is added in the `shared/src` directory, add the file in the
`autoload/files` section of `composer.json`, then regenerate the autoload file
with:

```bash
composer dump-autoload
```

## Writing Tests

All tests should live in the `tests` directory of each projects root directory (e.g. `LEAF_Nexus_Tests`).

### LEAFClient

For testing HTTP/API endpoints, `LEAFClient` is configured for LEAF and
authenticated to make API calls.

```php
$getResponse = LEAFClient::get('/LEAF_Nexus/api/?a=...');
$postResponse = LEAFClient::post('/LEAF_Nexus/api/?a=...', ["formField" => "fieldValue"]);
```

The `LEAFClient` can format the response. Currently the supported types are:

* JSON

```php
$jsonResponse = LEAFClient::get('/LEAF...', LEAFResponseType::JSON);
```

### DatabaseTest

To write a test against the database, extend the [DatabaseTest](shared/src/DatabaseTest.php) class. It provides a few methods for seeding the database (using `Phinx`). See [GroupTest.php](LEAF_Nexus_Tests/tests/api/GroupTest.php) for an example.

## TODO

* Enable `POST` requests against the API, needs `CSRF` token