package gov.va.leaf

import spock.lang.Unroll

import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static io.restassured.matcher.RestAssuredMatchers.*
import static org.hamcrest.Matchers.*

/**
 *
 * Searches groups
 *
 * Response takes on the form:
 *
 *
 *
 {
     "13": {
         "indicatorID": "13",
         "name": "Series",
         "format": "text",
         "required": "1",
         "data": "",
         "isWritable": 1
     },

    ...
 }

 */


class OrgChartPositionSpec extends BaseSpec {

    @Unroll
    def "Org Chart position"() {
        given:
        def request = given().log().uri().log().params()
                .urlEncodingEnabled(true)
                .filter(cookieFilter)
        when:
            def response = request.with().get("/LEAF_Nexus/api/?a=position/" + param.query)
        then:
            response.then().log().ifError().statusCode(200).spec(specification)
        where:
        param                           || specification
            [query: 1]                  || expect().spec(defaultSpec).body('', hasKey(equalTo("title")))
            [query: 1]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("indicatorID"))))
            [query: 1]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("name"))))
            [query: 1]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("format"))))
            [query: 1]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("required"))))
            [query: 1]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("data"))))
            [query: 1]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("isWritable"))))

            [query: 2]                  || expect().spec(defaultSpec).body('', hasKey(equalTo("title")))
            [query: 2]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("indicatorID"))))
            [query: 2]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("name"))))
            [query: 2]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("format"))))
            [query: 2]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("required"))))
            [query: 2]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("data"))))
            [query: 2]                  || expect().spec(defaultSpec).body('', both(instanceOf(HashMap.class)).and(hasValue(hasKey("isWritable"))))

    }
}
