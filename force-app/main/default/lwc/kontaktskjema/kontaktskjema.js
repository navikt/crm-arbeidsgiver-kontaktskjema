import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import kontaktsjemaBilde from '@salesforce/resourceUrl/KontaktskjemaLogo';
import index from '@salesforce/resourceUrl/index';
import createContactForm from '@salesforce/apex/TAG_ContactFormController.createContactForm';
import getAccountName from '@salesforce/apex/TAG_ContactFormController.getAccountName';

export default class Kontaktskjema extends LightningElement {
    bildeKontaktskjema = kontaktsjemaBilde;

    @track checkedTheme = '';
    @track classNameOption1 = 'radio-buttons';
    @track classNameOption2 = 'radio-buttons';
    @track checkedPreventSickLeave = false;
    @track checkedYesOrNo = false;
    @track contactOrg = '';
    @track contactName = '';
    @track contactEmail = '';
    @track contactPhone = '';
    @track accountName = '';
    @track showError = false;

    @track fieldValues = { 
        FullName: '',
        OrganizationNumber: '',
        Email: '',
        Phone: ''
    }

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

    @wire(getAccountName, {orgNumber: '$contactOrg' })
    wiredAccountName({ data, error }) {
        if (data) {
            this.accountName = data;
            this.showError = false;
        } else if (error) {
            this.accountName = '';
            console.error('Error retrieving account name:', error);
            this.showError = true;
        }
    }

    themeOption1 = [
        { label: 'Rekruttere og inkludere', value: 'Rekruttere og inkludere', name: 'theme', checked: false},
    ];
    themeOption2 = [
        { label: 'Forebygge sykefravær', value: 'Forebygge sykefravær', name: 'theme', checked: false}
    ];

    contactedEmployeeRepOptions = [
        { label: 'Ja', value: 'Ja', name: 'contactedEmpRep', checked: false },
        { label: 'Nei', value: 'Nei', name: 'contactedEmpRep', checked: false }
    ];

    handleThemeOption1(event) {
        const selectedTheme1 = event.detail;

        this.checkedTheme = selectedTheme1[0].checked ? 'Skal ansette' : '';
        this.checkedPreventSickLeave = false;
        this.classNameOption1 = 'radio-buttons radio-buttons-checked';
        this.classNameOption2 = 'radio-buttons';
    }
    handleThemeOption2(event) {
        const selectedTheme2 = event.detail;

        this.checkedTheme = selectedTheme2[0].checked ? 'Forebygge sykefravær' : '';
        this.checkedPreventSickLeave = true;
        this.classNameOption1 = 'radio-buttons';
        this.classNameOption2 = 'radio-buttons radio-buttons-checked';
    }
    
    handleContactedEmployeeRep(event) {
        const selectedContactedEmployeeRep = event.detail;
        if (selectedContactedEmployeeRep && selectedContactedEmployeeRep.length > 0) {
            this.checkedYesOrNo = selectedContactedEmployeeRep[0].checked ? true : false;
        }
        console.log('Checked ', this.checkedYesOrNo);
    }

    handleNameChange(event) {
        this.contactName = event.detail;
        this.handleEmptyField(event);
    }

    handleEmailChange(event) {
        this.contactEmail = event.detail;
        this.handleEmailField(event);
    }

    handlePhoneChange(event) {
        this.contactPhone = event.detail;
        this.handlePhoneField(event);
    }

    saveContactForm() {
        const contactFormData = {
            ContactOrg: this.contactOrg,
            ContactName: this.contactName,
            ContactEmail: this.contactEmail,
            ContactPhone: this.contactPhone,
            ThemeSelected: this.checkedTheme
        };

        createContactForm({ contactFormData })
        .then(result => {
            const toastEvent = new ShowToastEvent({
                title: 'Suksess',
                message: 'Kontaktskjema har blitt sendt til NAV',
                variant: 'success'
            });
            this.dispatchEvent(toastEvent);

            // Clear input field values
            this.contactOrg = '';
            this.contactName = '';
            this.contactEmail = '';
            this.contactPhone = '';
            this.checkedTheme = '';
            this.accountName = '';

            // Force a re-render of the component
            this.template.querySelectorAll('c-input').value = '';
            console.log('contactOrg: ', this.contactOrg);
        })
        .catch(error => {
            const toastEvent = new ShowToastEvent({
                title: 'Feilmelding',
                message: 'Noe gikk galt ved opprettelse av kontaktskjema. Prøv igjen.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        });
    }

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
    }

    connectedCallback() {
        window.addEventListener('resize', this.handleResize.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

    handleOrgNumberChange(event) {
        this.contactOrg = event.detail;
        const inputFieldOrgNumber = event.target;
        const isNotOrgNumberValid = inputFieldOrgNumber.validateOrgNumber(this.errorText);

        if (!isNotOrgNumberValid) {
            inputFieldOrgNumber.sendErrorMessage(this.errorText);
            this.showError = true;
        } else {
            getAccountName ({ inputFieldOrgNumber })
            .then(result => {
                this.accountName = result;
                this.showError = false;
            })
            .catch(error => {
                console.error('Error retrieving Account Name:', error);
                this.showError = true;
            });
        }
    }

    handlePhoneField(event) {
        const inputFieldPhone = event.target;
        inputFieldPhone.validatePhoneLength(this.errorText);
    }

    handleEmptyField(event) {
        const inputVariousField = event.target;
        console.log("Input is : "+inputVariousField.value);
        if (inputVariousField.value == '' || inputVariousField.value == null || inputVariousField.value.length < 1) {
            console.log("Send message is called");
            console.log(inputVariousField.errorText);
            inputVariousField.sendErrorMessage(inputVariousField.errorText);
        }
    }

    handleEmailField(event) {
        const inputEmailField = event.target;
        let regExp = RegExp(/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
        let isValidEmail = regExp.test(inputEmailField.value) ? true : false;
        if (!isValidEmail || inputEmailField.value == '' || inputEmailField.value == null || inputEmailField.value.length < 1) {
            console.log("Send message is called");
            console.log(inputEmailField.errorText);
            inputEmailField.sendErrorMessage(inputEmailField.errorText);
        }
    }
}