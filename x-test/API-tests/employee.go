package main

type EmployeeResponse map[int]Employee

type Employee struct {
	EmployeeId int    `json:"employeeId"`
	FirstName  string `json:"firstName"`
	LastName   string `json:"lastName"`
	MiddleName string `json:"middleName"`
	UserName   string `json:"userName"`
}

type EmployeeIdentifier struct {
	EmployeeId int `json:"employeeId"`
}
