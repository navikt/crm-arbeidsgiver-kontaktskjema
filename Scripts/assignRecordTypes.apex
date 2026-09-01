Id recordTypeIdAccount = [SELECT Id FROM RecordType WHERE DeveloperName = 'Employer' AND SobjectType = 'Account' LIMIT 1]?.Id;
List<Account> accounts = [SELECT Id, RecordTypeId FROM Account LIMIT 50];

for (Account a : accounts) {
    a.RecordTypeId = recordTypeIdAccount;
}

update accounts;