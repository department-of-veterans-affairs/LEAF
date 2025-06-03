package form

type Indicator struct {
	IndicatorID int    `json:"indicatorID"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Format      string `json:"format"`

	// Extra attributes
	FormatOptions []string `json:"formatOptions,omitempty"`
}
