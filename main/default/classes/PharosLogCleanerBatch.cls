public with sharing class PharosLogCleanerBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<pharos__Log__c> logs;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM pharos__Log__c LIMIT 10000]);
    }

    public void execute(Database.BatchableContext BC, List<pharos__Log__c> scope) {
        this.logs = scope;
    }

    public void finish(Database.BatchableContext BC) {
        if (this.logs != null && !this.logs.isEmpty()) {
            delete this.logs;
            Database.executeBatch(new PharosLogCleanerBatch());
        }
    }
}