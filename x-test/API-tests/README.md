# LEAF API Testing

This test suite should exercise access rules, data accuracy, and measure performance within hotpaths for the LEAF API. ***Currently only compatible with Sprint-60-c2 and newer, due to recent containerization changes.***

This leverages an existing [LEAF docker development environment](https://github.com/department-of-veterans-affairs/LEAF/blob/master/docs/InstallationConfiguration.md), and temporarily uses a predefined test database.

TODO:
1. Need a more streamlined way to visualize results from benchmarks between different releases

## Prerequisites
- Install [LEAF docker development environment](https://github.com/department-of-veterans-affairs/LEAF/blob/master/docs/InstallationConfiguration.md)
- The LEAF docker development environment must be running
  - If the test database's username/password in is different than tester/tester, update dbsetup_test.go

# Docker Environment

## Run
Navigate to the docker directory, then run:
```
docker compose up --remove-orphans
```


# Native Environment

## Prerequisites
- Install Go

## Run tests
-v is verbose output, will show more information on all the test.
```
go test -v
```

## Run benchmarks
```
go test -run="^$" -bench=. -count=3
```

## Benchmark analysis

Prerequisite:
```
go install golang.org/x/perf/cmd/benchstat
```

Store results:
```
go test -run="^$" -bench=. -count=10 > sprint61.txt
```

Compare:
```
benchstat sprint60.txt sprint63.txt
```

Example output:
```
goos: windows
goarch: amd64
pkg: LEAF/API-tester
cpu: 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz
                           │ sprint60.txt │            sprint63.txt             │
                           │    sec/op    │   sec/op     vs base                │
Homepage_defaultQuery-8       57.46m ± 3%   58.15m ± 3%        ~ (p=0.190 n=10)
Inbox_nonAdminActionable-8   315.92m ± 3%   80.22m ± 2%  -74.61% (p=0.000 n=10)
geomean                       134.7m        68.30m       -49.31%
```
