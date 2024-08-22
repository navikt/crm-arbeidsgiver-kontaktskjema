import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import index from '@salesforce/resourceUrl/index';
import arrowImage from '@salesforce/resourceUrl/ContactFormArrow';
import envelopeImage from '@salesforce/resourceUrl/ContactFormEnvelope';
import letterImage from '@salesforce/resourceUrl/ContactFormLetter';
import logoImage from '@salesforce/resourceUrl/ContactFormLogo';
import employeeImage from '@salesforce/resourceUrl/ContactFormEmployee';
import signImage from '@salesforce/resourceUrl/ContactFormSign';
import navStyling from '@salesforce/resourceUrl/navStyling';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
  } from "lightning/messageService";
  import TAG_CONTACT_FORM_CHANNEL from "@salesforce/messageChannel/tag_contactFormChannel__c";


export default class Tag_contactFormConfirmation extends LightningElement {
    subscription = null;
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


// tilhører uxsignals alt under her


@wire(MessageContext)
messageContext;
  isTrue;


  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        TAG_CONTACT_FORM_CHANNEL,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE },
      );
      console.log("Subscription established:", this.subscription);
    }
  } 

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  // Handler for message received by component
  handleMessage(message) {
    console.log("kjører handlemessage?")
    this.isTrue = message.isChecked;
    console.log(this.isTrue + " istrue param"); 
  }

  // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }


  // Helper
  dispatchToast(error) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error loading contact",
        message: reduceErrors(error).join(", "),
        variant: "error",
      }),
    );
  }

}