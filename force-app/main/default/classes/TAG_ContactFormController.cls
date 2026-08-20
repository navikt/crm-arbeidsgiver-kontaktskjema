/**
 * @description This Contact Form Controller class stores values entered by users in kontaktskjema experience site. It returns a value
 * to the kontaktskjema experience site.
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema)
 * @see TAG_ContactFormSendEmail
 * @see TAG_ContactFormController_Test
 *
 * @group TAG Contact Form
 */
public with sharing class TAG_ContactFormController {


     // Labels displayed in webform
     private static final List<Map<String, Object>> THEME_OPTIONS = new List<Map<String, Object>>{
         new Map<String, Object>{ 'label' => TAG_ContactForm.THEME_FOREBYGGE_SYKEFRAVAER_LABEL, 'value' => TAG_ContactForm.THEME_FOREBYGGE_SYKEFRAVAER_LABEL, 'name' => 'theme', 'checked' => false, 'info' => true },
         new Map<String, Object>{ 'label' => TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL, 'value' => TAG_ContactForm.THEME_REKRUTTERE_OG_INKLUDERE_LABEL, 'name' => 'theme', 'checked' => false, 'info' => false },
         new Map<String, Object>{ 'label' => TAG_ContactForm.THEME_UNGDOMSLOFTET_LABEL, 'value' => TAG_ContactForm.THEME_UNGDOMSLOFTET_LABEL, 'name' => 'theme', 'checked' => false, 'info' => false }
     };

     @AuraEnabled(cacheable=true)
     public static List<Map<String, Object>> getThemeOptions() {
         return THEME_OPTIONS;
     }

     // Validated server-side since the AuraEnabled method can be called directly, bypassing client-side validation
     private static final Pattern ORG_NUMBER_PATTERN = Pattern.compile('^\\d{9}$');
     private static final Pattern EMAIL_PATTERN = Pattern.compile('^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$');
     private static final Pattern PHONE_PATTERN = Pattern.compile('^\\d{8,14}$');

     private static void validateContactFormData(Map<String, String> contactFormData) {
         if (contactFormData == null) {
             throw new IllegalArgumentException('Kontaktskjemaets data mangler.');
         }
         if (!matchesPattern(ORG_NUMBER_PATTERN, contactFormData.get('ContactOrg'))) {
             throw new IllegalArgumentException('Ugyldig organisasjonsnummer.');
         }
         if (String.isBlank(contactFormData.get('ContactName'))) {
             throw new IllegalArgumentException('Navn mangler.');
         }
         if (!matchesPattern(EMAIL_PATTERN, contactFormData.get('ContactEmail'))) {
             throw new IllegalArgumentException('Ugyldig e-postadresse.');
         }
         if (!matchesPattern(PHONE_PATTERN, contactFormData.get('ContactPhone'))) {
             throw new IllegalArgumentException('Ugyldig telefonnummer.');
         }
     }

     private static Boolean matchesPattern(Pattern p, String value) {
         return value != null && p.matcher(value).matches();
     }


    /**
     * @description The createContactForm method creates a Contact Form record and sends the record to the insertInquiry method
     * which creates a new TAG Inquiry record
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param contactFormData The request/input parameter which is sent from the kontaktskjema lwc. Includes all the values submitted by
     * the user in the contact form.
     */    
     @AuraEnabled
    public static void createContactForm(Map<String, String> contactFormData) {        
        try{
            validateContactFormData(contactFormData);

            TAG_ContactForm newContactForm = new TAG_ContactForm();
            newContactForm.organizationNumber = contactFormData.get('ContactOrg');            
            newContactForm.organizationName = contactFormData.get('AccountName');
            newContactForm.fullName = contactFormData.get('ContactName');
            newContactForm.email = contactFormData.get('ContactEmail');
            newContactForm.phoneNumber = contactFormData.get('ContactPhone');
            newContactForm.theme = contactFormData.get('ThemeSelected');

            createInquiryFromContactForm(newContactForm);
            
        } catch (Exception e) {
           String message = 'Feil i Kontaktskjema: '+e.getMessage();
            message+='\nForm data: ' + contactFormData;
            logAndPublishError(message , e);
            throw new AuraHandledException('An unexpected error occurred.');
        }        
    }


    private static void createInquiryFromContactForm(TAG_ContactForm contactForm){
        EmployerInquiry__c newInquiry = new EmployerInquiry__c();
                newInquiry.TAG_WebFormAccountOrgNr__c = contactForm.organizationNumber;
                newInquiry.TAG_WebFormAccountName__c = contactForm.organizationName;
                newInquiry.TAG_WebFormContactEmail__c = contactForm.email;
                newInquiry.TAG_WebFormContactName__c = contactForm.fullName;
                newInquiry.TAG_WebFormContactPhone__c = contactForm.phoneNumber;

                newInquiry.TAG_WebFormTheme__c = contactForm.theme;               
                newInquiry.TAG_Status__c = TAG_ContactForm.STAGE;
                newInquiry.TAG_Source__c = TAG_ContactForm.SOURCE;
                newInquiry.Name = TAG_ContactForm.SOURCE + ': ' + newInquiry.TAG_WebFormTheme__c;
        insert newInquiry;
    }


    private static void logAndPublishError(String message, Exception e) {
        LoggerUtility logger = new LoggerUtility();
                logger.logMessage(
                    LoggerUtility.LogLevel.Error,
                    '',
                    '',
                    message?.abbreviate(32768), // textarea (32768)
                    e?.getStackTraceString()?.abbreviate(32768), // textarea (32768)
                    null,
                    CRM_ApplicationDomain.Domain.POAB
                );
                logger.publish();
            }

            private static AuraHandledException buildAuraException(String code) {
    AuraHandledException ex = new AuraHandledException(code);
    ex.setMessage(code); // uten dette blir meldingen "Script-thrown exception" i klienten
    return ex;
}

}