package gov.va.leaf

import io.restassured.RestAssured
import io.restassured.filter.cookie.CookieFilter
import groovy.sql.Sql
import spock.lang.Specification


import static io.restassured.RestAssured.*

class BaseSpec extends Specification {
    def cookieFilter = new CookieFilter()
    def CSRFToken =  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    
    static db_host = System.getProperty('db_host')
    static web_host = System.getProperty('web_host')

    static Map dbLeafUsers =  [url: "jdbc:mariadb://${db_host}:3306/leaf_users", user: 'tester', password: 'tester', driver: 'org.mariadb.jdbc.Driver']
    static Map dbLeafPortal = [url: "jdbc:mariadb://${db_host}:3306/leaf_portal", user: 'tester', password: 'tester', driver: 'org.mariadb.jdbc.Driver']
    static Sql sqlOrgChart
    static Sql sqlPortal

    def setupSpec() throws Exception {
        setupRestAssuredSpec()
        setupDBSpec()
        setupLeafUsersSpec()
    }

    def cleanupSpec() {
        cleanupDBSpec()
    }

    def setupRestAssuredSpec() throws Exception {
        RestAssured.baseURI = "http://${web_host}/"
        RestAssured.port = 80
        config = config().redirect(config.getRedirectConfig().followRedirects(true).and().maxRedirects(0))
                .logConfig(config.getLogConfig().enableLoggingOfRequestAndResponseIfValidationFails().enablePrettyPrinting(true))
                .httpClient(config.getHttpClientConfig().reuseHttpClientInstance())
                .sessionConfig(config.getSessionConfig().sessionIdName('PHPSESSID').sessionIdValue('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'))
                .sslConfig(config.getSSLConfig().allowAllHostnames())

    }

    def setupDBSpec() {
        sqlOrgChart = Sql.newInstance(dbLeafUsers)
        sqlPortal = Sql.newInstance(dbLeafPortal)
    }

    def cleanupDBSpec() {
        if(sqlOrgChart) {sqlOrgChart.close() }
        if(sqlPortal) {sqlPortal.close() }
    }

    def setupLeafUsersSpec() {
        def create_user_session = { userID, sessionKey ->
            def lastModified = System.currentTimeMillis() / 1000 + 15000
            def token = "${sessionKey}${sessionKey}"
            def data = "userID|s:${userID.length()}:\"${userID}\";name|s:18:\"firstName lastName\";CSRFToken|s:${token.length()}:\"${token}\";".toString()
            Map user =  [sessionKey:sessionKey, data:data, lastModified:lastModified]

            sqlOrgChart.execute """
        INSERT INTO sessions (sessionKey, variableKey, data, lastModified)
        VALUES (:sessionKey, '', :data, :lastModified)
        ON DUPLICATE KEY UPDATE data = :data, lastModified = :lastModified;
        """, user
        }

        create_user_session "tester", 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    }
}
