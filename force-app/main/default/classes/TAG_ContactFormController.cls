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
        System.debug(contactFormData);
        
        try{
            TAG_ContactForm newContactForm = new TAG_ContactForm();
            newContactForm.organizationNumber = contactFormData.get('ContactOrg');            
            newContactForm.organizationName = contactFormData.get('AccountName');
            newContactForm.fullName = contactFormData.get('ContactName');
            newContactForm.email = contactFormData.get('ContactEmail');
            newContactForm.phoneNumber = contactFormData.get('ContactPhone');
            newContactForm.theme = contactFormData.get('ThemeSelected');
            newContactForm.comesFromArticle = contactFormData.get('IsFromArticle');

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

}