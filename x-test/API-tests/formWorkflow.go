package main

type FormWorkflowResponse map[int]FormWorkflowDependency

type FormWorkflowDependency struct {
	DependencyID                     int      `json:"dependencyID"`
	RecordID                         int      `json:"recordID"`
	StepID                           int      `json:"stepID"`
	StepTitle                        string   `json:"stepTitle"`
	BlockingStepID                   int      `json:"blockingStepID"`
	WorkflowID                       int      `json:"workflowID"`
	ServiceID                        int      `json:"serviceID"`
	Filled                           int      `json:"filled"`
	StepBgColor                      string   `json:"stepBgColor"`
	StepFontColor                    string   `json:"stepFontColor"`
	StepBorder                       string   `json:"stepBorder"`
	Description                      string   `json:"description"`
	IndicatorID_for_assigned_empUID  int      `json:"indicatorID_for_assigned_empUID"`
	IndicatorID_for_assigned_groupID int      `json:"indicatorID_for_assigned_groupID"`
	JsSrc                            string   `json:"jsSrc"`
	UserID                           string   `json:"userID"`
	RequiresDigitalSignature         bool     `json:"requiresDigitalSignature"`
	IsActionable                     bool     `json:"isActionable"`
	ApproverName                     *string  `json:"approverName"` // some function(s) rely on this having an undefined state
	ApproverUID                      *string  `json:"approverUID"`  // some function(s) rely on this having an undefined state
	DependencyActions                []Action `json:"dependencyActions"`
	HasAccess                        bool     `json:"hasAccess"`
}

type Action struct {
	ActionType          string `json:"actionType"`
	WorkflowID          int    `json:"workflowID"`
	StepID              int    `json:"stepID"`
	NextStepID          int    `json:"nextStepID"`
	DisplayConditional  string `json:"displayConditional"`
	AcionText           string `json:"acionText"`
	ActionTextPasttense string `json:"actionTextPasttense"`
	ActionIcon          string `json:"actionIcon"`
	ActionAlignment     string `json:"actionAlignment"`
	Sort                int    `json:"sort"`
	FillDependency      int    `json:"fillDependency"`
	Deleted             int    `json:"deleted"`
}
