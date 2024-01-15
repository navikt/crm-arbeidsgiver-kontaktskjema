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
    private static final Id INCLUSION_RECORD_TYPE = Schema.SObjectType.CustomOpportunity__c.getRecordTypeInfosByDeveloperName()
        .get('Inclusion')
        .getRecordTypeId();

@TestSetup
static void makeData(){
    Group groupAlna = new Group(Name='NAV Test Alna', Type='Queue');
        insert groupAlna;
    Group groupBarum = new Group(Name='NAV Test Bærum', Type='Queue');
        insert groupBarum;
    Group groupVestViken = new Group(Name='NAV Test Arbeidslivssenter Vest-Viken', Type='Queue');
        insert groupVestViken;

    QueuesObject qoAlna = new QueueSObject(QueueID = groupAlna.id, SObjectType = 'CustomOpportunity__c');
        insert qoAlna;
    QueuesObject qoBarum = new QueueSObject(QueueID = groupVestViken.id, SObjectType = 'CustomOpportunity__c');
        insert qoBarum;
    QueuesObject qoVestViken = new QueueSObject(QueueID = groupVestViken.id, SObjectType = 'CustomOpportunity__c');
        insert qoVestViken;
    
    createDataAsync();
    }
    
    //Future method createDataAsync is needed to avoid the below error after QueueSObject is created
    //Error: MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object 
    @future
    static void createDataAsync() {
        Id queueAlna = [SELECT Id, Name FROM Group WHERE Type = 'queue' AND Name = 'NAV Test Alna'].Id;
        Id queueBarum = [SELECT Id, Name FROM Group WHERE Type = 'queue' AND Name = 'NAV Test Bærum'].Id;
        Id queueVestViken = [SELECT Id, Name FROM Group WHERE Type = 'queue' AND Name = 'NAV Test Arbeidslivssenter Vest-Viken'].Id;
    
        NavUnit__c navUnitAlna = new NavUnit__c(Name = 'Nav Alna', INT_UnitNumber__c = '4444', INT_Region__c = 'Oslo', 
        CRM_QueueId__c = queueAlna, INT_UnitType__c = 'LOKAL');
            insert navUnitAlna;
    
        NavUnit__c navUnitBarum = new NavUnit__c(Name = 'NAV Bærum', INT_UnitNumber__c = '4445', INT_Region__c = 'Vest-Viken', 
            CRM_QueueId__c = queueBarum, INT_UnitType__c = 'LOKAL');
            insert navUnitBarum;
    
        NavUnit__c navUnitVestViken = new NavUnit__c(Name = 'NAV Arbeidslivssenter Vest-Viken', INT_UnitNumber__c = '4446', INT_Region__c = 'Vest-Viken', 
            CRM_QueueId__c = queueVestViken, INT_UnitType__c = 'LOKAL');
            insert navUnitVestViken;
    
        Id idAlna = [SELECT Id FROM NavUnit__c WHERE Name = 'Nav Alna'].Id;
        Id idBarum = [SELECT Id FROM NavUnit__c WHERE Name = 'Nav Bærum'].Id;
    
        Account acc1 = new Account(Name = 'Test Employer 1', INT_OrganizationNumber__c = '973113631', INT_RegionNumber__c = '30', INT_MunicipalityNumber__c = '3001', TAG_NavUnit__c = idAlna);
            insert acc1;
        Account acc2 = new Account(Name = 'Test Employer 2', INT_OrganizationNumber__c = '973113632', INT_RegionNumber__c = '03', INT_MunicipalityNumber__c = '3002', TAG_NavUnit__c = idBarum);
            insert acc2;
    }

    /**
     * @description Testing the `createContactForm` method with correct values.
     * Testing with value: `contactFormMap` with theme = Skal ansette
     * Expected result: A new record in the CustomOpportunity__c object
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
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
            SELECT Id, Account__c, OwnerId, Contact__c, InquiryCategory__c, RecordTypeId, InclusionStage__c, Source__c, INT_RegionNumber__c, INT_MunicipalityNumber__c, TAG_NavUnit__c
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
        
        List<NavUnit__c> navUnitAlna = [
            SELECT Id, Name, INT_Region__c, CRM_QueueId__c
            FROM NavUnit__c WHERE Name = 'Nav Alna' LIMIT 1
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
        System.assertEquals(navUnitAlna[0].CRM_QueueId__c, opportunity[0].OwnerId, 'OwnerId should match QueueId');
        System.assertEquals(navUnitAlna[0].Id, opportunity[0].TAG_NavUnit__c, 'Nav Unit is not matching');
        //System.assertEquals('90909090', contact[0].Phone, 'Contact Phone should be 90909090');
    }

    /**
     * @description Testing the `createContactForm` method with correct values.
     * Testing with value: `contactFormMap` with theme = Forebygge sykefravær
     * Expected result: A new record in the CustomOpportunity__c object
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
    @IsTest
    static void testProcessSingleContactFormPreventSickLeavePositive() {
        Map<String, String> contactFormMap = new Map<String, String>();
        contactFormMap.put('ContactOrg', '973113632');
        contactFormMap.put('ContactName', 'Test Testersen');
        contactFormMap.put('ContactEmail', 'test.testersen@email.com');
        contactFormMap.put('ContactPhone', '90909090');
        contactFormMap.put('ThemeSelected', 'Forebygge sykefravær');

        Test.startTest();
        TAG_ContactFormController.createContactForm(contactFormMap);
        Test.stopTest();

        List<CustomOpportunity__c> opportunity = [
            SELECT Id, Account__c, OwnerId, Contact__c, InquiryCategory__c, RecordTypeId, InclusionStage__c, Source__c, INT_RegionNumber__c, INT_MunicipalityNumber__c, TAG_NavUnit__c
            FROM CustomOpportunity__c WHERE InquiryCategory__c = 'Forebygge sykefravær' LIMIT 1
        ];

        List<Account> account = [
            SELECT Id
            FROM Account WHERE INT_OrganizationNumber__c = '973113632' LIMIT 1
        ];

        List<Contact> contact = [
            SELECT Id, Name, FirstName, LastName, Email, Phone
            FROM Contact WHERE Email = 'test.testersen@email.com' LIMIT 1
        ];

        List<NavUnit__c> navUnitVestViken = [
            SELECT Id, Name, INT_Region__c, CRM_QueueId__c
            FROM NavUnit__c WHERE Name = 'NAV Arbeidslivssenter Vest-Viken' LIMIT 1
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
        System.assertEquals(null, opportunity[0].INT_RegionNumber__c, 'Region Number should be null');
        System.assertEquals(null, opportunity[0].INT_MunicipalityNumber__c, 'Municipality Number should be null');
        System.assertEquals(navUnitVestViken[0].CRM_QueueId__c, opportunity[0].OwnerId, 'OwnerId should match QueueId');
        System.assertEquals(navUnitVestViken[0].Id, opportunity[0].TAG_NavUnit__c, 'Nav Unit is not matching');
        //System.assertEquals('90909090', contact[0].Phone, 'Contact Phone should be 90909090');
    }

    /**
     * @description Testing the `createContactForm` method with null values.
     * Testing with value: `contactFormMap`
     * Expected result: Error message
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
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
        } catch(Exception e) {
            Assert.isNotNull(e);
            System.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * @description Testing the `getUnitName` method with correct values.
     * Testing with value: `regionNames`
     * Expected result: result should return the same values as unitNames list
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
    @IsTest
    static void testGetUnitRegionNamePositive() {
        List<String> regionNames = new List<String>{'ØstViken', 'Oslo', 'Innlandet', 'VestViken', 'Vestfold og Telemark', 'Agder', 'Rogaland', 'Vestland', 'Møre og Romsdal', 'Nordland', 'Troms og Finnmark', 'Trøndelag', 'WronRegionName'};
        List<String> unitNames = new List<String>{'NAV Arbeidslivssenter Øst-Viken', 'NAV Arbeidslivssenter Oslo', 'NAV Arbeidslivssenter Innlandet', 'NAV Arbeidslivssenter Vest-Viken', 'NAV Arbeid og helse Vestfold og Telemark', 'NAV Arbeidslivssenter Agder', 'NAV Arbeidslivssenter Rogaland', 'NAV Arbeidslivssenter Vestland', 'NAV Arbeidslivssenter Møre og Romsdal', 'NAV Arbeidslivssenter Nordland', 'NAV Arbeidslivssenter Troms og Finnmark', 'NAV Arbeidslivssenter Trøndelag', null};

        for (Integer i = 0; i < regionNames.size(); i++) {
            String regionName = regionNames[i];
            String unitName = unitNames[i];

            String result = TAG_ContactFormController.getUnitName(regionName);
            System.assertEquals(unitName, result, 'Incorrect result for region name ' + regionName);
        }
    }

    /**
     * @description Testing the `getAccountName` method with right values.
     * Testing with value: `orgNr`
     * Expected result: Name of the organization
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
    @IsTest
    static void testGetAccountNamePositive() {
        String orgNr = '973113631';
        String orgName = '';

        Test.startTest();
        orgName = TAG_ContactFormController.getAccountName(orgNr);
        Test.stopTest();

        System.assertEquals('Test Employer 1', orgName, 'Org name should be Test Employer 1');
    }

    /**
     * @description Testing the `getAccountName` method with wrong values.
     * Testing with value: `orgNr`
     * Expected result: error message
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
    @IsTest
    static void testGetAccountNameNegative() {
        String orgNr = '973113635';
        String errorMessage = '';
        String orgName = '';

        Test.startTest();
        try {
            orgName = TAG_ContactFormController.getAccountName(orgNr);
        } catch(Exception e) {
            Assert.isNotNull(e);
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Script-thrown exception', errorMessage, 'Error message not matching');
    }

    /**
     * @description Testing the `getAccountName` method with wrong values.
     * Testing with value: `orgNr`
     * Expected result: null
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     */
    @IsTest
    static void testGetAccountNameNull() {
        String orgNr = '';
        String errorMessage = '';
        String orgName = 'Test';

        Test.startTest();
        try {
            orgName = TAG_ContactFormController.getAccountName(orgNr);
        } catch(Exception e) {
            Assert.isNotNull(e);
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('', errorMessage, 'Error message should be empty');
        System.assertEquals(null, orgName, 'Org name should be empty');
    }
}

