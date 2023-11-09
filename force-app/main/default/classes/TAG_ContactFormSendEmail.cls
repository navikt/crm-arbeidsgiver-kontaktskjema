public with sharing class TAG_ContactFormSendEmail {
    public static void sendEmailReceipts(CustomOpportunity__c opportunity) {
        List<EmailQueue__c> emails = new List<EmailQueue__c>();
        try {
                if (opportunity.Contact__c != null) {
                    emails.add(generateDraftEmailReceipt(opportunity));
                }
            insert emails;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            System.debug('An exception has occured: ' + e.getMessage());
            /*LoggerUtility logger = new LoggerUtility();
            logger.logError('Failed to create custom opportunity' + e.getMessage() + '/n' + e.getStackTraceString());*/
        }
    }

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