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
    @track themeChecked = true;
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
    isOrgValid = false;
    isNameValid = false;
    isEpostValid = false;
    isPhoneValid = false;

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
        this.themeChecked = true;
        this.checkedTheme = selectedTheme1[0].checked ? 'Skal ansette' : '';
        this.checkedPreventSickLeave = false;
        this.classNameOption1 = 'radio-buttons radio-buttons-checked';
        this.classNameOption2 = 'radio-buttons';
    }
    handleThemeOption2(event) {
        const selectedTheme2 = event.detail;
        this.themeChecked = true;
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

    validateSendForm() {
        if (this.isPhoneValid === false) {
            let inputPhoneField = this.template.querySelector('[data-id="inputPhone"]');
            inputPhoneField.validatePhoneLength(inputPhoneField.errorText);
            inputPhoneField.focus();
        }

        if (this.isEpostValid === false) {
            let inputEpostField = this.template.querySelector('[data-id="inputEpost"]');
            inputEpostField.sendErrorMessage(inputEpostField.errorText);
            inputEpostField.focus();
        }

        if (this.isNameValid === false) {
            let inputNameField = this.template.querySelector('[data-id="inputName"]');
            inputNameField.sendErrorMessage(inputNameField.errorText);
            inputNameField.focus();
        }

        if (this.isOrgValid === false) {
            let inputOrgField = this.template.querySelector('[data-id="inputOrgNumber"]');
            inputOrgField.validateOrgNumber(this.errorText);
            inputOrgField.focus();
        }

        if (this.checkedTheme == '') {
            this.themeChecked = false;
            let radioTheme = this.template.querySelector('[data-id="radioTheme"]');
            radioTheme.focus();
            //radioTheme.style.border = '1px solid #ba3a26';
        }
    }

    saveContactForm() {
        this.validateSendForm();

        if(this.themeChecked === true && this.isOrgValid === true && this.isNameValid === true) {
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
        const isOrgNumberValid = inputFieldOrgNumber.validateOrgNumber(this.errorText);

        if (!isOrgNumberValid) {
            //inputFieldOrgNumber.sendErrorMessage(this.errorText);
            //this.showError = true;
            this.isOrgNumberValid = false;
        } else {
            this.isOrgNumberValid = true;
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
        const isPhoneInputValid = inputFieldPhone.validatePhoneLength(this.errorText);
        if (!isPhoneInputValid) {
            this.isPhoneValid = false;
        }
        else {
            this.isPhoneValid = true;
        }
    }

    handleEmptyField(event) {
        const inputVariousField = event.target;
        if (inputVariousField.value == '' || inputVariousField.value == null || inputVariousField.value.length < 1) {
            console.log("Send message is called");
            console.log(inputVariousField.errorText);
            inputVariousField.sendErrorMessage(inputVariousField.errorText);
            this.isNameValid = false;
        }
        else {
            this.isNameValid = true;
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
            this.isEpostValid = false;
        }
        else {
            this.isEpostValid = true;
        }
    }
}