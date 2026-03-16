/**
 * @description This is a test class for TAG_ContactFormSendEmail
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema)
 * @see TAG_ContactFormSendEmail
 *
 * @group TAG Contact Form
 */
@IsTest
public with sharing class TAG_ContactFormSendEmail_Test {
 
@TestSetup
static void makeData() {
    Account acc = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631');
        insert acc;

    Contact con = new Contact(FirstName = 'Test', LastName = 'Testersen', Email = 'test.testersen@email.com', Phone = '90909090');
        insert con;

    EmployerInquiry__c co = new EmployerInquiry__c();
        co.TAG_WebFormTheme__c = TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL;
        co.TAG_Account__c = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '973113631'].Id;
        co.TAG_Contact__c = [SELECT Id FROM Contact WHERE Email = 'test.testersen@email.com'].Id;
        co.TAG_Status__c = TAG_ContactForm.STAGE;
        co.TAG_Source__c = TAG_ContactForm.SOURCE;
        insert co;
    }

    /**
     * @description Testing the `sendEmailReceipts` method with correct value.
     * Testing with value: `EmployerInquiry__c inquiry`
     * Expected result: A new record in the EmailQueue__c object with status = Queued
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
    @IsTest
    static void testProcessEmailPositive() {

        EmployerInquiry__c inquiry = [
            SELECT Id, Name, TAG_Account__c, TAG_Contact__c, TAG_Status__c, TAG_Source__c, TAG_WebFormTheme__c
            FROM EmployerInquiry__c WHERE TAG_WebFormTheme__c = :TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL LIMIT 1
        ];

        Test.startTest();
        TAG_ContactFormSendEmail.sendEmailReceipts(inquiry);
        Test.stopTest();

        List<EmailQueue__c> queuedEmail = [
            SELECT Id, Name, TemplateName__c, TargetObjectId__c, Status__c, WhatId__c
            FROM EmailQueue__c LIMIT 1
        ];

        List<Contact> contact = [
            SELECT Id, Email
            FROM Contact WHERE Email = 'test.testersen@email.com' LIMIT 1
        ];

        System.assertEquals('kontaktskjemaRekrutteringReceipt', queuedEmail[0].TemplateName__c, 'Template name should be kontaktskjemaRekrutteringReceipt for '+TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL+' theme');
        System.assertEquals(contact[0].Id, queuedEmail[0].TargetObjectId__c, 'Contact Id not matching TargetObjectId__c');
        System.assertEquals('Queued', queuedEmail[0].Status__c, 'Status should have value Queued');
        System.assertEquals(inquiry.Id, queuedEmail[0].WhatId__c, 'Inquiry Id not matching the WhatId__c');
    }
}
