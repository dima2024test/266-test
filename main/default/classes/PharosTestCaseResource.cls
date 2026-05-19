@RestResource(urlMapping='/pharos_test_case_resource/*')
global with sharing class PharosTestCaseResource {

    @HttpPost
    global static PharosTestCaseResourceWrapper echoMyType(PharosTestCaseResourceWrapper wrapper) {
        return wrapper;
    }

    global class PharosTestCaseResourceWrapper {
        public String stringValue1;
        public String stringValue2 { get; set; }
        private String privateStringValue;
        public transient String transientStringValue;
    }
}