# LEAF End-to-end testing

TODO: Add overview

## Useful commands

Start Playwright's code generator UI:
```
npx playwright codegen --ignore-https-errors https://host.docker.internal/Test_Request_Portal/
```

Debug tests:
```
npx playwright test --ui
```

View trace:
```
npx playwright show-trace [path to trace.zip]
```
