package main

import (
	"testing"
)

func BenchmarkHomepage_defaultQuery(b *testing.B) {
	for i := 0; i < b.N; i++ {
		httpGet(RootURL + `api/form/query?q={"terms":[{"id":"title","operator":"LIKE","match":"***","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)
	}
}

func BenchmarkInbox_nonAdminActionable(b *testing.B) {
	for i := 0; i < b.N; i++ {
		httpGet(RootURL + `api/form/query?q={"terms":[{"id":"stepID","operator":"=","match":"actionable","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service"],"sort":{},"limit":1000,"limitOffset":0}&x-filterData=recordID,title&masquerade=nonAdmin`)
	}
}
