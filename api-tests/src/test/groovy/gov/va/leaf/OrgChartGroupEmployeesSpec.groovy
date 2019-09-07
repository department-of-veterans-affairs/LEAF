package gov.va.leaf

import spock.lang.Unroll

import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static io.restassured.matcher.RestAssuredMatchers.*
import static org.hamcrest.Matchers.*

/**
 *
 * Searches employees om group by ID
 *
 * Response takes on the form:

 [
     {
     "empUID": "1",
     "groupID": "1",
     "userName": "tester",
     "lastName": "lastName",
     "firstName": "firstName",
     "middleName": "middleName",
     "phoneticFirstName": "FN",
     "phoneticLastName": "LN",
     "domain": null,
     "deleted": "0",
     "lastUpdated": "0"
     }
 ]

 */


class OrgChartGroupEmployeesSpec extends BaseSpec {

    @Unroll
    def "Org Chart position"() {
        given:
        def request = given().log().uri().log().params()
                .urlEncodingEnabled(true)
                .pathParams("groupID", param.groupID)
                .filter(cookieFilter)
        when:
            def response = request.with().get("/LEAF_Nexus/api/group/{groupID}/employees")
        then:
            response.then().log().ifError().statusCode(200).spec(specification)
        where:
            param                                    || specification
            [groupID: 1, userName: "tester86"]         || expect().spec(defaultSpec).body('userName', hasItem(equalTo(param.userName)))
    }
}
