/**
 * @description This Contact Form class is a model class for the contact form
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontakt-oss/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontakt-oss)
 * @see TAG_ContactFormContoller
 * @see TAG_ContactFormSendEmail
 *
 * @group TAG Contact Form
 */

public with sharing class TAG_ContactForm {
    public String organizationNumber { get; set; }
    public String municipalityCode { get; set; }
    public String organizationName { get; set; }
    public String phoneNumber { get; set; }
    public String regionCode { get; set; }
    public String fullName { get; set; }
    public String email { get; set; }
    public String theme { get; set; }
}