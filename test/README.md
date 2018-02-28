# LEAF Nexus Testing

LEAF uses [PHPUnit](https://phpunit.de/) for unit testing.

**NOTE**: Currently these tests rely on data from the developers local database. This will be different from developer to developer. Expect these tests to randomly fail until a proper set of test data is available.

## Setup

Install [composer](https://getcomposer.org/).

Composer handles any PHP dependencies for the testing project. Initialize composer dependencies with:

```bash
composer install
```

Composer will install PHPUnit, so it does not need to installed separately.

## Running Tests

All tests should be run from this directory (`test`), the `include` paths in all the PHP files depend on it.

The following will run all tests in the [LEAF_Nexus_Tests/tests](LEAF_Nexus_Ttests) directory:

```bash
phpunit --bootstrap bootstrap.php LEAF_Nexus_Tests/tests
```

To run tests in a subdirectory:

```bash
phpunit --bootstrap bootstrap.php path/to/tests/subdirectory
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

## TODO

* Enable `POST` requests against the API, needs `CSRF` token
* Create test data