package group

type Member struct {
	EmpUID            int    `json:"empUID"`
	Username          string `json:"userName"`
	Lastname          string `json:"lastName"`
	Firstname         string `json:"firstName"`
	Middlename        string `json:"middleName"`
	PhoneticFirstname string `json:"phoneticFirstName"`
	PhoneticLastname  string `json:"phoneticLastName"`
	Domain            string `json:"domain"`
	Deleted           int    `json:"deleted"`
	LastUpdated       int    `json:"lastUpdated"`
	Email             string `json:"email"`
	PrimaryAdmin      int    `json:"primaryAdmin"`
	LocallyManaged    int    `json:"locallyManaged"`
	Active            int    `json:"active"`
}
