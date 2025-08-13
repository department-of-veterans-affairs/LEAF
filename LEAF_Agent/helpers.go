package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form"
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
	"github.com/department-of-veterans-affairs/LEAF/pkg/workflow"
)

func HttpPost(url string, values url.Values) (res *http.Response, err error) {
	req, err := http.NewRequest("POST", url, strings.NewReader(values.Encode()))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", AGENT_TOKEN)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	return client.Do(req)
}

func HttpGet(url string) (res *http.Response, err error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", AGENT_TOKEN)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	return client.Do(req)
}

// FormQuery uses the api/form/query endpoint to fetch matching records
func FormQuery(siteURL string, q query.Query, params string) (query.Response, error) {
	jsonQuery, err := json.Marshal(q)
	if err != nil {
		return nil, err
	}

	res, err := HttpGet(siteURL + "api/form/query?q=" + string(jsonQuery) + params)
	if err != nil {
		return nil, err
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var response query.Response
	err = json.Unmarshal(b, &response)
	if err != nil {
		return nil, fmt.Errorf("Unmarshal: %w (%v)", err, string(b))
	}

	return response, nil
}

// GetIndicatorMap returns a map of indicators, indexed by indicatorID, and performs two replacements:
// 1. Name is replaced by Description (short label), if available
// 2. Format is parsed into FormatOptions. If options exist, Format will only contain the format type.
func GetIndicatorMap(siteURL string) (map[int]form.Indicator, error) {
	res, err := HttpGet(siteURL + "api/form/indicator/list?sort=indicatorID&x-filterData=indicatorID,name,description,format")
	if err != nil {
		return nil, err
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var data []form.Indicator
	err = json.Unmarshal(b, &data)
	if err != nil {
		return nil, err
	}

	indicatorMap := make(map[int]form.Indicator)
	for k, indicator := range data {
		indicatorID := indicator.IndicatorID

		// Use the description (short label) if available
		indicatorMap[indicatorID] = indicator
		if indicator.ShortLabel != "" {
			tmp := indicator
			tmp.Name = indicator.ShortLabel
			indicatorMap[indicatorID] = tmp
		}

		// Parse format options
		compatString := strings.ReplaceAll(indicator.Format, "\r\n", "\n")
		formatOptions := strings.Split(compatString, "\n")
		data[k].Format = formatOptions[0]
		if formatOptions[0] == "radio" || formatOptions[0] == "dropdown" {
			data[k].FormatOptions = formatOptions[1:]
		}
		indicatorMap[indicatorID] = data[k]
	}

	return indicatorMap, nil
}

func GetActions(siteURL string, stepID string) ([]workflow.Action, error) {
	res, err := HttpGet(siteURL + "api/workflow/step/" + stepID + "/actions")
	if err != nil {
		return nil, err
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var actions []workflow.Action
	json.Unmarshal(b, &actions)

	return actions, nil
}
