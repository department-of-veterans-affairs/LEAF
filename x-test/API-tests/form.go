package main

type FormCategoryResponse []FormCategoryResponseItem

type FormCategoryResponseItemChild struct {
	IndicatorID    int    `json:"indicatorID"`
	CategoryID     string `json:"categoryID"`
	Series         int    `json:"series"`
	Name           string `json:"name"`
	Description    string `json:"description"`
	Default        string `json:"default"`
	ParentID       int    `json:"parentID"`
	Html           string `json:"html"`
	HtmlPrint      string `json:"htmlPrint"`
	Conditions     string `json:"conditions"`
	Required       int    `json:"required"`
	IsSensitive    int    `json:"is_sensitive"`
	IsEmpty        bool   `json:"isEmpty"`
	Value          string `json:"value"`
	DisplayedValue string `json:"displayedValue"`
	Timestamp      int    `json:"timestamp"`
	IsWritable     int    `json:"isWritable"`
	IsMasked       int    `json:"isMasked"`
	IsMaskable     *int   `json:"isMaskable,omitempty"`
	Sort           int    `json:"sort"`
	HasCode        string `json:"has_code"`
	Format         string `json:"format"`
}

type FormCategoryResponseItem struct {
	IndicatorID    int                                   `json:"indicatorID"`
	CategoryID     string                                `json:"categoryID"`
	Series         int                                   `json:"series"`
	Name           string                                `json:"name"`
	Description    string                                `json:"description"`
	Default        string                                `json:"default"`
	ParentID       int                                   `json:"parentID"`
	Html           string                                `json:"html"`
	HtmlPrint      string                                `json:"htmlPrint"`
	Conditions     string                                `json:"conditions"`
	Required       int                                   `json:"required"`
	IsSensitive    int                                   `json:"is_sensitive"`
	IsEmpty        bool                                  `json:"isEmpty"`
	Value          string                                `json:"value"`
	DisplayedValue string                                `json:"displayedValue"`
	Timestamp      int                                   `json:"timestamp"`
	IsWritable     int                                   `json:"isWritable"`
	IsMasked       int                                   `json:"isMasked"`
	IsMaskable     *int                                  `json:"isMaskable,omitempty"`
	Sort           int                                   `json:"sort"`
	HasCode        string                                `json:"has_code"`
	Format         string                                `json:"format"`
	Child          map[int]FormCategoryResponseItemChild `json:"child"`
}
