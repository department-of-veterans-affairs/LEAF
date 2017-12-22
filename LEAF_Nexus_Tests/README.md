# LEAF Nexus Testing

## Setup

Install [composer](https://getcomposer.org/).

Composer handles any PHP dependencies for the testing project. Initialize composer dependencies with:

```bash
composer install
```

Composer will install PHPUnit, so it does not need to installed separately.

## Running Tests

```bash
phpunit --bootstrap bootstrap.php tests
```

or execute the included script: `run_tests.sh`.

The `bootstrap.php` file autoloads the classes/files in the `src` directory. If
a new source file is added in the `src` directory, add the file in the
`autoload/files` section of `composer.json` the regenerate the autoload file
with:

```bash
composer dump-autoload
```

## Writing Tests

All tests should live in the `tests` directory.

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
* Setup separate testing database? Currently uses local dev database.
