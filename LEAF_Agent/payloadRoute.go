package main

type RoutePayload struct {
	ActionType string `json:"actionType"`
	Comment    string `json:"comment,omitempty"`
}

// route executes an action, payload.ActionType, for all records matching the task
func route(task *Task, payload RoutePayload) {
	for recordID := range task.Records {
		err := TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, payload.Comment)
		if err != nil {
			task.HandleError(recordID, "route:", err)
		}
	}
}
