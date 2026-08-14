public with sharing class TAG_EregLookupService {   

    private static final String ENHETER_ENDPOINT = 'https://data.brreg.no/enhetsregisteret/api/enheter';
    private static final String UNDERENHETER_ENDPOINT = 'https://data.brreg.no/enhetsregisteret/api/underenheter'; // B-type organizations


    // returns null       → 404/410, "orgnr finnes ikke"
    // throws Unavailable → 500, timeout, CalloutException
    // throws Technical   → 400, uventet status, parsefeil
    public static EntityData getEntityData(String orgnr) {
        Integer statusCode; 
        EntityData entityData = new EntityData();
        Boolean isSubUnit = false;

        HttpResponse response = doCallout(UNDERENHETER_ENDPOINT, orgnr);
        
        statusCode = response?.getStatusCode(); 
        
        if(statusCode == 200){           
            isSubUnit = true;
        } else if(statusCode == 404){
            response = doCallout(ENHETER_ENDPOINT, orgnr);
            statusCode = response?.getStatusCode();
        }

        switch on statusCode {
            when 200 {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                entityData.name = (String) results.get('navn');        
                entityData.organizationNumber= orgnr;
                entityData.isSubunit = isSubUnit;
                if(!isSubUnit){
                    try {
                        addSubUnits(entityData);
                    } catch (Exception e) {
                        // Non-critical feature, we will log the error and return an empty list of subunits instead of throwing an exception. Allows the main organization data to be returned even if the subunit callout fails. 
                        entityData.totalSubUnitsCount = 0;
                        entityData.subUnits = new List<EntityData>();
                    }
                } 
                return entityData;
            }
            when 404, 410 {
                return null;
            }
            when 400 {
                throw new EregTechnicalException();
            }
            when 500 {
                throw new EregUnavailableException();
            }
            when else {
                throw new EregTechnicalException();
            }
        }
    }

    private static void addSubUnits(EntityData entityData) {        
            HttpResponse response = doCallout(UNDERENHETER_ENDPOINT + '?overordnetEnhet=' + entityData.organizationNumber + '&size=1000', entityData.organizationNumber);
            if(response?.getStatusCode() != 200){
                throw new EregTechnicalException();
            }
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response?.getBody());
            Map<String, Object> page = (Map<String, Object>) results.get('page');
            entityData.totalSubUnitsCount = (Integer) page.get('totalElements');

            Map<String,Object> embeddedData = (Map<String, Object>) results.get('_embedded');
            List<Object> underenheter = (List<Object>) embeddedData.get('underenheter');  
            
            entityData.subUnits = new List<EntityData>();        
            for(Object obj : underenheter){                
                Map<String, Object> subUnitMap = (Map<String, Object>) obj;
                EntityData subUnit = new EntityData();
                subUnit.name = (String) subUnitMap.get('navn');
                subUnit.isSubunit = true;
                subUnit.organizationNumber = (String) subUnitMap.get('organisasjonsnummer');
                entityData.subUnits.add(subUnit);
            }
        
    }

    private static HttpResponse doCallout(String endpoint,String orgnr) {
        System.debug('endpoint: ' + endpoint);
        System.debug('orgnr: ' + orgnr);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + '/' + orgnr);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        System.debug('Status: ' + response.getStatusCode());
        System.debug('Response: ' + response.getBody());
        return response;
        
    }


    public class EntityData {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Boolean isSubunit { get; set; }
        @AuraEnabled public String organizationNumber { get; set; }
        @AuraEnabled public Integer totalSubUnitsCount { get; set; }
        @AuraEnabled public List<EntityData> subUnits { get; set; }
        public EntityData(){}
    }


    public class EregUnavailableException extends Exception {}    // 500, timeout, callout exception
    public class EregTechnicalException extends Exception {}      // 400, uventet status, parse-feil  

}