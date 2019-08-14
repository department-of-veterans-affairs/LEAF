package gov.va.leaf


import io.restassured.RestAssured
import io.restassured.builder.ResponseSpecBuilder
import io.restassured.http.Method
import io.restassured.specification.ResponseSpecification
import spock.lang.Unroll

import static gov.va.leaf.CommonSpec.defaultSpec
import static io.restassured.RestAssured.*
import static org.hamcrest.Matchers.*

class PortalAccessSpec extends BaseSpec {


    def "GET Portal '#url'"() {
        given:
            def request = given()
        when:
            def response = request.when().log().uri().request(method, url).andReturn()
        then:
            response.then().log().body().statusCode(status).and().spec(specification)
        where:
            method     || url                                                                                       || status  || specification
            Method.GET || '/LEAF_Request_Portal/api/?a=classicphonebook/version'                                    || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=classicphonebook/search'                                     || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=converter/version'                                           || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=converter'                                                   || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/version'                                                || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form'                                                        || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/categories'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/category'                                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/query'                                                  || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/indicator/list'                                         || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/indicator/list/disabled'                                || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formEditor/version'                                          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formEditor'                                                  || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formStack/version'                                           || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formStack'                                                   || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formStack/categoryList/all'                                  || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formWorkflow/version'                                        || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=FTEdata/version'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=FTEdata/selecteeSheet'                                       || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=FTEdata/selecteeSheetDateRange'                              || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=group/version'                                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=group/members'                                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=import/xls'                                                  || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=inbox/version'                                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=open/version'                                                || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=open'                                                        || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=service/version'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=service'                                                     || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=service/quadrads'                                            || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=signature/version'                                           || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=simpledata/version'                                          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=simpledata/equiptest'                                        || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/version'                                              || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/dbversion'                                            || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/services'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/groups'                                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/templates'                                            || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/reportTemplates'                                      || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/files'                                                || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/settings'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=telemetry/version'                                           || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=telemetry/summary/month'                                     || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=telemetry/simple/requests'                                   || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/version'                                            || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow'                                                    || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/categories'                                         || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/categoriesUnabridged'                               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/dependencies'                                       || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/actions'                                            || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/userActions'                                        || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/events'                                             || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/steps'                                              || 200     || expect().spec(defaultSpec)
    }

    def "Get Portal pathParam '#url'"() {
        given:
            def request = given()
        when:
            def response = request.when().log().uri().request(method, url, pathParams.toArray()).andReturn()
        then:
            response.then().log().all().statusCode(status).and().spec(specification)
        where:
            method     || url                                                                                       || pathParams        || status  || specification
//            Method.GET || '/LEAF_Request_Portal/api/?a=classicphonebook/search/{text}'                              || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/customData/{text}/{text}'                               || ["test","test"]   || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/search/indicator/{digit}'                               || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/search/submitter/{text}'                                || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}'                                                || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/data'                                           || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/data/tree'                                      || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/dataforsigning'                                 || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/progress'                                       || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/tags'                                           || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit1}/rawIndicator/{digit2}/{digit3}'                || [1,2,3]           || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit1}/{digit2}/{digit3}/history'                     || [1,2,3]           || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/indicator/formatSearch&formats=text'            || [1]               || 200     || expect().spec(defaultSpec).body(not(containsString("Parameter must be an array or an object that implements Countable")))
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/workflow/indicator/assigned'                    || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/{text}'                                                 || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/{text}/flat'                                            || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/{text}/export'                                          || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/{text}/workflow'                                        || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=form/{digit}/recordinfo'                                     || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=form/{text}/records'                                         || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formEditor/indicator/{digit}'                                || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formEditor/indicator/{digit}/privileges'                     || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=formEditor/{text}/privileges'                                || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=formEditor/{text}/stapled'                                   || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formWorkflow/{digit}/currentStep'                            || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formWorkflow/{digit}/lastAction'                             || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=formWorkflow/{digit}/lastActionSummary'                      || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=group/{digit}/members'                                       || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=inbox/dependency/{text}'                                     || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=open/form/query/{text}'                                      || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=service/{digit}/members'                                     || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=signature/{digit}'                                           || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=signature/{digit}/history'                                   || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=simpledata/{digit1}/{digit2}/{digit3}'                       || [1,2,3]           || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/updateService/{digit}'                                || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=system/updateGroup/{digit}'                                  || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=system/templates/{text}'                                     || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=system/templates/{text}/standard'                            || ["test"]          || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=system/reportTemplates/{text}'                               || ["test"]          || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/{digit}'                                            || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/{digit}/categories'                                 || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/{digit}/route'                                      || [1]               || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/{digit}/map/summary'                                || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/{digit}/step/{digit}/{text}/events'                 || [1,2,"test"]      || 200     || expect().spec(defaultSpec)
            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/step/{digit}/dependencies'                          || [1]               || 200     || expect().spec(defaultSpec)
//            Method.GET || '/LEAF_Request_Portal/api/?a=workflow/action/{text}'                                      || ["test"]          || 200     || expect().spec(defaultSpec)
    }

}
