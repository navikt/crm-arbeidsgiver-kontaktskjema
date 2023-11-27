/**
 * @description This Contact Form class is a model class for the contact form
 *
 * @author Andre Colle <andre.colle@nav.no>
 * @since 2023-11-14 Created.
 *
 * @see [License](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema/blob/main/LICENSE)
 * @see [Github](https://github.com/navikt/crm-arbeidsgiver-kontaktskjema)
 * @see TAG_ContactFormContoller
 * @see TAG_ContactFormSendEmail
 *
 * @group TAG Contact Form
 */

public with sharing class TAG_ContactForm {
    public String organizationNumber;
    public String municipalityCode;
    public String organizationName;
    public String phoneNumber;
    public String regionNumber;
    public String fullName;
    public String email;
    public String theme;
}