public with sharing class PharosTestCaseGeneratorController {
    
    @TestVisible
    private static final String LABEL_TEST_CASE_1 = 'Test Case 1';
    @TestVisible
    private static final String LABEL_TEST_CASE_2 = 'Test Case 2';
    @TestVisible
    private static final String LABEL_TEST_CASE_3 = 'Test Case 3';
    @TestVisible
    private static final String LABEL_TEST_CASE_4 = 'Test Case 4';
    @TestVisible
    private static final String LABEL_TEST_CASE_5 = 'Test Case 5';

    @TestVisible
    private static final String LABEL_TEST_CASE_6 = 'Test Case 6';
    @TestVisible
    private static final String LABEL_TEST_CASE_7 = 'Test Case 7';
    @TestVisible
    private static final String LABEL_TEST_CASE_8 = 'Test Case 8';
    @TestVisible
    private static final String LABEL_TEST_CASE_9 = 'Test Case 9';

    private static final String DESCRIPTION_TEST_CASE_1 = 'Attempt to de-reference a null object';
    private static final String DESCRIPTION_TEST_CASE_2 = 'System.ListException: List index out of bounds: 0';
    private static final String DESCRIPTION_TEST_CASE_3 = 'System.LimitException: Too many DML rows: 10001';
    private static final String DESCRIPTION_TEST_CASE_4 = 'System.IllegalArgumentException: Parameter value cannot be negative: -1';
    private static final String DESCRIPTION_TEST_CASE_5 = 'System.MathException: Divide by zero in Batch execute context';

    @TestVisible
    private static final String ERROR_CATEGORY_APEX = 'Apex';
    @TestVisible
    private static final String ERROR_CATEGORY_INTEGRATION = 'Integration';

    private static final Map<String, String> MAP_ERROR_CATEGORY_BY_ERROR = new Map<String, String>{
        LABEL_TEST_CASE_1 => ERROR_CATEGORY_APEX,
        LABEL_TEST_CASE_2 => ERROR_CATEGORY_APEX,
        LABEL_TEST_CASE_3 => ERROR_CATEGORY_APEX,
        LABEL_TEST_CASE_4 => ERROR_CATEGORY_APEX,
        LABEL_TEST_CASE_5 => ERROR_CATEGORY_APEX,

        LABEL_TEST_CASE_6 => ERROR_CATEGORY_INTEGRATION,
        LABEL_TEST_CASE_7 => ERROR_CATEGORY_INTEGRATION,
        LABEL_TEST_CASE_8 => ERROR_CATEGORY_INTEGRATION,
        LABEL_TEST_CASE_9 => ERROR_CATEGORY_INTEGRATION
    };

    private static final Set<String> FLOW_API_NAMES = new Set<String>{
        'Pharos_Account_Delete_Handler',
        'Pharos_Account_Integration_Logger',
        'Pharos_Account_Loop_Update',
        'Pharos_Account_Scheduled_Subflow',
        'Pharos_Account_Transform_Operations',
        'Pharos_Account_Update_Conditional',
        'Pharos_Asset_Create_Contact',
        'Pharos_Autolaunched_Opportunity_Creator',
        'Pharos_Case_Create_Fault_Path',
        'Pharos_Case_Fault_Path_Handler',
        'Pharos_Case_Team_Slack_Notification',
        'Pharos_Contact_Before_Save_Update',
        'Pharos_Contact_Create_Opportunity',
        'Pharos_Contact_Lead_Source_Notifier',
        'Pharos_Create_Lead',
        'Pharos_Issue_Analysis_Logger',
        'Pharos_Opportunity_Stage_Notifier',
        'Pharos_Opportunity_Trigger_Fault_Path',
        'Pharos_Partner_Intake_Form',
        'Pharos_Platform_Event_Error_Logger',
        'Pharos_Scheduled_Flow_Account_Type_Notifier',
        'Pharos_Scheduled_Flow_Birthday_Email',
        'Pharos_Scheduled_Flow_Loop_Subflow',
        'Pharos_Scheduled_Flow_Wait_Element',
        'Pharos_Scheduled_Flow_Wait_Elements',
        'Pharos_Screen_Flow_Account_Creation_Error',
        'Pharos_Screen_Flow_Account_Operations',
        'Pharos_Screen_Flow_Account_Selector',
        'Pharos_Screen_Flow_Contact_Birthday',
        'Pharos_Screen_Flow_Loop_Decision',
        'Pharos_Screen_Flow_Rollback',
        'Pharos_Screen_Flow_Rollback_Test',
        'Pharos_Update_Contact_Communication_Prefs'
    };

    @AuraEnabled
    public static List<PharosCategoryItemWrapper> getInitialData() {
        return new List<PharosCategoryItemWrapper>{
            new PharosCategoryItemWrapper(ERROR_CATEGORY_APEX, getApexTestCases()),
            new PharosCategoryItemWrapper(ERROR_CATEGORY_INTEGRATION, getIntegrationTestCases()),
            new PharosCategoryItemWrapper('Automation', getAutomationTestCases(), true)
        };
    }

    @AuraEnabled
    public static Map<String, Object> getLimits() {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        return new Map<String, Object>{
            'lastUpdatedDate' => Datetime.now(),
            'orgLimits' => new List<OrgLimitInfo>{
                new OrgLimitInfo(limitsMap.get('DataStorageMB')),
                new OrgLimitInfo(limitsMap.get('FileStorageMB')),
                new OrgLimitInfo(limitsMap.get('SingleEmail'))
            }
        };
    }

    @AuraEnabled
    public static Boolean isApexExceptionEmailExist() {
        return !getEmailServicesAddresses().isEmpty();
    }

    @AuraEnabled
    public static Boolean sendInboundEmail(Id inboundEmailId, String additionalPlainText) {
        List<pharos__Inbound_Email__c> inboundEmails = getInboundEmailById(inboundEmailId);
        if (inboundEmails.isEmpty()) {
            throw new AuraHandledException('Invalid record id');
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(inboundEmails.get(0).pharos__Subject__c);
        email.setToAddresses(new List<String>{ getEmailFromEmailServiceAddress(getEmailServicesAddresses().get(0)) });
        if (String.isNotBlank(inboundEmails.get(0).pharos__Html_Body__c)) {
            email.setHtmlBody(inboundEmails.get(0).pharos__Html_Body__c);
        } else {
            email.setPlainTextBody(inboundEmails.get(0).pharos__Plain_Text__c + additionalPlainText);
        }
        email.setSaveAsActivity(true);
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        return sendResults[0].success;
    }

    @AuraEnabled
    public static String generateTestCase(String error) {
        String result = String.valueOfGmt(System.now());
        if (error.equals(LABEL_TEST_CASE_1)) {
            System.enqueueJob(new PharosAsyncProcessesErrorGenerator.NullPointerGenerator());
        } else if (error.equals(LABEL_TEST_CASE_2)) {
            System.enqueueJob(new PharosAsyncProcessesErrorGenerator.ListIndexOutOfBoundsGenerator());
        } else if (error.equals(LABEL_TEST_CASE_3)) {
            System.enqueueJob(new PharosAsyncProcessesErrorGenerator.DMLRowLimitGenerator());
        } else if (error.equals(LABEL_TEST_CASE_4)) {
            System.enqueueJob(new PharosAsyncProcessesErrorGenerator.IllegalArgumentGenerator());
        } else if (error.equals(LABEL_TEST_CASE_5)) {
            Database.executeBatch(new PharosDivisionErrorGeneratorBatch(), 1);
        } else if (error.equals(LABEL_TEST_CASE_6)) {
            PharosIntegrationErrorGenerator.generateErrorUnauthorized();
        } else if (error.equals(LABEL_TEST_CASE_7)) {
            PharosIntegrationErrorGenerator.generateErrorNotFound();
        } else if (error.equals(LABEL_TEST_CASE_8)) {
            PharosIntegrationErrorGenerator.generateErrorMethodNotAllowed();
        } else if (error.equals(LABEL_TEST_CASE_9)) {
            PharosIntegrationErrorGenerator.generateErrorUnsupportedMediaType();
        } else {
            throw new AuraHandledException('This test case does not have actions');
        }
        return result;
    }

    @AuraEnabled
    public static Id deleteAllLogs() {
        return Database.executeBatch(new PharosLogCleanerBatch());
    }

    @AuraEnabled
    public static Id deleteAllDocuments() {
        return Database.executeBatch(new PharosDocumentCleanerBatch());
    }

    @AuraEnabled
    public static BatchJobStatus getBatchJobStatus(String jobId) {
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ExtendedStatus
                FROM AsyncApexJob 
                WHERE Id = :jobId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (jobs.isEmpty()) {
                throw new AuraHandledException('Job not found');
            }

            return new BatchJobStatus(jobs.get(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving batch job status: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static pharos__Log__c getLog(String error, String strDatetime) {
        List<pharos__Log__c> logs = [
            SELECT Id, Name
            FROM pharos__Log__c
            WHERE pharos__Category__c = :MAP_ERROR_CATEGORY_BY_ERROR.get(error)
            AND CreatedDate >= :Datetime.valueOfGmt(strDatetime)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!logs.isEmpty()) {
            return logs[0];
        }
        return null;
    }

    private static List<PharosTestCaseItemWrapper> getApexTestCases() {
        return new List<PharosTestCaseItemWrapper>{
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_1, DESCRIPTION_TEST_CASE_1),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_2, DESCRIPTION_TEST_CASE_2),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_3, DESCRIPTION_TEST_CASE_3),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_4, DESCRIPTION_TEST_CASE_4),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_5, DESCRIPTION_TEST_CASE_5)
        };
    }

    private static List<PharosTestCaseItemWrapper> getIntegrationTestCases() {
        return new List<PharosTestCaseItemWrapper>{
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_6, 'Error: 401 Unauthorized'),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_7, 'Error: 404 Not Found'),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_8, 'Error: 405 Method Not Allowed'),
            new PharosTestCaseItemWrapper(LABEL_TEST_CASE_9, 'Error: 415 Unsupported Media Type')
        };
    }

    private static List<PharosTestCaseItemWrapper> getAutomationTestCases() {
        List<PharosTestCaseItemWrapper> wrappers = new List<PharosTestCaseItemWrapper>();

        for (FlowDefinitionView currentFlowDefinitionView : getFlows()) {
            wrappers.add(new PharosTestCaseItemWrapper(currentFlowDefinitionView));
        }

        return wrappers;
    }

    private static String getEmailFromEmailServiceAddress(EmailServicesAddress address) {
        return address.LocalPart.toLowerCase() + '@' + address.EmailDomainName;
    }

    private static List<EmailServicesAddress> getEmailServicesAddresses() {
        return [
            SELECT Id, LocalPart, EmailDomainName
            FROM EmailServicesAddress
            WHERE IsActive = true
            AND Function.IsActive = true
            AND Function.ApexClassId = :getApexClassErrorEmailHandler().get(0).Id
        ];
    }

    private static List<ApexClass> getApexClassErrorEmailHandler() {
        return [
            SELECT Id
            FROM ApexClass
            WHERE Name = 'ErrorEmailHandler' AND NamespacePrefix = 'pharos'
        ];
    }

    private static List<pharos__Inbound_Email__c> getInboundEmailById(Id recordId) {
        return [
            SELECT pharos__Subject__c, pharos__Plain_Text__c, pharos__Html_Body__c
            FROM pharos__Inbound_Email__c
            WHERE Id = :recordId
        ];
    }

    private static List<FlowDefinitionView> getFlows() {
        return [
            SELECT 
                Id, ApiName, Label, Description,
                ProcessType, IsActive, ActiveVersionId,
                LatestVersionId, VersionNumber
            FROM FlowDefinitionView
            WHERE ApiName IN :FLOW_API_NAMES
            ORDER BY ApiName ASC
        ];
    }

    public class PharosCategoryItemWrapper {
        @AuraEnabled public String category;
        @AuraEnabled public Boolean isAutomation;
        @AuraEnabled public List<PharosTestCaseItemWrapper> testCases;

        public PharosCategoryItemWrapper(String category, List<PharosTestCaseItemWrapper> testCases) {
            this(category, testCases, false);
        }

        public PharosCategoryItemWrapper(String category, List<PharosTestCaseItemWrapper> testCases, Boolean isAutomation) {
            this.category = category;
            this.testCases = testCases;
            this.isAutomation = isAutomation;
        }
    }

    public class PharosTestCaseItemWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String description;

        // For Automation
        @AuraEnabled public String id;
        @AuraEnabled public String apiName;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public String versionId;

        public PharosTestCaseItemWrapper(String label, String description) {
            this.label = label;
            this.description = description;
        }

        public PharosTestCaseItemWrapper(FlowDefinitionView flowDefinitionView) {
            this.label = flowDefinitionView.Label;
            this.description = flowDefinitionView.Description;
            this.id = flowDefinitionView.Id;
            this.apiName = flowDefinitionView.ApiName;
            this.isActive = flowDefinitionView.IsActive;
            this.versionId = flowDefinitionView.ActiveVersionId ?? flowDefinitionView.LatestVersionId;
        }
    }

    public class BatchJobStatus {
        @AuraEnabled public String jobId;
        @AuraEnabled public String status;
        @AuraEnabled public String extendedStatus;
        @AuraEnabled public Boolean isCompleted;
        @AuraEnabled public Boolean isFailed;

        public BatchJobStatus(AsyncApexJob job) {
            this.jobId = job.Id;
            this.status = job.Status;
            this.extendedStatus = job.ExtendedStatus;
            this.isCompleted = (status == 'Completed');
            this.isFailed = (status == 'Failed' || status == 'Aborted');
        }
    }

    public class OrgLimitInfo {
        @AuraEnabled public String name;
        @AuraEnabled public Integer remaining;
        @AuraEnabled public Integer maxLimit;

        public OrgLimitInfo(System.OrgLimit orgLimit) {
            this.name = orgLimit.getName();
            this.maxLimit = orgLimit.getLimit();
            this.remaining = this.maxLimit - orgLimit.getValue();
        }
    }
}