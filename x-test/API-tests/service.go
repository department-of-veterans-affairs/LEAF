package main

type ServiceResponse []Service
type QuadResponse []Quad

type Quad struct {
	GroupID	int	   `json:"groupID"`
	Name	string `json:"name"`
}

type Service struct {
	ServiceID          int      `json:"serviceID"`
	Service            string   `json:"service"`
	AbbreviatedService string   `json:"abbreviatedService"`
	GroupID            int      `json:"groupID"`
	Members            []Member `json:"members"`
}

type Member struct {
	EmpUID            int    `json:"empUID"`
	UserName          string `json:"userName"`
	LastName          string `json:"lastName"`
	FirstName         string `json:"firstName"`
	MiddleName        string `json:"middleName"`
	PhoneticFirstName string `json:"phoneticFirstName"`
	PhoneticLastName  string `json:"phoneticLastName"`
	Domain            string `json:"domain"`
	Deleted           int    `json:"deleted"`
	LastUpdated       int    `json:"lastUpdated"`
	New_empUUID	      string `json:"new_empUUID"`
	Email             string `json:"email"`
	Lname             string `json:"Lname"`
	Fname             string `json:"Fname"`
	BackupID          string `json:"backupID"`
	LocallyManaged    int    `json:"locallyManaged"`
	Active            int    `json:"active"`
}
