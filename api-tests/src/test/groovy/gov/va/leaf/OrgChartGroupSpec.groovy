package gov.va.leaf

import spock.lang.Unroll

import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static io.restassured.matcher.RestAssuredMatchers.*
import static org.hamcrest.Matchers.*

/**
 *
 * Returns groups by ID
 *
 * Response takes on the form:

 {
     "4": {
         "indicatorID": "4",
         "name": "FTE Ceiling",
         "format": "number",
         "required": "1",
         "data": "",
         "isWritable": 0
     },
     "10": {
         "indicatorID": "10",
         "name": "Logo",
         "format": "image",
         "required": "0",
         "data": "",
         "isWritable": 0
     },
     "24": {
         "indicatorID": "24",
         "name": "Contact Info",
         "format": "text",
         "required": "1",
         "data": "",
         "isWritable": 0
     },
     "25": {
         "indicatorID": "25",
         "name": "Location",
         "format": "text",
         "required": "1",
         "data": "",
         "isWritable": 0
     },
    "title": "System Administrators"
 }
 */


class OrgChartGroupSpec extends BaseSpec {

    @Unroll
    def "Org Chart group by id"() {
        given:
        def request = given().log().uri().log().params()
                .urlEncodingEnabled(true)
                .pathParams("groupID", param.groupID)
                .filter(cookieFilter)
        when:
            def response = request.with().get("/LEAF_Nexus/api/group/{groupID}")
        then:
            response.then().log().ifError().statusCode(200).spec(specification)
        where:
            param                                            || specification
            [groupID: 1, title: 'System Administrators']     || expect().spec(defaultSpec).body('title', equalTo(param.title))
            [groupID: 2, title: 'Everyone']                  || expect().spec(defaultSpec).body('title', equalTo(param.title))
            [groupID: 3, title: 'Owner']                     || expect().spec(defaultSpec).body('title', equalTo(param.title))
    }
}
