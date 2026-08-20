import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import logoImage from '@salesforce/resourceUrl/ContactFormLogo';
import infoImage from '@salesforce/resourceUrl/ContactFormInfo';
import index from '@salesforce/resourceUrl/index';
import createContactForm from '@salesforce/apex/TAG_ContactFormController.createContactForm';
import getThemeOptions from '@salesforce/apex/TAG_ContactFormController.getThemeOptions';
import { getEntityData, EregUnavailableError } from './tag_contactFormEregService';

import navStyling from '@salesforce/resourceUrl/navStyling';
const ERROR_MESSAGES = {
    SERVICE_UNAVAILABLE:
        'Kan ikke kontrollere organisasjonsnummeret. Tjenesten er midlertidig utilgjengelig. Prøv igjen om litt.',
    TECHNICAL_ERROR:
        'Kan ikke kontrollere organisasjonsnummeret. Det oppstod en teknisk feil. Kontakt oss hvis problemet fortsetter.',
    INVALID_INPUT: 'Ugyldig organisasjonsnummer. Det skal være 9 sifre.'
};

export default class Kontaktskjema extends NavigationMixin(LightningElement) {
    // Static resources
    logoImage = logoImage;
    infoImage = infoImage;

    // Theme/topic selection
    @track checkedTheme = '';
    @track themeChecked = true;
    @track checkedPreventSickLeave = false;
    @track checkedYesOrNo = false;
    themeOptions = [];

    // Form field values
    @track contactOrg = '';
    @track contactName = '';
    @track contactEmail = '';
    @track contactPhone = '';

    // Field validation state
    isOrgValid = false;
    isNameValid = false;
    isEpostValid = false;
    isPhoneValid = false;

    // Page/navigation state
    @track showError = false;
    @track urlRoute = 'kontaktskjemabekreftelse';

    // Organization number lookup (Ereg)
    _eregEntityData = null; // result from org number lookup
    @track offerSubUnitSelection = false;
    @track selectedSubUnit = null;
    _orgLookupTimer;
    _lastLookedUpOrg;
    ORG_LOOKUP_DEBOUNCE_MS = 100;

    // Submission payload, independent of the individual form field properties above
    _contactFormData = null;

    @wire(getThemeOptions)
    wiredThemeOptions({ data, error }) {
        if (data) {
            this.themeOptions = data.map((option) => ({ ...option, checked: false }));
        } else if (error) {
            console.error('Error loading theme options:', error);
        }
    }

    contactedEmployeeRepOptions = [
        { label: 'Ja', value: 'Ja', name: 'contactedEmpRep', checked: false },
        { label: 'Nei', value: 'Nei', name: 'contactedEmpRep', checked: false }
    ];

    handleThemeOption(event) {
        const selectedTheme = event.detail;
        this.themeChecked = true;

        const selectedOption = selectedTheme.find((option) => option.checked === true);

        if (selectedOption) {
            this.checkedTheme = selectedOption.value;
            if (selectedOption.info === true) {
                this.checkedPreventSickLeave = true;
            } else {
                this.checkedPreventSickLeave = false;
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

    handleOrgNumberChange(event) {
        const inputFieldOrgNumber = event.target;
        const orgValue = inputFieldOrgNumber.value ? inputFieldOrgNumber.value.replace(/\s/g, '') : '';
        const isValidOrgNumber = /^\d{9}$/.test(orgValue);
        this.contactOrg = orgValue;

        clearTimeout(this._orgLookupTimer);

        if (!isValidOrgNumber || orgValue === '' || orgValue == null || orgValue.length < 1) {
            inputFieldOrgNumber.sendErrorMessage(inputFieldOrgNumber.errorText);
            this.isOrgValid = false;
            return;
        }

        if (orgValue === this._lastLookedUpOrg && this.isOrgValid) {
            return;
        }

        this._orgLookupTimer = setTimeout(() => {
            this._lookupOrganization(orgValue, inputFieldOrgNumber);
        }, this.ORG_LOOKUP_DEBOUNCE_MS);
    }

    _lookupOrganization(orgValue, inputFieldOrgNumber) {
        this.clearLookupOrgData();
        this._lastLookedUpOrg = orgValue;
        getEntityData(orgValue)
            .then((data) => {
                console.log('Organization lookup result:', data);
                if (data && data.name) {
                    this._eregEntityData = data;
                    this.isOrgValid = true;
                    this.offerSubUnitSelection = this._eregEntityData && this._eregEntityData.totalSubUnitsCount > 1;

                    let accountNameRead = this.template.querySelector('[data-id="accountNameRead"]');
                    setTimeout(function () {
                        accountNameRead.style.display = 'block';
                        accountNameRead.focus();
                    }, 500);
                } else {
                    inputFieldOrgNumber.sendErrorMessage('Fant ingen bedrifter med dette organisasjonsnummeret.');
                    this.clearLookupOrgData();
                }
            })
            .catch((error) => {
                console.error('Error validating organization number:', error);
                const msg =
                    error instanceof EregUnavailableError
                        ? ERROR_MESSAGES.SERVICE_UNAVAILABLE
                        : ERROR_MESSAGES.TECHNICAL_ERROR;
                inputFieldOrgNumber.sendErrorMessage(msg);
                this.clearLookupOrgData();
                this._lastLookedUpOrg = null;
            });
    }

    clearLookupOrgData() {
        this._eregEntityData = null;
        this.selectedSubUnit = null;
        this.offerSubUnitSelection = false;
        this.isOrgValid = false;
    }

    // Single source of truth for the resolved company, derived from the Ereg lookup and any subunit choice
    get resolvedOrgNumber() {
        if (this.selectedSubUnit && this.selectedSubUnit.name !== 'DEFAULT') {
            return this.selectedSubUnit.name;
        }
        return this._eregEntityData ? this._eregEntityData.organizationNumber : '';
    }

    get resolvedAccountName() {
        if (this.selectedSubUnit && this.selectedSubUnit.name !== 'DEFAULT') {
            return this.selectedSubUnit.label;
        }
        return this._eregEntityData ? this._eregEntityData.name : '';
    }

    get accountName() {
        if (this._eregEntityData && this._eregEntityData.name) {
            return this._eregEntityData.name;
        }
        return null;
    }

    get subUnitChoices() {
        const defaultChoice = [
            {
                label: 'Velg underenhet',
                name: 'DEFAULT'
            }
        ];
        const choices =
            this._eregEntityData && this._eregEntityData.subUnits
                ? this._eregEntityData.subUnits.map((subUnit) => ({
                      label: subUnit.name,
                      name: subUnit.organizationNumber
                  }))
                : [];
        return defaultChoice.concat(choices);
    }

    handleSubUnitSelection(event) {
        this.selectedSubUnit = this.subUnitChoices.find((choice) => choice.name === event.detail.name);
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
            inputOrgField.sendErrorMessage(inputOrgField.errorText);
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
        if (
            this.themeChecked === true &&
            this.isOrgValid === true &&
            this.isNameValid === true &&
            this.isPhoneValid === true &&
            this.isEpostValid === true
            // this.isAccountNameValid === true
        ) {
            this._contactFormData = {
                ContactOrg: this.resolvedOrgNumber,
                AccountName: this.resolvedAccountName,
                ContactName: this.contactName,
                ContactEmail: this.contactEmail,
                ContactPhone: this.contactPhone,
                ThemeSelected: this.checkedTheme
            };

            createContactForm({ contactFormData: this._contactFormData })
                .then((result) => {
                    const currentUrl = window.location.href;
                    let newUrl = currentUrl.replace('#k', '') + this.urlRoute;
                    // Clear input field values
                    this.contactOrg = '';
                    this.contactName = '';
                    this.contactEmail = '';
                    this.contactPhone = '';
                    this.checkedTheme = '';
                    this._eregEntityData = null;
                    this.selectedSubUnit = null;
                    this.offerSubUnitSelection = false;
                    this._contactFormData = null;
                    this.isOrgValid = false;
                    this.isNameValid = false;
                    this.isEpostValid = false;
                    this.isPhoneValid = false;
                    // this.isAccountNameValid = false;

                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: newUrl
                        }
                    });
                })
                .catch((error) => {
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
        loadStyle(this, navStyling);
    }

    connectedCallback() {
        window.addEventListener('resize', this.handleResize.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

    handleEmptyField(event) {
        const inputVariousField = event.target;
        if (inputVariousField.value == '' || inputVariousField.value == null || inputVariousField.value.length < 1) {
            inputVariousField.sendErrorMessage(inputVariousField.errorText);
            this.isNameValid = false;
        } else {
            this.isNameValid = true;
        }
    }

    handleEmailField(event) {
        const inputEmailField = event.target;
        let regExp = RegExp(
            /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        );
        let isValidEmail = regExp.test(inputEmailField.value) ? true : false;
        if (
            !isValidEmail ||
            inputEmailField.value == '' ||
            inputEmailField.value == null ||
            inputEmailField.value.length < 1
        ) {
            inputEmailField.sendErrorMessage(inputEmailField.errorText);
            this.isEpostValid = false;
        } else {
            this.isEpostValid = true;
        }
    }

    handlePhoneField(event) {
        const inputPhoneField = event.target;
        let regExp = RegExp(/^\d{8,14}$/);
        let isValidPhoneNr = regExp.test(inputPhoneField.value) ? true : false;
        if (
            !isValidPhoneNr ||
            inputPhoneField.value == '' ||
            inputPhoneField.value == null ||
            inputPhoneField.value.length < 1
        ) {
            inputPhoneField.sendErrorMessage(inputPhoneField.errorText);
            this.isPhoneValid = false;
        } else {
            this.isPhoneValid = true;
        }
    }

    validateOrgNumberField() {
        let regExp = RegExp('\\d{9}');
        let orgNumber = this.template.querySelector('input').value.replaceAll(' ', '');
    }

    /*
    const entity = {
    name: 'NAV',
    isSubunit: false,
    organizationNumber: '889640782',
    totalSubUnitsCount: 0,
    subUnits: []
};
searchOrganizationJs(searchTerm) {}
*/
}
