Id navUnitAlna = [SELECT Id FROM NavUnit__c WHERE Name = 'Nav Alna' LIMIT 1]?.Id;
Id navUnitKristiansand = [SELECT Id FROM NavUnit__c WHERE Name = 'Nav Kristiansand' LIMIT 1]?.Id;

List<Account> accountList = [SELECT Id, TAG_NAVUnit__c FROM Account WHERE IsPersonAccount = false];
List<Account> accountListUpdated = new List<Account>();

for (Account a : accountList) {

    a.TAG_NAVUnit__c = navUnitAlna;
    accountListUpdated.add(a);
}

update accountListUpdated;
