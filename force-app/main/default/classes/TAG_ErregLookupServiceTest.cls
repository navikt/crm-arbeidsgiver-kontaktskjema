
@isTest
private class TAG_ErregLookupServiceTest {

    @isTest
    static void lookupOrganizationSubunit_returnsName_whenCalloutSucceeds() {
        Test.setMock(HttpCalloutMock.class, new TAG_ErregLookupServiceCalloutMock());

        Test.startTest();
        String result = TAG_ErregLookupService.lookupOrganizationSubunit('900000001');
        Test.stopTest();

        Assert.areEqual('TEST UNDERENHET', result, 'Should return organization name from callout response');
    }

    @isTest
    static void lookupOrganizationUnit_returnsName_whenCalloutSucceeds() {
        Test.setMock(HttpCalloutMock.class, new TAG_ErregLookupServiceCalloutMock());

        Test.startTest();
        String result = TAG_ErregLookupService.lookupOrganizationUnit('900000002');
        Test.stopTest();

        Assert.areEqual('TEST ENHET', result, 'Should return organization name from callout response');
    }
}