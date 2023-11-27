/**
 * @description This Contact Form Send Email class sends email receipts to users who submitted the kontaktskjema experience site.
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema)
 * @see TAG_ContactFormController
 * @see TAG_ContactFormSendEmail_Test
 *
 * @group TAG Contact Form
 */
public with sharing class TAG_ContactFormSendEmail {

    /**
     * @description The sendEmailReceipts method adds the email to the email queue
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param opportunity The request/input parameter which is sent from the insertCustomOpportunity method in TAG_ContactFormController
     * class.
     */
    public static void sendEmailReceipts(CustomOpportunity__c opportunity) {
        List<EmailQueue__c> emails = new List<EmailQueue__c>();
        try {
                if (opportunity.Contact__c != null) {
                    emails.add(generateDraftEmailReceipt(opportunity));
                }
            insert emails;
        } catch (Exception e) {
            System.debug('An exception has occured: ' + e.getMessage());
            /*LoggerUtility logger = new LoggerUtility();
            logger.logError('Failed to create custom opportunity' + e.getMessage() + '/n' + e.getStackTraceString());*/
        }
    }

    /**
     * @description The generateDraftEmailReceipt method generates the email
     *
     * @author Andre Colle <andre.colle@nav.no>
     * @since 2023-11-14 Created.
     *
     * @param opportunity The request/input parameter which is sent from the sendEmailReceipts method in this class.
     */
    public static EmailQueue__c generateDraftEmailReceipt(CustomOpportunity__c opportunity) {
        String templateName = opportunity.InquiryCategory__c == 'Forebygge sykefravær'
            ? 'kontaktskjemaSykefravaerReceipt'
            : 'kontaktskjemaRekrutteringReceipt';
        EmailQueue__c email = new EmailQueue__c();
        email.TemplateName__c = templateName;
        email.TargetObjectId__c = opportunity.Contact__c;
        email.WhatId__c = opportunity.Id;
        email.Priority__c = '5';
        email.Status__c = 'Queued';
        email.SaveAsActivity__c = true;

        return email;
    }
}