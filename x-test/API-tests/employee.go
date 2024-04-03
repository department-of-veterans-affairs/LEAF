package main

type EmployeeResponse map[string]Employee

type Employee struct {
	EmployeeId int    `json:"empUID"`
	FirstName  string `json:"firstName"`
	LastName   string `json:"lastName"`
	MiddleName string `json:"middleName"`
	UserName   string `json:"userName"`
}

type EmployeeIdentifier struct {
	EmployeeId int `json:"employeeId"`
}
