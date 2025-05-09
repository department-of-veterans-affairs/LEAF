package query

type Query struct {
	Terms       []Term   `json:"terms"`
	Joins       []string `json:"joins"`
	Sort        Sort     `json:"sort"`
	GetData     []int    `json:"getData"`
	Limit       int      `json:"limit,omitempty"`
	LimitOffset int      `json:"limitOffset,omitempty"`
}

type Term struct {
	ID          string `json:"id"`
	IndicatorID string `json:"indicatorID,omitempty"`
	Operator    string `json:"operator"`
	Match       string `json:"match"`
	Gate        string `json:"gate,omitempty"`
}

type Sort struct {
	Column    string `json:"column"`
	Direction string `json:"direction"`
}
