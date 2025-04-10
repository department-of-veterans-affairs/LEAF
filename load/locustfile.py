from locust import HttpUser, task, between
class HelloWorldUser(HttpUser):

    wait_time = between(1, 5)

    def on_start(self):
        #https://github.com/locustio/locust/issues/417 - this may have clues on how to do login
        """ on_start is called when a Locust start before any task is scheduled """
        self.client.verify = False

        # some examples I have found for logging in.
        #self.login_page()
        #self.client.post("/login", json={"username":"foo", "password":"bar"})

    # Weight home page over other pages
    @task(3)
    def home_page(self):
        self.client.get("/Test_Request_Portal/")

    @task
    def report_builder(self):
        self.client.get("/Test_Request_Portal/?a=reports&v=3&query=N4IgLgpgTgtgziAXAbVASwCZJBiAbCSLAGhAHsAHaAQzDKmwF4RSZaBjACyQAZSBzWhGwBBAHIAREAF8AuqQBWZNADsEKEHGgA3NO2Gl2Q%2FvQCeY6jAOawtAK4JSqtGDS16FqyxDV2rsioA%2BpxocHRQpt5hEBQAYnZ4AGZoeHhWKmAA8ip4kfKa9GBIwNKkeGgwLkgAjDx1ZRUumYmJWkWIPNJAA&indicators=NobwRAlgdgJhDGBDALgewE4EkAiYBcYyEyANgKZgA0YUiAthQVWAM4bL4AMAvpeNHCRosuAizLoAbggrVaDfGGZt0HPDz6RYCFBhyLkATwAOsmvUZLqKtRv7ahe0a2QoAri2bzLy9l172groiitDEEMFeFoq%2Bqv6aAjrC%2BgSI8ESoUABCbshoUFEKTNZ%2B6gFaQcnOaRlQAPoAFhAswoaFPiVxZQkOwSlgiMbG6KiSiCSNza3tMZ225YmOIQQwiIYsdSzQ8GR1JIgtdTUQmTPFrKV2FUlOiqvrm9u7%2B4ctZMZ1dKNkDFAcctFzjZ%2FABdIA%3D%3D%3D")

    @task
    def view_lq_report(self):
        self.client.get("""/Test_Request_Portal/api/form/query/?q={"terms":[{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","categoryName","status","initiatorName","action_history","stepFulfillmentOnly"],"sort":{}}&x-filterData=recordID,title,service,categoryNames,stepTitle,lastStatus,lastName,firstName,action_history.time,action_history.comment,action_history.description,action_history.actionTextPasttense,action_history.approverName,action_history.stepID,action_history.actionType,stepFulfillmentOnly,submitted""")
