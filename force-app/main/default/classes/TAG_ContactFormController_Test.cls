/**
 * @description This is a test class for TAG_ContactFormController
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontakt-oss/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontakt-oss)
 * @see TAG_ContactFormController
 *
 * @group TAG Contact Form
 */
@IsTest
public with sharing class TAG_ContactFormController_Test {
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

@TestSetup
static void makeData(){
    Account acc1 = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631', INT_RegionNumber__c = '30', INT_MunicipalityNumber__c = '3001');
        insert acc1;
    Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632', INT_RegionNumber__c = '03', INT_MunicipalityNumber__c = '3002');
        insert acc2;
    Account accWrongRegionNr = new Account(Name = 'Test Employer 3', INT_OrganizationNumber__c = '973113633', INT_RegionNumber__c = '22', INT_MunicipalityNumber__c = '3003');
        insert accWrongRegionNr;

    NavUnit__c navUnitAlna = new NavUnit__c(Name = 'Nav Alna', INT_UnitNumber__c = '0303', INT_Region__c = 'Oslo', 
            CRM_QueueId__c = '00G0E000004aoilUAA', INT_UnitType__c = 'LOKAL');
        insert navUnitAlna;
    NavUnit__c navUnitKristiansand = new NavUnit__c(Name = 'Nav Kristiansand', INT_UnitNumber__c = '1987', INT_Region__c = 'Agder', 
    CRM_QueueId__c = '00G0E000004aoilUBB', INT_UnitType__c = 'LOKAL');
        insert navUnitKristiansand;
    }

    @IsTest
    static void testProcessSingleContactFormRecruiteAndIncludePositive() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '973113631');
        contactFormMap.put('ContactName', 'Test Testersen');
        contactFormMap.put('ContactEmail', 'test.testersen@email.com');
        contactFormMap.put('ContactPhone', '90909090');
        contactFormMap.put('ThemeSelected', 'Skal ansette');

        Test.startTest();
        TAG_ContactFormController.createContactForm(contactFormMap);
        Test.stopTest();

        List<CustomOpportunity__c> opportunity = [
            SELECT Id, Account__c, Contact__c, InquiryCategory__c, RecordTypeId, InclusionStage__c, Source__c, INT_RegionNumber__c, INT_MunicipalityNumber__c
            FROM CustomOpportunity__c WHERE InquiryCategory__c = 'Skal ansette' LIMIT 1
        ];

        List<Account> account = [
            SELECT Id
            FROM Account WHERE INT_OrganizationNumber__c = '973113631' LIMIT 1
        ];

        List<Contact> contact = [
            SELECT Id, Name, FirstName, LastName, Email, Phone
            FROM Contact WHERE Email = 'test.testersen@email.com' LIMIT 1
        ];

        System.assertEquals(account[0].Id, opportunity[0].Account__c, 'Account Id not matching');
        System.assertEquals(contact[0].Id, opportunity[0].Contact__c, 'Contact Id not matching');
        System.assertEquals('Skal ansette', opportunity[0].InquiryCategory__c, 'InquiryCategory__c should be Skal ansette');
        System.assertEquals(INCLUSION_RECORD_TYPE, opportunity[0].RecordTypeId, 'RecordTypeId not matching');
        System.assertEquals('Ny henvendelse', opportunity[0].InclusionStage__c, 'InclusionStage__c should be Ny henvendelse');
        System.assertEquals('Kontaktskjema', opportunity[0].Source__c, 'Source__c should be Kontaktskjema');
        System.assertEquals('Test Testersen', contact[0].Name, 'Contact Name should be Test Testersen');
        System.assertEquals('Test', contact[0].FirstName, 'Contact FirstName should be Test');
        System.assertEquals('Testersen', contact[0].LastName, 'Contact LastName should be Testersen');
        System.assertEquals('test.testersen@email.com', contact[0].Email, 'Contact Email should be test.testersen@email.com');
        System.assertEquals(null, opportunity[0].INT_RegionNumber__c, 'Region Number should be null');
        System.assertEquals('3001', opportunity[0].INT_MunicipalityNumber__c, 'Municipality Number should be 3001');
        //System.assertEquals('90909090', contact[0].Phone, 'Contact Phone should be 90909090');
    }

    @IsTest
    static void testProcessSingleContactFormPreventSickLeavePositive() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '973113631');
        contactFormMap.put('ContactName', 'Test Testersen');
        contactFormMap.put('ContactEmail', 'test.testersen@email.com');
        contactFormMap.put('ContactPhone', '90909090');
        contactFormMap.put('ThemeSelected', 'Forebygge sykefravær');

        Test.startTest();
        TAG_ContactFormController.createContactForm(contactFormMap);
        Test.stopTest();

        List<CustomOpportunity__c> opportunity = [
            SELECT Id, Account__c, Contact__c, InquiryCategory__c, RecordTypeId, InclusionStage__c, Source__c, INT_RegionNumber__c, INT_MunicipalityNumber__c
            FROM CustomOpportunity__c WHERE InquiryCategory__c = 'Forebygge sykefravær' LIMIT 1
        ];

        List<Account> account = [
            SELECT Id
            FROM Account WHERE INT_OrganizationNumber__c = '973113631' LIMIT 1
        ];

        List<Contact> contact = [
            SELECT Id, Name, FirstName, LastName, Email, Phone
            FROM Contact WHERE Email = 'test.testersen@email.com' LIMIT 1
        ];

        System.assertEquals(account[0].Id, opportunity[0].Account__c, 'Account Id not matching');
        System.assertEquals(contact[0].Id, opportunity[0].Contact__c, 'Contact Id not matching');
        System.assertEquals('Forebygge sykefravær', opportunity[0].InquiryCategory__c, 'InquiryCategory__c should be Forebygge sykefravær');
        System.assertEquals(INCLUSION_RECORD_TYPE, opportunity[0].RecordTypeId, 'RecordTypeId not matching');
        System.assertEquals('Ny henvendelse', opportunity[0].InclusionStage__c, 'InclusionStage__c should be Ny henvendelse');
        System.assertEquals('Kontaktskjema', opportunity[0].Source__c, 'Source__c should be Kontaktskjema');
        System.assertEquals('Test Testersen', contact[0].Name, 'Contact Name should be Test Testersen');
        System.assertEquals('Test', contact[0].FirstName, 'Contact FirstName should be Test');
        System.assertEquals('Testersen', contact[0].LastName, 'Contact LastName should be Testersen');
        System.assertEquals('test.testersen@email.com', contact[0].Email, 'Contact Email should be test.testersen@email.com');
        System.assertEquals('0200', opportunity[0].INT_RegionNumber__c, 'Region Number should be 0200');
        System.assertEquals(null, opportunity[0].INT_MunicipalityNumber__c, 'Municipality Number should be null');
        //System.assertEquals('90909090', contact[0].Phone, 'Contact Phone should be 90909090');
    }

    @IsTest
    static void testProcessSingleContactFormPreventSickLeaveNegative() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '');
        contactFormMap.put('ContactName', '');
        contactFormMap.put('ContactEmail', '');
        contactFormMap.put('ContactPhone', '');
        contactFormMap.put('ThemeSelected', '');

        Test.startTest();
        try {
            TAG_ContactFormController.createContactForm(contactFormMap);
        } catch(Exception e) {
            Assert.isNotNull(e);
            System.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetUnitRegionNumberPositive() {
        List<String> countyNumbers = new List<String>{'30', '03', '34', '38', '42', '11', '46', '15', '18', '54', '50'};
        List<String> unitRegionNumbers = new List<String>{'0200', '0300', '0400', '0800', '1000', '1100', '1200', '1500', '1800', '1900', '5700'};

        for (Integer i = 0; i < countyNumbers.size(); i++) {
            String countyNumber = countyNumbers[i];
            String unitRegionNumber = unitRegionNumbers[i];

            String result = TAG_ContactFormController.getUnitRegionNumber(countyNumber);
            System.assertEquals(unitRegionNumber, result, 'Incorrect result for county number ' + countyNumber);
        }
    }

    @IsTest
    static void testGetUnitRegionNumberNegative() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '973113633');
        contactFormMap.put('ContactName', 'Test Testersen');
        contactFormMap.put('ContactEmail', 'test.testersen@email.com');
        contactFormMap.put('ContactPhone', '90909090');
        contactFormMap.put('ThemeSelected', 'Forebygge sykefravær');

        Test.startTest();
        try {
            TAG_ContactFormController.createContactForm(contactFormMap);
        } catch(Exception e) {
            Assert.isNotNull(e);
            System.assertEquals('An error occurred while inserting Custom Opportunity to the database.', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetAccountNamePositive() {
        String orgNr = '973113631';

        Test.startTest();
        String orgName = TAG_ContactFormController.getAccountName(orgNr);
        Test.stopTest();

        System.assertEquals('Test Employer 1', orgName, 'Org name should be Test Employer 1');
    }

    @IsTest
    static void testGetAccountNameNegative() {
        String orgNr = '973113635';

        Test.startTest();
        try {
            String orgName = TAG_ContactFormController.getAccountName(orgNr);
        } catch(Exception e) {
            Assert.isNotNull(e);
        }
        Test.stopTest();
    }
}

