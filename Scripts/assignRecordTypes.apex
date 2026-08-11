Id recordTypeIdAccount = [SELECT Id FROM RecordType WHERE DeveloperName = 'Employer' AND SobjectType = 'Account' LIMIT 1]?.Id;
Id recordTypeIdCustomOpportunity = [SELECT Id FROM RecordType WHERE DeveloperName = 'Inclusion' LIMIT 1]?.Id;

List<Account> accounts = [SELECT Id, RecordTypeId FROM Account LIMIT 50];
List<CustomOpportunity__c> opportunities = [SELECT Id, RecordTypeId FROM CustomOpportunity__c LIMIT 50];

for (Account a : accounts) {
    a.RecordTypeId = recordTypeIdAccount;
}

for (CustomOpportunity__c c : opportunities) {
    c.RecordTypeId = recordTypeIdCustomOpportunity;
}

update accounts;
update opportunities;