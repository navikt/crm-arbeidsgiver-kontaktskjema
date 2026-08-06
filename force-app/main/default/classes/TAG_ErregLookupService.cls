public with sharing class TAG_ErregLookupService {   

    private static final String ENHETER_ENDPOINT = 'https://data.brreg.no/enhetsregisteret/api/enheter';
    private static final String UNDERENHETER_ENDPOINT = 'https://data.brreg.no/enhetsregisteret/api/underenheter'; // B-type organizations

     public static String lookupOrganizationSubunit(String orgnr) {
        String responseBody = doCallout(UNDERENHETER_ENDPOINT, orgnr);
        if (responseBody == null) {
            return null; // Return null if both callouts fail. It means the organization number is not found in either endpoint.
        }
        System.debug('The organization is a B-type unit.');
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String orgName = (String) results.get('navn');
        return orgName;
     }
   
    public static String lookupOrganizationUnit(String orgnr) {        
        String responseBody = doCallout(ENHETER_ENDPOINT, orgnr);        
        if (responseBody == null) {
            return null; // Return null if both callouts fail. It means the organization number is not found in either endpoint.
        }
        System.debug('The organization is J-type or O-type unit.');
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String orgName = (String) results.get('navn');        
        return orgName;
    }

    private static String doCallout(String endpoint,String orgnr) {
        System.debug('endpoint: ' + endpoint);
        System.debug('orgnr: ' + orgnr);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + '/' + orgnr);
        request.setMethod('GET');

        try {
            HttpResponse response = http.send(request);
            System.debug('Status: ' + response.getStatusCode());
            System.debug('Response: ' + response.getBody());
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }
}