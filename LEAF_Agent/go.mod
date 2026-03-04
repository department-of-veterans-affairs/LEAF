module leaf-agent

go 1.25.0

require github.com/department-of-veterans-affairs/LEAF/pkg/form v0.0.0-20260304194100-125d6b3ce913 // indirect

replace github.com/department-of-veterans-affairs/LEAF/pkg/form => ../pkg/form

require github.com/department-of-veterans-affairs/LEAF/pkg/form/query v0.0.0-20260304194100-125d6b3ce913 // indirect

replace github.com/department-of-veterans-affairs/LEAF/pkg/form/query => ../pkg/form/query

require github.com/department-of-veterans-affairs/LEAF/pkg/portal/group v0.0.0-20260304194100-125d6b3ce913 // indirect

replace github.com/department-of-veterans-affairs/LEAF/pkg/portal/group => ../pkg/portal/group

require github.com/department-of-veterans-affairs/LEAF/pkg/agent v0.0.0-20260304194100-125d6b3ce913

replace github.com/department-of-veterans-affairs/LEAF/pkg/agent => ../pkg/agent

require (
	github.com/aymerick/douceur v0.2.0 // indirect
	github.com/department-of-veterans-affairs/LEAF/pkg/workflow v0.0.0-20260304194100-125d6b3ce913 // indirect
	github.com/gorilla/css v1.0.1 // indirect
	github.com/microcosm-cc/bluemonday v1.0.27 // indirect
	golang.org/x/net v0.51.0 // indirect
)

replace github.com/department-of-veterans-affairs/LEAF/pkg/workflow => ../pkg/workflow
