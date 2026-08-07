public with sharing class TAG_ErregLookupServiceCalloutMock implements HttpCalloutMock {
     public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(RESPONSE_200_SUB_UNIT);
        res.setStatusCode(200);
        return res;
    }

    private static final String RESPONSE_200_SUB_UNIT = '{'+
    '"organisasjonsnummer": "912998827",'+
    '"navn": "ARBEIDS- OG VELFERDSDIREKTORATET AVD FYRSTIKKALLÉEN",'+
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
            '"navn": "ARBEIDS- OG VELFERDSDIREKTORATET AVD ØKERNVEIEN",'+
            '"fraDato": "2013-12-23 20:45:00",'+
            '"tilDato": "2020-08-11 21:35:02"'+
        '}'+
    '],'+
    '"postadresse": {'+
        '"land": "Norge",'+
        '"landkode": "NO",'+
        '"postnummer": "8601",'+
        '"poststed": "MO I RANA",'+
        '"adresse": ['+
            '"Postboks 354"'+
        '],'+
        '"kommune": "RANA",'+
        '"kommunenummer": "1833"'+
    '},'+
    '"registreringsdatoEnhetsregisteret": "2013-12-23",'+
    '"registrertIMvaregisteret": false,'+
    '"naeringskode1": {'+
        '"kode": "84.120",'+
        '"beskrivelse": "Offentlig administrasjon tilknyttet helsestell, undervisning, kultur og annen sosial virksomhet"'+
    '},'+
    '"antallAnsatte": 1729,'+
    '"harRegistrertAntallAnsatte": true,'+
    '"overordnetEnhet": "889640782",'+
    '"registreringsdatoAntallAnsatteEnhetsregisteret": "2026-07-14",'+
    '"registreringsdatoAntallAnsatteNAVAaregisteret": "2026-07-10",'+
    '"oppstartsdato": "2013-12-01",'+
    '"beliggenhetsadresse": {'+
        '"land": "Norge",'+
        '"landkode": "NO",'+
        '"postnummer": "0661",'+
        '"poststed": "OSLO",'+
        '"adresse": ['+
            '"Fyrstikkalléen 1"'+
        '],'+
        '"kommune": "OSLO",'+
        '"kommunenummer": "0301"'+
    '},'+
    '"_links": {'+
        '"self": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/underenheter/912998827"'+
        '},'+
        '"overordnetEnhet": {'+
            '"href": "https://data.brreg.no/enhetsregisteret/api/enheter/889640782"'+
        '}'+
    '},'+
    '"respons_klasse": "Underenhet"'+
'}';
    
}