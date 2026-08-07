
@isTest
private class TAG_ErregLookupServiceTest {

    private static final String EXPECTED_NAME = 'ARBEIDS- OG VELFERDSDIREKTORATET AVD FYRSTIKKALLÉEN';
    private static final String ORGNR = '912998827';

    @isTest
    static void lookupOrganizationSubunit_returnsName_whenCalloutSucceeds() {
        Test.setMock(HttpCalloutMock.class, new TAG_ErregLookupServiceCalloutMock());

        Test.startTest();
        String result = TAG_ErregLookupService.lookupOrganizationSubunit(ORGNR);
        Test.stopTest();

        Assert.areEqual(EXPECTED_NAME, result, 'Should return organization name from callout response');
    }

    @isTest
    static void lookupOrganizationUnit_returnsName_whenCalloutSucceeds() {
        Test.setMock(HttpCalloutMock.class, new TAG_ErregLookupServiceCalloutMock());

        Test.startTest();
        String result = TAG_ErregLookupService.lookupOrganizationUnit(ORGNR);
        Test.stopTest();

        Assert.areEqual(EXPECTED_NAME, result, 'Should return organization name from callout response');
    }
}