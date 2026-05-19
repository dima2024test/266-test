@IsTest
public with sharing class PharosTestCaseGeneratorControllerTest {
    
    @IsTest
    static void testGetInitialData() {
        Test.startTest();
            List<PharosTestCaseGeneratorController.PharosCategoryItemWrapper> result = 
                PharosTestCaseGeneratorController.getInitialData();
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areEqual(3, result.size(), 'Should return 3 categories');
        
        // Verify Apex category
        PharosTestCaseGeneratorController.PharosCategoryItemWrapper apexCategory = result.get(0);
        Assert.areEqual(PharosTestCaseGeneratorController.ERROR_CATEGORY_APEX, apexCategory.category, 'The category should be Apex');
        Assert.areEqual(false, apexCategory.isAutomation, 'Apex category should not be automation');
        Assert.isFalse(apexCategory.testCases == null || apexCategory.testCases.isEmpty(), 'Apex test cases should not be null or empty');

        PharosTestCaseGeneratorController.PharosCategoryItemWrapper integrationCategory = result.get(1);
        Assert.areEqual(PharosTestCaseGeneratorController.ERROR_CATEGORY_INTEGRATION, integrationCategory.category, 'The category should be Integration');
        Assert.areEqual(false, integrationCategory.isAutomation, 'Integration category should not be automation');
        Assert.isFalse(integrationCategory.testCases == null || integrationCategory.testCases.isEmpty(), 'Integration test cases should not be null or empty');
        
        // Verify Automation category
        PharosTestCaseGeneratorController.PharosCategoryItemWrapper automationCategory = result.get(2);
        Assert.areEqual('Automation', automationCategory.category, 'Second category should be Automation');
        Assert.areEqual(true, automationCategory.isAutomation, 'Automation category should be automation');
    }
    
    @IsTest
    static void testGetLimits() {
        Test.startTest();
            Map<String, Object> result = PharosTestCaseGeneratorController.getLimits();
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.isTrue(result.containsKey('lastUpdatedDate'), 'Should contain lastUpdatedDate');
        Assert.isTrue(result.containsKey('orgLimits'), 'Should contain orgLimits');
        
        Datetime lastUpdated = (Datetime)result.get('lastUpdatedDate');
        Assert.areNotEqual(null, lastUpdated, 'lastUpdatedDate should not be null');
        
        List<PharosTestCaseGeneratorController.OrgLimitInfo> orgLimits = 
            (List<PharosTestCaseGeneratorController.OrgLimitInfo>)result.get('orgLimits');
        Assert.areEqual(3, orgLimits.size(), 'Should return 3 org limits');
    }
    
    @IsTest
    static void testIsApexExceptionEmailExist() {
        Test.startTest();
            Boolean result = PharosTestCaseGeneratorController.isApexExceptionEmailExist();
        Test.stopTest();
        
        // Result depends on org configuration, just verify it doesn't throw
        Assert.areNotEqual(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void testGenerateTestCase1_NullPointer() {
        String result;
        try {
            Test.startTest();
                result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_1);
            Test.stopTest();
        } catch(Exception e) {}
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
    }
    
    @IsTest
    static void testGenerateTestCase2_ListIndexOutOfBounds() {
        String result;
        try {
            Test.startTest();
                result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_2);
            Test.stopTest();
        } catch(Exception e) {}
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
    }
    
    @IsTest
    static void testGenerateTestCase3_DMLRowLimit() {
        String result;
        try {
            Test.startTest();
                result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_3);
            Test.stopTest();
        } catch(Exception e) {}
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
    }
    
    @IsTest
    static void testGenerateTestCase4_IllegalArgument() {
        String result;
        try {
            Test.startTest();
                result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_4);
            Test.stopTest();
        } catch(Exception e) {}
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
    }
    
    @IsTest
    static void testGenerateTestCase5_DivisionByZero() {
        // Create test Account for batch
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        String result;
        try {
            Test.startTest();
                result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_5);
            Test.stopTest();
        } catch(Exception e) {}
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
    }

    @IsTest
    static void testGenerateTestCase6_ErrorUnauthorized() {
        Test.setMock(HttpCalloutMock.class, new IntegrationErrorMock(401, 'Unauthorized'));
        
        Test.startTest();
            String result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_6);
        Test.stopTest();
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
        Assert.areEqual(1, [SELECT COUNT() FROM pharos__Log__c]);
    }

    @IsTest
    static void testGenerateTestCase7_ErrorNotFound() {
        Test.setMock(HttpCalloutMock.class, new IntegrationErrorMock(404, 'Not Found'));
        
        Test.startTest();
            String result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_7);
        Test.stopTest();
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
        Assert.areEqual(1, [SELECT COUNT() FROM pharos__Log__c]);
    }

    @IsTest
    static void testGenerateTestCase8_ErrorMethodNotAllowed() {
        Test.setMock(HttpCalloutMock.class, new IntegrationErrorMock(405, 'Method Not Allowed'));
        
        Test.startTest();
            String result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_8);
        Test.stopTest();
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
        Assert.areEqual(1, [SELECT COUNT() FROM pharos__Log__c]);
    }

    @IsTest
    static void testGenerateTestCase9_ErrorUnsupportedMediaType() {
        Test.setMock(HttpCalloutMock.class, new IntegrationErrorMock(415, 'Unsupported Media Type'));
        
        Test.startTest();
            String result = PharosTestCaseGeneratorController.generateTestCase(PharosTestCaseGeneratorController.LABEL_TEST_CASE_9);
        Test.stopTest();
        
        Assert.isTrue(String.isNotBlank(result), 'Result should not be null or empty');
        Assert.areEqual(1, [SELECT COUNT() FROM pharos__Log__c]);
    }
    
    @IsTest
    static void testGenerateTestCaseInvalidError() {
        AuraHandledException expectedException;
        Test.startTest();
            try {
                PharosTestCaseGeneratorController.generateTestCase('Invalid Test Case');
            } catch (AuraHandledException e) {
                expectedException = e;
            }
        Test.stopTest();

        Assert.isNotNull(expectedException, 'Expected exception should not be null');
    }
    
    @IsTest
    static void testDeleteAllLogs() {
        // Create a test log
        pharos__Log__c testLog = new pharos__Log__c(
            pharos__Category__c = PharosTestCaseGeneratorController.ERROR_CATEGORY_APEX
        );
        insert testLog;

        Test.startTest();
        Id batchId = PharosTestCaseGeneratorController.deleteAllLogs();
        Test.stopTest();
        
        Assert.areNotEqual(null, batchId, 'Batch ID should not be null');
        Assert.areEqual(0, [SELECT COUNT() FROM pharos__Log__c]);
    }
    
    @IsTest
    static void testDeleteAllDocuments() {
        // Create test ContentVersion (which creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        Test.startTest();
            Id batchId = PharosTestCaseGeneratorController.deleteAllDocuments();
        Test.stopTest();
        
        Assert.areNotEqual(null, batchId, 'Batch ID should not be null');

        // Verify document was deleted
        List<ContentDocument> remainingDocs = [
            SELECT Id FROM ContentDocument WHERE Title = 'Test Document'
        ];
        Assert.areEqual(0, remainingDocs.size(), 'Test document should be deleted');
    }
    
    @IsTest
    static void testGetBatchJobStatus() {
        // Start a batch to get a valid job ID
        Test.startTest();
            Id batchId = Database.executeBatch(new PharosLogCleanerBatch());
        Test.stopTest();
        
        PharosTestCaseGeneratorController.BatchJobStatus status = 
            PharosTestCaseGeneratorController.getBatchJobStatus(batchId);
        
        Assert.areNotEqual(null, status, 'Status should not be null');
        Assert.areEqual(batchId, status.jobId, 'Job ID should match');
        Assert.areNotEqual(null, status.status, 'Status string should not be null');
    }
    
    @IsTest
    static void testGetBatchJobStatusInvalidId() {
        AuraHandledException expectedException;
        Test.startTest();
            try {
                // Use a fake ID that won't exist
                PharosTestCaseGeneratorController.getBatchJobStatus('707000000000000AAA');
            } catch (AuraHandledException e) {
                expectedException = e;
            }
        Test.stopTest();

        Assert.isNotNull(expectedException, 'Expected exception should not be null');
    }
    
    @IsTest
    static void testGetLog() {
        String strDatetime = String.valueOfGmt(System.now().addMinutes(-1));
        
        Test.startTest();
            pharos__Log__c result = PharosTestCaseGeneratorController.getLog(PharosTestCaseGeneratorController.LABEL_TEST_CASE_1, strDatetime);
        Test.stopTest();
        
        Assert.areEqual(null, result, 'Should not find the created log');
    }
    
    @IsTest
    static void testGetLogWithExistingLog() {
        // Create a test log
        pharos__Log__c testLog = new pharos__Log__c(
            pharos__Category__c = PharosTestCaseGeneratorController.ERROR_CATEGORY_APEX
        );
        insert testLog;
        
        String strDatetime = String.valueOfGmt(System.now().addMinutes(-1));
        
        Test.startTest();
            pharos__Log__c result = PharosTestCaseGeneratorController.getLog(PharosTestCaseGeneratorController.LABEL_TEST_CASE_1, strDatetime);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should find the created log');
        Assert.areEqual(testLog.Id, result.Id, 'Should return the correct log');
    }

    @IsTest
    static void testSendInboundEmailWithPlainText() {
        // return [
        //     SELECT pharos__Subject__c, pharos__Plain_Text__c, pharos__Html_Body__c
        //     FROM pharos__Inbound_Email__c
        //     WHERE Id = :recordId
        // ];

        pharos__Inbound_Email__c inboundEmail = new pharos__Inbound_Email__c(
            pharos__Subject__c = 'test',
            pharos__Plain_Text__c = 'test'
        );

        insert inboundEmail;
        
        Integer numberOfEmailInvocations;
        Test.startTest();
            Boolean result = PharosTestCaseGeneratorController.sendInboundEmail(inboundEmail.Id, 'test');
            numberOfEmailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.isTrue(result);
        Assert.isNotNull(numberOfEmailInvocations);
        Assert.isTrue(numberOfEmailInvocations > 0);
    }

    @IsTest
    static void testSendInboundEmailWithHtmlText() {
        pharos__Inbound_Email__c inboundEmail = new pharos__Inbound_Email__c(
            pharos__Subject__c = 'test',
            pharos__Html_Body__c = 'test'
        );

        insert inboundEmail;

        Integer numberOfEmailInvocations;
        Test.startTest();
            Boolean result = PharosTestCaseGeneratorController.sendInboundEmail(inboundEmail.Id, null);
            numberOfEmailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.isTrue(result);
        Assert.isNotNull(numberOfEmailInvocations);
        Assert.isTrue(numberOfEmailInvocations > 0);
    }
    
    @IsTest
    static void testSendInboundEmailInvalidId() {
        AuraHandledException expectedException;
        Test.startTest();
        try {
            PharosTestCaseGeneratorController.sendInboundEmail(null, 'test');
        } catch (AuraHandledException e) {
            expectedException = e;
        }
        Test.stopTest();

        Assert.isNotNull(expectedException, 'Expected exception should not be null');
    }

    private class IntegrationErrorMock implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        
        public IntegrationErrorMock(Integer statusCode, String status) {
            this.statusCode = statusCode;
            this.status = status;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setStatus(status);
            res.setBody('{"error": "' + status + '"}');
            return res;
        }
    }
}