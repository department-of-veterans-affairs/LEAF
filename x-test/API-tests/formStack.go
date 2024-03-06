package main

type FormStackResponse []FormStackCategory

type FormStackCategory struct {
	CategoryID              string      `json:"categoryID"`
	ParentID                string      `json:"parentID"`
	CategoryName            string      `json:"categoryName"`
	CategoryDescription     string      `json:"categoryDescription"`
	WorkflowID              int         `json:"workflowID"`
	Sort                    int         `json:"sort"`
	NeedToKnow              int         `json:"needToKnow"`
	FormLibraryID           int         `json:"formLibraryID"`
	Visible                 int         `json:"visible"`
	Disabled                int         `json:"disabled"`
	Type                    string      `json:"type"`
	DestructionAge          int         `json:"destructionAge"`
	Description	            string      `json:"description"`
}