
@isTest
private class TAG_EregLookupServiceTest {

    @isTest
    static void lookupOrganizationSubunit_returnsName_whenCalloutSucceeds() {
        Test.setMock(HttpCalloutMock.class, new TAG_EregLookupServiceCalloutMock());
        TAG_EregLookupService.EntityData entityData;
        Test.startTest();
        entityData = TAG_EregLookupService.getEntityData('900000001');
        Test.stopTest();

        Assert.areEqual('TEST UNDERENHET', entityData.name, 'Should return organization name from callout response');
    }

    @isTest
    static void lookupOrganizationUnit_returnsName_whenCalloutSucceeds() {
        Test.setMock(HttpCalloutMock.class, new TAG_EregLookupServiceCalloutMock());
        TAG_EregLookupService.EntityData entityData;
        Test.startTest();
        entityData = TAG_EregLookupService.getEntityData('900000002');
        Test.stopTest();

        Assert.areEqual('TEST ENHET', entityData.name, 'Should return organization name from callout response');
    }
}