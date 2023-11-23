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

    CustomOpportunity__c co = new CustomOpportunity__c();
        co.InquiryCategory__c = 'Rekruttere og inkludere';
        co.Account__c = [SELECT Id FROM Account WHERE INT_OrganizationNumber__c = '973113631'].Id;
        co.Contact__c = [SELECT Id FROM Contact WHERE Email = 'test.testersen@email.com'].Id;
        co.InclusionStage__c = 'Ny henvendelse';
        co.Source__c = 'Kontaktskjema';
        insert co;
    }

    @IsTest
    static void testProcessEmailPositive() {

        CustomOpportunity__c opportunity = [
            SELECT Id, Name, Account__c, Contact__c, InclusionStage__c, Source__c, InquiryCategory__c
            FROM CustomOpportunity__c WHERE InquiryCategory__c = 'Rekruttere og inkludere' LIMIT 1
        ];

        Test.startTest();
        TAG_ContactFormSendEmail.sendEmailReceipts(opportunity);
        Test.stopTest();

        List<EmailQueue__c> queuedEmail = [
            SELECT Id, Name, TemplateName__c, TargetObjectId__c, Status__c, WhatId__c
            FROM EmailQueue__c LIMIT 1
        ];

        List<Contact> contact = [
            SELECT Id, Email
            FROM Contact WHERE Email = 'test.testersen@email.com' LIMIT 1
        ];

        System.assertEquals('kontaktskjemaRekrutteringReceipt', queuedEmail[0].TemplateName__c, 'Template name should be Rekruttere og inkludere');
        System.assertEquals(contact[0].Id, queuedEmail[0].TargetObjectId__c, 'Contact Id not matching TargetObjectId__c');
        System.assertEquals('Queued', queuedEmail[0].Status__c, 'Status should have value Queued');
        System.assertEquals(opportunity.Id, queuedEmail[0].WhatId__c, 'Custom Opportunity Id not matching the WhatId__c');
    }
}
