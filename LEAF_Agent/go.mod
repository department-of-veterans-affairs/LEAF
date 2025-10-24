module leaf-agent

go 1.25

require github.com/department-of-veterans-affairs/LEAF/pkg/form v0.0.0-00010101000000-000000000000

replace github.com/department-of-veterans-affairs/LEAF/pkg/form => ../pkg/form

require github.com/department-of-veterans-affairs/LEAF/pkg/form/query v0.0.0-20250930151516-28db1e3cc383

replace github.com/department-of-veterans-affairs/LEAF/pkg/form/query => ../pkg/form/query

require github.com/department-of-veterans-affairs/LEAF/pkg/portal/group v0.0.0-00010101000000-000000000000

replace github.com/department-of-veterans-affairs/LEAF/pkg/portal/group => ../pkg/portal/group

require github.com/department-of-veterans-affairs/LEAF/pkg/agent v0.0.0-00010101000000-000000000000

replace github.com/department-of-veterans-affairs/LEAF/pkg/agent => ../pkg/agent

require (
	github.com/department-of-veterans-affairs/LEAF/pkg/workflow v0.0.0-00010101000000-000000000000
	github.com/microcosm-cc/bluemonday v1.0.27
)

require (
	github.com/aymerick/douceur v0.2.0 // indirect
	github.com/gorilla/css v1.0.1 // indirect
	golang.org/x/net v0.44.0 // indirect
)

replace github.com/department-of-veterans-affairs/LEAF/pkg/workflow => ../pkg/workflow
replace golang.org/x/net => github.com/golang/net v0.44.0
