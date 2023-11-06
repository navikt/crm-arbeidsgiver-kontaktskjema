import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import kontaktsjemaBilde from '@salesforce/resourceUrl/KontaktskjemaLogo';
import index from '@salesforce/resourceUrl/index';

export default class Kontaktskjema extends LightningElement {
    bildeKontaktskjema = kontaktsjemaBilde;
    //PhoneNumber;

    @track breadcrumbs = [
        {
            label: 'nav.no',
            href: ''
        },
        {
            label: 'Arbeidsgiver',
            href: 'mine-samtaler'
        },
        {
            label: 'Kontakt NAV',
            href: 'detail'
        },
        {
            label: 'Kontaktskjema',
            href: 'detail'
        }
    ];

    renderedCallback() {
        loadStyle(this, index);
    }

    handleResize() {
        const img = this.template.querySelector('[data-id="imageBanner"]');
        if (window.innerWidth < 800) {
            img.style.display = 'none';
        } else {
            img.style.display = 'flex';
        }
    }

    connectedCallback() {
        window.addEventListener('resize', this.handleResize.bind(this));
       // this.PhoneNumber = this.template.querySelector('#PhoneNumber');
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

    handleOrgNumberBlur(event) {
        //const inputValue = event.target.value;
        const inputField = event.target;
        const isOrgNumberValid = inputField.validateOrgNumber(this.errorText);

        if (!isOrgNumberValid) {
            inputField.sendErrorMessage(this.errorText);
        }
        inputField.blur();

    }

    handlePhoneBlur(event) {
        const inputFieldPhone = event.target;
        const isPhoneValid = inputFieldPhone.validatePhoneLength(this.errorText);

        if (!isPhoneValid) {
            inputFieldPhone.sendErrorMessage(this.errorText);
        }
        inputFieldPhone.blur();

    }
/*
    handleEmptyField(event) {
        const inputVariousField = event.target.value;
        console.log(toString(inputVariousField));
        if (inputVariousField === '') {
            inputVariousField.sendErrorMessage(this.errorText);
        }
    }*/
}