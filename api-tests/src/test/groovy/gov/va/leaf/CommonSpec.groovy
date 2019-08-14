package gov.va.leaf

import io.restassured.builder.ResponseSpecBuilder
import io.restassured.specification.ResponseSpecification

import static io.restassured.RestAssured.*
import static io.restassured.matcher.RestAssuredMatchers.*
import static org.hamcrest.Matchers.*

/*
        Contains common restassured responseSpecification validations.  Note that specs built in this way means that all expected matches must evaluate to true for the spec to be true.

        In other words, the following spec checks that the response has a status code of 200, AND the body does not contain  "Controller is undefined", AND the body does not contain "Invalid Token."


            private static ResponseSpecification validPhpResponse = ResponseSpecBuilder.newInstance().expectStatusCode(200).expectBody(not(equalTo("\"Controller is undefined.\""))).expectBody(not(equalTo("\"Invalid Token.\""))).build()

        This is probably not what is desired.  Instead, create two ResponseSpecifications, and then joined together:

            private static ResponseSpecification validPhpControllerResponse = ResponseSpecBuilder.newInstance().expectStatusCode(200).expectBody(not(equalTo("\"Controller is undefined.\""))).build()

            private static ResponseSpecification validTokenResponse =  ResponseSpecBuilder.newInstance().expectBody(not(equalTo("\"Invalid Token.\""))).build()

            private static ResponseSpecification defaultSpec = expect().spec(validPhpControllerResponse).spec(validTokenResponse)


 */

class CommonSpec {

    private static ResponseSpecification validPhpResponse = ResponseSpecBuilder.newInstance().expectBody(not(containsString("Uncaught Error: Call to"))).expectBody(not(contains("<b>Fatal error</b>"))).build()

    private static ResponseSpecification validPhpSession = ResponseSpecBuilder.newInstance().expectCookie("PHPSESSID",not(isEmptyOrNullString())).expectCookie("PHPSESSID", not(equalTo("deleted"))).build()

    private static ResponseSpecification validPhpControllerResponse = ResponseSpecBuilder.newInstance().expectStatusCode(200).expectBody(not(equalTo("\"Controller is undefined.\""))).build()

    private static ResponseSpecification validTokenResponse =  ResponseSpecBuilder.newInstance().expectBody(not(equalTo("\"Invalid Token.\""))).build()

    private static ResponseSpecification validReferer = ResponseSpecBuilder.newInstance().expectBody(not(containsString("Error: Invalid request. Mismatched Referer"))).build()

    public static ResponseSpecification defaultSpec = expect().spec(validPhpSession).spec(validPhpResponse).spec(validPhpControllerResponse).spec(validTokenResponse).spec(validReferer)
}
