public with sharing class TAG_ContactFormController {
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

    @AuraEnabled
    public static void createContactForm(Map<String, String> contactFormData) {
        Map<String, Account> accountMap = getAccountMap(contactFormData.get('ContactOrg'));
        List<TAG_ContactForm> newContactFormList = new List<TAG_ContactForm>();

        TAG_ContactForm newContactForm = new TAG_ContactForm();
            newContactForm.organizationNumber = contactFormData.get('ContactOrg');
            newContactForm.municipalityCode = accountMap.get(contactFormData.get('ContactOrg')).INT_MunicipalityNumber__c;
            newContactForm.organizationName = accountMap.get(contactFormData.get('ContactOrg')).name;
            newContactForm.fullName = contactFormData.get('ContactName');
            newContactForm.email = contactFormData.get('ContactEmail');
            newContactForm.phoneNumber = contactFormData.get('ContactPhone');
            newContactForm.theme = contactFormData.get('ThemeSelected');

            newContactFormList.add(newContactForm);

            System.debug(newContactFormList);

            Map<String, Contact> contactMap = getContactMap(newContactFormList, accountMap);

            insertCustomOpportunity(newContactFormList, accountMap, contactMap);
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountName(String orgNumber) {
        String accountName = '';

        try {
            Account acc = [SELECT Name FROM Account WHERE INT_OrganizationNumber__c = :orgNumber LIMIT 1];
            if (acc != null) {
                accountName = acc.Name;
            } else {
                throw new AuraHandledException('Dette organisasjonsnummeret eksisterer ikke');
            }
        } catch (Exception e) {
            System.debug('An exception has occured: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while retrieving the Account Name.');
        }
        
        return accountName;
    }

    private static void insertCustomOpportunity(List<TAG_ContactForm> contactFormList, Map<String, Account> accountMap, Map<String, Contact> contactMap) {
        try {
            CustomOpportunity__c newCustomOpportunity = new CustomOpportunity__c();
                newCustomOpportunity.Account__c = accountMap.get(contactFormList[0].organizationNumber).Id;
                newCustomOpportunity.Contact__c = contactMap.get(contactFormList[0].email.toLowerCase()).Id;
                newCustomOpportunity.TAG_OrganizationNameFromForm__c = contactFormList[0].organizationName;
                newCustomOpportunity.INT_MunicipalityNumber__c = contactFormList[0].municipalityCode;
                newCustomOpportunity.InquiryCategory__c = contactFormList[0].theme;
                newCustomOpportunity.RecordTypeId = INCLUSION_RECORD_TYPE;
                newCustomOpportunity.InclusionStage__c = 'Ny henvendelse';
                newCustomOpportunity.Source__c = 'Kontaktskjema';

            insert newCustomOpportunity;
            TAG_ContactFormSendEmail.sendEmailReceipts(newCustomOpportunity);

        } catch (Exception e) {
            System.debug('An exception has occured: ' + e.getMessage());
            /*LoggerUtility logger = new LoggerUtility();
            logger.logError('Failed to create custom opportunity' + e.getMessage() + '/n' + e.getStackTraceString());*/
        }
    }

    private static Map<String, Account> getAccountMap(String contactOrgNr) {
        Map<String, Account> accountMap = new Map<String, Account>();
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c, INT_MunicipalityNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c =:contactOrgNr AND IsPersonAccount = FALSE
        ];

        for (Account a : accounts) {
            accountMap.put(a.INT_OrganizationNumber__c, a);
        }
        return accountMap;
    }
    
    private static Map<String, Contact> getContactMap(List<TAG_ContactForm> formSubmissions, Map<String, Account> accountMap) {

        List<SharedFunctions_ContactModel> contactWrappers = new List<SharedFunctions_ContactModel>();


        for (TAG_ContactForm submission : formSubmissions) {
            SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();

            wrapper.email = submission.email == null ? '' : submission.email; // if null, make it empty to avoid bug in SharedFunctions.fetchOrCreateContact
            wrapper.companyNumber = submission.organizationNumber;
            wrapper.phone = submission.phoneNumber;
            wrapper.email = submission.email;
            wrapper.source = 'Kontaktskjema';
            setName(wrapper, submission);
            contactWrappers.add(wrapper);
        }

        return SharedFunctions.fetchOrCreateContact(contactWrappers, accountMap);
    }

    private static void setName(SharedFunctions_ContactModel wrapper, TAG_ContactForm model) {
        if (!String.isEmpty(model.fullName)) {
            List<String> fullName = model.fullName.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = model.fullName.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted;
            wrapper.lastName = lastNameSplitted;
        }
    }
}