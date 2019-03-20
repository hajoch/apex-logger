@isTest
public class LoggerTest {
	
	@isTest
    public static void testEntryMethods() {
        Account a = new Account('Test Account'); insert a;
        
        Test.startTest();
        Logger log = new Logger();
        log.info('info', a);
        log.debug('debug', a);
        log.error('error', a);
        log.critical('critical', a);
        try {
            Case c = null;
           	String fail = c.Id;
        } catch(System.NullPointerException e) {
            log.exception(e);
            log.exception(e, a);
        }
        log.publish();
        Test.stopTest();
        
        App_Log__c[] logs = [SELECT Id FROM App_Log__c];
        System.assertEquals(6, logs.size());
    }
    
    @isTest
    public static void testStaticPublisher() {
        Account a = new Account('Test Account'); insert a;
        
        Test.startTest();
        Logger.log().error('Static init error', a).publish();
        Test.stopTest();
        
        App_Log__c[] logs = [SELECT Id FROM App_Log__c];
        System.assertEquals(1, logs.size());
    }
    
    @isTest
    public static void testChaining() {
        Account a = new Account('Test Account'); insert a
        
        Test.startTest();
        Logger log = new Logger();
        log.error('Error message', a)
            .reference(UserInfo.getUserId())
            .referenceType('User ID')
            .deltaTime(30000)
            .message('Override Message');
        log.publish();
        Test.stopTest();
        
        Application_Log__c result = [SELECT Id, Message__c, Reference_Id__c, Reference_Type__c, Delta_Time__c FROM App_Log__c LIMIT 1];
        
        System.assertNotEquals(null, result);
        System.assertEquals('Override Message', result.Message__c);
        System.assertEquals(30000, result.Delta_Time__c);
        System.assertEquals('User ID', result.Reference_Type__c);
        System.assertEquals(UserInfo.getUserId(), result.Reference_Id__c);
    }
}
