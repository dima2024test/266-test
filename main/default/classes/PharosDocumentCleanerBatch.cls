public with sharing class PharosDocumentCleanerBatch implements Database.Batchable<SObject> {
    private static final Set<String> EXCLUDE_CONTENT_DOCUMENT_TITLES = new Set<String>{
        'Pharos_Logo_RGB_Color_Blk'
    };

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM ContentDocument 
            WHERE Title NOT IN :EXCLUDE_CONTENT_DOCUMENT_TITLES
        ]);
    }

    public void execute(Database.BatchableContext BC, List<ContentDocument> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {}
}