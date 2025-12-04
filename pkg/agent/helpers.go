package agent

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"maps"
	"net/http"
	"net/url"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form"
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
	"github.com/department-of-veterans-affairs/LEAF/pkg/portal/group"
	"github.com/department-of-veterans-affairs/LEAF/pkg/workflow"
)

func (a Agent) HttpPost(url string, values url.Values) (res *http.Response, err error) {
	req, err := http.NewRequest("POST", url, strings.NewReader(values.Encode()))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", a.authToken)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	return a.httpClient.Do(req)
}

func (a Agent) HttpGet(url string) (res *http.Response, err error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", a.authToken)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	return a.httpClient.Do(req)
}

// FormQuery uses the api/form/query endpoint to fetch matching records
func (a Agent) FormQuery(siteURL string, q query.Query, params string) (query.Response, error) {
	if siteURL[len(siteURL)-1] != '/' {
		siteURL += "/"
	}

	response := make(map[int]query.Record)
	batchSize := 500 // Number of records per batch. Target < 500ms p90 response time
	limitOffset := 0

	for {
		// Split queries into chunks
		if q.Limit == 0 {
			q.Limit = batchSize
		}

		jsonQuery, err := json.Marshal(q)
		if err != nil {
			return nil, err
		}

		res, err := a.HttpGet(siteURL + "api/form/query?q=" + string(jsonQuery) + params)
		if err != nil {
			return nil, err
		}

		b, err := io.ReadAll(res.Body)
		if err != nil {
			return nil, err
		}

		var batch query.Response
		err = json.Unmarshal(b, &batch)
		if err != nil {
			return nil, fmt.Errorf("unmarshal: %w (%v)", err, string(b))
		}

		maps.Copy(response, batch)

		limitOffset += batchSize
		q.LimitOffset = limitOffset

		// the api includes the header leaf-query = "continue" if more results are available
		if res.Header.Get("leaf-query") == "" {
			break
		}
	}

	return response, nil
}

// GetIndicatorMap returns a map of indicators, indexed by indicatorID, and performs two replacements:
// 1. Name is replaced by Description (short label), if available
// 2. Format is parsed into FormatOptions. If options exist, Format will only contain the format type.
func (a Agent) GetIndicatorMap(siteURL string) (map[int]form.Indicator, error) {
	if siteURL[len(siteURL)-1] != '/' {
		siteURL += "/"
	}

	res, err := a.HttpGet(siteURL + "api/form/indicator/list?sort=indicatorID&x-filterData=indicatorID,name,description,format")
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

func (a Agent) GetActions(siteURL string, stepID string) ([]workflow.Action, error) {
	if siteURL[len(siteURL)-1] != '/' {
		siteURL += "/"
	}

	res, err := a.HttpGet(siteURL + "api/workflow/step/" + stepID + "/actions")
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

// GetAdmins retrieves the list of admins for the specified siteURL
func (a Agent) GetAdmins(siteURL string) ([]group.Member, error) {
	if siteURL[len(siteURL)-1] != '/' {
		siteURL += "/"
	}

	res, err := a.HttpGet(siteURL + "api/group/1/members")
	if err != nil {
		log.Println("Error retrieving admins:", siteURL)
		return nil, err
	}

	// marshal JSON response into []group.Members
	var admins []group.Member

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	err = json.Unmarshal(b, &admins)
	if err != nil {
		log.Println("Error unmarshaling admins:", err)
		return nil, err
	}

	return admins, nil
}

func (a Agent) IsSiteAdmin(siteURL string, userName string) (bool, error) {
	admins, err := a.GetAdmins(siteURL)
	if err != nil {
		log.Println("Error retrieving admins:", err)
		return false, err
	}

	isAdmin := false
	for _, admin := range admins {
		if admin.Username == userName {
			isAdmin = true
			break
		}
	}

	return isAdmin, nil
}
