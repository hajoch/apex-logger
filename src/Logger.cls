/**
*	@author Hallvard Jore christensen
* @date 13. March 2018
**/
public class Logger {

	public enum Severity { DEBUG, INFO, WARNING, ERROR, CRITICAL }

    //Settings
    public static final Severity DEFAULT_SEVERITY = Severity.DEBUG;
    //Local variables
    private List<App_Log__c> logs;

    public Logger(){
         logs = new List<App_Log__c>();
    }

    public void publish() {
        insert logs;
        logs.clear();
    }

    public App_Log__c peek() { return (logs.isEmpty() ? null : logs.get(logs.size()-1)); }

    public AppLogBuilder debug(String message, sObject obj) 	{ return logMessage(message, Severity.DEBUG, obj); }
    public AppLogBuilder info(String message,  sObject obj) 	{ return logMessage(message, Severity.INFO, obj); }
    public AppLogBuilder warning(String message,  sObject obj) 	{ return logMessage(message, Severity.WARNING, obj); }
		public AppLogBuilder error(String message,  sObject obj) 	{ return logMessage(message, Severity.ERROR, obj); }
    public AppLogBuilder critical(String message,  sObject obj)	{ return logMessage(message, Severity.CRITICAL, obj); }
    public AppLogBuilder exception(Exception e) {
        return logMessage(e.getTypeName()+': \r\n'+e.getMessage(), null, null,
                          Severity.ERROR, null, null, e.getStackTraceString(), null, null);
    }

    public AppLogBuilder logMessage(String message, sObject obj) {
        return logMessage(message, Severity.DEBUG, obj);
    }
    public AppLogBuilder logMessage(String message, Severity severity, sObject obj) {
        String objectName = (obj == null ? '' : obj.getSObjectType().getDescribe().getName());
        String objId = (obj == null ? null : obj.Id);
        return logMessage(message, null, null, severity, objId, objectName, null, JSON.serializePretty(obj), null);
    }
    public AppLogBuilder logMessage(String message, String source, String sourceFunction, Severity severity, String referenceId, String referenceType, String stackTrace, String payload, Integer deltaTime) {

        //Backup value
        if(severity == null) severity = DEFAULT_SEVERITY;
				//Create log message
        App_Log__c log = new App_Log__c(
       		Message__c = message,
            Source__c = source,
            Source_Function__c = sourceFunction,
            Debug_Level__c = severity.name(),
            Reference_Id__c = referenceId,
            Reference_Type__c = referenceType,
            Stack_Trace__c = stackTrace,
            Payload__c = payload,
            Delta_Time__c = deltaTime
        );

				//Fill in missing context information and add to list
        trackAppLog(log);
				logs.add(log);
        return new AppLogBuilder(log);
    }

    public class AppLogBuilder {
        public final App_Log__c log;
        public AppLogBuilder(App_Log__c log) { this.log = log; }
        public AppLogBuilder source(String sourceClass) 			{ log.Source__c = sourceClass; return this; }
        public AppLogBuilder message(String message) 				{ log.Message__c = message; return this; }
        public AppLogBuilder payload(String payload)  				{ log.Payload__c = payload; return this; }
        public AppLogBuilder reference(String referenceId) 			{ log.Reference_Id__c = referenceId; return this; }
        public AppLogBuilder deltaTime(Integer deltaTime) 			{ log.Delta_Time__c = deltaTime; return this; }
        public AppLogBuilder stackTrace(String stackTrace) 			{ log.Stack_Trace__c = stackTrace; return this; }
        public AppLogBuilder referenceType(String referenceType)	{ log.Reference_Type__c = referenceType; return this; }
        public AppLogBuilder sourceFunction(String sourceFunction)	{ log.Source_Function__c = sourceFunction; return this; }
    }

    private static void trackAppLog(App_Log__c log) {
        //Extract and fill context information if missing
        if(String.isBlank(log.Stack_Trace__c))
            log.Stack_Trace__c = getStackTrace();
        String sourceClass = log.Stack_Trace__c
            .substringAfter('Class.')
            .substringBefore('.');
        String sourceFunction = log.Stack_Trace__c
            .substringAfter(sourceClass+'.')
            .substringBefore(':');
        if(String.isBlank(log.Source__c)) 			log.Source__c = sourceClass;
        if(String.isBlank(log.Source_Function__c)) 	log.Source_Function__c = sourceFunction;
    }

    private static String getStackTrace() {
        String stackTrace = '';
        try { update new Account(); }
				catch(Exception e) {
            stackTrace = e.getStackTraceString()
                .substringAfterLast('Class.Logger')
                .substringAfter('column 1');
        }
        return stackTrace;
    }
}
