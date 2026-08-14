public with sharing class TAG_EregLookupServiceCalloutMock implements HttpCalloutMock {
     public HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        
        if(endpoint.contains('/underenheter')){            
            if(endpoint.contains('/900000001')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(MOCK_RESPONSE_SUB_UNIT);
                res.setStatusCode(200);
            } else{
                res.setStatusCode(404);
            }                       
            return res;
        } else if(endpoint.contains('/enheter')){            
            if(endpoint.contains('/900000002')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(MOCK_RESPONSE_UNIT);
                res.setStatusCode(200);
            } else{
                res.setStatusCode(404);
            }
            return res;
        } 
        res.setStatusCode(400);
        return res;
    }

    private static final String MOCK_RESPONSE_SUB_UNIT = '{'+
    '"organisasjonsnummer": "900000001",'+
    '"navn": "TEST UNDERENHET",'+
    '"organisasjonsform": {'+
    '"kode": "BEDR",'+
    '"beskrivelse": "Underenhet til næringsdrivende og offentlig forvaltning",'+
    '"_links": {'+
        '"self": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/organisasjonsformer/BEDR"'+
        '}'+
    '}'+
'},'+
    '"historiskeNavn": ['+
        '{'+
            '"navn": "TEST UNDERENHET",'+
            '"fraDato": "2013-12-23 20:45:00",'+
            '"tilDato": "2020-08-11 21:35:02"'+
        '}'+
    '],'+
    '"postadresse": {'+
        '"land": "Norge",'+
        '"landkode": "NO",'+
        '"postnummer": "0001",'+
        '"poststed": "TESTSTED",'+
        '"adresse": ['+
            '"Postboks 123"'+
        '],'+
        '"kommune": "TEST KOMMUNE",'+
        '"kommunenummer": "0001"'+
    '},'+
    '"registreringsdatoEnhetsregisteret": "2013-12-23",'+
    '"registrertIMvaregisteret": false,'+
    '"naeringskode1": {'+
        '"kode": "84.120",'+
        '"beskrivelse": "Offentlig administrasjon tilknyttet helsestell, undervisning, kultur og annen sosial virksomhet"'+
    '},'+
    '"antallAnsatte": 1729,'+
    '"harRegistrertAntallAnsatte": true,'+
    '"overordnetEnhet": "900000002",'+
    '"registreringsdatoAntallAnsatteEnhetsregisteret": "2026-07-14",'+
    '"registreringsdatoAntallAnsatteNAVAaregisteret": "2026-07-10",'+
    '"oppstartsdato": "2013-12-01",'+
    '"beliggenhetsadresse": {'+
        '"land": "Norge",'+
        '"landkode": "NO",'+
        '"postnummer": "0001",'+
        '"poststed": "TESTSTED",'+
        '"adresse": ['+
            '"Testalléen 1"'+
        '],'+
        '"kommune": "TEST KOMMUNE",'+
        '"kommunenummer": "0001"'+
    '},'+
    '"_links": {'+
        '"self": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/underenheter/900000001"'+
        '},'+
        '"overordnetEnhet": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/enheter/900000002"'+
        '}'+
    '},'+
    '"respons_klasse": "Underenhet"'+
'}';

 private static final String MOCK_RESPONSE_UNIT = '{'+
    '"organisasjonsnummer": "900000002",'+
    '"navn": "TEST ENHET",'+
    '"organisasjonsform": {'+
    '"kode": "ORGL",'+
    '"beskrivelse": "Enhet til næringsdrivende og offentlig forvaltning",'+
    '"_links": {'+
        '"self": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/organisasjonsformer/ORGL"'+
        '}'+
    '}'+
'},'+
    '"historiskeNavn": ['+
        '{'+
            '"navn": "TEST ENHET",'+
            '"fraDato": "2013-12-23 20:45:00",'+
            '"tilDato": "2020-08-11 21:35:02"'+
        '}'+
    '],'+
    '"postadresse": {'+
        '"land": "Norge",'+
        '"landkode": "NO",'+
        '"postnummer": "0001",'+
        '"poststed": "TESTSTED",'+
        '"adresse": ['+
            '"Postboks 123"'+
        '],'+
        '"kommune": "TEST KOMMUNE",'+
        '"kommunenummer": "0001"'+
    '},'+
    '"registreringsdatoEnhetsregisteret": "2013-12-23",'+
    '"registrertIMvaregisteret": false,'+
    '"naeringskode1": {'+
        '"kode": "84.120",'+
        '"beskrivelse": "Offentlig administrasjon tilknyttet helsestell, undervisning, kultur og annen sosial virksomhet"'+
    '},'+
    '"antallAnsatte": 1729,'+
    '"harRegistrertAntallAnsatte": true,'+
    '"overordnetEnhet": "900000003",'+
    '"registreringsdatoAntallAnsatteEnhetsregisteret": "2026-07-14",'+
    '"registreringsdatoAntallAnsatteNAVAaregisteret": "2026-07-10",'+
    '"oppstartsdato": "2013-12-01",'+
    '"beliggenhetsadresse": {'+
        '"land": "Norge",'+
        '"landkode": "NO",'+
        '"postnummer": "0001",'+
        '"poststed": "TESTSTED",'+
        '"adresse": ['+
            '"Testalléen 1"'+
        '],'+
        '"kommune": "TEST KOMMUNE",'+
        '"kommunenummer": "0001"'+
    '},'+
    '"_links": {'+
        '"self": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/enheter/900000002"'+
        '},'+
        '"overordnetEnhet": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/enheter/900000003"'+
        '}'+
    '},'+
    '"respons_klasse": "Enhet"'+
'}';
    
}