package gov.va.leaf

import spock.lang.Unroll
import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static io.restassured.matcher.RestAssuredMatchers.*
import static org.hamcrest.Matchers.*

class FormCreateSpec extends BaseSpec {

    void cleanup() {
        sqlPortal.execute 'DELETE FROM indicators WHERE name = ?', ['test_field']
        sqlPortal.execute 'DELETE FROM categories WHERE categoryName = ?', ['test_create_form']
    }

    @Unroll
    def "Create Editor new form '#param.name' [#iterationCount]"() {
        given:
            def request = given().log().all()
                .urlEncodingEnabled(true)
                .filter(cookieFilter)
                .param("name", param.name)
                .param("description", param.name)
                .param("parentID", param.parentID)
                .param("CSRFToken", CSRFToken)
        when:
            def response = request.with().post("/LEAF_Request_Portal/api/?a=formEditor/new")
        then:
            def categoryID = response.then().log().all().statusCode(status).spec(specification).extract().body().asString().replaceAll('"','')
        and: "add form section ${categoryID}"
            given().log().all().urlEncodingEnabled(true).filter(cookieFilter)
                .param("CSRFToken", CSRFToken)
                .param('name', 'test_field')
                .param('description', 'test_field')
                .param('categoryID', categoryID)
            .with().post('/LEAF_Request_Portal/api/?a=formEditor/newIndicator')
            .then().log().all().statusCode(200).body(both(startsWith('"')).and(endsWith('"')))
        and: "and get form ${categoryID}"
            given().log().all().urlEncodingEnabled(true).filter(cookieFilter)
                .pathParam('categoryID', categoryID)
                .with().get('/LEAF_Request_Portal/api/form/_{categoryID}')
                .then().log().ifError().body('name', hasItem(equalTo('test_field')))
        where:
            param                           ||  status    ||  specification
            [name: 'test_create_form', parentID: '']    ||  200       || expect().spec(defaultSpec).body(startsWith("\"form_"))
    }
}

