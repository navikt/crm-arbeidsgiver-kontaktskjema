/**
 * @description This is a test class for TAG_ContactFormController
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema)
 * @see TAG_ContactFormController
 *
 * @group TAG Contact Form
 */
@IsTest
public with sharing class TAG_ContactFormController_Test {
    
  
    @IsTest
    static void testProcessSingleContactFormRecruiteAndIncludePositive() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '973113631');
        contactFormMap.put('ContactName', 'Test Testersen');
        contactFormMap.put('ContactEmail', 'test.testersen@email.com');
        contactFormMap.put('ContactPhone', '90909090');
        contactFormMap.put('ThemeSelected', TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL);

        Test.startTest();
        TAG_ContactFormController.createContactForm(contactFormMap);
        Test.stopTest();

        List<EmployerInquiry__c> inquiry = [
            SELECT Id, TAG_WebFormAccountOrgNr__c, TAG_WebFormTheme__c, TAG_WebFormAccountName__c, TAG_WebFormContactEmail__c,TAG_WebFormContactName__c, TAG_WebFormContactPhone__c, TAG_Status__c, TAG_Source__c
            FROM EmployerInquiry__c WHERE TAG_WebFormTheme__c = :TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL LIMIT 1
        ];

        System.assertEquals(TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL, inquiry[0].TAG_WebFormTheme__c, 'WebFormTheme__c should be Recruit and Include');
        System.assertEquals(TAG_ContactForm.STAGE, inquiry[0].TAG_Status__c, 'TAG_Status__c should be Ny henvendelse');
        System.assertEquals(TAG_ContactForm.SOURCE, inquiry[0].TAG_Source__c, 'Source__c should be Kontaktskjema');
        System.assertEquals('Test Testersen', inquiry[0].TAG_WebFormContactName__c, 'Contact Name should be Test Testersen');
        System.assertEquals('test.testersen@email.com', inquiry[0].TAG_WebFormContactEmail__c, 'Contact Email should be test.testersen@email.com');
        System.assertEquals('90909090', inquiry[0].TAG_WebFormContactPhone__c, 'Contact Phone should be 90909090');
    }

    @IsTest
    static void testProcessSingleContactFormPreventSickLeavePositive() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '973113632');
        contactFormMap.put('ContactName', 'Test Testersen');
        contactFormMap.put('ContactEmail', 'test.testersen@email.com');
        contactFormMap.put('ContactPhone', '90909090');
        contactFormMap.put('ThemeSelected', TAG_ContactForm.THEME_FOREBYGGE_SYKEFRAVAER_LABEL);

        Test.startTest();
        TAG_ContactFormController.createContactForm(contactFormMap);
        Test.stopTest();

        List<EmployerInquiry__c> inquiry = [
            SELECT Id, TAG_WebFormAccountOrgNr__c, TAG_WebFormTheme__c, TAG_WebFormAccountName__c, TAG_WebFormContactEmail__c,TAG_WebFormContactName__c, TAG_WebFormContactPhone__c, TAG_Status__c, TAG_Source__c
            FROM EmployerInquiry__c WHERE TAG_WebFormTheme__c = :TAG_ContactForm.THEME_FOREBYGGE_SYKEFRAVAER_LABEL LIMIT 1
        ];

        System.assertEquals(TAG_ContactForm.THEME_FOREBYGGE_SYKEFRAVAER_LABEL, inquiry[0].TAG_WebFormTheme__c, 'WebFormTheme__c should be Prevent sick leave');
        System.assertEquals(TAG_ContactForm.STAGE, inquiry[0].TAG_Status__c, 'TAG_Status__c should be Ny henvendelse');
        System.assertEquals(TAG_ContactForm.SOURCE, inquiry[0].TAG_Source__c, 'Source__c should be Kontaktskjema');
        System.assertEquals('Test Testersen', inquiry[0].TAG_WebFormContactName__c, 'Contact Name should be Test Testersen');
        System.assertEquals('test.testersen@email.com', inquiry[0].TAG_WebFormContactEmail__c, 'Contact Email should be test.testersen@email.com');
        System.assertEquals('90909090', inquiry[0].TAG_WebFormContactPhone__c, 'Contact Phone should be 90909090');
    }

    @IsTest
    static void testProcessSingleContactFormPreventSickLeaveNull() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '');
        contactFormMap.put('ContactName', '');
        contactFormMap.put('ContactEmail', '');
        contactFormMap.put('ContactPhone', '');
        contactFormMap.put('ThemeSelected', '');

        Test.startTest();
        try {
            TAG_ContactFormController.createContactForm(contactFormMap);
        } catch(AuraHandledException e) {
            Assert.isNotNull(e);
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

   
}

