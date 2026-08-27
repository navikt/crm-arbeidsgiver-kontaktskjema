/**
 * Assigns a permission set to the guest user.
 */

String guestUserName='Kontaktskjema Site Guest User';
String permissionSetName='Arbeidsgiver_Kontaktskjema_Eksterne';

User guestUser = [SELECT Id FROM User WHERE Name = :guestUserName LIMIT 1];
PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];

PermissionSetAssignment psa = new PermissionSetAssignment(
    AssigneeId = guestUser.Id,
    PermissionSetId = permissionSet.Id
);
insert psa;