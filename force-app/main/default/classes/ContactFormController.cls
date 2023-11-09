public with sharing class ContactFormController {
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

    
    @AuraEnabled
    public static void createContactForm(Map<String, String> contactFormData) {
        Map<String, Account> accountMap = getOrgNumberAccountMap(contactFormData.get('ContactOrg'));
        List<ContactForm> newContactFormList = new List<ContactForm>();

        ContactForm newContactForm = new ContactForm();
            newContactForm.organizationNumber = contactFormData.get('ContactOrg');
            newContactForm.municipalityCode = accountMap.get(contactFormData.get('ContactOrg')).INT_MunicipalityNumber__c;
            newContactForm.organizationName = accountMap.get(contactFormData.get('ContactOrg')).name;
            newContactForm.fullName = contactFormData.get('ContactName');
            newContactForm.email = contactFormData.get('ContactEmail');
            newContactForm.phoneNumber = contactFormData.get('ContactPhone');
            newContactForm.theme = contactFormData.get('ThemeSelected');

            newContactFormList.add(newContactForm);

            Map<String, Contact> contactMap = getContactMap(newContactFormList, accountMap);

            insertCustomOpportunity(newContactFormList, accountMap, contactMap);  
    }


    private static void insertCustomOpportunity(List<ContactForm> formSubmissions, Map<String, Account> accountMap, Map<String, Contact> contactMap) {
        CustomOpportunity__c newCustomOpportunity = new CustomOpportunity__c();
            newCustomOpportunity.Account__c = accountMap.get(formSubmissions[0].organizationNumber).Id;
            newCustomOpportunity.Contact__c = contactMap.get(formSubmissions[0].email.toLowerCase()).Id;
            newCustomOpportunity.TAG_OrganizationNameFromForm__c = formSubmissions[0].organizationName;
            newCustomOpportunity.INT_MunicipalityNumber__c = formSubmissions[0].municipalityCode;
            newCustomOpportunity.InquiryCategory__c = formSubmissions[0].theme;
            newCustomOpportunity.RecordTypeId = INCLUSION_RECORD_TYPE;
            newCustomOpportunity.InclusionStage__c = 'Ny henvendelse';
            newCustomOpportunity.Source__c = 'Kontaktskjema';

        insert newCustomOpportunity;
    }

    private static Map<String, Account> getOrgNumberAccountMap(String contactOrgNr) {
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

    
    private static Map<String, Contact> getContactMap(List<ContactForm> formSubmissions, Map<String, Account> accountMap) {

        List<SharedFunctions_ContactModel> contactWrappers = new List<SharedFunctions_ContactModel>();


        for (ContactForm submission : formSubmissions) {
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

    private static void setName(SharedFunctions_ContactModel wrapper, ContactForm model) {
        if (!String.isEmpty(model.fullName)) {
            List<String> fullName = model.fullName.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = model.fullName.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted;
            wrapper.lastName = lastNameSplitted;
        }
    }
}