# LEAF Javascript Testing

LEAF Javascript testing uses:

* [Yarn](https://yarnpkg.com)
* [Jest](https://facebook.github.io/jest)

## Setup

Install [Yarn](https://yarnpkg.com).

Yarn handles any dependencies for testing Javascript usage within LEAF. Initialize dependencies by running the following within this directory:

```bash
yarn install
```

Yarn will install `Jest`, so it does not need to be installed separately.

## Running Tests

Within this directory:

```bash
yarn test
```

## Writing Tests

In order to be required within a test file, the Javascript module being tested must have its methods exported. See [XSSHelpers.js](../../libs/js/LEAF/XSSHelpers.js) for an example.

Javascript tests should have the same filename as the file being tested, but with `test.js` as the extension. See [XSSHelpers.test.js](libs/LEAF/XSSHelpers.test.js) for an example of unit tests written with Jest.