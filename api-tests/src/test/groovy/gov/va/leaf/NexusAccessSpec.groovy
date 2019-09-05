package gov.va.leaf


import io.restassured.builder.ResponseSpecBuilder
import io.restassured.http.Method
import io.restassured.specification.ResponseSpecification

import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static org.hamcrest.Matchers.*

class NexusAccessSpec extends BaseSpec {


    def "GET Nexus '#url'"() {
        given:
            def request = given()
        when:
            def response = request.when().log().uri().request(method, url).andReturn()
        then:
            response.then().log().body().statusCode(status).and().spec(specification)
        where:
            method     || url                                                                                       || status  ||   specification
            Method.GET || '/LEAF_Nexus/api/?a=employee/version'                                                     || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=employee/search'                                                      || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=group/version'                                                        || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=indicator/version'                                                    || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=national/employee/version'                                            || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=national/employee/search'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/version'                                                     || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position'                                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/search'                                                      || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=system/version'                                                       || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=system/dbversion'                                                     || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=system/templates'                                                     || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=system/reportTemplates'                                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=tag/version'                                                          || 200     || expect().spec(defaultSpec)
    }

    def "Get Nexus pathParam '#url'"() {
        given:
            def request = given()
        when:
            def response = request.when().log().uri().request(method, url, pathParams.toArray()).andReturn()
        then:
            response.then().log().body().statusCode(status).and().spec(specification)
        where:
            method     || url                                                                                       || pathParams        || status  || specification
            Method.GET || '/LEAF_Nexus/api/?a=employee/{digit}'                                                     || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=employee/{digit}/backup'                                              || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=employee/{digit}/backupFor'                                           || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=employee/search/userName/{text}'                                      || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=indicator/{digit}/permissions'                                        || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=national/employee/{digit}'                                            || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}'                                                     || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}/employees'                                           || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}/subordinates'                                        || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}/supervisor'                                          || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}/service'                                             || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}/quadrad'                                             || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=position/{digit}/search/parentTag/{text}'                             || [1,"test"]        || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=system/templates/{text}'                                              || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=system/reportTemplates/{text}'                                        || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Nexus/api/?a=tag/{text}/parent'                                                    || ["test"]          || 200     || expect().spec(defaultSpec)
    }


    def "Post Nexus pathParam '#url'"() {
        given:
            def request = given().urlEncodingEnabled(true).param("CSRFToken", CSRFToken)
        when:


            if ( params )
                request = request.formParams(params)

            if (queryParams)
                request = request.queryParams(queryParams)

            request = request.when().log().uri().log().params()

            def response

            if( pathParams )
                response = request.post(url, pathParams.toArray())
            else
                response = request.post(url)
        then:
            response.then().log().body().statusCode(200).and().spec(specification)
        where:
            url                                     || pathParams   || params                                || queryParams                                       || specification
            '/LEAF_Nexus/api/?a=employee'           || null         || null || ["firstName":"newEmp1_first", "lastName":"newEmp1_last"]                           || expect().spec(defaultSpec).body(containsString("[firstName] => newEmp1_first")).body(containsString("[lastName] => newEmp1_last"))
            '/LEAF_Nexus/api/?a=employee/new'       || null         || ["firstName":"f", "lastName":"l", "middleName":"m", "userName":"newEmpTest" ]|| null       || expect().spec(defaultSpec).body(startsWith('"')).body(endsWith('"'))
            '/LEAF_Nexus/api/?a=employee/{digit}'   || [1]          || null                                                                         || null       || expect().spec(defaultSpec)


    }






}
