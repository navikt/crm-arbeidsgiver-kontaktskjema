import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import index from '@salesforce/resourceUrl/index';
import arrowImage from '@salesforce/resourceUrl/ContactFormArrow';
import envelopeImage from '@salesforce/resourceUrl/ContactFormEnvelope';
import letterImage from '@salesforce/resourceUrl/ContactFormLetter';
import logoImage from '@salesforce/resourceUrl/ContactFormLogo';
import employeeImage from '@salesforce/resourceUrl/ContactFormEmployee';
import signImage from '@salesforce/resourceUrl/ContactFormSign';
import navStyling from '@salesforce/resourceUrl/navStyling';

export default class Tag_contactFormConfirmation extends LightningElement {
    arrowImage = arrowImage;
    envelopeImage = envelopeImage;
    letterImage = letterImage;
    logoImage = logoImage;
    employeeImage = employeeImage;
    signImage = signImage;

    handleResize() {
        const img = this.template.querySelector('[data-id="imageBanner"]');
        if (window.innerWidth < 800) {
            img.style.display = 'none';
        } else {
            img.style.display = 'flex';
        }
    }

    renderedCallback() {
        loadStyle(this, index);
        loadStyle(this,navStyling);
    }

    connectedCallback() {
        window.addEventListener('resize', this.handleResize.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

}