package form

type Indicator struct {
	IndicatorID int    `json:"indicatorID"`
	Name        string `json:"name"`        // The full field name
	ShortLabel  string `json:"description"` // A short label for the field
	Format      string `json:"format"`

	// Extra attributes
	FormatOptions []string `json:"formatOptions,omitempty"`
}
