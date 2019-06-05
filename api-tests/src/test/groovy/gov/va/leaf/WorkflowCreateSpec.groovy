package gov.va.leaf

import org.apache.http.entity.ContentType
import spock.lang.Unroll

import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static org.hamcrest.Matchers.*


class WorkflowCreateSpec extends BaseSpec {

    @Unroll
    def "Create Workflow"() {
        given:
            def request = given().contentType(ContentType.APPLICATION_FORM_URLENCODED.toString()).log().all()
                .header('Referer', 'http://localhost/LEAF_Request_Portal/admin/?a=workflow')
                .header("Host", "localhost")
                .urlEncodingEnabled(true)
                .filter(cookieFilter)
                .param("description", "create-workflow")
                .param("CSRFToken", CSRFToken)
        when:
            def response = request.with().post("/LEAF_Request_Portal/api/workflow/new")
        then:
            response.then().log().all().statusCode(status).spec(specification)
        where:
            param                           ||  status    || specification
            []                              ||  200       || expect().spec(defaultSpec).body(startsWith('"')).body(endsWith('"'))
    }
}
