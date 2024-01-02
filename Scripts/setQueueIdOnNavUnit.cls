List<NavUnit__c> navUnits = [SELECT Id, Name, CRM_QueueId__c FROM NavUnit__c];

Id queueIdNavAlna = [SELECT Id FROM Group WHERE Type = 'queue' AND Name = 'NAV Alna']?.Id;
Id queueIdNavKristiansand = [SELECT Id FROM Group WHERE Type = 'queue' AND Name = 'NAV Kristiansand']?.Id;
Id queueIdNavBarum = [SELECT Id FROM Group WHERE Type = 'queue' AND Name = 'NAV Bærum']?.Id;
Id queueIdNavVestViken = [SELECT Id FROM Group WHERE Type = 'queue' AND Name = 'NAV Arbeidslivssenter Vest-Viken']?.Id;

List<NavUnit__c> navUnitsWithQueueId = new List<NavUnit__c>();

for (NavUnit__c nu : navUnits) {
    if (nu.Name == 'NAV Alna') {
        nu.CRM_QueueId__c = String.valueOf(queueIdNavAlna);
    } else if (nu.Name == 'NAV Kristiansand'){
        nu.CRM_QueueId__c = String.valueOf(queueIdNavKristiansand);
    } else if (nu.Name == 'NAV Bærum'){
        nu.CRM_QueueId__c = String.valueOf(queueIdNavBarum);
    } else {
        nu.CRM_QueueId__c = String.valueOf(queueIdNavVestViken);
    }
    
    navUnitsWithQueueId.add(nu);
}

update navUnitsWithQueueId;
