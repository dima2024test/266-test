public with sharing class PharosIntegrationErrorGenerator {

    private static final String URL_BASE = System.Url.getOrgDomainUrl().toExternalForm();
    private static final String URL_APEX_REST_BASE = URL_BASE + '/services/apexrest/';
    private static final String ENDPOINT_PHAROS_TEST_CASE_RESOURCE = 'pharos_test_case_resource';
    private static final String METHOD_POST = 'POST';
    private static final String METHOD_GET = 'GET';

    private static Map<String, String> AUTHORIZATION_HEADERS = new Map<String, String>{
        'Authorization' => 'Bearer ' + UserInfo.getSessionId()
    };

    private static String orgNamespacePrefix {
        get {
            if (orgNamespacePrefix == null) {
                Organization org = [SELECT NamespacePrefix FROM Organization LIMIT 1];
                orgNamespacePrefix = String.isNotBlank(org.NamespacePrefix) ? org.NamespacePrefix : '';
            }
            return orgNamespacePrefix;
        }
        private set;
    }
    
    @future(Callout=true)
    public static void generateErrorUnauthorized() {
        httpRequest(
            getUnauthorizedEndpoint(),
            METHOD_GET,
            new Map<String, String>(),
            null
        );
    }

    @future(Callout=true)
    public static void generateErrorNotFound() {
        httpRequest(
            getNotFoundEndpoint(),
            METHOD_GET,
            AUTHORIZATION_HEADERS,
            null
        );
    }

    @future(Callout=true)
    public static void generateErrorMethodNotAllowed() {
        httpRequest(
            getTestCaseResourceEndpoint(),
            METHOD_GET,
            AUTHORIZATION_HEADERS,
            null
        );
    }

    @future(Callout=true)
    public static void generateErrorUnsupportedMediaType() {
        httpRequest(
            getTestCaseResourceEndpoint(),
            METHOD_POST,
            AUTHORIZATION_HEADERS,
            '{"name":"Dima","age":30}'
        );
    }

    private static String getUnauthorizedEndpoint() {
        return URL_APEX_REST_BASE + ENDPOINT_PHAROS_TEST_CASE_RESOURCE;
    }

    private static String getNotFoundEndpoint() {
        return URL_APEX_REST_BASE + 'invalidEndpoint';
    }

    private static String getTestCaseResourceEndpoint() {
        return URL_APEX_REST_BASE + (String.isNotBlank(orgNamespacePrefix) ? orgNamespacePrefix + '/' : '') + ENDPOINT_PHAROS_TEST_CASE_RESOURCE;
    }

    private static String httpRequest(String endpoint, String method, Map<String, String> headers, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        if (String.isNotBlank(body)) req.setBody(body);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res;
        try {
            res = h.send(req);
        } catch (Exception e) {
            Triton.instance.integrationError(TritonTypes.Area.Community, e, req, res);
        }
        if (res != null && res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            Triton.instance.integrationError(TritonTypes.Type.Backend, TritonTypes.Area.Community, res.getStatus(), res.getStatus(), req, res);
            System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
        } else {
            System.debug('Response Body: ' + res.getBody());
        }
        return res != null ? res.getBody() : null;
    }
}