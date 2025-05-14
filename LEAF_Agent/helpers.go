package main

import (
	"encoding/json"
	"io"
	"net/http"
	"net/url"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
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
		return nil, err
	}

	return response, nil
}

func GetIndicatorList(siteURL string) (map[int]string, error) {
	res, err := HttpGet(siteURL + "api/form/indicator/list?sort=indicatorID&x-filterData=indicatorID,name,description")
	if err != nil {
		return nil, err
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	type ind struct {
		IndicatorID int    `json:"indicatorID"`
		Name        string `json:"name"`
		Description string `json:"description"`
	}

	var data []ind
	err = json.Unmarshal(b, &data)
	if err != nil {
		return nil, err
	}

	indicatorList := make(map[int]string)
	for _, indicator := range data {
		indicatorID := indicator.IndicatorID

		indicatorList[indicatorID] = indicator.Name
		if indicator.Description != "" {
			indicatorList[indicatorID] = indicator.Description
		}
	}

	return indicatorList, nil
}
