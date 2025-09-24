module leaf-agent

go 1.25

require github.com/department-of-veterans-affairs/LEAF/pkg/form v0.0.0-00010101000000-000000000000

replace github.com/department-of-veterans-affairs/LEAF/pkg/form => ../pkg/form

require github.com/department-of-veterans-affairs/LEAF/pkg/form/query v0.0.0-00010101000000-000000000000

replace github.com/department-of-veterans-affairs/LEAF/pkg/form/query => ../pkg/form/query

require github.com/department-of-veterans-affairs/LEAF/pkg/portal/group v0.0.0-00010101000000-000000000000

replace github.com/department-of-veterans-affairs/LEAF/pkg/portal/group => ../pkg/portal/group

require (
	github.com/department-of-veterans-affairs/LEAF/pkg/workflow v0.0.0-00010101000000-000000000000
	github.com/microcosm-cc/bluemonday v1.0.27
)

require (
	github.com/aymerick/douceur v0.2.0 // indirect
	github.com/gorilla/css v1.0.1 // indirect
	golang.org/x/net v0.26.0 // indirect
)

replace github.com/department-of-veterans-affairs/LEAF/pkg/workflow => ../pkg/workflow
