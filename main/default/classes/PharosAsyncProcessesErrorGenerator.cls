public with sharing class PharosAsyncProcessesErrorGenerator {
    
    // Attempt to de-reference a null object
    public class NullPointerGenerator implements Queueable {
        public void execute(QueueableContext context) {
            String testString = null;
            String result = testString.toUpperCase();
        }
    }

    // System.ListException: List index out of bounds: 0
    public class ListIndexOutOfBoundsGenerator implements Queueable {
        public void execute(QueueableContext context) {
            try {
                // Create a list with no elements
                List<String> emptyList = new List<String>();
                // Attempt to access an index that doesn't exist
                String item = emptyList.get(0); // This will throw a ListException
            } catch (System.ListException e) {
                System.debug('Caught a ListException: ' + e.getMessage());
                // Optionally, rethrow the exception to fail the job
                throw e;
            }
        }
    }

    // System.LimitException: Too many DML rows: 10001
    public class DMLRowLimitGenerator implements Queueable {
        private final Integer maxDMLRows = !Test.isRunningTest() ? 200000 : 1;
        public void execute(QueueableContext context) {
            try {
                // Simulating a scenario that might lead to an AsyncException
                // For example, creating a very large number of records that exceeds limits
                List<Account> accountsToInsert = new List<Account>();
                for (Integer i = 0; i < maxDMLRows; i++) { // Trying to insert too many records
                    accountsToInsert.add(new Account(Name = 'Test Account ' + i));
                }
                insert accountsToInsert; // This will likely exceed governor limits

                // In test context, throw a simulated exception since LimitException is uncatchable
                if (Test.isRunningTest()) {
                    throw new DMLRowLimitException('Too many DML rows: 10001');
                }
            } catch (Exception ex) {
                System.debug('Caught an exception: ' + ex.getMessage());
                // Optionally, rethrow to fail the job
                throw ex;
            }
        }
    }
    
    public class DMLRowLimitException extends Exception {}

    // System.IllegalArgumentException: Parameter value cannot be negative: -1
    public class IllegalArgumentGenerator implements Queueable {
        public void execute(QueueableContext context) {
            try {
                // Simulating a scenario that causes an invalid parameter issue
                Integer invalidValue = -1; // Negative value is invalid in this context
                this.validateParameter(invalidValue);
            } catch (IllegalArgumentException ex) {
                System.debug('Caught an IllegalArgumentException: ' + ex.getMessage());
                // Optionally, rethrow to fail the job
                throw ex;
            } catch (Exception ex) {
                System.debug('Caught a general exception: ' + ex.getMessage());
                // Optionally, rethrow to fail the job
                throw ex;
            }
        }

        private void validateParameter(Integer value) {
            // Throw an exception if the value is invalid
            if (value < 0) {
                throw new IllegalArgumentException('Parameter value cannot be negative: ' + value);
            }
        }
    }
}