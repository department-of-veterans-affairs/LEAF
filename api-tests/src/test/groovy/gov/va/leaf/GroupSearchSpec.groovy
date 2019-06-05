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
[
        {
            "groupID": "...",
            "parentID": "...",
            "groupTitle": "...",
            "data": { ... }
            "tags": [ ... ]
        },
        {
             "groupID": "...",
             "parentID": "...",
             "groupTitle": "...",
             "data": { ... }
             "tags": [ ... ]
         },
        ...
 ]


 The following RestAssured jsonPath assertions can be read as

 .body('[0].groupTitle', equalTo('System Administrators')
 The first element in the response array is expected to have a groupTitle key with a value of System Administrators

 .body('', not(emptyIterable()))
 Empty array is not allowed

 .body('groupTitle', hasItem('System Administrators'))
 The array that is returned from the jsonPath 'groupTitle', is a new array where each element is the value of the 'groupTitle' key in the original response.
 i,e: ["System Administrators", "System Reserved.2", "System Reserved.3", "System Reserved.4"]
 The assertion checks that atleast one of the items in the array is equalsTo System Administrators

 .body('', everyItem(hasKey('groupTitle')))
 The response array is returned without modifications.  Every element in the array is expected to have a key groupTitle

 */


class GroupSearchSpec extends BaseSpec {

    @Unroll
    def "Group Search for System Administrator"() {
        given:
        def request = given().log().uri().log().params()
                .urlEncodingEnabled(true)
                .filter(cookieFilter)
                .param("q", param.query)
                .param("noLimit", 0)
        when:
            def response = request.with().get("/LEAF_Nexus/api/?a=group/search")
        then:
            response.then().log().ifError().statusCode(200).spec(specification)
        where:
        param                                         || specification
            [query: 'System Administrators']          || expect().spec(defaultSpec).body('[0].groupID', equalTo('1')).body('[0].groupTitle', equalTo('System Administrators'))
            [query: 'syst']                           || expect().spec(defaultSpec).body('', not(emptyIterable()))
            [query: 'syst']                           || expect().spec(defaultSpec).body('groupTitle', hasItem('System Administrators'))
            [query: 'syst']                           || expect().spec(defaultSpec).body('', everyItem(hasKey('groupTitle')))
            [query: 'syst']                           || expect().spec(defaultSpec).body('', allOf(
                    everyItem(hasKey('groupID')),
                    everyItem(hasKey('parentID')),
                    everyItem(hasKey('groupTitle')),
                    everyItem(hasKey('data')),
                    everyItem(hasKey('tags'))
            ))
    }
}
