@IsTest
public with sharing class PharosTestCaseResourceTest {
    
    @IsTest
    static void testPharosTestCaseResourcePost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/pharos_test_case_resource';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"stringValue1": "test1", "stringValue2": "test2"}');
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
            PharosTestCaseResource.PharosTestCaseResourceWrapper result = 
                PharosTestCaseResource.echoMyType(new PharosTestCaseResource.PharosTestCaseResourceWrapper());
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
    }
    
    @IsTest
    static void testPharosTestCaseResourceWrapperFields() {
        PharosTestCaseResource.PharosTestCaseResourceWrapper wrapper = 
            new PharosTestCaseResource.PharosTestCaseResourceWrapper();
        
        wrapper.stringValue1 = 'value1';
        wrapper.stringValue2 = 'value2';
        wrapper.transientStringValue = 'transient';
        
        Assert.areEqual('value1', wrapper.stringValue1, 'stringValue1 should match');
        Assert.areEqual('value2', wrapper.stringValue2, 'stringValue2 should match');
        Assert.areEqual('transient', wrapper.transientStringValue, 'transientStringValue should match');
    }
}