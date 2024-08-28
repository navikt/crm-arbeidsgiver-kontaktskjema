import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import logoImage from '@salesforce/resourceUrl/ContactFormLogo';
import infoImage from '@salesforce/resourceUrl/ContactFormInfo';
import index from '@salesforce/resourceUrl/index';
import createContactForm from '@salesforce/apex/TAG_ContactFormController.createContactForm';
import getAccountName from '@salesforce/apex/TAG_ContactFormController.getAccountName';
import navStyling from '@salesforce/resourceUrl/navStyling';

export default class Kontaktskjema extends NavigationMixin(LightningElement) {
    logoImage = logoImage;
    infoImage = infoImage;

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
    @track comesFromArticle = false;
    @track urlRoute = '';
    isOrgValid = false;
    isNameValid = false;
    isEpostValid = false;
    isPhoneValid = false;

    @wire(getAccountName, {orgNumber: '$contactOrg' })
    wiredAccountName({ data, error }) {
        if (data) {
            this.accountName = data;
            this.showError = false;
            this.isOrgValid = true;
            let accountNameRead = this.template.querySelector('[data-id="accountNameRead"]');
            setTimeout(function(){
                accountNameRead.style.display = "block";
                accountNameRead.focus();
           },500); //delay is in milliseconds 
        } else if (error) {
            this.accountName = '';
            this.isOrgValid = false;
            let inputOrgField = this.template.querySelector('[data-id="inputOrgNumber"]');
            inputOrgField.sendErrorMessage(inputOrgField.errorText);
            inputOrgField.focus();
            let accountNameRead = this.template.querySelector('[data-id="accountNameRead"]');
            accountNameRead.style.display = "none";
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

    handleThemeOption(event) {
        const selectedTheme = event.detail;
        this.themeChecked = true;
    
        if(selectedTheme[0].checked === true){
        if (selectedTheme[0].value == 'Rekruttere og inkludere') {
            console.log("rekruttere og inkludere");

           this.checkedTheme = 'Skal ansette';
            this.checkedPreventSickLeave = false;
            this.classNameOption1 = 'radio-buttons radio-buttons-checked';
            this.urlRoute = 'kontaktskjemabekreftelse2';
        } else if(selectedTheme[0].value == 'Forebygge sykefravær'){
            console.log("forebygge sykefravær");
           this.checkedTheme = 'Forebygge sykefravær';
            this.checkedPreventSickLeave = true;
            this.classNameOption2 = 'radio-buttons radio-buttons-checked';
            this.urlRoute = 'kontaktskjemabekreftelse';
            
        }
    }
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
            inputPhoneField.sendErrorMessage(inputPhoneField.errorText);
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

        if (this.checkedTheme === '') {
            this.themeChecked = false;
            let radioTheme = this.template.querySelector('[data-id="radioTheme"]');
            radioTheme.focus();
        }
    }

    saveContactForm() {
        this.validateSendForm();
        if(this.themeChecked === true && this.isOrgValid === true && this.isNameValid === true && this.isPhoneValid === true && this.isEpostValid === true) {
            const contactFormData = {
                ContactOrg: this.contactOrg,
                ContactName: this.contactName,
                ContactEmail: this.contactEmail,
                ContactPhone: this.contactPhone,
                ThemeSelected: this.checkedTheme,
                IsFromArticle: this.comesFromArticle
            };
           
            console.log(  window.location.href + " må ha med #s er det her?");

            createContactForm({ contactFormData })
            .then(result => {
                const currentUrl = window.location.href;
                //let newUrl = currentUrl.replace("#s","") + 'kontaktskjemabekreftelse2'; 
                //let newUrl = currentUrl.replace("#s","") + 'kontaktskjemabekreftelse'; Denne funker ikke
                let newUrl = currentUrl.replace("#s","") + urlRoute; 
               
    
                // Clear input field values
                this.contactOrg = '';
                this.contactName = '';
                this.contactEmail = '';
                this.contactPhone = '';
                this.checkedTheme = '';
                this.accountName = '';
                this.isOrgValid = false;
                this.isNameValid = false;
                this.isEpostValid = false;
                this.isPhoneValid = false;

                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: newUrl
                    }
                });
            })
            .catch(error => {
                const toastEvent = new ShowToastEvent({
                    title: 'Feilmelding',
                    message: 'Noe gikk galt ved opprettelse av kontaktskjema. Prøv igjen.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
                console.error('Navigation error:', error);
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
        loadStyle(this,navStyling);
    }

    connectedCallback() {
        window.addEventListener('resize', this.handleResize.bind(this));
        const docURL = document.URL;
        if (docURL.includes('kontaktskjema.arbeidsgiver.nav.no/s/#s')) {
            // Perform actions based on the referrer URL
            // For example, create a record in Salesforce
            this.comesFromArticle = true;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

    handleOrgNumberChange(event) {
        this.contactOrg = event.detail;
        const inputFieldOrgNumber = event.target;
        const isOrgNumberValid = inputFieldOrgNumber.validateOrgNumber(this.errorText);
    }

    handleEmptyField(event) {
        const inputVariousField = event.target;
        if (inputVariousField.value == '' || inputVariousField.value == null || inputVariousField.value.length < 1) {
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
            inputEmailField.sendErrorMessage(inputEmailField.errorText);
            this.isEpostValid = false;
        }
        else {
            this.isEpostValid = true;
        }
    }

    handlePhoneField(event) {
        const inputPhoneField = event.target;
        let regExp = RegExp(/^\d{8,14}$/);
        let isValidPhoneNr = regExp.test(inputPhoneField.value) ? true : false;
        if (!isValidPhoneNr || inputPhoneField.value == '' || inputPhoneField.value == null || inputPhoneField.value.length < 1) {
            inputPhoneField.sendErrorMessage(inputPhoneField.errorText);
            this.isPhoneValid = false;
        }
        else {
            this.isPhoneValid = true;
        }
    }
}