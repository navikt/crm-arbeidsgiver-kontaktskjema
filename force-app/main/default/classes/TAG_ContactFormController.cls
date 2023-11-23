/**
 * @description This Contact Form Controller class stores values entered by users in kontaktskjema experience site. It returns a value
 * to the kontaktskjema experience site.
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema)
 * @see TAG_ContactFormSendEmail
 * @see TAG_ContactFormController_Test
 *
 * @group TAG Contact Form
 */
public with sharing class TAG_ContactFormController {
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

    /**
     * @description The createContactForm method creates a Contact Form record and sends the record to the insertCustomOpportunity method
     * which creates a new Custom Opportunity record
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param contactFormData The request/input parameter which is sent from the kontaktskjema lwc. Includes all the values submitted by
     * the user in the contact form.
     */
    @AuraEnabled
    public static void createContactForm(Map<String, String> contactFormData) {
        Map<String, Account> accountMap = getAccountMap(contactFormData.get('ContactOrg'));
        List<TAG_ContactForm> newContactFormList = new List<TAG_ContactForm>();

        TAG_ContactForm newContactForm = new TAG_ContactForm();
            newContactForm.organizationNumber = contactFormData.get('ContactOrg');
            newContactForm.municipalityCode = accountMap.get(contactFormData.get('ContactOrg')).INT_MunicipalityNumber__c;
            newContactForm.organizationName = accountMap.get(contactFormData.get('ContactOrg')).name;
            newContactForm.regionNumber = accountMap.get(contactFormData.get('ContactOrg')).INT_RegionNumber__c;
            newContactForm.fullName = contactFormData.get('ContactName');
            newContactForm.email = contactFormData.get('ContactEmail');
            newContactForm.phoneNumber = contactFormData.get('ContactPhone');
            newContactForm.theme = contactFormData.get('ThemeSelected');

            newContactFormList.add(newContactForm);

            Map<String, Contact> contactMap = getContactMap(newContactFormList, accountMap);

            insertCustomOpportunity(newContactFormList, accountMap, contactMap);
    }

     /**
     * @description The getAccountName method finds the name of the company which the user represents, based on the organization number.
     * It returns the account name value.
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param orgNumber The request/input parameter which is sent from the kontaktskjema lwc. It indludes the the organization number
     * of the company that the user represents
     * @return accountName The return value, to kontaktskjema lwc, is the name of the company/account
     */
    @AuraEnabled(cacheable=true)
    public static String getAccountName(String orgNumber) {
        try {
            if (String.isEmpty(orgNumber)){
                return null;
            } else {
                String accountName = [SELECT Name FROM Account WHERE INT_OrganizationNumber__c = :orgNumber LIMIT 1].Name;
                return accountName;
            }
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while retrieving the Account Name.');
        }
    }

    /**
     * @description The insertCustomOpportunity method creates a new Custom Opportunity record and inserts it to the database. 
     * It then calls the TAG_ContactFormSendEmail.sendEmailReceipts method so an email receipt can be sent to the user
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param contactFormList The request/input parameter sent from createContactForm method, containing the Contact Form object
     * @param accountMap The request/input parameter sent from createContactForm method, containing account map of the account (company)
     * which the user represents
     * @param contactMap The request/input parameter sent from createContactForm method, containing the contact record of the user
     */
    private static void insertCustomOpportunity(List<TAG_ContactForm> contactFormList, Map<String, Account> accountMap, Map<String, Contact> contactMap) {
        try {
            CustomOpportunity__c newCustomOpportunity = new CustomOpportunity__c();
                newCustomOpportunity.Account__c = accountMap.get(contactFormList[0].organizationNumber).Id;
                newCustomOpportunity.Contact__c = contactMap.get(contactFormList[0].email.toLowerCase()).Id;
                newCustomOpportunity.TAG_OrganizationNameFromForm__c = contactFormList[0].organizationName;
                newCustomOpportunity.InquiryCategory__c = contactFormList[0].theme;
                newCustomOpportunity.RecordTypeId = INCLUSION_RECORD_TYPE;
                newCustomOpportunity.InclusionStage__c = 'Ny henvendelse';
                newCustomOpportunity.Source__c = 'Kontaktskjema';
                //newCustomOpportunity.OwnerId = getNavUnitQueue(accountMap.get(contactFormList[0].organizationNumber).TAG_NavUnit__c);

                if(contactFormList[0].theme == 'Skal ansette') {
                    newCustomOpportunity.INT_MunicipalityNumber__c = contactFormList[0].municipalityCode;
                } else if (contactFormList[0].theme == 'Forebygge sykefravær') {
                    newCustomOpportunity.INT_RegionNumber__c = getUnitRegionNumber(contactFormList[0].regionNumber);
                }

            insert newCustomOpportunity;
            TAG_ContactFormSendEmail.sendEmailReceipts(newCustomOpportunity);
        } catch (Exception e) {
            System.debug('An error occurred while inserting Custom Opportunity to the database: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while inserting Custom Opportunity to the database.');
        }
    }

    /**
     * @description The getAccountName method finds the record of the company which the user represents, based on the organization number.
     * It returns the account record within a map.
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param contactOrgNr The request/input parameter which is sent from the createContactForm method, contains the company/account
     * organization number
     * @return accountMap The return value, to createContactForm method, is the company/account record stored in a map with the 
     * INT_OrganizationNumber__c as key
     */
    private static Map<String, Account> getAccountMap(String contactOrgNr) {
        Map<String, Account> accountMap = new Map<String, Account>();
        Account a = [
            SELECT Id, Name, INT_OrganizationNumber__c, INT_MunicipalityNumber__c, TAG_NavUnit__c, INT_RegionNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c =:contactOrgNr AND IsPersonAccount = FALSE LIMIT 1
        ];

            accountMap.put(a.INT_OrganizationNumber__c, a); 

        return accountMap;
    }

    /**
     * @description The getContactMap method finds the contact record of the user, based on the data entered by the user in kontaktskjema,
     * which is stored in the ContactForm record. If the contact already exist it retrives the existing record, if not, it creates a new record.
     * This is done by calling the fetchOrCreateContact method in crm-arbeidsgiver-base repo.
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param formSubmissions The request/input parameter which is sent from the createContactForm method, contains ContactForm record
     * @param accountMap The request/input parameter which is sent from the createContactForm method, contains the account record in a map.
     * This value is sent on to the fetchOrCreateContact method so the Contact record can be related to an Account
     * @return The return value is the Contact record stored in a map
     */
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

            System.debug('Phone: ' + wrapper.phone);
        }

        return SharedFunctions.fetchOrCreateContact(contactWrappers, accountMap);
    }

    /**
     * @description The setName method splits the first name and last name for a contact record. It is called by the getContactMap method.
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param wrapper Contains the Contact Model record
     * @param model Contains the Contact Form record
     */
    private static void setName(SharedFunctions_ContactModel wrapper, TAG_ContactForm model) {
        if (!String.isEmpty(model.fullName)) {
            List<String> fullName = model.fullName.split(' ');
            String lastNameSplitted = fullName[fullName.size() - 1];
            String firstNameSplitted = model.fullName.removeEnd(' ' + lastNameSplitted);
            wrapper.firstName = firstNameSplitted.left(40);
            wrapper.lastName = lastNameSplitted.left(80);
        }
    }

    /**
     * @description The getNavUnitQueue method is called by the insertCustomOpportunity method. It takes in the Nav Unit Id of the nav unit 
     * which the company/account is related to. Then return the queue id of the nav unit
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param navUnitId Contains the Nav Unit record Id
     * @return navUnitQueue Contains the Nav Unit queue Id
     
    private static String getNavUnitQueue(Id navUnitId) {
        String navUnitQueue = [
            SELECT Id, CRM_QueueId__c
            FROM NAVUnit__c
            WHERE Id =:navUnitId AND IsDeleted = FALSE AND CRM_QueueId__c != null LIMIT 1
        ].CRM_QueueId__c;

        System.debug('getNavUnitQueue metoden: ' + navUnitQueue);

        return navUnitQueue;
    }*/

    /**
     * @description The getUnitRegionNumber method switches the national Region number to NAVs Unit region number
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-21 Created.
     *
     * @param regionNr Contains the national Region number (for countys in Norway)
     * @return NAVs Unit region number, which is unique for each Region/county office
     */
    @testVisible
    private static String getUnitRegionNumber(String regionNr) {
        switch on regionNr {
            when '30' {
                return '0200';
            }
            when '03' {
                return '0300';
            }
            when '34' {
                return '0400';
            }
            when '38' {
                return '0800';
            }
            when '42' {
                return '1000';
            }
            when '11' {
                return '1100';
            }
            when '46' {
                return '1200';
            }
            when '15' {
                return '1500';
            }
            when '18' {
                return '1800';
            }
            when '54' {
                return '1900';
            }
            when '50' {
                return '5700';
            }
            when else {
                return null;
            }
        }
    }
}